import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../pages/edit_order_page.dart';

class OrderTableRow extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderTableRow({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () {
        _showQuickActions(context, order);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: const Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              // ID
              _buildCell(order.id, 1),
              // Cliente
              _buildCell(order.customer, 2),
              // Cultivo
              _buildCell(order.crop, 1),
              // Variedad
              _buildCell(order.variety, 1),
              // Cantidad
              _buildCell('${order.quantity} ${order.unit}', 1),
              // Fecha de entrega (NUEVA COLUMNA)
              _buildDateCell(),
              // Estado
              _buildStatusCell(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateCell() {
    return Expanded(
      flex: 1,
      child: Text(
        _formatDate(order.deliveryDate),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: order.statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: order.statusColor),
        ),
        child: Text(
          order.statusText,
          style: TextStyle(
            color: order.statusColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showQuickActions(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pedido #${order.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Entrega: ${_formatDate(order.deliveryDate)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF00CFC3)),
              title: const Text(
                'Editar Pedido',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToEdit(context, order.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy, color: Colors.blue),
              title: const Text(
                'Duplicar Pedido',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _duplicateOrder(context, order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar Pedido',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, order);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderPage(orderId: orderId),
      ),
    );
  }

  void _duplicateOrder(BuildContext context, OrderModel order) {
    // TODO: Implementar duplicación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de duplicar - Próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Eliminar Pedido',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar el pedido #${order.id}?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad de eliminar - Próximamente'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
