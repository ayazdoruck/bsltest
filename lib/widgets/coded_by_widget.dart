import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

// "coded by @ayazdoruck"
class CodedByWidget extends StatefulWidget {
  final bool showCompact;
  const CodedByWidget({super.key, this.showCompact = false});

  @override
  State<CodedByWidget> createState() => _CodedByWidgetState();
}

class _CodedByWidgetState extends State<CodedByWidget> {
  late final TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = _launchUrl;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/ayazdoruck');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: widget.showCompact
              ? scheme.onSurfaceVariant.withValues(alpha: 0.8)
              : scheme.onSurfaceVariant,
          fontSize: widget.showCompact ? 11 : 13,
        ),
        children: [
          TextSpan(text: t.codedBy),
          TextSpan(
            text: '@ayazdoruck',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: _tapRecognizer,
          ),
        ],
      ),
    );
  }
}
