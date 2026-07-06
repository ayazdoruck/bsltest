import 'dart:async';

import 'package:flutter/material.dart';

import '../models/transfer_task.dart';
import '../services/transfer_server.dart';
import '../utils/constants.dart';
import '../utils/format.dart';

// Gelen bir dosya transferi için kabul/red dialoğu.
// Sunucu tarafında aynı süreyle (kTransferApprovalTimeout) zaman aşımına
// uğrayan istekle senkron kalmak için bu dialog da kendini otomatik kapatır.
void showIncomingTransferDialog(
  BuildContext context,
  TransferTask task,
  TransferServer server,
) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _IncomingTransferDialog(task: task, server: server),
  );
}

class _IncomingTransferDialog extends StatefulWidget {
  final TransferTask task;
  final TransferServer server;

  const _IncomingTransferDialog({required this.task, required this.server});

  @override
  State<_IncomingTransferDialog> createState() =>
      _IncomingTransferDialogState();
}

class _IncomingTransferDialogState extends State<_IncomingTransferDialog> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(kTransferApprovalTimeout, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _respond(bool accepted) {
    widget.server.respondToRequest(widget.task.id, accepted);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Gelen Dosya'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.task.peer.displayName} size bir dosya gönderiyor:'),
          const SizedBox(height: 12),
          Text(widget.task.fileName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(formatBytes(widget.task.fileSize),
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _respond(false),
          child: const Text('Reddet', style: TextStyle(color: Colors.redAccent)),
        ),
        TextButton(
          onPressed: () => _respond(true),
          child: const Text('Kabul Et',
              style: TextStyle(
                  color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
