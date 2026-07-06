import 'package:flutter/material.dart';

import '../widgets/coded_by_widget.dart';
import 'home_screen.dart';

// GİRİŞ / SPLASH EKRANI (ağ durumu ne olursa olsun açılışta görünür)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F111E), Color(0xFF1E1E38)],
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
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_to_mobile_rounded,
                    size: 80,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  'Bslend',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aynı yerel ağ üzerindeki cihazları bulup aralarında hızlı dosya aktarımı yapın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text(
                      'Başlayalım',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
