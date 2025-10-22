// app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../data/auth/auth_controller.dart';

// Páginas existentes
import '../../features/dashboard_agricultor/pages/agricultor_home_page.dart';
import '../../features/dashboard_ingeniero/pages/ingeniero_home_page.dart';
import '../../features/panel/pages/panel_page.dart';
import '../../features/login/login.dart';
import '../../features/misc/pages/splash_page.dart';
import '../../features/misc/pages/forbidden_page.dart';

// Mapeo (ajusta el import y el nombre del widget si difiere)
import '../../features/mapeo_plantulas/pages/plant_inventory_page.dart';

// Si no tienes aún páginas de Siembras/POS, dejo placeholders locales.
// Si YA las tienes, borra estas clases y cambia los imports.
class _SiembrasPage extends StatelessWidget {
  const _SiembrasPage();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Siembras (próximamente)')),
      );
}

class _PosPage extends StatelessWidget {
  const _PosPage();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('POS (próximamente)')),
      );
}

/// IMPORTANTE:
/// - createRouter recibe la MISMA instancia de AuthController
/// - refreshListenable: auth
/// - redirect usa `auth` directamente (no context.read)
GoRouter createRouter(
  GlobalKey<NavigatorState> key,
  AuthController auth,
) {
  return GoRouter(
    navigatorKey: key,
    initialLocation: '/splash',
    refreshListenable: auth, // 👈 evita dobles notifiers
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login',  builder: (_, __) => const LoginPage()),
      GoRoute(path: '/403',    builder: (_, __) => const ForbiddenPage()),

      // Dashboards
      GoRoute(
        path: '/dashboard/agricultor',
        builder: (_, __) => const AgricultorHomePage(),
      ),
      GoRoute(
        path: '/dashboard/ingeniero',
        builder: (_, __) => const IngenieroHomePage(),
      ),

      // Panel (admin / genérico)
      GoRoute(path: '/panel', builder: (_, __) => const PanelPage()),

      // Extras del drawer
      GoRoute(
        path: '/mapeo',
        builder: (_, __) => const PlantInventoryPage(), // ajusta si tu clase difiere
      ),
      GoRoute(
        path: '/siembras',
        builder: (_, __) => const _SiembrasPage(), // cambia por tu página real si ya existe
      ),
      GoRoute(
        path: '/pos',
        builder: (_, __) => const _PosPage(), // cambia por tu página real si ya existe
      ),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // 1) unknown/loading -> splash (sin loops)
      if (auth.status == AuthStatus.unknown || auth.status == AuthStatus.loading) {
        return (loc == '/splash') ? null : '/splash';
      }

      // 2) no autenticado -> login
      if (auth.status == AuthStatus.unauthenticated) {
        return (loc == '/login') ? null : '/login';
      }

      // 3) autenticado: controla accesos por rol + home preferido
      if (auth.status == AuthStatus.authenticated) {
        if (loc == '/splash' || loc == '/login' || loc == '/') {
          return auth.preferredHome();
        }
        final u = auth.currentUser!;
        // Reglas por rol (ajusta a tu política):
        if (loc.startsWith('/dashboard/ingeniero') && !u.isIngeniero && !u.isAdmin) {
          return '/403';
        }
        if (loc.startsWith('/dashboard/agricultor') && !u.isAgricultor && !u.isAdmin) {
          return '/403';
        }
        // Mapeo visible para ingeniero y admin (cámbialo si quieres)
        if (loc.startsWith('/mapeo') && !(u.isIngeniero || u.isAdmin)) {
          return '/403';
        }
        // Siembras visible para agricultor y admin
        if (loc.startsWith('/siembras') && !(u.isAgricultor || u.isAdmin)) {
          return '/403';
        }
        // POS visible para admin (y si quieres: agricultor)
        if (loc.startsWith('/pos') && !u.isAdmin) {
          return '/403';
        }
        return null;
      }

      return null;
    },
  );
}
