import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../validators/order_validator.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();
  
  int? _selectedClienteId;
  String? _selectedClienteNombre;
  int? _selectedSemillaId;
  // ignore: unused_field
  String? _selectedSemillaNombre;
  // ignore: unused_field
  String? _selectedSemillaVariedad;
  double? _selectedSemillaPrecio;
  
  OrderStatus _selectedStatus = OrderStatus.pending;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  
  bool _loading = false;
  bool _expandedNotes = false;
  bool _loadingData = true;

  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _semillas = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final orderProvider = context.read<OrderProvider>();
      await orderProvider.loadClientes();
      await orderProvider.loadSemillas();
      
      setState(() {
        _clientes = orderProvider.clientes;
        _semillas = orderProvider.semillas;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      _showErrorSnackBar('Error cargando datos: $e');
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF20A79A),
              onPrimary: Colors.black,
              surface: Color(0xFF1C2428),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1C2428)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClienteId == null) {
      _showErrorSnackBar('Por favor seleccione un cliente');
      return;
    }

    if (_selectedSemillaId == null) {
      _showErrorSnackBar('Por favor seleccione un cultivo');
      return;
    }

    final dateError = OrderValidator.validateDeliveryDate(_selectedDate);
    if (dateError != null) {
      _showErrorSnackBar(dateError);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      
      final newOrder = orderProvider.createNewOrder(
        idCliente: _selectedClienteId!,
        customer: _selectedClienteNombre!,
        tipo: 'venta',
        status: _selectedStatus,
        monto: double.parse(_priceController.text),
        volumen: double.tryParse(_quantityController.text),
        fechaEntrega: _selectedDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      await orderProvider.addOrder(newOrder);
      _showSuccessSnackBar();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Error al crear pedido: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Pedido creado exitosamente'),
          ],
        ),
        backgroundColor: const Color(0xFF6DBF63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFCC4F4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13181C),
      body: Column(
        children: [
          _buildAppBar(),
          
          Expanded(
            child: _loadingData 
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        
                        _buildForm(),
                        const SizedBox(height: 32),
                        
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2428),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 16, left: 24, right: 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD3D9DE), size: 24),
            onPressed: _cancel,
          ),
          const SizedBox(width: 12),
          const Text(
            'Nuevo Pedido',
            style: TextStyle(
              color: Color(0xFFD3D9DE),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF20A79A),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crear Nuevo Pedido',
          style: TextStyle(
            color: const Color(0xFFD3D9DE),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete la información del pedido a continuación',
          style: TextStyle(
            color: const Color(0xFFB9C3C9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Información básica
          _buildSectionHeader(
            icon: Icons.description,
            title: 'Información del Pedido',
          ),
          const SizedBox(height: 20),
          
          // Selección de Cliente
          _buildClienteField(),
          const SizedBox(height: 16),
          
          // Selección de Cultivo/Variedad
          _buildSemillaField(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _quantityController,
                  label: 'Cantidad *',
                  hintText: '0.000',
                  icon: Icons.scale,
                  keyboardType: TextInputType.number,
                  validator: OrderValidator.validateQuantity,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildTextField(
                  controller: _unitController,
                  label: 'Unidad',
                  hintText: 'kg',
                  icon: Icons.square_foot,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _priceController,
            label: 'Precio Unitario *',
            hintText: '0.00',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          
          // Fecha y Estado
          _buildSectionHeader(
            icon: Icons.schedule,
            title: 'Programación y Estado',
          ),
          const SizedBox(height: 20),
          
          _buildDateField(),
          const SizedBox(height: 16),
          
          _buildStatusField(),
          const SizedBox(height: 32),
          
          // Notas (expandible)
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF20A79A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF20A79A), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD3D9DE),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildClienteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cliente *',
          style: TextStyle(
            color: const Color(0xFFD3D9DE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C2428),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF39464D)),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedClienteId,
            onChanged: (int? newValue) {
              setState(() {
                _selectedClienteId = newValue;
                if (newValue != null) {
                  final cliente = _clientes.firstWhere(
                    (c) => c['id_cliente'] == newValue,
                    orElse: () => {'nombre_completo': 'Cliente no encontrado'}
                  );
                  _selectedClienteNombre = cliente['nombre_completo'];
                }
              });
            },
            dropdownColor: const Color(0xFF1C2428),
            style: const TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: const Color(0xFF20A79A)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Seleccione un cliente',
              hintStyle: TextStyle(color: const Color(0xFFB9C3C9)),
            ),
            items: _clientes.map((cliente) {
              return DropdownMenuItem<int>(
                value: cliente['id_cliente'] as int,
                child: Text(
                  cliente['nombre_completo'],
                  style: const TextStyle(color: Color(0xFFD3D9DE)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSemillaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cultivo/Variedad *',
          style: TextStyle(
            color: const Color(0xFFD3D9DE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C2428),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF39464D)),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedSemillaId,
            onChanged: (int? newValue) {
              setState(() {
                _selectedSemillaId = newValue;
                if (newValue != null) {
                  final semilla = _semillas.firstWhere(
                    (s) => s['id_semilla'] == newValue,
                    orElse: () => {
                      'nombre': 'No encontrado',
                      'variedad': 'Sin variedad',
                      'precio_unitario': 0.0
                    }
                  );
                  _selectedSemillaNombre = semilla['nombre'];
                  _selectedSemillaVariedad = semilla['variedad'];
                  _selectedSemillaPrecio = (semilla['precio_unitario'] as num).toDouble();
                  
                  // Auto-completar el precio si está disponible
                  if (_selectedSemillaPrecio != null && _selectedSemillaPrecio! > 0) {
                    _priceController.text = _selectedSemillaPrecio!.toStringAsFixed(2);
                  }
                }
              });
            },
            dropdownColor: const Color(0xFF1C2428),
            style: const TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.eco, color: const Color(0xFF20A79A)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Seleccione cultivo y variedad',
              hintStyle: TextStyle(color: const Color(0xFFB9C3C9)),
            ),
            items: _semillas.map((semilla) {
              return DropdownMenuItem<int>(
                value: semilla['id_semilla'] as int,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      semilla['nombre'],
                      style: const TextStyle(
                        color: Color(0xFFD3D9DE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      semilla['variedad'] ?? 'Sin variedad',
                      style: TextStyle(
                        color: const Color(0xFFB9C3C9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFD3D9DE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: const Color(0xFFB9C3C9)),
            prefixIcon: Icon(icon, color: const Color(0xFF20A79A)),
            filled: true,
            fillColor: const Color(0xFF1C2428),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF39464D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF39464D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF20A79A), width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCC4F4F), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        Text(
          'Fecha de Entrega *',
          style: TextStyle(
            color: const Color(0xFFD3D9DE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2428),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF39464D)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFF20A79A)),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'Seleccionar',
                  style: TextStyle(
                    color: const Color(0xFFB9C3C9),
                    fontSize: 14,
                  ),
                ),
              ],
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
        Text(
          'Estado del Pedido *',
          style: TextStyle(
            color: const Color(0xFFD3D9DE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C2428),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF39464D)),
          ),
          child: DropdownButtonFormField<OrderStatus>(
            initialValue: _selectedStatus,
            onChanged: (OrderStatus? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStatus = newValue;
                });
              }
            },
            dropdownColor: const Color(0xFF1C2428),
            style: const TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.info_outline, color: const Color(0xFF20A79A)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: OrderStatus.values.map((OrderStatus status) {
              return DropdownMenuItem<OrderStatus>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      status.displayText,
                      style: const TextStyle(color: Color(0xFFD3D9DE)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedNotes = !_expandedNotes;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2428),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF39464D)),
            ),
            child: Row(
              children: [
                Icon(Icons.notes, color: const Color(0xFF20A79A)),
                const SizedBox(width: 12),
                const Text(
                  'Notas Adicionales',
                  style: TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
                ),
                const Spacer(),
                Icon(
                  _expandedNotes ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF20A79A),
                ),
              ],
            ),
          ),
        ),
        if (_expandedNotes) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            style: const TextStyle(color: Color(0xFFD3D9DE), fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Agregue notas adicionales sobre el pedido...',
              hintStyle: TextStyle(color: const Color(0xFFB9C3C9)),
              filled: true,
              fillColor: const Color(0xFF1C2428),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF39464D)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _loading ? null : _cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD3D9DE),
                side: const BorderSide(color: Color(0xFF39464D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8F86),
                foregroundColor: const Color(0xFFDDE6E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFDDE6E6),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CREAR PEDIDO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return status.displayColor;
  }

  // ignore: unused_element
  String _getStatusText(OrderStatus status) {
    return status.displayText;
  }
}