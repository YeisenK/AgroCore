import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de control')),
      body: Center(
        child: Wrap(
          spacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/dashboard/agricultor'),
              child: const Text('Entrar como Agricultor'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/dashboard/ingeniero'),
              child: const Text('Entrar como Ingeniero'),
            ),
          ],
        ),
      ),
    );
  }
}
