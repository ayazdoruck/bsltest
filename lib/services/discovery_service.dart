import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/discovery_status.dart';
import '../models/peer.dart';
import '../utils/constants.dart';

// Aynı yerel ağdaki diğer cihazları UDP broadcast ile bulur.
// Her cihaz periyodik olarak kendini duyurur ve gelen duyuruları dinleyip
// bir peer haritası tutar; belirli süreden fazla görüntülenmeyen peer'lar
// listeden düşürülür.
class DiscoveryService {
  final String myId;
  final String myName;
  final String myPlatform;

  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  Timer? _sweepTimer;
  Timer? _scanTimer;
  bool _scanning = false;

  final Map<String, Peer> _peers = {};
  final _peersController = StreamController<List<Peer>>.broadcast();
  final _statusController = StreamController<DiscoveryStatus>.broadcast();

  Stream<List<Peer>> get peers => _peersController.stream;
  // Konsola erisimi olmayan (ör. IPA ile kurulmus) cihazlarda ekranda
  // gosterilebilecek ham tanilama verisi (UI tarafinda lokalize edilir).
  Stream<DiscoveryStatus> get statusUpdates => _statusController.stream;

  List<String> _myAddresses = [];
  int _broadcastCount = 0;
  int _receivedCount = 0;
  int _scanCount = 0;
  String? _lastError;

  DiscoveryService({
    required this.myId,
    required this.myName,
    required this.myPlatform,
  });

  Future<void> start() async {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      kDiscoveryUdpPort,
      reuseAddress: true,
    );
    _socket!.broadcastEnabled = true;
    _socket!.listen(_onEvent);
    debugPrint(
        '[Discovery] UDP soket $kDiscoveryUdpPort portunda dinliyor (id: $myId, ad: $myName).');

    await _refreshMyAddresses();
    _emitStatus();

    _broadcastAnnounce();
    _broadcastTimer = Timer.periodic(
      kBroadcastInterval,
      (_) => _broadcastAnnounce(),
    );
    _sweepTimer = Timer.periodic(kStalenessSweepInterval, (_) => _sweepStale());

