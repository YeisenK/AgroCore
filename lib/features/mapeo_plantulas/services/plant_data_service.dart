import 'dart:math';
import '../models/plant_model.dart';

class PlantDataService {
  final Random _random = Random();

  List<Plant> generatePlants(String seccion, int count) {
    final types = ['Maíz', 'Frijol', 'Trigo', 'Arroz', 'Sorgo', 'Tomate', 'Chile', 'Cebolla', 'Zanahoria', 'Lechuga'];
    final List<Plant> plants = [];

    for (int i = 1; i <= count; i++) {
      final type = types[_random.nextInt(types.length)];
      plants.add(
        Plant(
          id: '${seccion[0]}P${i.toString().padLeft(2, '0')}',
          nombre: 'Planta $seccion-$i',
          tipo: type,
          variedad: 'Variedad ${_random.nextInt(5) + 1}',
          estado: ['Excelente', 'Bueno', 'Regular', 'Necesita Atención'][_random.nextInt(4)],
          seccion: seccion,
          subseccion: 'Sector ${((i - 1) ~/ 6) + 1}',
          fila: 'Fila ${((i - 1) % 6) + 1}',
          pedidoAsociado: 'ORD-00${_random.nextInt(6) + 1}',
          fechaSiembra: '2024-${_random.nextInt(12) + 1}-${_random.nextInt(28) + 1}',
          diasCrecimiento: _random.nextInt(90) + 10,
          humedad: '${65 + _random.nextInt(25)}%',
          temperatura: '${22 + _random.nextInt(8)}°C',
          ph: (6.0 + _random.nextDouble() * 1.5).toStringAsFixed(1),
          nutrientes: ['Bajo', 'Óptimo', 'Alto'][_random.nextInt(3)],
          produccionEstimada: '${_random.nextInt(20) + 5}kg',
          cuidadosEspeciales: 'Riego cada ${_random.nextInt(3) + 1} días',
          imagen: _getEmoji(type),
        ),
      );
    }
    return plants;
  }

  String _getEmoji(String tipo) {
    const icons = {'Maíz': '🌽', 'Frijol': '🫘', 'Tomate': '🍅', 'Chile': '🌶️', 'Cebolla': '🧅', 'Zanahoria': '🥕', 'Lechuga': '🥬'};
    return icons[tipo] ?? '🌱';
  }
}
