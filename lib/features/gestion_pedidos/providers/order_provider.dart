import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  OrderRepository _repository;
  List<OrderModel> _orders = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _semillas = [];
  bool _loading = false;
  bool _loadingData = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  List<Map<String, dynamic>> get clientes => _clientes;
  List<Map<String, dynamic>> get semillas => _semillas;
  bool get loading => _loading;
  bool get loadingData => _loadingData;
  String? get error => _error;

  OrderProvider({String? authToken}) 
    : _repository = OrderRepository(authToken: authToken) {
    _loadInitialData();
  }

  // Método para actualizar el token
  void updateAuthToken(String token) {
    _repository.setAuthToken(token);
  }

  Future<void> _loadInitialData() async {
    _loadingData = true;
    notifyListeners();
    
    try {
      await Future.wait([
        loadOrders(),
        loadClientes(),
        loadSemillas(),
      ]);
    } catch (e) {
      _error = 'Error cargando datos iniciales: $e';
    } finally {
      _loadingData = false;
      notifyListeners();
    }
  }

  Future<void> loadClientes() async {
    try {
      _clientes = await _repository.getClientes();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar clientes: $e';
      _clientes = [];
    }
    notifyListeners();
  }

  Future<void> loadSemillas() async {
    try {
      _semillas = await _repository.getSemillas();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar semillas: $e';
      _semillas = [];
    }
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    
    try {
      _orders = await _repository.getOrders();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar pedidos: $e';
      _orders = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(OrderModel order) async {
    _loading = true;
    notifyListeners();
    
    try {
      await _repository.addOrder(order);
      _orders.insert(0, order);
      _error = null;
    } catch (e) {
      _error = 'Error al agregar pedido: $e';
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrder(OrderModel updatedOrder) async {
    _loading = true;
    notifyListeners();
    
    try {
      await _repository.updateOrder(updatedOrder);
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
        
        if (updatedOrder.status == OrderStatus.shipped) {
          _showShippingAlert(updatedOrder);
        }
        
        _error = null;
      }
    } catch (e) {
      _error = 'Error al actualizar pedido: $e';
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // CORREGIDO: Método searchOrders sin usar crop y variety
  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.customer.toLowerCase().contains(lowercaseQuery) ||
             order.id.toLowerCase().contains(lowercaseQuery) ||
             order.tipo.toLowerCase().contains(lowercaseQuery) ||
             (order.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<void> deleteOrder(String orderId) async {
    _loading = true;
    notifyListeners();
    
    try {
      await _repository.deleteOrder(orderId);
      _orders.removeWhere((order) => order.id == orderId);
      _error = null;
    } catch (e) {
      _error = 'Error al eliminar pedido: $e';
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _showShippingAlert(OrderModel order) {
    debugPrint('ALERTA: Preparar envío para el pedido ${order.id}');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  int get totalOrders => _orders.length;

  int getOrdersCountByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }

  // Método para generar ID local (compatibilidad)
  String generateNextOrderId() {
    if (_orders.isEmpty) return "1";
    final maxId = _orders.map((o) => int.tryParse(o.id) ?? 0)
                        .reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString();
  }

  // Método para crear un nuevo OrderModel con datos correctos
  OrderModel createNewOrder({
    required int idCliente,
    required String customer,
    required String tipo,
    required OrderStatus status,
    required double monto,
    double? volumen,
    DateTime? fechaEntrega,
    String? notes,
  }) {
    return OrderModel.createNew(
      id: '', // Se asignará cuando se guarde
      tenantId: 1, // Obtener del usuario autenticado
      idCliente: idCliente,
      customer: customer,
      tipo: tipo,
      status: status,
      monto: monto,
      volumen: volumen,
      fechaEntrega: fechaEntrega,
      creadoPor: 1, // Obtener del usuario autenticado
      notes: notes,
    );
  }

  // Método para recargar todos los datos
  Future<void> refreshAllData() async {
    _loadingData = true;
    notifyListeners();
    
    try {
      await Future.wait([
        loadOrders(),
        loadClientes(),
        loadSemillas(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Error al recargar datos: $e';
    } finally {
      _loadingData = false;
      notifyListeners();
    }
  }

  // Método para verificar conexión con el servidor
  Future<bool> checkServerConnection() async {
    try {
      return await _repository.checkServerConnection();
    } catch (e) {
      return false;
    }
  }

  // Método para obtener estadísticas
  Future<Map<String, dynamic>> getOrderStatistics() async {
    // Calcular estadísticas localmente
    final totalOrders = _orders.length;
    final pendingCount = _orders.where((o) => o.status == OrderStatus.pending).length;
    final inProcessCount = _orders.where((o) => o.status == OrderStatus.inProcess).length;
    final shippedCount = _orders.where((o) => o.status == OrderStatus.shipped).length;
    final deliveredCount = _orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledCount = _orders.where((o) => o.status == OrderStatus.cancelled).length;

    final totalAmount = _orders.fold(0.0, (sum, order) => sum + order.monto);
    final totalPendingAmount = _orders.fold(0.0, (sum, order) => sum + order.saldoPendiente);

    return {
      'totalOrders': totalOrders,
      'pendingCount': pendingCount,
      'inProcessCount': inProcessCount,
      'shippedCount': shippedCount,
      'deliveredCount': deliveredCount,
      'cancelledCount': cancelledCount,
      'totalAmount': totalAmount,
      'pendingAmount': totalPendingAmount,
      'averageAmount': totalOrders > 0 ? totalAmount / totalOrders : 0,
    };
  }
}