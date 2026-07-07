import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/device_identity_service.dart';
import '../../services/locale_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/coded_by_widget.dart';

class SettingsTab extends StatefulWidget {
  final DeviceIdentityService identity;
  final VoidCallback onIdentityChanged;

  const SettingsTab({
    super.key,
    required this.identity,
    required this.onIdentityChanged,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final SettingsService _settings = SettingsService();
  final LocaleService _locale = LocaleService();
  final TextEditingController _nameController = TextEditingController();

  String? _saveDirectory;
  bool _loading = true;

  static const _languageNames = {
    'en': 'English',
    'tr': 'Türkçe',
    'ru': 'Русский',
    'zh': '中文',
  };

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
    final t = AppLocalizations.of(context)!;
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.identity.name) return;
    await widget.identity.setName(newName);
    widget.onIdentityChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.deviceNameUpdated),
          backgroundColor: Theme.of(context).colorScheme.secondary,
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
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final currentLanguage = Localizations.localeOf(context).languageCode;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionTitle(context, t.deviceName),
        Text(t.deviceNameHelp,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                onSubmitted: (_) => _saveName(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.check_circle_rounded, color: scheme.secondary),
              onPressed: _saveName,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _sectionTitle(context, t.saveLocation),
        const SizedBox(height: 12),
        if (Platform.isWindows) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _saveDirectory ?? t.defaultDownloads,
                    style: TextStyle(color: scheme.onSurface),
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
                  label: Text(t.chooseFolder),
                ),
              ),
              if (_saveDirectory != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _resetSaveDirectory,
                  child: Text(t.resetToDefault),
                ),
              ],
            ],
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_special_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.iosFixedLocationInfo,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
        _sectionTitle(context, t.language),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppLocalizations.supportedLocales.map((locale) {
            final selected = locale.languageCode == currentLanguage;
            return ChoiceChip(
              label: Text(_languageNames[locale.languageCode] ?? locale.languageCode),
              selected: selected,
              onSelected: (_) => _locale.setLocale(locale),
            );
          }).toList(),
        ),
        const SizedBox(height: 48),
        const Center(child: CodedByWidget()),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      );
}
