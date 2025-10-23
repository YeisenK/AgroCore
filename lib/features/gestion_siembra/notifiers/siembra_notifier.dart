import 'package:flutter/material.dart';

// Asegúrate de que las rutas sean correctas
import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/repositories/mock_siembra_repository.dart';

class SiembraNotifier extends ChangeNotifier {
  final MockSiembraRepository _repository;

  SiembraNotifier(this._repository) {
    fetchSiembras();
  }

  bool _isLoading = false;
  List<SiembraModel> _siembras = [];

  bool get isLoading => _isLoading;
  List<SiembraModel> get siembras => _siembras;

  Future<void> fetchSiembras() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Obtenemos nuestra PROPIA COPIA de la lista desde el repositorio
      _siembras = await _repository.getSiembras();
    } catch (e) {
      print('Error al cargar las siembras: $e');
      _siembras = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// **CREATE: (CORREGIDO)**
  Future<void> addSiembra(SiembraModel nuevaSiembra) async {
    try {
      // 1. Le decimos al repositorio que guarde el cambio permanentemente.
      //    No usamos 'await' para que la UI sea instantánea.
      _repository.addSiembra(nuevaSiembra);

      // 2. ACTUALIZACIÓN OPTIMISTA: Añadimos la siembra a nuestra lista local.
      _siembras.add(nuevaSiembra);

      // 3. Notificamos a la UI de inmediato.
      notifyListeners();
      print('NOTIFIER: Siembra añadida localmente y notificado.');

      // 4. NO HAY "fetchSiembras()". Esto evita el duplicado.
    } catch (e) {
      print('Error al añadir la siembra: $e');
    }
  }

  /// **UPDATE: (CORREGIDO)**
  Future<void> actualizarSiembra(SiembraModel siembraActualizada) async {
    try {
      // 1. Le decimos al repositorio que guarde el cambio.
      _repository.actualizarSiembra(siembraActualizada);

      // 2. ACTUALIZACIÓN OPTIMISTA: Actualizamos nuestra lista local.
      final index = _siembras.indexWhere((s) => s.id == siembraActualizada.id);
      if (index != -1) {
        _siembras[index] = siembraActualizada;
        // 3. Notificamos a la UI.
        notifyListeners();
        print('NOTIFIER: Siembra actualizada localmente y notificado.');
      }
    } catch (e) {
      print('Error al actualizar la siembra: $e');
    }
  }

  /// **DELETE: (CORREGIDO)**
  Future<void> eliminarSiembra(String id) async {
    try {
      // 1. Le decimos al repositorio que elimine el dato.
      _repository.eliminarSiembra(id);

      // 2. ACTUALIZACIÓN OPTIMISTA: Eliminamos de nuestra lista local.
      _siembras.removeWhere((s) => s.id == id);

      // 3. Notificamos a la UI de inmediato.
      notifyListeners();
      print('NOTIFIER: Siembra eliminada localmente y notificado.');

      // 4. NO HAY "fetchSiembras()". Esto soluciona el bug de borrado.
    } catch (e) {
      print('Error al eliminar la siembra: $e');
    }
  }
}
