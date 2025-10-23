import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Asegúrate de que las rutas a tu modelo sean correctas
import 'package:main/features/gestion_siembra/models/siembra_model.dart';

class MockSiembraRepository {
  List<SiembraModel>? _cachedSiembras;

  Future<List<SiembraModel>> getSiembras() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_cachedSiembras != null) {
      // --- CAMBIO CLAVE 1: Devuelve una COPIA de la lista ---
      return List<SiembraModel>.from(_cachedSiembras!);
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/mock/siembras.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      _cachedSiembras = jsonList
          .map((json) => SiembraModel.fromJson(json))
          .toList();

      // --- CAMBIO CLAVE 2: Devuelve una COPIA de la lista ---
      return List<SiembraModel>.from(_cachedSiembras!);
    } catch (e) {
      print('Error al leer el mock de siembras: $e');
      _cachedSiembras = []; // Inicializa la lista vacía en caso de error
      return [];
    }
  }

  Future<void> addSiembra(SiembraModel siembra) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_cachedSiembras == null) {
      await getSiembras();
    }

    // El repositorio solo añade la siembra que ya viene con ID desde el formulario.
    _cachedSiembras!.add(siembra);
    print('REPOSITORIO: Siembra añadida al caché.');
  }

  Future<void> actualizarSiembra(SiembraModel siembra) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_cachedSiembras == null) {
      await getSiembras();
    }

    final index = _cachedSiembras!.indexWhere((s) => s.id == siembra.id);
    if (index != -1) {
      _cachedSiembras![index] = siembra;
      print('REPOSITORIO: Siembra actualizada en caché.');
    }
  }

  Future<void> eliminarSiembra(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_cachedSiembras == null) {
      await getSiembras();
    }

    _cachedSiembras!.removeWhere((s) => s.id == id);
    print('REPOSITORIO: Siembra eliminada del caché.');
  }
}
