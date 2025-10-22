import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> pedido;

  const OrderDetailPage({super.key, required this.pedido});

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

    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido #${pedido["id"].toString().substring(0, 8)}"),
        backgroundColor: const Color(0xFF12121D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(estadoIcon, color: estadoColor),
                  const SizedBox(width: 10),
                  Text("Estado: ${pedido["estado"]}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: estadoColor)),
                ]),
                const SizedBox(height: 20),
                _row('Cliente', pedido['cliente']),
                _row('Fecha de entrega', pedido['fecha']),
                _row('Productos', pedido['productos']),
                _row('Dirección', pedido['direccion']),
                _row('Total', pedido['total']),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Acciones:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Función de edición en desarrollo'))),
              label: const Text('Editar Pedido'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Pedido marcado como entregado'))),
              label: const Text('Marcar Entregado'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text(value)),
      ]),
    );
  }
}
