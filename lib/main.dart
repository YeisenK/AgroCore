// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'app/data/auth/auth_repository.dart';
import 'app/data/auth/auth_controller.dart';
import 'app/router/app_router.dart';

// Estado del ingeniero
import 'features/dashboard_ingeniero/controllers/engineer_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgroCoreApp());
}

class AgroCoreApp extends StatefulWidget {
  const AgroCoreApp({super.key});
  @override
  State<AgroCoreApp> createState() => _AgroCoreAppState();
}

class _AgroCoreAppState extends State<AgroCoreApp> {
  // 🔑 Clave global para el Navigator (GoRouter)
  final _navKey = GlobalKey<NavigatorState>();

  // Instancias únicas compartidas
  late final AuthRepository _repo;
  late final AuthController _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // 1) Instancias únicas (ajusta tu baseUrl)
    _repo = AuthRepository(baseUrl: 'http://192.168.1.33');
    _auth = AuthController(_repo);

    // 2) Router recibiendo la MISMA instancia de AuthController
    _router = createRouter(_navKey, _auth);

    // 3) Arrancar auth (restaura/valida sesión)
    _auth.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Reutiliza las mismas instancias (no crees nuevas dentro del provider)
        Provider<AuthRepository>.value(value: _repo),
        ChangeNotifierProvider<AuthController>.value(value: _auth),

        // Estado del Ingeniero (independiente)
        ChangeNotifierProvider<EngineerState>(
          create: (_) {
            final s = EngineerState();
            s.bootstrap();
            return s;
          },
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
      ),
    );
  }
}
