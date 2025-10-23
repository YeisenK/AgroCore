import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../validators/order_validator.dart';

class CreateOrderDialog extends StatefulWidget {
  const CreateOrderDialog({super.key});

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  final _customerController = TextEditingController();
  final _cropController = TextEditingController();
  final _varietyController = TextEditingController();
  final _quantityController = TextEditingController();

  OrderStatus _selectedStatus = OrderStatus.pending;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  bool _loading = false;

  @override
  void dispose() {
    _customerController.dispose();
    _cropController.dispose();
    _varietyController.dispose();
    _quantityController.dispose();
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
      final newOrder = OrderModel(
        id: _generateOrderId(),
        customer: _customerController.text.trim(),
        crop: _cropController.text.trim(),
        variety: _varietyController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: "unidades",
        orderDate: DateTime.now(),
        deliveryDate: _selectedDate,
        status: _selectedStatus,
      );

      await context.read<OrderProvider>().addOrder(newOrder);

      if (_selectedStatus == OrderStatus.shipped) {
        _showShippingAlert(newOrder);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear pedido: $e'),
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

  String _generateOrderId() {
    final provider = context.read<OrderProvider>();
    return provider.generateNextOrderId();
  }

  void _showShippingAlert(OrderModel order) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Preparar Envío',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'El pedido #${order.id} ha sido marcado como "Enviado". '
            'Por favor, preparar los documentos de envío.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Color(0xFF00CFC3)),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F1C2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 40), // NUEVO: Padding reducido
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500, // NUEVO: Ancho máximo reducido
          maxHeight: 600, // NUEVO: Alto máximo reducido
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20), // NUEVO: Padding interno reducido
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y botón cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nuevo pedido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // NUEVO: Tamaño de fuente reducido
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white,
                        size: 20), // NUEVO: Icono más pequeño
                    onPressed: _cancel,
                    padding: EdgeInsets.zero, // NUEVO: Sin padding
                    constraints:
                        const BoxConstraints(), // NUEVO: Sin constraints
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
                margin: const EdgeInsets.symmetric(
                    vertical: 12), // NUEVO: Margen reducido
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
          // Cliente
          _buildListField(
            controller: _customerController,
            label: 'Cliente',
            validator: OrderValidator.validateCustomer,
          ),
          const SizedBox(height: 12), // NUEVO: Espaciado reducido

          // Variedad de cultivo
          _buildListField(
            controller: _cropController,
            label: 'Variedad de cultivo',
            validator: OrderValidator.validateCrop,
          ),
          const SizedBox(height: 12), // NUEVO: Espaciado reducido

          // Variedad de plantulas
          _buildListField(
            controller: _varietyController,
            label: 'Variedad de plantulas',
            validator: OrderValidator.validateVariety,
          ),
          const SizedBox(height: 12), // NUEVO: Espaciado reducido

          // Cantidad
          _buildListField(
            controller: _quantityController,
            label: 'Cantidad',
            keyboardType: TextInputType.number,
            validator: OrderValidator.validateQuantity,
          ),
          const SizedBox(height: 12), // NUEVO: Espaciado reducido

          // Fecha de entrega
          _buildDateField(),
          const SizedBox(height: 12), // NUEVO: Espaciado reducido

          // Estado
          _buildStatusField(),
        ],
      ),
    );
  }

  Widget _buildListField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bullet point y label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point
            Container(
              margin: const EdgeInsets.only(
                  top: 6, right: 8), // NUEVO: Margen reducido
              width: 5, // NUEVO: Tamaño reducido
              height: 5, // NUEVO: Tamaño reducido
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            // Label
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, // NUEVO: Tamaño de fuente reducido
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6), // NUEVO: Espaciado reducido

        // Campo de texto
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              color: Colors.white, fontSize: 14), // NUEVO: Fuente reducida
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(6), // NUEVO: Border radius reducido
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, // NUEVO: Padding reducido
              vertical: 10, // NUEVO: Padding reducido
            ),
            errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 11), // NUEVO: Fuente de error reducida
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
        // Bullet point y label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point
            Container(
              margin: const EdgeInsets.only(
                  top: 6, right: 8), // NUEVO: Margen reducido
              width: 5, // NUEVO: Tamaño reducido
              height: 5, // NUEVO: Tamaño reducido
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            // Label
            const Text(
              'Fecha de entrega',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // NUEVO: Tamaño de fuente reducido
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6), // NUEVO: Espaciado reducido

        // Selector de fecha
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12), // NUEVO: Padding reducido
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius:
                  BorderRadius.circular(6), // NUEVO: Border radius reducido
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // NUEVO: Fuente reducida
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00CFC3),
                  size: 18, // NUEVO: Icono más pequeño
                ),
              ],
            ),
          ),
        ),

        // Mensaje de error de fecha
        if (OrderValidator.validateDeliveryDate(_selectedDate) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              OrderValidator.validateDeliveryDate(_selectedDate)!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11, // NUEVO: Fuente reducida
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
        // Bullet point y label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point
            Container(
              margin: const EdgeInsets.only(
                  top: 6, right: 8), // NUEVO: Margen reducido
              width: 5, // NUEVO: Tamaño reducido
              height: 5, // NUEVO: Tamaño reducido
              decoration: const BoxDecoration(
                color: Color(0xFF00CFC3),
                shape: BoxShape.circle,
              ),
            ),
            // Label
            const Text(
              'Estado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // NUEVO: Tamaño de fuente reducido
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6), // NUEVO: Espaciado reducido

        // Dropdown de estado
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 12), // NUEVO: Padding reducido
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius:
                BorderRadius.circular(6), // NUEVO: Border radius reducido
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
            style: const TextStyle(
                color: Colors.white, fontSize: 14), // NUEVO: Fuente reducida
            items: OrderStatus.values.map((OrderStatus status) {
              return DropdownMenuItem<OrderStatus>(
                value: status,
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14), // NUEVO: Fuente reducida
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
            height: 42, // NUEVO: Altura reducida
            child: OutlinedButton(
              onPressed: _loading ? null : _cancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6), // NUEVO: Border radius reducido
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14, // NUEVO: Fuente reducida
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12), // NUEVO: Espaciado reducido

        // Botón Ingresar
        Expanded(
          child: SizedBox(
            height: 42, // NUEVO: Altura reducida
            child: ElevatedButton(
              onPressed: _loading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFC3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6), // NUEVO: Border radius reducido
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 16, // NUEVO: Tamaño reducido
                      width: 16, // NUEVO: Tamaño reducido
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 14, // NUEVO: Fuente reducida
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
