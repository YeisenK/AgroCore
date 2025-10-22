import 'package:flutter/material.dart';
import '../../../app/core/widgets/app_shell.dart';

/// Contenedor de página de panel reutilizable.
/// Envía tus slivers (secciones) y acciones del AppBar.
/// Úsalo en Ingeniero, Agricultor, Admin, etc.
class PanelPage extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final List<Widget> slivers;
  final EdgeInsetsGeometry? padding;

  const PanelPage({
    super.key,
    required this.title,
    required this.actions,
    required this.slivers,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: title,
      actions: actions,
      body: LayoutBuilder(
        builder: (context, c) {
          final isMobile = c.maxWidth < 600;
          final pad = padding ?? EdgeInsets.all(isMobile ? 12 : 16);
          return Padding(
            padding: pad,
            child: CustomScrollView(slivers: slivers),
          );
        },
      ),
    );
  }
}
