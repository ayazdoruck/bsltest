import '../utils/constants.dart';

class Peer {
  final String id;
  final String displayName;
  final String host;
  final int port;
  final String platform;
  DateTime lastSeen;

  Peer({
    required this.id,
    required this.displayName,
    required this.host,
    required this.port,
    required this.platform,
    required this.lastSeen,
  });

  bool get isStale => DateTime.now().difference(lastSeen) > kPeerTimeout;
}
