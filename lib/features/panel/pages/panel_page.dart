import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF1C2428),
        foregroundColor: const Color(0xFFD3D9DE),
        elevation: 0,
      ),
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SmallButton(
              text: 'Agricultor',
              onPressed: () => context.go('/dashboard/agricultor'),
            ),
            _SmallButton(
              text: 'Ingeniero', 
              onPressed: () => context.go('/dashboard/ingeniero'),
            ),
            _SmallButton(
              text: 'Pedidos',
              onPressed: () => context.go('/pedidos'),
            ),
            _SmallButton(
              text: 'Siembras',
              onPressed: () => context.go('/siembras'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SmallButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B8F86),
        foregroundColor: const Color(0xFFDDE6E6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text),
    );
  }
}