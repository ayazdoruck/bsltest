import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/discovery_status.dart';
import '../models/peer.dart';
import '../models/transfer_task.dart';
import '../services/device_identity_service.dart';
import '../services/discovery_service.dart';
import '../services/transfer_client.dart';
import '../services/transfer_server.dart';
import '../widgets/coded_by_widget.dart';
import 'incoming_transfer_dialog.dart';
import 'tabs/receive_tab.dart';
import 'tabs/send_tab.dart';
import 'tabs/settings_tab.dart';

enum HomeTab { receive, send, settings }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final DeviceIdentityService _identity = DeviceIdentityService();
  DiscoveryService? _discovery;
  TransferServer? _transferServer;
  TransferClient? _transferClient;

  List<Peer> _peers = [];
  final Map<String, TransferTask> _tasks = {};
  DiscoveryStatus? _discoveryStatus;

  bool _starting = true;
  String? _startError;
  HomeTab _currentTab = HomeTab.send;

  @override
  void initState() {
    super.initState();
    _startServices();
  }

  Future<void> _startServices() async {
    try {
      await _identity.load();

      final transferServer = TransferServer(
        myId: _identity.id,
        myName: _identity.name,
        myPlatform: _identity.platform,
      );
      await transferServer.start();

      final discovery = DiscoveryService(
        myId: _identity.id,
        myName: _identity.name,
        myPlatform: _identity.platform,
      );
      await discovery.start();

      final transferClient =
          TransferClient(myId: _identity.id, myName: _identity.name);

      discovery.peers.listen((peers) {
        if (mounted) setState(() => _peers = peers);
      });
      discovery.statusUpdates.listen((status) {
        if (mounted) setState(() => _discoveryStatus = status);
      });
      transferServer.incomingRequests.listen((task) {
        if (!mounted) return;
        setState(() => _tasks[task.id] = task);
        showIncomingTransferDialog(context, task, transferServer);
      });
      transferServer.transferUpdates.listen((task) {
        if (mounted) setState(() => _tasks[task.id] = task);
      });
      transferClient.transferUpdates.listen((task) {
        if (mounted) setState(() => _tasks[task.id] = task);
      });

      setState(() {
        _discovery = discovery;
        _transferServer = transferServer;
        _transferClient = transferClient;
        _starting = false;
      });
    } catch (e) {
      setState(() {
        _startError = '$e';
        _starting = false;
      });
    }
  }

  @override
  void dispose() {
    _discovery?.stop();
    _transferServer?.stop();
    _transferClient?.dispose();
    super.dispose();
  }

  Future<void> _restartServices() async {
    await _discovery?.stop();
    await _transferServer?.stop();
    _transferClient?.dispose();
    setState(() {
      _discovery = null;
      _transferServer = null;
      _transferClient = null;
      _peers = [];
      _tasks.clear();
      _discoveryStatus = null;
      _starting = true;
      _startError = null;
    });
    await _startServices();
  }

  Future<void> _pickAndSend(Peer peer) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    for (final picked in result.files) {
      if (picked.path == null) continue;
      await _transferClient!.sendFile(peer, File(picked.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_starting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_startError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.servicesFailedToStart(_startError!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final allTasks = _tasks.values.toList().reversed.toList();
    final incoming =
        allTasks.where((t) => t.direction == TransferDirection.receive).toList();
    final outgoing =
        allTasks.where((t) => t.direction == TransferDirection.send).toList();

    final destinations = [
      (icon: Icons.wifi_rounded, label: t.tabReceive),
      (icon: Icons.send_rounded, label: t.tabSend),
      (icon: Icons.settings_rounded, label: t.tabSettings),
    ];

    final pages = [
      ReceiveTab(
        identity: _identity,
        discoveryStatus: _discoveryStatus,
        incomingTasks: incoming,
      ),
      SendTab(
        peers: _peers,
        discoveryStatus: _discoveryStatus,
        outgoingTasks: outgoing,
        onPeerTap: _pickAndSend,
      ),
      SettingsTab(
        identity: _identity,
        onIdentityChanged: _restartServices,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 600;

      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bslend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const CodedByWidget(showCompact: true),
            ],
          ),
        ),
        body: Row(
          children: [
            if (isWide)
              NavigationRail(
                selectedIndex: _currentTab.index,
                onDestinationSelected: (i) =>
                    setState(() => _currentTab = HomeTab.values[i]),
                labelType: NavigationRailLabelType.all,
                destinations: destinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentTab.index,
                children: pages,
              ),
            ),
          ],
        ),
        bottomNavigationBar: isWide
            ? null
            : NavigationBar(
                selectedIndex: _currentTab.index,
                onDestinationSelected: (i) =>
                    setState(() => _currentTab = HomeTab.values[i]),
                destinations: destinations
                    .map((d) => NavigationDestination(
                          icon: Icon(d.icon),
                          label: d.label,
                        ))
                    .toList(),
              ),
      );
    });
  }
}
