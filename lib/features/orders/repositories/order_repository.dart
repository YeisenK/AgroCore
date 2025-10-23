import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/order_model.dart';

class OrderRepository {
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Solo 1 pedido de ejemplo
    final orders = [
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
        notes: "Pedido entregado satisfactoriamente",
      ),
    ];

    // Ordenar por ID de forma ascendente
    orders.sort((a, b) => a.id.compareTo(b.id));

    return orders;
  }

  Future<void> addOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Pedido agregado al repositorio: ${order.id}');
  }

  Future<void> updateOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Pedido actualizado en repositorio: ${order.id}');
  }

  Future<void> deleteOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Pedido eliminado del repositorio: $id');
  }

  // Método opcional para cargar datos desde un archivo JSON
  Future<List<OrderModel>> loadOrdersFromJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/mock/orders.json');
      final data = await json.decode(response) as List;

      final orders = data.map((json) => OrderModel.fromJson(json)).toList();

      // Ordenar por ID
      orders.sort((a, b) => a.id.compareTo(b.id));

      return orders;
    } catch (e) {
      print('Error cargando datos desde JSON: $e');
      return getOrders();
    }
  }

  // Método opcional para buscar pedidos por criterios específicos
  Future<List<OrderModel>> searchOrders({
    String? customer,
    String? crop,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final allOrders = await getOrders();
    var filteredOrders = allOrders;

    // Filtrar por cliente
    if (customer != null && customer.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((order) =>
              order.customer.toLowerCase().contains(customer.toLowerCase()))
          .toList();
    }

    // Filtrar por cultivo
    if (crop != null && crop.isNotEmpty) {
      filteredOrders = filteredOrders
          .where(
              (order) => order.crop.toLowerCase().contains(crop.toLowerCase()))
          .toList();
    }

    // Filtrar por estado
    if (status != null) {
      filteredOrders =
          filteredOrders.where((order) => order.status == status).toList();
    }

    // Filtrar por rango de fechas
    if (startDate != null) {
      filteredOrders = filteredOrders
          .where((order) =>
              order.deliveryDate.isAfter(startDate) ||
              order.deliveryDate.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      filteredOrders = filteredOrders
          .where((order) =>
              order.deliveryDate.isBefore(endDate) ||
              order.deliveryDate.isAtSameMomentAs(endDate))
          .toList();
    }

    // Ordenar resultados por ID
    filteredOrders.sort((a, b) => a.id.compareTo(b.id));

    return filteredOrders;
  }

  // Método opcional para obtener estadísticas
  Future<Map<String, dynamic>> getOrderStatistics() async {
    final orders = await getOrders();

    final totalOrders = orders.length;
    final pendingCount =
        orders.where((o) => o.status == OrderStatus.pending).length;
    final inProcessCount =
        orders.where((o) => o.status == OrderStatus.inProcess).length;
    final shippedCount =
        orders.where((o) => o.status == OrderStatus.shipped).length;
    final deliveredCount =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledCount =
        orders.where((o) => o.status == OrderStatus.cancelled).length;

    final totalQuantity =
        orders.fold(0.0, (sum, order) => sum + order.quantity);

    return {
      'totalOrders': totalOrders,
      'pendingCount': pendingCount,
      'inProcessCount': inProcessCount,
      'shippedCount': shippedCount,
      'deliveredCount': deliveredCount,
      'cancelledCount': cancelledCount,
      'totalQuantity': totalQuantity,
      'averageQuantity': totalOrders > 0 ? totalQuantity / totalOrders : 0,
    };
  }

  // Método opcional para verificar si un ID ya existe
  Future<bool> orderIdExists(String id) async {
    final orders = await getOrders();
    return orders.any((order) => order.id == id);
  }

  // Método opcional para obtener el próximo ID disponible
  Future<String> getNextOrderId() async {
    final orders = await getOrders();

    if (orders.isEmpty) {
      return "AA01";
    }

    // Extraer el número más alto de los IDs existentes
    int maxNumber = 0;
    for (var order in orders) {
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
