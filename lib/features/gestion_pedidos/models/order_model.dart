import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  inProcess,
  shipped,
  delivered,
  cancelled,
  confirmed
}

class OrderModel {
  final String id;
  final int tenantId;
  final int idCliente;
  final String customer;
  final String tipo;
  final String estado;
  final double monto;
  final double saldoPendiente;
  final double? volumen;
  final DateTime fechaCreacion;
  final DateTime? fechaEntrega;
  final int? creadoPor;
  final String? notes;

  OrderModel({
    required this.id,
    required this.tenantId,
    required this.idCliente,
    required this.customer,
    required this.tipo,
    required this.estado,
    required this.monto,
    required this.saldoPendiente,
    this.volumen,
    required this.fechaCreacion,
    this.fechaEntrega,
    this.creadoPor,
    this.notes,
  });

  // Mapear estado string a OrderStatus
  OrderStatus get status {
    switch (estado) {
      case 'borrador': return OrderStatus.pending;
      case 'confirmado': return OrderStatus.confirmed;
      case 'preparacion': return OrderStatus.inProcess;
      case 'enviado': return OrderStatus.shipped;
      case 'entregado': return OrderStatus.delivered;
      case 'cancelado': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  // Mapear OrderStatus a estado string para la API
  String get statusString {
    switch (status) {
      case OrderStatus.pending: return 'borrador';
      case OrderStatus.confirmed: return 'confirmado';
      case OrderStatus.inProcess: return 'preparacion';
      case OrderStatus.shipped: return 'enviado';
      case OrderStatus.delivered: return 'entregado';
      case OrderStatus.cancelled: return 'cancelado';
    }
  }

  // Propiedades para compatibilidad con la UI existente
  String get crop => 'Cultivo Principal'; // Placeholder - ajustar según tu lógica
  String get variety => 'Variedad Principal'; // Placeholder - ajustar según tu lógica
  double get quantity => volumen ?? 0.0;
  String get unit => 'kg'; // Placeholder - ajustar según tu lógica
  DateTime get orderDate => fechaCreacion;
  DateTime get deliveryDate => fechaEntrega ?? fechaCreacion.add(const Duration(days: 7));

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
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
        return const Color(0xFFB07C3C);
      case OrderStatus.confirmed:
        return const Color(0xFF4E668F);
      case OrderStatus.inProcess:
        return const Color(0xFF7660A0);
      case OrderStatus.shipped:
        return const Color(0xFF4A7CB0);
      case OrderStatus.delivered:
        return const Color(0xFF4A9A72);
      case OrderStatus.cancelled:
        return const Color(0xFF9B5353);
    }
  }

  OrderModel copyWith({
    String? id,
    int? tenantId,
    int? idCliente,
    String? customer,
    String? tipo,
    String? estado,
    double? monto,
    double? saldoPendiente,
    double? volumen,
    DateTime? fechaCreacion,
    DateTime? fechaEntrega,
    int? creadoPor,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      idCliente: idCliente ?? this.idCliente,
      customer: customer ?? this.customer,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      monto: monto ?? this.monto,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      volumen: volumen ?? this.volumen,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      creadoPor: creadoPor ?? this.creadoPor,
      notes: notes ?? this.notes,
    );
  }

  // Para enviar a la API
  Map<String, dynamic> toApiJson() {
    return {
      'id_cliente': idCliente,
      'tipo': tipo,
      'estado': statusString,
      'monto': monto,
      'saldo_pendiente': saldoPendiente,
      'volumen': volumen,
      'fecha_entrega': fechaEntrega?.toIso8601String(),
      'creado_por': creadoPor,
      'notes': notes,
    };
  }

  // Para compatibilidad con código existente
  Map<String, dynamic> toJson() {
    return toApiJson();
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id_pedido'].toString(),
      tenantId: json['tenant_id'] as int,
      idCliente: json['id_cliente'] as int,
      customer: json['cliente_nombre'] ?? 'Cliente no encontrado',
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
      monto: (json['monto'] as num).toDouble(),
      saldoPendiente: (json['saldo_pendiente'] as num).toDouble(),
      volumen: json['volumen'] != null ? (json['volumen'] as num).toDouble() : null,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaEntrega: json['fecha_entrega'] != null ? DateTime.parse(json['fecha_entrega']) : null,
      creadoPor: json['creado_por'] as int?,
      notes: json['notes'] as String?,
    );
  }

  // Factory para crear nuevo pedido
  factory OrderModel.createNew({
    required String id,
    required int tenantId,
    required int idCliente,
    required String customer,
    required String tipo,
    required OrderStatus status,
    required double monto,
    double? volumen,
    DateTime? fechaEntrega,
    int? creadoPor,
    String? notes,
  }) {
    return OrderModel(
      id: id,
      tenantId: tenantId,
      idCliente: idCliente,
      customer: customer,
      tipo: tipo,
      estado: status.statusString,
      monto: monto,
      saldoPendiente: monto, // Por defecto el saldo pendiente es igual al monto
      volumen: volumen,
      fechaCreacion: DateTime.now(),
      fechaEntrega: fechaEntrega,
      creadoPor: creadoPor,
      notes: notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extensión para OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get statusString {
    switch (this) {
      case OrderStatus.pending: return 'borrador';
      case OrderStatus.confirmed: return 'confirmado';
      case OrderStatus.inProcess: return 'preparacion';
      case OrderStatus.shipped: return 'enviado';
      case OrderStatus.delivered: return 'entregado';
      case OrderStatus.cancelled: return 'cancelado';
    }
  }

  String get displayText {
    switch (this) {
      case OrderStatus.pending: return 'Pendiente';
      case OrderStatus.confirmed: return 'Confirmado';
      case OrderStatus.inProcess: return 'En Proceso';
      case OrderStatus.shipped: return 'Enviado';
      case OrderStatus.delivered: return 'Entregado';
      case OrderStatus.cancelled: return 'Cancelado';
    }
  }

  Color get displayColor {
    switch (this) {
      case OrderStatus.pending: return const Color(0xFFB07C3C);
      case OrderStatus.confirmed: return const Color(0xFF4E668F);
      case OrderStatus.inProcess: return const Color(0xFF7660A0);
      case OrderStatus.shipped: return const Color(0xFF4A7CB0);
      case OrderStatus.delivered: return const Color(0xFF4A9A72);
      case OrderStatus.cancelled: return const Color(0xFF9B5353);
    }
  }
}