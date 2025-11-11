import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Asegúrate de que las rutas a tus otros archivos sean correctas
import 'package:main/core/router/routes.dart';
import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/notifiers/siembra_notifier.dart';
import 'package:main/features/gestion_siembra/screens/siembra_form_screen.dart';

class SiembraListScreen extends StatelessWidget {
  const SiembraListScreen({super.key});

  /// Muestra el formulario de siembra (para crear o editar) en un diálogo modal.
  void _mostrarFormularioDialogo(
    BuildContext context, {
    SiembraModel? siembra,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(child: SiembraFormScreen(siembra: siembra));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el notifier aquí, en el widget padre
    final notifier = Provider.of<SiembraNotifier>(context);

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

                // --- ✅ AQUÍ ESTÁ LA CORRECCIÓN ---
                // Volvemos a pasar la función 'onDelete' al widget de la tarjeta.
                return _SiembraCard(
                  siembra: siembra,
                  onEdit: () =>
                      _mostrarFormularioDialogo(context, siembra: siembra),
                  onDelete: () => notifier.eliminarSiembra(
                    siembra.id,
                  ), // <-- Esta línea faltaba
                );
                // --- FIN DE LA CORRECCIÓN ---
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarFormularioDialogo(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Widget para cada tarjeta de la lista ---

class _SiembraCard extends StatelessWidget {
  final SiembraModel siembra;
  final VoidCallback onEdit;
  // --- ✅ CORRECCIÓN 1: Volvemos a añadir 'onDelete' al constructor ---
  final VoidCallback onDelete;

  const _SiembraCard({
    required this.siembra,
    required this.onEdit,
    required this.onDelete, // <-- Lo hacemos requerido
  });

  /// Muestra el diálogo de confirmación para eliminar
  // --- ✅ CORRECCIÓN 2: La función ahora recibe 'onDelete' ---
  Future<void> _mostrarDialogoConfirmacion(
    BuildContext context,
    VoidCallback onDeleteCallback,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar la siembra del lote \'${siembra.lote}\'?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDeleteCallback(); // <-- Llama al callback que recibimos
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Ya no necesitamos 'Provider.of' aquí, porque recibimos todo por el constructor

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
        title: Text(siembra.lote.toString(), style: textTheme.titleMedium),
        subtitle: Text(
          // Lógica para mostrar los cultivos
          '${siembra.detalles.isNotEmpty ? siembra.detalles.first.cultivo : "Sin cultivos"}\n'
          'Fecha: ${DateFormat('dd MMM yyyy', 'es_MX').format(siembra.fechaSiembra)}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String result) {
            if (result == 'editar') {
              onEdit(); // Llama al callback de editar
            } else if (result == 'eliminar') {
              // --- ✅ CORRECCIÓN 3: Pasamos la función 'onDelete' al diálogo ---
              _mostrarDialogoConfirmacion(context, onDelete);
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
