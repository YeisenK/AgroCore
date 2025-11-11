// lib/features/gestion_siembra/screens/siembra_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

// Asegúrate de que la ruta a tu modelo sea correcta
import 'package:main/features/gestion_siembra/models/siembra_model.dart';

class SiembraDetailScreen extends StatelessWidget {
  final SiembraModel siembra;
  const SiembraDetailScreen({super.key, required this.siembra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- CORRECCIÓN 1: Convertir el 'lote' (int) a String ---
        title: Text('Lote: ${siembra.lote.toString()}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECCIÓN 1: Detalles Generales ---
          Text(
            'Información General',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Responsable:', siembra.responsable),
          _buildDetailRow('Tipo de Riego:', siembra.tipoRiego),
          _buildDetailRow(
            'Fecha de Siembra:',
            DateFormat('dd MMM yyyy', 'es_MX').format(siembra.fechaSiembra),
          ),

          const Divider(height: 32),

          // --- SECCIÓN 2: Lista de Cultivos (Detalles) ---
          Text(
            'Cultivos en este Lote',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (siembra.detalles.isEmpty)
            const Text('No hay cultivos registrados en este lote.')
          else
            // Creamos una mini-lista con los detalles
            Column(
              children: siembra.detalles.map((detalle) {
                return Card(
                  elevation: 0,
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  child: ListTile(
                    title: Text(
                      detalle.cultivo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(detalle.especificacion),
                    trailing: Text(
                      'Cant: ${detalle.cantidad}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              }).toList(),
            ),

          const Divider(height: 32),

          // --- SECCIÓN 3: Línea de Tiempo (usando datos reales) ---
          Text(
            'Línea de Tiempo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (siembra.timeline.isEmpty)
            const Text('No hay eventos en la línea de tiempo.')
          else
            Column(
              children: siembra.timeline.asMap().entries.map((entry) {
                int idx = entry.key;
                TimelineEvent evento = entry.value;
                return _buildTimelineEvent(
                  context,
                  title: evento.titulo,
                  subtitle: evento.descripcion,
                  date: evento.fecha,
                  isFirst: idx == 0,
                  isLast: idx == siembra.timeline.length - 1,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Widget de ayuda para mostrar filas de detalle (Label: Value)
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

  /// Widget de ayuda para dibujar cada evento de la línea de tiempo
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
              DateFormat('dd MMM yyyy, h:mm a', 'es_MX').format(date),
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
