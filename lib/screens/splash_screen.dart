import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../l10n/app_localizations.dart';
import '../services/device_identity_service.dart';
import '../services/discovery_service.dart';
import '../services/transfer_client.dart';
import '../services/transfer_server.dart';
import '../widgets/coded_by_widget.dart';
import 'home_shell.dart';

// GİRİŞ / SPLASH EKRANI. Kullanıcıdan tıklama beklemez: kimlik/keşif/
// transfer servislerini burada başlatıp hazır olduklarında otomatik olarak
// HomeShell'e geçer (pushReplacement ile - geri gidilecek bir splash rotası
// kalmaz, HomeShell'in AppBar'ında da bu yuzden geri oku çıkmaz).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _retry() {
    setState(() => _error = null);
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final identity = DeviceIdentityService();
      await identity.load();

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeShell(
            identity: identity,
            discovery: discovery,
            transferServer: transferServer,
            transferClient: transferClient,
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.surface, scheme.primaryContainer],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _AnimatedEntrance(
                  child: Container(
                    width: 168,
                    height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/bslend_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _AnimatedEntrance(
                  delay: const Duration(milliseconds: 120),
                  child: Text(
                    'Bslend',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AnimatedEntrance(
                  delay: const Duration(milliseconds: 220),
                  child: Text(
                    t.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                _AnimatedEntrance(
                  delay: const Duration(milliseconds: 320),
                  child: _error == null
                      ? Column(
                          children: [
                            SpinKitPulse(color: scheme.primary, size: 46),
                            const SizedBox(height: 18),
                            Text(
                              t.preparingServer,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: scheme.error, size: 36),
                            const SizedBox(height: 12),
                            Text(
                              t.servicesFailedToStart(_error!),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.error, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _retry,
                              child: Text(t.retry),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 40),
                const CodedByWidget(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Basit fade + kaydirma girisi (ekstra paket gerektirmeden), gecikmeli
// baslayabilir (sekans hissi vermek icin).
class _AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedEntrance({required this.child, this.delay = Duration.zero});

  @override
  State<_AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<_AnimatedEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
