import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:main/core/router/routes.dart';
import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/notifiers/siembra_notifier.dart';

class SiembraListScreen extends StatelessWidget {
  const SiembraListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SiembraNotifier>(
      builder: (context, notifier, child) {
        print(
          '🎨 [UI] El Consumer se reconstruyó. Cargando: ${notifier.isLoading}, Items: ${notifier.siembras.length}',
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Siembras'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: notifier.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: notifier.siembras.length,
                  itemBuilder: (context, index) {
                    final siembra = notifier.siembras[index];
                    return _SiembraCard(siembra: siembra);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.siembraForm);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _SiembraCard extends StatelessWidget {
  final SiembraModel siembra;
  const _SiembraCard({required this.siembra});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          '${siembra.cultivo} - ${siembra.especificacion}\nResponsable: ${siembra.responsable}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          DateFormat('dd MMM yyyy', 'es_MX').format(siembra.fechaSiembra),
          style: textTheme.bodySmall,
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.siembraDetail,
            arguments: siembra,
          );
        },
      ),
    );
  }
}
