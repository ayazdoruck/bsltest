import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  Stream<List<Peer>> get peers => _peersController.stream;

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

    _broadcastAnnounce();
    _broadcastTimer = Timer.periodic(
      kBroadcastInterval,
      (_) => _broadcastAnnounce(),
    );
    _sweepTimer = Timer.periodic(kStalenessSweepInterval, (_) => _sweepStale());
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

  void _broadcastAnnounce() {
    final payload = utf8.encode(jsonEncode({
      'id': myId,
      'name': myName,
      'platform': myPlatform,
      'port': kTransferHttpPort,
      'type': 'announce',
    }));
    try {
      _socket?.send(payload, InternetAddress('255.255.255.255'), kDiscoveryUdpPort);
    } catch (_) {
      // Ağ geçici olarak kullanılamıyor olabilir, bir sonraki tick'te tekrar dener.
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
    _socket?.close();
    _socket = null;
    await _peersController.close();
  }
}
