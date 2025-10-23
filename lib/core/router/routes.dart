import 'package:flutter/material.dart';

// Asegúrate de que las rutas a tus archivos sean correctas
import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/screens/siembra_list_screen.dart';
import 'package:main/features/gestion_siembra/screens/siembra_detail_screen.dart';
import 'package:main/features/gestion_siembra/screens/siembra_form_screen.dart';

class AppRoutes {
  static const String siembraList = '/';
  static const String siembraDetail = '/siembra-detail';
  static const String siembraForm = '/siembra-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case siembraList:
        return MaterialPageRoute(builder: (_) => const SiembraListScreen());

      case siembraDetail:
        // La pantalla de detalle recibe una siembra (esto ya lo tenías)
        final siembra = settings.arguments as SiembraModel;
        return MaterialPageRoute(
          builder: (_) => SiembraDetailScreen(siembra: siembra),
        );

      // --- AQUÍ ESTÁ EL CAMBIO IMPORTANTE ---
      case siembraForm:
        // 1. Extraemos los argumentos.
        //    Puede ser un SiembraModel (Modo Edición) o null (Modo Creación).
        final siembra = settings.arguments as SiembraModel?;

        return MaterialPageRoute(
          builder: (context) => SiembraFormScreen(
            // 2. Pasamos la siembra (o null) al constructor del formulario.
            siembra: siembra,
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SiembraListScreen());
    }
  }
}
