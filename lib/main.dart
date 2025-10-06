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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.siembraList,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
