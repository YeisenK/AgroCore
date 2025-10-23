import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  inProcess,
  shipped,
  delivered,
  cancelled
  // Eliminado: confirmed
}

class OrderModel {
  final String id;
  final String customer;
  final String crop;
  final String variety;
  final double quantity;
  final String unit;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final String? notes;
  // Eliminados: unitPrice, total, address

  OrderModel({
    required this.id,
    required this.customer,
    required this.crop,
    required this.variety,
    required this.quantity,
    required this.unit,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    this.notes,
    // Eliminados: unitPrice, address
  });

  // Eliminado: get total

  String get statusText {
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

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.inProcess:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  OrderModel copyWith({
    String? id,
    String? customer,
    String? crop,
    String? variety,
    double? quantity,
    String? unit,
    DateTime? orderDate,
    DateTime? deliveryDate,
    OrderStatus? status,
    String? notes,
    // Eliminados: unitPrice, address
  }) {
    return OrderModel(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      crop: crop ?? this.crop,
      variety: variety ?? this.variety,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'crop': crop,
      'variety': variety,
      'quantity': quantity,
      'unit': unit,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status.name,
      'notes': notes,
      // Eliminados: unitPrice, address
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customer: json['customer'],
      crop: json['crop'],
      variety: json['variety'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      notes: json['notes'],
      // Eliminados: unitPrice, address
    );
  }
}
