// lib/app/data/auth/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'auth_repository.dart';

enum AuthStatus { unknown, loading, unauthenticated, authenticated }

class UserX {
  final int id;
  final String email;
  final List<String> roles;
  UserX({
    required this.id,
    required this.email,
    required this.roles,
  });

  bool get isAdmin => roles.contains('admin');
  bool get isIngeniero => roles.contains('ingeniero');
  bool get isAgricultor => roles.contains('agricultor');

  @override
  String toString() => 'UserX(id:$id, email:$email, roles:$roles)';
}

class AuthController extends ChangeNotifier {
  final AuthRepository repo;
  AuthController(this.repo);

  AuthStatus status = AuthStatus.unknown;
  UserX? currentUser;

  // ---------- Bootstrap ----------
  Future<void> bootstrap() async {
    status = AuthStatus.loading;
    notifyListeners();
    final t0 = DateTime.now();
    debugPrint('[Auth] bootstrap start');

    try {
      final token = await repo.getStoredAccessToken();
      debugPrint('[Auth] token? ${token != null}');
      if (token == null || token.isEmpty) {
        currentUser = null;
        status = AuthStatus.unauthenticated;
        notifyListeners();
        debugPrint('[Auth] no token -> UNAUTH (+${DateTime.now().difference(t0).inMilliseconds}ms)');
        return;
      }

      final me = await repo.me(); // valida y cachea
      final parsed = _parseUser(me);

      // SIN ROLES ⇒ se considera NO autenticado
      if (parsed.roles.isEmpty) {
        await repo.logout();
        currentUser = null;
        status = AuthStatus.unauthenticated;
        notifyListeners();
        debugPrint('[Auth] user sin roles -> UNAUTH');
        return;
      }

      currentUser = parsed;
      status = AuthStatus.authenticated;
      notifyListeners();
      debugPrint('[Auth] AUTH ok ${currentUser.toString()} (+${DateTime.now().difference(t0).inMilliseconds}ms)');
    } catch (e) {
      await repo.logout();
      currentUser = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      debugPrint('[Auth] bootstrap fail -> UNAUTH ($e)');
    }
  }

  // ---------- Login ----------
  Future<bool> doLogin(String idStr, String password) async {
    status = AuthStatus.loading;
    notifyListeners();
    debugPrint('[Auth] doLogin(id:$idStr)');

    try {
      final id = int.tryParse(idStr) ?? -1;
      if (id <= 0) {
        throw Exception('ID inválido');
      }

      await repo.login(id: id, password: password);
      final me = await repo.me(); // valida y cachea
      final parsed = _parseUser(me);

      // SIN ROLES ⇒ no autenticar
      if (parsed.roles.isEmpty) throw Exception('Usuario sin roles');

      currentUser = parsed;
      status = AuthStatus.authenticated;
      notifyListeners();
      debugPrint('[Auth] doLogin OK -> AUTH ${currentUser.toString()}');
      return true;
    } catch (e) {
      await repo.logout(); // evita estados pegados
      currentUser = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      debugPrint('[Auth] doLogin FAIL -> UNAUTH ($e)');
      return false;
    }
  }

  // ---------- Logout ----------
  Future<void> logout() async {
    debugPrint('[Auth] logout()');
    await repo.logout(); // limpia tokens y cache
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();   // vital para que GoRouter redirija
  }

  // ---------- Home preferido ----------
  String preferredHome() {
    final u = currentUser;
    if (u == null) return '/login';
    // Si no tienes /panel todavía, puedes redirigir admin a ingeniero temporalmente:
    if (u.isAdmin) return '/panel'; // o '/dashboard/ingeniero'
    if (u.isIngeniero) return '/dashboard/ingeniero';
    if (u.isAgricultor) return '/dashboard/agricultor';
    // Por seguridad, jamás devuelvas un dashboard si no hay rol claro.
    return '/login';
  }

  // ---------- Helpers ----------
  UserX _parseUser(Map<String, dynamic> me) {
    // roles puede venir como ["admin","ingeniero"] o como [{name:"admin"}, ...]
    List<String> roles = const [];
    final r = me['roles'];
    if (r is List) {
      roles = r.map<String>((e) {
        if (e is String) return e.toLowerCase();
        if (e is Map && e['name'] != null) return '${e['name']}'.toLowerCase();
        return '$e'.toLowerCase();
      }).toList();
    }

    final email = (me['email'] ?? me['correo'] ?? '').toString();
    final rawId = me['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? -1;

    return UserX(id: id, email: email, roles: roles);
  }
}
