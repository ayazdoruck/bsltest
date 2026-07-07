import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/discovery_status.dart';
import '../../models/peer.dart';
import '../../models/transfer_task.dart';
import '../../widgets/peer_list_tile.dart';
import '../../widgets/transfer_progress_tile.dart';

class SendTab extends StatelessWidget {
  final List<Peer> peers;
  final DiscoveryStatus? discoveryStatus;
  final List<TransferTask> outgoingTasks;
  final ValueChanged<Peer> onPeerTap;

  const SendTab({
    super.key,
    required this.peers,
    required this.discoveryStatus,
    required this.outgoingTasks,
    required this.onPeerTap,
  });

  String _diagnosticsLine(AppLocalizations t) {
    final status = discoveryStatus;
    if (status == null) return '';
    final addr = status.addresses.isEmpty ? '...' : status.addresses.join(', ');
    return t.diagnosticsLine(
      addr,
      '${status.broadcastCount}',
      '${status.receivedCount}',
      '${status.scanCount}',
      status.error ?? t.noneError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _sectionHeader(context, t.nearbyDevices),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            _diagnosticsLine(t),
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10),
          ),
        ),
        if (peers.isEmpty)
          _emptyHint(context, t.searchingForDevices)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: peers
                  .map((peer) =>
                      PeerListTile(peer: peer, onTap: () => onPeerTap(peer)))
                  .toList(),
            ),
          ),
        Divider(color: scheme.outlineVariant, height: 24),
        _sectionHeader(context, t.outgoingTransfers),
        Expanded(
          child: outgoingTasks.isEmpty
              ? _emptyHint(context, t.noTransfersYet)
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: outgoingTasks
                      .map((task) => TransferProgressTile(task: task))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
        ),
      );

  Widget _emptyHint(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7))),
        ),
      );
}
