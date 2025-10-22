import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal in-file stub to satisfy the missing `local_auth_db.dart` import.
/// This provides a LocalAuthDb class with a `db` object exposing the methods
/// used by the repository (query, rawQuery, update). The implementations are
/// no-ops / placeholders and should be replaced with the real database code.
class LocalAuthDb {
  late final _DummyDb db;

  Future<void> init() async {
    db = _DummyDb();
  }
}

class _DummyDb {
  Future<List<Map<String, Object?>>> query(String table, {String? where, List<Object?>? whereArgs, int? limit}) async =>
      [];

  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? args]) async => [];

  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs}) async => 1;
}

class LocalAuthRepository {
  final _db = LocalAuthDb();
  static const _kAccess = 'access_token';
  static const _kUid    = 'access_user_id';

  Future<void> init() => _db.init();

  /// Emula POST /api/auth/login
  /// body: {email|username, password}
  Future<Map<String, dynamic>> login({
    String? email,
    String? username,
    required String password,
  }) async {
    await init();
    final d = _db.db;
    Map<String, Object?>? u;

    if (email != null) {
      final rows = await d.query('users', where: 'email = ?', whereArgs: [email]);
      if (rows.isNotEmpty) u = rows.first;
    } else if (username != null) {
      final rows = await d.query('users', where: 'username = ?', whereArgs: [username]);
      if (rows.isNotEmpty) u = rows.first;
    }

    if (u == null) {
      throw Exception('Contraseña incorrecta'); // mismo contrato 401
    }
    if ((u['is_active'] as int) != 1) {
      throw Exception('Usuario deshabilitado'); // 403
    }

    final hash = (u['password_hash'] as String);
    final ok = _bcryptVerify(password, hash);
    if (!ok) {
      throw Exception('Contraseña incorrecta');
    }

    final uid = u['id'] as int;

    // Roles
    final roles = await d.rawQuery('''
SELECT r.name FROM roles r
JOIN user_roles ur ON ur.role_id = r.id
WHERE ur.user_id = ?
ORDER BY r.name
''', [uid]);
    final roleList = roles.map((e)=> e['name'].toString()).toList();

    // token offline
    final token = base64Url.encode(utf8.encode('OFFLINE:$uid:${DateTime.now().millisecondsSinceEpoch}'));

    // persistimos token y uid
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, token);
    await prefs.setInt(_kUid, uid);

    // update last_login_at
    await d.update('users', {'last_login_at': DateTime.now().toIso8601String()},
      where: 'id = ?', whereArgs: [uid]);

    final userJson = {
      'id': uid,
      'name': u['name'],
      'username': u['username'] ?? u['email'],
      'email': u['email'],
      'roles': roleList,
      'isAdmin': roleList.contains('admin'),
      'isIngeniero': roleList.contains('ingeniero'),
      'isAgricultor': roleList.contains('agricultor'),
    };

    return {
      'access_token': token,
      'refresh_token': null,
      'token_type': 'Bearer',
      'expires_in': 3600,
      'user': userJson,
    };
  }

  /// Emula GET /api/auth/me
  Future<Map<String, dynamic>> me() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt(_kUid);
    final token = prefs.getString(_kAccess);
    if (uid == null || token == null) {
      throw Exception('Token inválido o expirado');
    }

    final d = _db.db;
    final rows = await d.query('users', where: 'id = ?', whereArgs: [uid], limit: 1);
    if (rows.isEmpty) throw Exception('Token inválido o expirado');
    final u = rows.first;

    final roles = await d.rawQuery('''
SELECT r.name FROM roles r
JOIN user_roles ur ON ur.role_id = r.id
WHERE ur.user_id = ?
ORDER BY r.name
''', [uid]);
    final roleList = roles.map((e)=> e['name'].toString()).toList();

    return {
      'id': uid,
      'name': u['name'],
      'username': u['username'] ?? u['email'],
      'email': u['email'],
      'roles': roleList,
      'isAdmin': roleList.contains('admin'),
      'isIngeniero': roleList.contains('ingeniero'),
      'isAgricultor': roleList.contains('agricultor'),
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kUid);
  }

  Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccess);
  }

  // Algunos paquetes bcrypt no aceptan "$2y$". Esta función intenta ambas.
  bool _bcryptVerify(String plain, String hash) {
    try {
      // bcrypt >=1.1.3 suele soportar $2y$
      return BCrypt.checkpw(plain, hash);
    } catch (_) {
      // fallback reemplazando encabezado
      final fixed = hash.replaceFirst('\$2y\$', '\$2a\$');
      return BCrypt.checkpw(plain, fixed);
    }
  }
}
