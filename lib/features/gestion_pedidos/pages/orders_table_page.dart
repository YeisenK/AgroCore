import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';
import '../../../app/data/auth/auth_controller.dart';
import 'create_order_page.dart';
import 'edit_order_page.dart';
import '../widgets/order_table_row.dart';
import '../../../app/core/widgets/app_shell.dart';

class OrdersTablePage extends StatefulWidget {
  const OrdersTablePage({super.key});

  @override
  State<OrdersTablePage> createState() => _OrdersTablePageState();
}

class _OrdersTablePageState extends State<OrdersTablePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pedido #${order.id}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem('Cliente', order.customer, Icons.person),
              _buildDetailItem('Cultivo', order.crop, Icons.eco),
              _buildDetailItem('Variedad', order.variety, Icons.category),
              _buildDetailItem('Cantidad', '${order.quantity} ${order.unit}', Icons.scale),
              _buildDetailItem('Entrega', _formatDate(order.deliveryDate), Icons.calendar_today),
              _buildStatusDetail('Estado', order.statusText, order.status.name),
              if (order.notes != null && order.notes!.isNotEmpty)
                _buildDetailItem('Notas', order.notes!, Icons.note),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cerrar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToEditOrder(order.id);
                    },
                    child: Text('Editar Pedido'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 18),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetail(String label, String value, String status) {
    final cs = Theme.of(context).colorScheme;
    Color statusColor = cs.primary;
    IconData statusIcon = Icons.pending;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  void _navigateToCreateOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateOrderPage()),
    );
  }

  void _navigateToEditOrder(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditOrderPage(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final cs = Theme.of(context).colorScheme;

    final canCreate = user!.isAdmin || user.isAgricultor || user.isPedidos;

    final content = Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surfaceContainerHighest,
                cs.surfaceContainerHighest,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: cs.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Gestión de Pedidos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Administra y realiza seguimiento de todos los pedidos del sistema',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Estadísticas
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatCard(
                context,
                'Total Pedidos',
                provider.orders.length.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                'Pendientes',
                // ignore: unrelated_type_equality_checks
                provider.orders.where((o) => o.status == 'pending').length.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                'Completados',
                // ignore: unrelated_type_equality_checks
                provider.orders.where((o) => o.status == 'completed').length.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                'Cancelados',
                // ignore: unrelated_type_equality_checks
                provider.orders.where((o) => o.status == 'cancelled').length.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ],
          ),
        ),

        // Contenido principal
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Header de tabla
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.surfaceContainerHighest,
                        cs.surfaceContainerHighest,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: const Row(
                    children: [
                      _TableHeader(text: 'ID', flex: 1),
                      _TableHeader(text: 'Cliente', flex: 2),
                      _TableHeader(text: 'Cultivo', flex: 1),
                      _TableHeader(text: 'Variedad', flex: 1),
                      _TableHeader(text: 'Cantidad', flex: 1),
                      _TableHeader(text: 'Entrega', flex: 1),
                      _TableHeader(text: 'Estado', flex: 1),
                      _TableHeader(text: '', flex: 1),
                    ],
                  ),
                ),

                // Lista de pedidos
                Expanded(
                  child: provider.loading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: cs.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Cargando pedidos...',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : provider.orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay pedidos registrados',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (canCreate)
                                    ElevatedButton(
                                      onPressed: _navigateToCreateOrder,
                                      child: Text('Crear Primer Pedido'),
                                    ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: ListView.builder(
                                itemCount: provider.orders.length,
                                itemBuilder: (_, index) {
                                  final order = provider.orders[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: OrderTableRow(
                                      order: order,
                                      onTap: () => _showOrderDetails(order),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),

        if (canCreate)
          Container(
            margin: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _navigateToCreateOrder,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Pedido'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
      ],
    );

    return AppShell(
      title: 'Gestión de Pedidos',
      body: content,
      actions: [
        if (canCreate)
          IconButton(
            tooltip: 'Volver a selección de usuario',
            icon: const Icon(Icons.switch_account),
            onPressed: () => context.go(auth.preferredHome()),
          ),
        if (canCreate)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateOrder,
            tooltip: 'Nuevo Pedido',
          ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;

  const _TableHeader({
    required this.text,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}