    _scanSubnets();
    _scanTimer = Timer.periodic(kSubnetScanInterval, (_) => _scanSubnets());
  }

  Future<void> _refreshMyAddresses() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      _myAddresses = [
        for (final iface in interfaces)
          for (final addr in iface.addresses) addr.address,
      ];
    } catch (_) {
      _myAddresses = [];
    }
  }

  void _emitStatus() {
    _statusController.add(DiscoveryStatus(
      addresses: List.unmodifiable(_myAddresses),
      broadcastCount: _broadcastCount,
      receivedCount: _receivedCount,
      scanCount: _scanCount,
      error: _lastError,
    ));
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket?.receive();
    if (datagram == null) return;

    try {
      final Map<String, dynamic> json = jsonDecode(utf8.decode(datagram.data));
      if (json['type'] != 'announce') return;

      final String id = json['id'] as String;
      if (id == myId) return;

      debugPrint(
          '[Discovery] Duyuru alindi: ${json['name']} (${datagram.address.address}).');

      _receivedCount++;
      _emitStatus();

      _peers[id] = Peer(
        id: id,
        displayName: json['name'] as String,
        host: datagram.address.address,
        port: json['port'] as int,
        platform: json['platform'] as String,
        lastSeen: DateTime.now(),
      );
      _emit();
    } catch (_) {
      // Bozuk/ilgisiz paket, yok say.
    }
  }

  Future<void> _broadcastAnnounce() async {
    await _refreshMyAddresses();

    final payload = utf8.encode(jsonEncode({
      'id': myId,
      'name': myName,
      'platform': myPlatform,
      'port': kTransferHttpPort,
      'type': 'announce',
    }));

    // Birden fazla aktif ag karti varsa (ör. Ethernet + Wi-Fi ayni anda),
    // tek bir anyIPv4 soketten gonderim yapmak isletim sistemine hangi
    // kartin secilecegini birakiyor (genelde daha dusuk metrikli kablolu
    // baglanti kazaniyor). Bunun onune gecmek icin her yerel adrese ayri,
    // o adrese baglanmis bir gonderim soketi acip paketi o karttan
    // gondermeye zorluyoruz.
    var anySucceeded = false;
    String? error;

    for (final address in _myAddresses) {
      final parts = address.split('.');
      if (parts.length != 4) continue;
      final directedBroadcast = '${parts[0]}.${parts[1]}.${parts[2]}.255';

      RawDatagramSocket? sender;
      try {
        sender = await RawDatagramSocket.bind(InternetAddress(address), 0);
        sender.broadcastEnabled = true;
        sender.send(
            payload, InternetAddress(directedBroadcast), kDiscoveryUdpPort);
        sender.send(
            payload, InternetAddress('255.255.255.255'), kDiscoveryUdpPort);
        anySucceeded = true;
      } catch (e) {
        error = '$address: $e';
        debugPrint('[Discovery] $address uzerinden gonderilemedi: $e');
      } finally {
        sender?.close();
      }
    }

    if (anySucceeded) _broadcastCount++;
    _lastError = error;
    _emitStatus();
  }

  // UDP broadcast'in iletilmedigi aglar icin yedek kesif: kendi /24 alt
  // agindaki her IP'ye kisa zaman asimiyla unicast HTTP istegi atip
  // "/api/whoami" cevap veren cihazlari peer olarak ekler. Unicast trafik
  // broadcast'ten farkli olarak bircok ISP/router konfigurasyonunda
  // engellenmedigi icin bu, broadcast calismayan aglarda da kesfi saglar.
  Future<void> _scanSubnets() async {
    if (_scanning) return;
    _scanning = true;
    try {
      await _refreshMyAddresses();

      final prefixes = <String>{};
      for (final address in _myAddresses) {
        final parts = address.split('.');
        if (parts.length == 4) {
          prefixes.add('${parts[0]}.${parts[1]}.${parts[2]}');
        }
      }
      if (prefixes.isEmpty) return;

      final client = HttpClient()..connectionTimeout = kSubnetScanTimeout;
      try {
        for (final prefix in prefixes) {
          final candidates = [
            for (var i = 1; i <= 254; i++) '$prefix.$i',
          ]..removeWhere(_myAddresses.contains);

          for (var i = 0; i < candidates.length; i += kSubnetScanConcurrency) {
            final end = (i + kSubnetScanConcurrency < candidates.length)
                ? i + kSubnetScanConcurrency
                : candidates.length;
            await Future.wait(
              candidates.sublist(i, end).map((ip) => _probe(client, ip)),
            );
          }
        }
      } finally {
        client.close(force: true);
      }

      _scanCount++;
      _emitStatus();
    } finally {
      _scanning = false;
    }
  }

  Future<void> _probe(HttpClient client, String ip) async {
    try {
      final request = await client
          .getUrl(Uri.http('$ip:$kTransferHttpPort', '/api/whoami'))
          .timeout(kSubnetScanTimeout);
      final response = await request.close().timeout(kSubnetScanTimeout);
      final body =
          await utf8.decodeStream(response).timeout(kSubnetScanTimeout);
      final json = jsonDecode(body) as Map<String, dynamic>;

      final String id = json['id'] as String;
      if (id == myId) return;

      debugPrint('[Discovery] Tarama ile bulundu: ${json['name']} ($ip).');

      _peers[id] = Peer(
        id: id,
        displayName: json['name'] as String,
        host: ip,
        port: kTransferHttpPort,
        platform: json['platform'] as String,
        lastSeen: DateTime.now(),
      );
      _emit();
    } catch (_) {
      // Bu adreste cihaz yok ya da yanit vermedi, yok say.
    }
  }

  void _sweepStale() {
    final before = _peers.length;
    _peers.removeWhere((_, peer) => peer.isStale);
    if (_peers.length != before) _emit();
  }

  void _emit() => _peersController.add(_peers.values.toList());

  Future<void> stop() async {
    _broadcastTimer?.cancel();
    _sweepTimer?.cancel();
    _scanTimer?.cancel();
    _socket?.close();
    _socket = null;
    await _peersController.close();
    await _statusController.close();
  }
}
