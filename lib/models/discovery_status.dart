// DiscoveryService'in ham tanilama verisi. BuildContext'i olmayan bir
// serviste lokalize metin uretilemedigi icin bu ham veri disariya (UI
// katmanina) tasinip orada formatlaniyor.
class DiscoveryStatus {
  final List<String> addresses;
  final int broadcastCount;
  final int receivedCount;
  final int scanCount;
  final String? error;

  const DiscoveryStatus({
    required this.addresses,
    required this.broadcastCount,
    required this.receivedCount,
    required this.scanCount,
    this.error,
  });
}
