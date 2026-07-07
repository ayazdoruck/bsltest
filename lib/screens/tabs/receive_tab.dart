import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/discovery_status.dart';
import '../../models/transfer_task.dart';
import '../../services/device_identity_service.dart';
import '../../widgets/transfer_progress_tile.dart';

class ReceiveTab extends StatelessWidget {
  final DeviceIdentityService identity;
  final DiscoveryStatus? discoveryStatus;
  final List<TransferTask> incomingTasks;

  const ReceiveTab({
    super.key,
    required this.identity,
    required this.discoveryStatus,
    required this.incomingTasks,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final myIp = (discoveryStatus?.addresses.isNotEmpty ?? false)
        ? discoveryStatus!.addresses.first
        : '...';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: scheme.secondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primary,
                  child: Icon(
                    identity.platform == 'windows'
                        ? Icons.desktop_windows_rounded
                        : Icons.phone_iphone_rounded,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.myDevice,
                          style: TextStyle(
                              color: scheme.onSecondaryContainer, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(identity.name,
                          style: TextStyle(
                              color: scheme.onSecondaryContainer,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(myIp,
                          style: TextStyle(
                              color: scheme.onSecondaryContainer
                                  .withValues(alpha: 0.7),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(t.incomingFiles,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (incomingTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(t.noIncomingFiles,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ),
          )
        else
          ...incomingTasks.map((task) => TransferProgressTile(task: task)),
      ],
    );
  }
}
