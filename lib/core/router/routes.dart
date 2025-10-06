import 'package:flutter/material.dart';

// Rutas de paquete corregidas
import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/screens/siembra_detail_screen.dart';
import 'package:main/features/gestion_siembra/screens/siembra_form_screen.dart';
import 'package:main/features/gestion_siembra/screens/siembra_list_screen.dart';

class AppRoutes {
  static const String siembraList = '/';
  static const String siembraForm = '/siembra-form';
  static const String siembraDetail = '/siembra-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case siembraList:
        return MaterialPageRoute(builder: (_) => const SiembraListScreen());

      case siembraForm:
        return MaterialPageRoute(builder: (_) => const SiembraFormScreen());

      case siembraDetail:
        final siembra = settings.arguments as SiembraModel;
        return MaterialPageRoute(
          builder: (_) => SiembraDetailScreen(siembra: siembra),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Error: Ruta no encontrada')),
          ),
        );
    }
  }
}
