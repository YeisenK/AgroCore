import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Rutas de paquete corregidas
import 'package:main/core/router/routes.dart';
import 'package:main/features/gestion_siembra/notifiers/siembra_notifier.dart';
import 'package:main/features/gestion_siembra/repositories/mock_siembra_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SiembraNotifier(MockSiembraRepository()),
      child: MaterialApp(
        title: 'Gestión de Vivero',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,

        // 2. Definimos cómo se ve nuestro tema oscuro
        darkTheme: ThemeData(
          brightness: Brightness.dark, // Importante para el modo oscuro
          useMaterial3: true,

          // Fondo de la app (scaffold)
          scaffoldBackgroundColor: Colors.black,

          // Paleta de colores basada en azul
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),

          // Apariencia del AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black, // Fondo del AppBar
            foregroundColor: Colors.blue, // Título (letras) del AppBar
          ),

          // Apariencia del texto
          textTheme: const TextTheme(
            // Para el título del ListTile (ej: "Lote A-101")
            titleMedium: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            // Para el subtítulo (ej: "Maíz")
            bodyMedium: TextStyle(color: Colors.blue),
            // Para el texto pequeño (ej: la fecha)
            bodySmall: TextStyle(color: Colors.blue),
          ),
        ),

        // 3. Le decimos cuál es la pantalla de inicio

        // 4. Le decimos cómo manejar las rutas (esto ya lo tenías)
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.siembraList,
      ),
    );
  }
}
