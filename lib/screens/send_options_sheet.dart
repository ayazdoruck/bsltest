import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/peer.dart';

enum SendSource { files, gallery, camera }

// Bir peer'a dosya gondermeden once "Dosya Sec / Galeriden Sec / Kamerayla
// Cek" secenekleri sunan alt sayfa (LocalSend'deki gibi). Sadece mobilde
// (iOS) gosterilir; Windows'ta dogrudan dosya secici acilir.
Future<SendSource?> showSendOptionsSheet(BuildContext context, Peer peer) {
  final t = AppLocalizations.of(context)!;
  final scheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<SendSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.sendToPeer(peer.displayName),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file_rounded, color: scheme.primary),
            title: Text(t.pickFile),
            onTap: () => Navigator.pop(sheetContext, SendSource.files),
          ),
          ListTile(
            leading: Icon(Icons.photo_library_rounded, color: scheme.primary),
            title: Text(t.pickFromGallery),
            onTap: () => Navigator.pop(sheetContext, SendSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt_rounded, color: scheme.primary),
            title: Text(t.takePhoto),
            onTap: () => Navigator.pop(sheetContext, SendSource.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
