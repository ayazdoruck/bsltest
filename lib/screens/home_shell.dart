import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/discovery_status.dart';
import '../models/peer.dart';
import '../models/transfer_task.dart';
import '../services/device_identity_service.dart';
import '../services/discovery_service.dart';
import '../services/transfer_client.dart';
import '../services/transfer_server.dart';
import 'incoming_transfer_dialog.dart';
import 'send_options_sheet.dart';
import 'tabs/receive_tab.dart';
import 'tabs/send_tab.dart';
import 'tabs/settings_tab.dart';

enum HomeTab { receive, send, settings }

// Servisler artik burada degil, SplashScreen'de baslatiliyor (yukleme
// animasyonu sirasinda) ve hazir halde bu widget'a aktariliyor - boylece
// HomeShell'in kendi "yukleniyor" ekranina ya da geri gidilebilecek bir
// splash rotasina ihtiyaci kalmiyor.
class HomeShell extends StatefulWidget {
  final DeviceIdentityService identity;
  final DiscoveryService discovery;
  final TransferServer transferServer;
  final TransferClient transferClient;

  const HomeShell({
    super.key,
    required this.identity,
    required this.discovery,
    required this.transferServer,
    required this.transferClient,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late DiscoveryService _discovery;
  late TransferServer _transferServer;
  late TransferClient _transferClient;

  List<Peer> _peers = [];
  final Map<String, TransferTask> _tasks = {};
  DiscoveryStatus? _discoveryStatus;
  HomeTab _currentTab = HomeTab.send;

  @override
  void initState() {
    super.initState();
    _discovery = widget.discovery;
    _transferServer = widget.transferServer;
    _transferClient = widget.transferClient;
    _wireListeners();
  }

  void _wireListeners() {
    _discovery.peers.listen((peers) {
      if (mounted) setState(() => _peers = peers);
    });
    _discovery.statusUpdates.listen((status) {
      if (mounted) setState(() => _discoveryStatus = status);
    });
    _transferServer.incomingRequests.listen((task) {
      if (!mounted) return;
      setState(() => _tasks[task.id] = task);
      showIncomingTransferDialog(context, task, _transferServer);
    });
    _transferServer.transferUpdates.listen((task) {
      if (mounted) setState(() => _tasks[task.id] = task);
    });
    _transferClient.transferUpdates.listen((task) {
      if (mounted) setState(() => _tasks[task.id] = task);
    });
  }

  @override
  void dispose() {
    _discovery.stop();
    _transferServer.stop();
    _transferClient.dispose();
    super.dispose();
  }

  // Ayarlar'dan cihaz adi degistirildiginde cagirilir: eski servisleri
  // durdurup yeni isimle yeniden baslatir.
  Future<void> _restartServices() async {
    await _discovery.stop();
    await _transferServer.stop();
    _transferClient.dispose();

    final identity = widget.identity;
    final transferServer = TransferServer(
      myId: identity.id,
      myName: identity.name,
      myPlatform: identity.platform,
    );
    await transferServer.start();

    final discovery = DiscoveryService(
      myId: identity.id,
      myName: identity.name,
      myPlatform: identity.platform,
    );
    await discovery.start();

    final transferClient =
        TransferClient(myId: identity.id, myName: identity.name);

    if (!mounted) return;
    setState(() {
      _discovery = discovery;
      _transferServer = transferServer;
      _transferClient = transferClient;
      _peers = [];
      _tasks.clear();
      _discoveryStatus = null;
    });
    _wireListeners();
  }

  Future<void> _pickAndSend(Peer peer) async {
    // Windows'ta galeri/kamera kavrami olmadigi icin dogrudan dosya secici
    // acilir; iOS'ta LocalSend'deki gibi Dosya/Galeri/Kamera secenekleri
    // sunulur.
    if (Platform.isWindows) {
      await _pickFilesAndSend(peer);
      return;
    }

    final source = await showSendOptionsSheet(context, peer);
    if (source == null) return;

    switch (source) {
      case SendSource.files:
        await _pickFilesAndSend(peer);
        break;
      case SendSource.gallery:
        await _pickGalleryAndSend(peer);
        break;
      case SendSource.camera:
        await _pickCameraAndSend(peer);
        break;
    }
  }

  Future<void> _pickFilesAndSend(Peer peer) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    for (final picked in result.files) {
      if (picked.path == null) continue;
      await _transferClient.sendFile(peer, File(picked.path!));
    }
  }

  Future<void> _pickGalleryAndSend(Peer peer) async {
    final picked = await ImagePicker().pickMultipleMedia();
    for (final xfile in picked) {
      await _transferClient.sendFile(peer, File(xfile.path));
    }
  }

  Future<void> _pickCameraAndSend(Peer peer) async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo == null) return;
    await _transferClient.sendFile(peer, File(photo.path));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
        identity: widget.identity,
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
        identity: widget.identity,
        onIdentityChanged: _restartServices,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 600;

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Bslend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
