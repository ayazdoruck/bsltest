import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/peer.dart';
import '../models/transfer_task.dart';
import '../services/device_identity_service.dart';
import '../services/discovery_service.dart';
import '../services/transfer_client.dart';
import '../services/transfer_server.dart';
import '../widgets/coded_by_widget.dart';
import '../widgets/peer_list_tile.dart';
import '../widgets/transfer_progress_tile.dart';
import 'incoming_transfer_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceIdentityService _identity = DeviceIdentityService();
  DiscoveryService? _discovery;
  TransferServer? _transferServer;
  TransferClient? _transferClient;

  List<Peer> _peers = [];
  final Map<String, TransferTask> _tasks = {};
  String _discoveryStatus = '';

  bool _starting = true;
  String? _startError;

  @override
  void initState() {
    super.initState();
    _startServices();
  }

  Future<void> _startServices() async {
    try {
      await _identity.load();

      final discovery = DiscoveryService(
        myId: _identity.id,
        myName: _identity.name,
        myPlatform: _identity.platform,
      );
      await discovery.start();

      final transferServer = TransferServer();
      await transferServer.start();

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
    final tasks = _tasks.values.toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bslend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CodedByWidget(showCompact: true),
          ],
        ),
        backgroundColor: const Color(0xFF151829),
      ),
      body: _starting
          ? const Center(child: CircularProgressIndicator())
          : _startError != null
              ? Center(
                  child: Text(
                    'Servisler başlatılamadı: $_startError',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    _sectionHeader('Yakındaki Cihazlar'),
                    if (_discoveryStatus.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          _discoveryStatus,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 10),
                        ),
                      ),
                    _peers.isEmpty
                        ? _emptyHint(
                            'Aynı ağ üzerinde başka bir cihaz aranıyor...')
                        : Column(
                            children: _peers
                                .map((peer) => PeerListTile(
                                      peer: peer,
                                      onTap: () => _pickAndSend(peer),
                                    ))
                                .toList(),
                          ),
                    const Divider(color: Color(0xFF232840), height: 24),
                    _sectionHeader('Transferler'),
                    Expanded(
                      child: tasks.isEmpty
                          ? _emptyHint('Henüz bir transfer yok.')
                          : ListView(
                              children: tasks
                                  .map((task) =>
                                      TransferProgressTile(task: task))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
        ),
      );

  Widget _emptyHint(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(text, style: TextStyle(color: Colors.grey[600])),
        ),
      );
}
