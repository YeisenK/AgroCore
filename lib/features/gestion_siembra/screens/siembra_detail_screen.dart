import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

// Ruta de paquete corregida
import 'package:main/features/gestion_siembra/models/siembra_model.dart';

class SiembraDetailScreen extends StatelessWidget {
  final SiembraModel siembra;
  const SiembraDetailScreen({super.key, required this.siembra});

  void _exportarJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(siembra.toJson());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Lote a JSON'),
        content: SingleChildScrollView(child: Text(jsonString)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(siembra.lote),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () => _exportarJson(context),
            tooltip: 'Exportar a JSON',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailRow('Cultivo:', siembra.cultivo),
          _buildDetailRow('Responsable:', siembra.responsable),
          _buildDetailRow('Especificación:', siembra.especificacion.toString()),
          _buildDetailRow('Tipo de Riego:', siembra.tipoRiego),
          const SizedBox(height: 24),
          Text(
            'Línea de Tiempo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildTimelineEvent(
            context,
            title: 'Siembra Iniciada',
            subtitle: 'Lote registrado en el sistema.',
            date: siembra.fechaSiembra,
            isFirst: true,
          ),
          _buildTimelineEvent(
            context,
            title: 'Primer Riego Aplicado',
            subtitle: 'Riego inicial post-siembra.',
            date: siembra.fechaSiembra.add(const Duration(days: 1)),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(
    BuildContext context, {
    required String title,
    required String subtitle,
    required DateTime date,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(color: Theme.of(context).colorScheme.primary),
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: Theme.of(context).colorScheme.primary,
        iconStyle: IconStyle(iconData: Icons.check_circle, color: Colors.white),
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMMM yyyy', 'es_MX').format(date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
