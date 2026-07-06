import 'package:flutter/material.dart';

import '../models/transfer_task.dart';
import '../utils/format.dart';

class TransferProgressTile extends StatelessWidget {
  final TransferTask task;

  const TransferProgressTile({super.key, required this.task});

  String _statusText() {
    switch (task.status) {
      case TransferStatus.awaitingApproval:
        return 'Onay bekleniyor...';
      case TransferStatus.inProgress:
        return '${(task.progressRatio * 100).toStringAsFixed(0)}%';
      case TransferStatus.completed:
        return 'Tamamlandı';
      case TransferStatus.rejected:
        return 'Reddedildi';
      case TransferStatus.timedOut:
        return 'Zaman aşımı';
      case TransferStatus.failed:
        return 'Hata: ${task.errorMessage ?? ''}';
    }
  }

  Color _statusColor() {
    switch (task.status) {
      case TransferStatus.completed:
        return const Color(0xFF10B981);
      case TransferStatus.rejected:
      case TransferStatus.timedOut:
      case TransferStatus.failed:
        return Colors.redAccent;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSend = task.direction == TransferDirection.send;

    return Card(
      color: const Color(0xFF1E2235),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSend ? Icons.upload_rounded : Icons.download_rounded,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.fileName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  task.peer.displayName,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: task.status == TransferStatus.inProgress ||
                        task.status == TransferStatus.completed
                    ? task.progressRatio
                    : 0,
                minHeight: 6,
                backgroundColor: const Color(0xFF232840),
                valueColor: AlwaysStoppedAnimation(_statusColor()),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_statusText(),
                    style: TextStyle(color: _statusColor(), fontSize: 12)),
                Text(formatBytes(task.fileSize),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
