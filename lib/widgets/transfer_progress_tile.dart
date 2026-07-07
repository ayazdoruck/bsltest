import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/transfer_task.dart';
import '../utils/format.dart';

class TransferProgressTile extends StatelessWidget {
  final TransferTask task;

  const TransferProgressTile({super.key, required this.task});

  String _statusText(AppLocalizations t) {
    switch (task.status) {
      case TransferStatus.awaitingApproval:
        return t.statusAwaitingApproval;
      case TransferStatus.inProgress:
        return '${(task.progressRatio * 100).toStringAsFixed(0)}%';
      case TransferStatus.completed:
        return t.statusCompleted;
      case TransferStatus.rejected:
        return t.statusRejected;
      case TransferStatus.timedOut:
        return t.statusTimedOut;
      case TransferStatus.failed:
        return t.statusFailed(task.errorMessage ?? '');
    }
  }

  Color _statusColor(ColorScheme scheme) {
    switch (task.status) {
      case TransferStatus.completed:
        return scheme.secondary;
      case TransferStatus.rejected:
      case TransferStatus.timedOut:
      case TransferStatus.failed:
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bool isSend = task.direction == TransferDirection.send;
    final statusColor = _statusColor(scheme);

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 6),
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
                  color: scheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.fileName,
                    style: TextStyle(
                        color: scheme.onSurface, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  task.peer.displayName,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
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
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_statusText(t),
                    style: TextStyle(color: statusColor, fontSize: 12)),
                Text(formatBytes(task.fileSize),
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
