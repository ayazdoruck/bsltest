import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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

  final Map<String, Peer> _peers = {};
  final _peersController = StreamController<List<Peer>>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<List<Peer>> get peers => _peersController.stream;
  // Konsola erisimi olmayan (ör. IPA ile kurulmus) cihazlarda ekranda
  // gosterilebilecek insan-okunur tanilama satiri.
  Stream<String> get statusUpdates => _statusController.stream;

  List<String> _myAddresses = [];
  int _broadcastCount = 0;
  int _receivedCount = 0;
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
    final addr = _myAddresses.isEmpty ? 'bilinmiyor' : _myAddresses.join(', ');
    _statusController.add(
      'Benim IP: $addr | Yayin gonderildi: $_broadcastCount | '
      'Alinan duyuru: $_receivedCount | Hata: ${_lastError ?? 'yok'}',
    );
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

    // Evrensel broadcast bazi router/adaptor kombinasyonlarinda iletilmeyebilir;
    // bu yuzden ek olarak her aktif arayuzun kendi alt ag broadcast adresine
    // (varsayilan /24) de gonderiyoruz.
    final targets = <String>{'255.255.255.255'};
    for (final address in _myAddresses) {
      final parts = address.split('.');
      if (parts.length == 4) {
        targets.add('${parts[0]}.${parts[1]}.${parts[2]}.255');
      }
    }

    var anySucceeded = false;
    String? error;
    for (final target in targets) {
      try {
        _socket?.send(payload, InternetAddress(target), kDiscoveryUdpPort);
        anySucceeded = true;
      } catch (e) {
        error = '$target: $e';
        debugPrint('[Discovery] $target adresine gonderilemedi: $e');
      }
    }

    if (anySucceeded) _broadcastCount++;
    _lastError = error;
    _emitStatus();
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
    _socket?.close();
    _socket = null;
    await _peersController.close();
    await _statusController.close();
  }
}
