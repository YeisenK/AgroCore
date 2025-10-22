import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../services/plant_data_service.dart';

class PlantInventoryController extends ChangeNotifier {
  final _service = PlantDataService();

  late List<Plant> invernaderoA;
  late List<Plant> invernaderoB;

  String searchQuery = '';
  String filter = 'Todas';

  void initData() {
    invernaderoA = _service.generatePlants('Invernadero A', 30);
    invernaderoB = _service.generatePlants('Invernadero B', 30);
    notifyListeners(); // opcional: para pintar en cuanto cargue
  }

  List<Plant> get filteredA => _applyFilters(invernaderoA);
  List<Plant> get filteredB => _applyFilters(invernaderoB);

  // --- Normalizador: minusculas + sin acentos (incluye ñ -> n)
  String _normalize(String text) {
    final lower = text.toLowerCase();
    return lower
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'ñ'), 'n');
  }

  bool get _isAllFilter => _normalize(filter) == 'todas';

  List<Plant> _applyFilters(List<Plant> plants) {
    var result = plants;

    // Filtro por estado (tolerante a acentos y mayúsculas)
    if (!_isAllFilter) {
      final f = _normalize(filter);
      result = result.where((p) => _normalize(p.estado) == f).toList();
    }

    // Búsqueda (tolerante a acentos y mayúsculas)
    if (searchQuery.isNotEmpty) {
      result = result.where((p) {
        final nombre = _normalize(p.nombre);
        final tipo = _normalize(p.tipo);
        final variedad = _normalize(p.variedad);
        final pedido = _normalize(p.pedidoAsociado);
        return nombre.contains(searchQuery) ||
               tipo.contains(searchQuery) ||
               variedad.contains(searchQuery) ||
               pedido.contains(searchQuery);
      }).toList();
    }

    return result;
  }

  void updateSearch(String query) {
    searchQuery = _normalize(query);
    notifyListeners();
  }

  void updateFilter(String value) {
    filter = value;
    notifyListeners();
  }
}
