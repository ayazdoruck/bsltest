import 'package:flutter/material.dart';

import '../models/peer.dart';

class PeerListTile extends StatelessWidget {
  final Peer peer;
  final VoidCallback onTap;

  const PeerListTile({super.key, required this.peer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isWindows = peer.platform == 'windows';

    return Card(
      color: const Color(0xFF1E2235),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.18),
          child: Icon(
            isWindows ? Icons.desktop_windows_rounded : Icons.phone_iphone_rounded,
            color: const Color(0xFF6366F1),
          ),
        ),
        title: Text(peer.displayName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(peer.host,
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: const Icon(Icons.send_rounded, color: Color(0xFF10B981)),
      ),
    );
  }
}
