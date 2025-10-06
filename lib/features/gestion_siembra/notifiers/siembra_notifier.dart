import 'package:flutter/material.dart';

import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/repositories/mock_siembra_repository.dart';

// La clase extiende ChangeNotifier para poder "notificar" a la UI cuando hay cambios.
class SiembraNotifier extends ChangeNotifier {
  // Dependencia del repositorio para obtener los datos.
  final MockSiembraRepository _repository;

  // El constructor recibe el repositorio e inmediatamente carga los datos iniciales.
  SiembraNotifier(this._repository) {
    fetchSiembras();
  }

  // --- ESTADO INTERNO DE ESTE MÓDULO ---

  // Bandera para saber si estamos cargando datos (para mostrar un spinner).
  bool _isLoading = false;
  // La lista de siembras que se mostrará en la pantalla.
  List<SiembraModel> _siembras = [];

  // --- GETTERS PÚBLICOS ---
  // La UI usará estos para leer el estado de forma segura.
  bool get isLoading => _isLoading;
  List<SiembraModel> get siembras => _siembras;

  // --- MÉTODOS (ACCIONES) ---

  /// Carga la lista completa de siembras desde el repositorio.
  Future<void> fetchSiembras() async {
    _isLoading = true;
    notifyListeners(); // Notifica a la UI que empiece a mostrar el loading.

    try {
      // Llama al repositorio para obtener los datos.
      _siembras = await _repository.getSiembras();
      print(
        '🧠 [NOTIFIER] Datos recibidos. Número de siembras: ${_siembras.length}',
      );
    } catch (e) {
      // En una app real, aquí manejaríamos un estado de error.
      print('Error al cargar las siembras: $e');
      _siembras = []; // En caso de error, dejamos la lista vacía.
    }

    _isLoading = false;
    notifyListeners(); // Notifica a la UI que la carga terminó y que puede redibujarse con los nuevos datos.
    print('🔔 [NOTIFIER] ¡Llamado a notifyListeners() para actualizar la UI!');
  }

  /// Añade una nueva siembra y actualiza la lista.
  Future<void> addSiembra(SiembraModel nuevaSiembra) async {
    try {
      // Llama al repositorio para que "guarde" el nuevo dato.
      await _repository.addSiembra(nuevaSiembra);

      // Después de guardar, vuelve a cargar toda la lista para que incluya el nuevo elemento.
      // Esta es una estrategia simple y efectiva para mantener la UI sincronizada.
      await fetchSiembras();
    } catch (e) {
      print('Error al añadir la siembra: $e');
    }
  }
}
