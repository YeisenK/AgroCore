import 'package:flutter/material.dart';
import 'panel_page.dart';

class AdminPanelHome extends StatelessWidget {
  const AdminPanelHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const PanelPage(
      title: 'Panel',
      actions: [],
      slivers: [
        // Pon aquí tus secciones del panel general
        SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }
}
