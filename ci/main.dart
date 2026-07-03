import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSL TCP Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Bilgisayarinin LAN IP'si (server 0.0.0.0:9339 dinliyor)
  final _host = TextEditingController(text: '192.168.0.16');
  final _port = TextEditingController(text: '9339');
  final _msg = TextEditingController(text: 'merhaba sunucu');
  final List<String> _log = [];
  Socket? _socket;
  bool _connected = false;

  void _addLog(String s) {
    setState(() =>
        _log.insert(0, '${DateTime.now().toString().substring(11, 19)}  $s'));
  }

  String _hex(List<int> b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join(' ');

  Future<void> _connect() async {
    if (_connected) {
      await _socket?.close();
      _cleanup();
      _addLog('kapatildi');
      return;
    }
    final host = _host.text.trim();
    final port = int.tryParse(_port.text.trim()) ?? 0;
    _addLog('baglaniliyor -> $host:$port ...');
    try {
      final s =
          await Socket.connect(host, port, timeout: const Duration(seconds: 8));
      _socket = s;
      setState(() => _connected = true);
      _addLog('BAGLANDI (${s.remoteAddress.address}:${s.remotePort})');
      s.listen(
        (data) => _addLog('RX ${data.length}B: ${_hex(data)}'),
        onError: (e) {
          _addLog('HATA: $e');
          _cleanup();
        },
        onDone: () {
          _addLog('sunucu baglantiyi kapatti');
          _cleanup();
        },
      );
    } catch (e) {
      _addLog('BAGLANTI HATASI: $e');
    }
  }

  void _cleanup() {
    _socket?.destroy();
    _socket = null;
    if (mounted) setState(() => _connected = false);
  }

  void _send() {
    final s = _socket;
    if (s == null) {
      _addLog('once baglan');
      return;
    }
    final bytes = utf8.encode(_msg.text);
    s.add(bytes);
    _addLog('TX ${bytes.length}B: ${_hex(bytes)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BSL TCP Test')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                flex: 3,
                child: TextField(
                    controller: _host,
                    decoration: const InputDecoration(labelText: 'Host / IP')),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Port')),
              ),
            ]),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _connect,
              child: Text(_connected ? 'BAGLANTIYI KES' : 'BAGLAN'),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                    controller: _msg,
                    decoration:
                        const InputDecoration(labelText: 'Gonderilecek metin')),
              ),
              const SizedBox(width: 8),
              FilledButton(
                  onPressed: _connected ? _send : null,
                  child: const Text('GONDER')),
            ]),
            const Divider(height: 24),
            Row(children: [
              const Text('Log',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                  onPressed: () => setState(_log.clear),
                  child: const Text('temizle')),
            ]),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(_log[i],
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
