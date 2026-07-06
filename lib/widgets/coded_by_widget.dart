import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: widget.showCompact ? Colors.grey[400] : Colors.grey[500],
          fontSize: widget.showCompact ? 11 : 13,
        ),
        children: [
          const TextSpan(text: 'coded by '),
          TextSpan(
            text: '@ayazdoruck',
            style: const TextStyle(
              color: Colors.purpleAccent,
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
