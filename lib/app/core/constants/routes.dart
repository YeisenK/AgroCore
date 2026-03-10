import 'package:flutter/material.dart';

import '../../../features/gestion_siembra/models/siembra_model.dart';
import '../../../features/gestion_siembra/screens/siembra_list_screen.dart';
import '../../../features/gestion_siembra/screens/siembra_detail_screen.dart';
import '../../../features/gestion_siembra/screens/siembra_form_screen.dart';

class Routes {
  static const splash     = '/splash';
  static const login      = '/login';
  static const ingeniero  = '/ingeniero';
  static const agricultor = '/agricultor';
  static const panel      = '/panel';
  static const mapeo      = '/mapeo';
  static const siembras   = '/siembras';
  static const pos        = '/pos';
  static const forbidden  = '/403';

  static const String siembraList   = '/';
  static const String siembraDetail = '/siembra-detail';
  static const String siembraForm   = '/siembra-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case siembraList:
        return MaterialPageRoute(builder: (_) => SiembraListScreen());

      case siembraDetail:
        final siembra = settings.arguments as SiembraModel;
        return MaterialPageRoute(
          builder: (_) => SiembraDetailScreen(siembra: siembra),
        );

      case siembraForm:
        final siembra = settings.arguments as SiembraModel?;
        return MaterialPageRoute(
          builder: (_) => SiembraFormScreen(siembra: siembra),
        );

      default:
        return MaterialPageRoute(builder: (_) => SiembraListScreen());
    }
  }
}
