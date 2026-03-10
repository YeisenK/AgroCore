import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../app/core/constants/env.dart';
import '../models/order_model.dart';

class OrderRepository {
  final String baseUrl = '$kApiBaseUrl/api/sales';
  final http.Client client;
  String? _authToken;

  OrderRepository({http.Client? client, String? authToken}) 
    : client = client ?? http.Client(),
      _authToken = authToken;

  // Método para actualizar el token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Headers con autenticación
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Verificar conexión con el servidor
  Future<bool> checkServerConnection() async {
    try {
      log('🔍 Verificando conexión con: $baseUrl/orders.php');
      
      final response = await client.get(
        Uri.parse('$baseUrl/orders.php'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      log('📡 Status de conexión: ${response.statusCode}');
      
      // Considerar exitoso si responde 200 (OK) o 401 (Token requerido) 
      // porque significa que el endpoint existe
      if (response.statusCode == 200) {
        log('✅ Servidor responde correctamente');
        return true;
      } else if (response.statusCode == 401) {
        log('⚠️  Servidor responde pero requiere autenticación');
        return true; // El endpoint existe, solo necesita token válido
      } else if (response.statusCode == 404) {
        log('❌ Endpoint no encontrado (404)');
        return false;
      } else {
        log('❌ Error del servidor: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('💥 Error de conexión: $e');
      return false;
    }
  }

  // Verificar conexión detallada con diagnóstico
  Future<Map<String, dynamic>> diagnoseConnection() async {
    final results = <String, dynamic>{};
    
    try {
      log('🔍 Iniciando diagnóstico de conexión...');
      
      final endpoints = [
        '$baseUrl/orders.php',
        '$baseUrl/clientes.php',
        '$baseUrl/semillas.php',
      ];
      
      for (final endpoint in endpoints) {
        try {
          final response = await client.get(
            Uri.parse(endpoint),
            headers: _headers,
          ).timeout(const Duration(seconds: 5));
          
          results[endpoint] = {
            'status': response.statusCode,
            'working': response.statusCode == 200 || response.statusCode == 401,
            'response': response.body.length > 100 
                ? '${response.body.substring(0, 100)}...' 
                : response.body,
          };
          
          log('🔗 $endpoint → Status: ${response.statusCode}');
        } catch (e) {
          results[endpoint] = {
            'status': 'ERROR',
            'working': false,
            'error': e.toString(),
          };
          log('💥 $endpoint → Error: $e');
        }
      }
      
      return results;
    } catch (e) {
      log('💥 Error en diagnóstico completo: $e');
      return {'error': e.toString()};
    }
  }

  // Obtener clientes
  Future<List<Map<String, dynamic>>> getClientes() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/clientes.php'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      log('GET Clientes Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          throw Exception('El servidor devolvió HTML en lugar de JSON');
        }
        
        final data = json.decode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido o expirado');
      } else {
        throw Exception('Error ${response.statusCode} al obtener clientes');
      }
    } catch (e) {
      log('Error en getClientes: $e');
      rethrow;
    }
  }

  // Obtener semillas
  Future<List<Map<String, dynamic>>> getSemillas() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/semillas.php'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      log('GET Semillas Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          throw Exception('El servidor devolvió HTML en lugar de JSON');
        }
        
        final data = json.decode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido o expirado');
      } else {
        throw Exception('Error ${response.statusCode} al obtener semillas');
      }
    } catch (e) {
      log('Error en getSemillas: $e');
      rethrow;
    }
  }

  // Obtener pedidos
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/orders.php'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      log('GET Orders Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          throw Exception('El servidor devolvió HTML en lugar de JSON');
        }
        
        final data = json.decode(response.body) as List;
        final orders = data.map((json) => OrderModel.fromJson(json)).toList();
        orders.sort((a, b) => b.id.compareTo(a.id));
        return orders;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido o expirado');
      } else {
        throw Exception('Error HTTP ${response.statusCode} al obtener pedidos');
      }
    } catch (e) {
      log('Error en getOrders: $e');
      rethrow;
    }
  }

  // Crear pedido
  Future<void> addOrder(OrderModel order) async {
    try {
      final orderData = order.toApiJson();
      
      log('🔄 Enviando pedido: ${order.id}');
      log('📦 Datos: ${json.encode(orderData)}');

      final response = await client.post(
        Uri.parse('$baseUrl/orders.php'),
        headers: _headers,
        body: json.encode(orderData),
      ).timeout(const Duration(seconds: 15));

      log('📡 Respuesta HTTP: ${response.statusCode}');

      // Verificar si es HTML (error 404, 500, etc.)
      if (response.body.trim().startsWith('<!DOCTYPE') || 
          response.body.trim().startsWith('<html')) {
        throw Exception('''
❌ ERROR DEL SERVIDOR:
El endpoint orders.php no está respondiendo correctamente.
Status: ${response.statusCode}
''');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Pedido creado: ${order.id}');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido o expirado');
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? 'Error desconocido del servidor';
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        
        throw Exception('❌ ERROR: $errorMessage');
      }
    } catch (e) {
      log('💥 Error en addOrder: $e');
      rethrow;
    }
  }

  // Actualizar pedido
  Future<void> updateOrder(OrderModel order) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/orders.php/${order.id}'),
        headers: _headers,
        body: json.encode(order.toApiJson()),
      );

      if (response.statusCode == 200) {
        log('✅ Pedido actualizado: ${order.id}');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido o expirado');
      } else {
        throw Exception('Error ${response.statusCode} al actualizar pedido');
      }
    } catch (e) {
      log('Error en updateOrder: $e');
      rethrow;
    }
  }

  // Eliminar pedido
  Future<void> deleteOrder(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/orders.php/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('✅ Pedido eliminado: $id');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido o expirado');
      } else {
        throw Exception('Error ${response.statusCode} al eliminar pedido');
      }
    } catch (e) {
      log('Error en deleteOrder: $e');
      rethrow;
    }
  }

  // Obtener siguiente ID
  Future<String> getNextOrderId() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/orders.php/next-id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && !response.body.trim().startsWith('<')) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['nextId']?.toString() ?? '1';
      } else {
        // Fallback: consultar pedidos y calcular
        final orders = await getOrders();
        if (orders.isEmpty) return "1";
        final maxId = orders.map((o) => int.tryParse(o.id) ?? 0)
                          .reduce((a, b) => a > b ? a : b);
        return (maxId + 1).toString();
      }
    } catch (e) {
      log('Error en getNextOrderId: $e');
      // Fallback seguro
      final orders = await getOrders();
      if (orders.isEmpty) return "1";
      final maxId = orders.map((o) => int.tryParse(o.id) ?? 0)
                        .reduce((a, b) => a > b ? a : b);
      return (maxId + 1).toString();
    }
  }

  void dispose() {
    client.close();
  }
}