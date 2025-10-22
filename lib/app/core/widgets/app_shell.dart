import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: const _AppDrawer(),
      body: body,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  void _go(BuildContext context, String path) {
    // Cierra el drawer antes de navegar
    Navigator.of(context).pop();
    // Navegación con GoRouter
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('AgroCore')),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text('Ingeniero'),
            // 👇 consistente con tu app_router actual
            onTap: () => _go(context, '/dashboard/ingeniero'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Mapeo de plántulas'),
            onTap: () => _go(context, '/mapeo'),
          ),
          ListTile(
            leading: const Icon(Icons.agriculture),
            title: const Text('Siembras'),
            onTap: () => _go(context, '/siembras'),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('POS'),
            onTap: () => _go(context, '/pos'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Panel de control'),
            onTap: () => _go(context, '/panel'),
          ),
        ],
      ),
    );
  }
}
