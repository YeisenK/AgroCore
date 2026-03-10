import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginTokens {
  final String access;
  final String? refresh;
  LoginTokens({required this.access, this.refresh});
}

class AuthRepository {
  final String baseUrl;
  AuthRepository({required this.baseUrl});

  Uri _u(String path) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<LoginTokens> login({
    required int id,
    required String password,
  }) async {
    final url = _u('/api/auth/login');
    debugPrint('[AuthRepository] POST $url');

    final jsonMap = {
      'id': id,
      'password': password,
    };
    final jsonBody = jsonEncode(jsonMap);
    debugPrint('[AuthRepository] JSON body=$jsonBody');

    http.Response r;
    try {
      r = await http
          .post(
            url,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      rethrow;
    }

    Future<String?> getCurrentToken() async {
    return await getStoredAccessToken();
  }

    if (r.statusCode == 400 && r.body.contains('Faltan credenciales')) {
      debugPrint('[AuthRepository] Reintentando como form-urlencoded...');
      final formBody =
          'id=${Uri.encodeQueryComponent('$id')}&password=${Uri.encodeQueryComponent(password)}';
      r = await http
          .post(
            url,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: formBody,
          )
          .timeout(const Duration(seconds: 2));
    }

    debugPrint('[AuthRepository] login status=${r.statusCode} body=${r.body}');

    if (r.statusCode == 401) {
      if (r.body.contains('Contraseña incorrecta')) {
        throw Exception('Contraseña incorrecta');
      }
      if (r.body.contains('Usuario no encontrado') ||
          r.body.contains('Usuario inactivo') ||
          r.body.contains('Tenant inactivo')) {
        throw Exception('Usuario no encontrado/inactivo o tenant inactivo');
      }
      throw Exception('No autorizado: ${r.body}');
    }

    if (r.statusCode != 200) {
      throw Exception(
          'Login fallido: ${r.statusCode} ${r.reasonPhrase} ${r.body}');
    }

    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final access = ((data['access_token'] ?? data['token']) ?? '') as String;
    final refresh = data['refresh_token'] as String?;
    if (access.isEmpty) throw Exception('Token vacío');

    // Cache tokens + usuario (si viene)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    if (refresh != null) await prefs.setString('refresh_token', refresh);

    final userJson = data['user'];
    if (userJson != null) {
      await prefs.setString('user_json', jsonEncode(userJson));
    }

    return LoginTokens(access: access, refresh: refresh);
  }


  Future<Map<String, dynamic>> me() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No hay token almacenado');
    }

    final url = _u('/api/auth/me');
    debugPrint('[AuthRepository] GET $url');

    try {
      final r = await http
          .get(
            url,
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 2));

      debugPrint('[AuthRepository] me status=${r.statusCode} body=${r.body}');

      if (r.statusCode == 200) {
        await prefs.setString('user_json', r.body);
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        return data;
      }

      if (r.statusCode == 401) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_json');
        throw Exception('Token inválido/expirado');
      }

      throw Exception('Perfil no disponible: ${r.statusCode} ${r.reasonPhrase}');
    } catch (e) {
      final cached = prefs.getString('user_json');
      if (cached != null && cached.isNotEmpty) {
        try {
          return jsonDecode(cached) as Map<String, dynamic>;
        } catch (_) {
        }
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      try {
        final url = _u('/api/auth/logout');
        await http
            .post(
              url,
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 2));
      } catch (_) {
      }
    }

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_json');
  }


  Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    final hadToken = prefs.getString('access_token');
    if (hadToken != null && hadToken.isNotEmpty) {
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_json');
    }

    return null;
  }

}
