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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Siembras'),
            // ... (resto de tu AppBar) ...
          ),
          body: notifier.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: notifier.siembras.length,
                  itemBuilder: (context, index) {
                    final siembra = notifier.siembras[index];
                    return _SiembraCard(
                      siembra: siembra,
                    ); // Tu widget _SiembraCard
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navega al formulario en MODO CREACIÓN (sin argumentos)
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

  Future<void> _mostrarDialogoConfirmacion(
    BuildContext context,
    SiembraNotifier notifier,
  ) async {
    // ... (Tu código de diálogo de eliminación aquí) ...
  }

  // --- CAMBIO CONFIRMADO: Esta es la navegación de edición ---
  void _navegarAEditar(BuildContext context) {
    // Navega al formulario en MODO EDICIÓN
    Navigator.pushNamed(
      context,
      AppRoutes.siembraForm,
      arguments: siembra, // ¡Aquí se pasa la siembra que se va a editar!
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = Provider.of<SiembraNotifier>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          // ... (tu leading) ...
        ),
        title: Text(siembra.lote, style: textTheme.titleMedium),
        subtitle: Text(
          '${siembra.cultivo}\nFecha: ${DateFormat('dd MMM yyyy', 'es_MX').format(siembra.fechaSiembra)}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String result) {
            if (result == 'editar') {
              _navegarAEditar(context); // Llama a la navegación de edición
            } else if (result == 'eliminar') {
              _mostrarDialogoConfirmacion(context, notifier);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'editar',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Editar'),
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Eliminar'),
              ),
            ),
          ],
        ),
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
