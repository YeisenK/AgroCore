import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/core/constants/routes.dart';
import '../notifiers/siembra_notifier.dart';
import '../repositories/mock_siembra_repository.dart';

class PanelSiembra extends StatelessWidget {
  const PanelSiembra({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SiembraNotifier(MockSiembraRepository()),
      child: MaterialApp(
        title: 'Gestión de Vivero',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.black,

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.blue,
          ),

          textTheme: const TextTheme(
            titleMedium: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(color: Colors.blue),
            bodySmall: TextStyle(color: Colors.blue),
          ),

          // Agregar estilo para el Drawer del AppShell
          drawerTheme: const DrawerThemeData(
            backgroundColor: Colors.black,
          ),
        ),

        onGenerateRoute: Routes.onGenerateRoute,
        initialRoute: Routes.siembraList,
      ),
    );
  }
}