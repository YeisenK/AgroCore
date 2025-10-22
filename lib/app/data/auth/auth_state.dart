import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _svc;
  String? _token;
  String? _role;
  bool _loading = false;
  String? _error;

  AuthState({AuthService? service}) : _svc = service ?? AuthService();

  bool get isLoading => _loading;
  String? get token => _token;
  String? get role => _role;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String user, String pass) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _svc.login(user, pass);
      _token = res.token;
      _role = res.role;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _role = null;
    _error = null;
    notifyListeners();
  }
}
