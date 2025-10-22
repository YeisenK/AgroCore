import 'package:flutter/material.dart';

class AlertTile extends StatelessWidget {
  final Map<String, dynamic> alerta;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;
  final VoidCallback? onDelete;

  const AlertTile({
    super.key,
    required this.alerta,
    this.onTap,
    this.onResolve,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (alerta['nivel']) {
      case 'Alto':
        color = Colors.redAccent;
        icon = Icons.error;
        break;
      case 'Medio':
        color = Colors.orangeAccent;
        icon = Icons.warning;
        break;
      case 'Bajo':
        color = Colors.yellowAccent;
        icon = Icons.info;
        break;
      default:
        color = Colors.white;
        icon = Icons.help;
    }

    final isResolved = alerta['resuelta'] == true;

    return Card(
      color: isResolved ? const Color(0xFF2A402A) : const Color(0xFF402A2A),
      child: ListTile(
        leading: Icon(icon, color: isResolved ? Colors.green : color),
        title: Text(
          alerta['mensaje'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            decoration: isResolved ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          "Nivel: ${alerta["nivel"]} - ${alerta["fecha"]}",
          style: TextStyle(
            color: isResolved ? Colors.green : color,
            fontSize: 12,
            decoration: isResolved ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onResolve != null && !isResolved)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: onResolve,
                tooltip: 'Marcar como resuelta',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Eliminar alerta',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
