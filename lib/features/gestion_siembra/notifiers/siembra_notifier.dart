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

  // --- MÉTODO NUEVO PARA REVISAR DUPLICADOS ---
  /// Revisa si un número de lote ya existe en la lista.
  /// Opcionalmente ignora un ID (necesario para el modo de edición).
  bool checkLoteExists(int lote, {String? siembraIdToIgnore}) {
    return _siembras.any((siembra) {
      // Condición 1: ¿Es el mismo número de lote?
      final bool isSameLote = siembra.lote == lote;

      // Condición 2: ¿Es un item DIFERENTE al que estamos editando?
      final bool isDifferentItem = siembra.id != siembraIdToIgnore;

      // Es un duplicado si es el mismo lote Y un item diferente
      return isSameLote && isDifferentItem;
    });
  }
  // --- FIN DEL MÉTODO NUEVO ---

  /// READ: Carga la lista inicial de siembras.
  Future<void> fetchSiembras() async {
    _isLoading = true;
    notifyListeners();
    try {
      _siembras = await _repository.getSiembras();
    } catch (e) {
      print('Error al cargar las siembras: $e');
      _siembras = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// CREATE: Añade una nueva siembra (Actualización Optimista).
  Future<void> addSiembra(SiembraModel nuevaSiembra) async {
    try {
      _repository.addSiembra(nuevaSiembra); // Llama al repo (sin await)
      _siembras.add(nuevaSiembra); // Añade a la lista local
      notifyListeners(); // Notifica a la UI
    } catch (e) {
      print('Error al añadir la siembra: $e');
    }
  }

  /// UPDATE: Actualiza una siembra existente (Actualización Optimista).
  Future<void> actualizarSiembra(SiembraModel siembraActualizada) async {
    try {
      _repository.actualizarSiembra(
        siembraActualizada,
      ); // Llama al repo (sin await)

      final index = _siembras.indexWhere((s) => s.id == siembraActualizada.id);
      if (index != -1) {
        _siembras[index] = siembraActualizada; // Actualiza lista local
        notifyListeners(); // Notifica a la UI
      }
    } catch (e) {
      print('Error al actualizar la siembra: $e');
    }
  }

  /// DELETE: Elimina una siembra (Actualización Optimista).
  Future<void> eliminarSiembra(String id) async {
    try {
      _repository.eliminarSiembra(id); // Llama al repo (sin await)
      _siembras.removeWhere((s) => s.id == id); // Elimina de lista local
      notifyListeners(); // Notifica a la UI
    } catch (e) {
      print('Error al eliminar la siembra: $e');
    }
  }
}
