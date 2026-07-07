import 'package:flutter/material.dart';

import '../models/peer.dart';

class PeerListTile extends StatelessWidget {
  final Peer peer;
  final VoidCallback onTap;

  const PeerListTile({super.key, required this.peer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isWindows = peer.platform == 'windows';
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            isWindows ? Icons.desktop_windows_rounded : Icons.phone_iphone_rounded,
            color: scheme.onPrimaryContainer,
          ),
        ),
        title: Text(peer.displayName,
            style: TextStyle(
                color: scheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(peer.host,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
        trailing: Icon(Icons.send_rounded, color: scheme.secondary),
      ),
    );
  }
}
