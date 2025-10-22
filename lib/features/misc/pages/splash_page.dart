// lib/features/misc/pages/splash_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/data/auth/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final List<String> _phrases = const [
    'Cargando AgroCore…',
    'Sincronizando sensores…',
    'Optimizando invernaderos…',
    'Revisando clima y humedad…',
    'Conectando con el servidor…',
  ];
  Timer? _timer;
  int _currentPhrase = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _currentPhrase = (_currentPhrase + 1) % _phrases.length);
    });
    // 👇 Nada de bootstrap ni context.go aquí.
    // El GoRouter con redirect basado en AuthStatus se encarga de navegar.
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthController>().status;

    const bg = Color(0xFF1E1E2C);
    const accent = Colors.tealAccent;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture_rounded, size: 72, color: accent),
            const SizedBox(height: 40),
            const CircularProgressIndicator(strokeWidth: 3, color: accent),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _phrases[_currentPhrase],
                key: ValueKey(_phrases[_currentPhrase]),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Debug opcional para ver el estado actual (puedes quitarlo)
            Text(
              'Estado: $status',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
