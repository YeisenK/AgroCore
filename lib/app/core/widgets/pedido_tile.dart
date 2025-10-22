import 'package:flutter/material.dart';

class PedidoTile extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final VoidCallback? onTap;

  const PedidoTile({super.key, required this.pedido, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color estadoColor;
    IconData estadoIcon;

    switch (pedido['estado']) {
      case 'Programado':
        estadoColor = Colors.blue;
        estadoIcon = Icons.schedule;
        break;
      case 'Preparando':
        estadoColor = Colors.orange;
        estadoIcon = Icons.build;
        break;
      case 'En camino':
        estadoColor = Colors.green;
        estadoIcon = Icons.local_shipping;
        break;
      case 'Entregado':
        estadoColor = Colors.grey;
        estadoIcon = Icons.check_circle;
        break;
      default:
        estadoColor = Colors.white;
        estadoIcon = Icons.help;
    }

    return Card(
      child: ListTile(
        leading: Icon(estadoIcon, color: estadoColor),
        title: Text(pedido['cliente']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Entrega: ${pedido["fecha"]}"),
            Text(pedido['productos'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pedido['total'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent)),
            const SizedBox(height: 4),
            Text(pedido['estado'], style: TextStyle(color: estadoColor, fontSize: 12)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
