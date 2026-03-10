import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/core/constants/routes.dart';
import '../../../app/core/widgets/app_shell.dart';
import '../../../app/data/auth/auth_controller.dart'; // Importar AuthController
import '../models/siembra_model.dart';
import '../notifiers/siembra_notifier.dart';
import '../screens/siembra_form_screen.dart';

class SiembraListScreen extends StatelessWidget {
  const SiembraListScreen({super.key});

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
    final notifier = Provider.of<SiembraNotifier>(context);
    final auth = context.watch<AuthController>(); // Obtener AuthController

    // Contenido de la página
    final content = notifier.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: notifier.siembras.length,
            itemBuilder: (context, index) {
              final siembra = notifier.siembras[index];

              return _SiembraCard(
                siembra: siembra,
                onEdit: () =>
                    _mostrarFormularioDialogo(context, siembra: siembra),
                onDelete: () => notifier.eliminarSiembra(siembra.id),
              );
            },
          );

    // Usar AppShell
    return AppShell(
      title: 'Gestión de Siembras',
      body: content,
      actions: [
        IconButton(
          tooltip: 'Volver a selección de usuario',
          icon: const Icon(Icons.switch_account),
          onPressed: () => context.go(auth.preferredHome()),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _mostrarFormularioDialogo(context),
          tooltip: 'Nueva Siembra',
        ),
      ],
    );
  }
}

class _SiembraCard extends StatelessWidget {
  final SiembraModel siembra;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SiembraCard({
    required this.siembra,
    required this.onEdit,
    required this.onDelete,
  });

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
            Routes.siembraDetail,
            arguments: siembra,
          );
        },
      ),
    );
  }
}