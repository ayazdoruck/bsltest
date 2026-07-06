// Ağ sabitleri: keşif (UDP) ve dosya transferi (HTTP) portları/zamanlamaları.
const int kDiscoveryUdpPort = 57332;
const int kTransferHttpPort = 57333;

const Duration kBroadcastInterval = Duration(seconds: 3);
const Duration kStalenessSweepInterval = Duration(seconds: 2);
const Duration kPeerTimeout = Duration(seconds: 8);
const Duration kTransferApprovalTimeout = Duration(seconds: 30);
