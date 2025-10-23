import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _loading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  OrderProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _orders = [
      OrderModel(
        id: "AA01",
        customer: "Juanito Blas",
        crop: "Tomate",
        variety: "Selecto",
        quantity: 15.0,
        unit: "charolas",
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.delivered,
      ),
    ];
  }

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      _orders = await _repository.getOrders();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar pedidos: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      await _repository.addOrder(order);

      // Aplicar valores por defecto si están vacíos
      final orderWithDefaults = order.copyWith(
        unit: order.unit.isEmpty ? "unidades" : order.unit,
      );

      _orders.insert(0, orderWithDefaults);

      if (orderWithDefaults.status == OrderStatus.shipped) {
        _showShippingAlert(orderWithDefaults);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar pedido: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOrder(OrderModel updatedOrder) async {
    try {
      await _repository.updateOrder(updatedOrder);
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;

        if (updatedOrder.status == OrderStatus.shipped) {
          _showShippingAlert(updatedOrder);
        }

        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar pedido: $e';
      notifyListeners();
      rethrow;
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

  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.customer.toLowerCase().contains(lowercaseQuery) ||
          order.crop.toLowerCase().contains(lowercaseQuery) ||
          order.variety.toLowerCase().contains(lowercaseQuery) ||
          order.id.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _repository.deleteOrder(orderId);
      _orders.removeWhere((order) => order.id == orderId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar pedido: $e';
      notifyListeners();
      rethrow;
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

  // Métodos para estadísticas
  int get totalOrders => _orders.length;

  int getOrdersCountByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }

  // Método para generar próximo ID en formato AA01, AA02, etc.
  String generateNextOrderId() {
    if (_orders.isEmpty) {
      return "AA01";
    }

    // Extraer el número más alto de los IDs existentes
    int maxNumber = 0;
    for (var order in _orders) {
      if (order.id.startsWith('AA')) {
        try {
          final number = int.parse(order.id.substring(2));
          if (number > maxNumber) {
            maxNumber = number;
          }
        } catch (e) {
          // Si el formato no es correcto, continuar
        }
      }
    }

    return 'AA${(maxNumber + 1).toString().padLeft(2, '0')}';
  }
}
