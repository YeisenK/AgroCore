import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../validators/order_validator.dart';

class EditOrderDialog extends StatefulWidget {
  final String orderId;

  const EditOrderDialog({super.key, required this.orderId});

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _customerController;
  late TextEditingController _cropController;
  late TextEditingController _varietyController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  late OrderStatus _selectedStatus;
  late DateTime _selectedDate;

  bool _loading = false;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  void _loadOrderData() {
    final order = context.read<OrderProvider>().getOrderById(widget.orderId);
    if (order != null) {
      setState(() {
        _order = order;
        _customerController = TextEditingController(text: order.customer);
        _cropController = TextEditingController(text: order.crop);
        _varietyController = TextEditingController(text: order.variety);
        _quantityController =
            TextEditingController(text: order.quantity.toString());
        _notesController = TextEditingController(text: order.notes ?? '');
        _selectedStatus = order.status;
        _selectedDate = order.deliveryDate;
      });
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _cropController.dispose();
    _varietyController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_order == null) return;

    final dateError = OrderValidator.validateDeliveryDate(_selectedDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final updatedOrder = _order!.copyWith(
        customer: _customerController.text.trim(),
        crop: _cropController.text.trim(),
        variety: _varietyController.text.trim(),
        quantity: double.parse(_quantityController.text),
        deliveryDate: _selectedDate,
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await context.read<OrderProvider>().updateOrder(updatedOrder);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _deleteOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Eliminar Pedido',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar el pedido #${_order?.id}?',
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

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Dialog(
        backgroundColor: const Color(0xFF0F1C2E),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF00CFC3),
              ),
              const SizedBox(height: 12),
              Text(
                'Cargando pedido...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: const Color(0xFF0F1C2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 650,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y botón cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar #${_order!.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: _cancel,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Lista de campos
              _buildFieldList(),
              const SizedBox(height: 16),

              // Línea divisoria
              Container(
                height: 1,
                color: Colors.grey[700],
                margin: const EdgeInsets.symmetric(vertical: 12),
              ),

              // Botones
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldList() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ID (solo lectura)
          _buildReadOnlyField(
            label: 'ID del Pedido',
            value: _order!.id,
          ),
          const SizedBox(height: 12),

          // Cliente
          _buildListField(
            controller: _customerController,
            label: 'Cliente',
            validator: OrderValidator.validateCustomer,
          ),
          const SizedBox(height: 12),

          // Variedad de cultivo
          _buildListField(
            controller: _cropController,
            label: 'Variedad de cultivo',
            validator: OrderValidator.validateCrop,
          ),
          const SizedBox(height: 12),

          // Variedad de plantulas
          _buildListField(
            controller: _varietyController,
            label: 'Variedad de plantulas',
            validator: OrderValidator.validateVariety,
          ),
          const SizedBox(height: 12),

          // Cantidad
          _buildListField(
            controller: _quantityController,
            label: 'Cantidad',
            keyboardType: TextInputType.number,
            validator: OrderValidator.validateQuantity,
          ),
          const SizedBox(height: 12),

          // Fecha de entrega
          _buildDateField(),
          const SizedBox(height: 12),

          // Estado
          _buildStatusField(),
          const SizedBox(height: 12),

          // Notas (opcional)
          _buildListField(
            controller: _notesController,
            label: 'Notas (opcional)',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[800],
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildListField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            errorStyle: const TextStyle(color: Colors.red, fontSize: 11),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              'Fecha de entrega',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00CFC3),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (OrderValidator.validateDeliveryDate(_selectedDate) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              OrderValidator.validateDeliveryDate(_selectedDate)!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              'Estado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<OrderStatus>(
            value: _selectedStatus,
            onChanged: (OrderStatus? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStatus = newValue;
                });
              }
            },
            dropdownColor: Colors.grey[800],
            underline: const SizedBox(),
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: OrderStatus.values.map((OrderStatus status) {
              return DropdownMenuItem<OrderStatus>(
                value: status,
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.inProcess:
        return 'En Proceso';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botón Cancelar
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: _loading ? null : _cancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Actualizar
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFC3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Actualizar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
