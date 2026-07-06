import 'peer.dart';

enum TransferDirection { send, receive }

enum TransferStatus {
  awaitingApproval,
  inProgress,
  completed,
  rejected,
  timedOut,
  failed,
}

class TransferTask {
  final String id;
  final String fileName;
  final int fileSize;
  final TransferDirection direction;
  final Peer peer;
  TransferStatus status;
  int progressBytes;
  String? errorMessage;

  TransferTask({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.direction,
    required this.peer,
    this.status = TransferStatus.awaitingApproval,
    this.progressBytes = 0,
    this.errorMessage,
  });

  double get progressRatio =>
      fileSize == 0 ? 0 : (progressBytes / fileSize).clamp(0, 1);
}
