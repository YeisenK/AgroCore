import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SiembraUIData {
  final String lote;
  final String cultivo;
  final String responsable;
  final DateTime fechaSiembra;

  SiembraUIData({
    required this.lote,
    required this.cultivo,
    required this.responsable,
    required this.fechaSiembra,
  });
}

void main() async {
  await initializeDateFormatting('es_MX', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Vivero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SiembraListScreen(),
    );
  }
}

class SiembraListScreen extends StatelessWidget {
  const SiembraListScreen({super.key});

  static final List<SiembraUIData> _mockSiembras = [
    SiembraUIData(
      lote: 'JT-SAL-001',
      cultivo: 'Jitomate Saladette',
      responsable: 'Ana Torres',
      fechaSiembra: DateTime(2025, 9, 15),
    ),
    SiembraUIData(
      lote: 'CH-AG-002',
      cultivo: 'Chile de Agua',
      responsable: 'Carlos Vega',
      fechaSiembra: DateTime(2025, 9, 20),
    ),
    SiembraUIData(
      lote: 'TM-VER-003',
      cultivo: 'Tomate Verde',
      responsable: 'Ana Torres',
      fechaSiembra: DateTime(2025, 9, 21),
    ),
    SiembraUIData(
      lote: 'CB-BLA-004',
      cultivo: 'Cebolla Blanca',
      responsable: 'Laura Cruz',
      fechaSiembra: DateTime(2025, 9, 22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Siembras'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _mockSiembras.length,
        itemBuilder: (context, index) {
          return _SiembraCard(siembra: _mockSiembras[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Añadir Siembra',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SiembraCard extends StatelessWidget {
  final SiembraUIData siembra;

  const _SiembraCard({required this.siembra});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            Icons.eco_rounded,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(siembra.lote, style: textTheme.titleMedium),
        subtitle: Text(
          '${siembra.cultivo}\nResponsable: ${siembra.responsable}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          DateFormat('dd MMM yyyy', 'es_MX').format(siembra.fechaSiembra),
          style: textTheme.bodySmall,
        ),
        isThreeLine: true,
        onTap: () {},
      ),
    );
  }
}
