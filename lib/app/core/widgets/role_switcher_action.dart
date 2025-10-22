import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSwitcherAction extends StatelessWidget {
  final List<String> roles;
  const RoleSwitcherAction({super.key, required this.roles});

  String _label(String r) {
    switch (r) {
      case 'ingeniero': return 'Ingeniero';
      case 'agricultor': return 'Agricultor';
      case 'admin': return 'Panel';
      default: return r;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Cambiar usuario',
      icon: const Icon(Icons.switch_account),
      itemBuilder: (ctx) => [
        for (final r in roles) PopupMenuItem(value: r, child: Text(_label(r))),
      ],
      onSelected: (r) {
        switch (r) {
          case 'ingeniero': context.go('/dashboard/ingeniero'); break;
          case 'agricultor': context.go('/dashboard/agricultor'); break;
          case 'admin': context.go('/panel'); break;
          default: break;
        }
      },
    );
  }
}
