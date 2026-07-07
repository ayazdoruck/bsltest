import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/device_identity_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final DeviceIdentityService identity;

  const SettingsScreen({super.key, required this.identity});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final TextEditingController _nameController = TextEditingController();

  String? _saveDirectory;
  bool _nameChanged = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.identity.name;
    _loadSaveDirectory();
  }

  Future<void> _loadSaveDirectory() async {
    final custom = await _settings.getSaveDirectory();
    setState(() {
      _saveDirectory = custom;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.identity.name) return;
    await widget.identity.setName(newName);
    _nameChanged = true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cihaz adı güncellendi.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _pickSaveDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    await _settings.setSaveDirectory(path);
    setState(() => _saveDirectory = path);
  }

  Future<void> _resetSaveDirectory() async {
    await _settings.setSaveDirectory(null);
    setState(() => _saveDirectory = null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ayarlar'),
          backgroundColor: const Color(0xFF151829),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(_nameChanged),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _sectionTitle('Cihaz Adı'),
                  Text(
                    'Diğer cihazlarda seni bu adla görürler.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E2235),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _saveName(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF10B981)),
                        onPressed: _saveName,
                        tooltip: 'Kaydet',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _sectionTitle('Dosya Kayıt Konumu'),
                  const SizedBox(height: 12),
                  if (Platform.isWindows) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_rounded,
                              color: Color(0xFF6366F1)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _saveDirectory ?? 'Varsayılan (İndirilenler)',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickSaveDirectory,
                            icon: const Icon(Icons.drive_folder_upload_rounded),
                            label: const Text('Klasör Seç'),
                          ),
                        ),
                        if (_saveDirectory != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _resetSaveDirectory,
                            child: const Text('Varsayılana Dön'),
                          ),
                        ],
                      ],
                    ),
                  ] else
                    FutureBuilder<Directory>(
                      future: getApplicationDocumentsDirectory(),
                      builder: (context, snapshot) => Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2235),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_special_rounded,
                                color: Color(0xFF6366F1)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Uygulama içi (Dosyalar > Bslend üzerinden erişilebilir)',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      );
}
