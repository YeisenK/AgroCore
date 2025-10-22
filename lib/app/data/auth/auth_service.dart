import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/core/constants/env.dart';

class AuthResult {
  final String token;
  final String role; // 'ING' | 'AGR' | 'ADMIN'...
  AuthResult(this.token, this.role);
}

class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResult> login(String user, String pass) async {
    // Fallback de pruebas (offline o sin backend listo)
    if (user == 'admin' && pass == 'admin') {
      return AuthResult('DEV_TOKEN_ADMIN', 'ADMIN');
    }

    final uri = Uri.parse('$kApiBaseUrl/auth/login');
    final r = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': user, 'password': pass}),
        )
        .timeout(kHttpTimeout);

    if (r.statusCode == 200) {
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final token = (j['token'] ?? '') as String;
      final role = (j['role'] ?? 'ING') as String;
      if (token.isEmpty) {
        throw Exception('Respuesta inválida del servidor.');
      }
      return AuthResult(token, role);
    } else if (r.statusCode == 401) {
      throw Exception('Credenciales inválidas.');
    } else {
      throw Exception('Error del servidor (${r.statusCode}).');
    }
  }
}
