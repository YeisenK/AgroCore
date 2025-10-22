import 'package:flutter/foundation.dart';
import '../models/sensor_models.dart';

/// Estado del dashboard del Ingeniero SIN dependencias HTTP.
/// Más adelante puedes inyectar lecturas reales con un servicio.
class EngineerState extends ChangeNotifier {
  final List<SensorInfo> _sensores = [];
  final List<AlertItem> _alertas = [];
  final List<TimeSeriesPoint> _series24h = [];

  int get sensoresOnline => _sensores.where((s) => s.online).length;
  int get sensoresOffline => _sensores.where((s) => !s.online).length;
  List<SensorInfo> get sensores => List.unmodifiable(_sensores);
  List<AlertItem> get alertas => List.unmodifiable(_alertas);
  List<TimeSeriesPoint> get series24h => List.unmodifiable(_series24h);

  double get humedadPromedio {
    if (_series24h.isEmpty) return 0;
    final lastHour = DateTime.now().subtract(const Duration(hours: 1));
    final points = _series24h.where((p) => p.t.isAfter(lastHour)).toList();
    if (points.isEmpty) return 0;
    return points.map((p) => p.humedad).reduce((a, b) => a + b) / points.length;
  }

  double get lecturasPorHora {
    if (_series24h.isEmpty) return 0;
    final lastHour = DateTime.now().subtract(const Duration(hours: 1));
    return _series24h.where((p) => p.t.isAfter(lastHour)).length.toDouble();
  }

  void bootstrap() {
    _sensores.clear();
    _alertas.clear();
    _series24h.clear();

    // Seed mínimo para ver UI
    final now = DateTime.now();
    _sensores.add(
      SensorInfo(
        id: 'S001',
        zona: 'Invernadero 1',
        online: true,
        humedad: 55.0,
        temperatura: 24.2,
        ultimaLectura: now,
      ),
    );
    for (int i = 23; i >= 0; i--) {
      final t = now.subtract(Duration(hours: i));
      _series24h.add(
        TimeSeriesPoint(t, 45 + (i % 8).toDouble(), 20 + (i % 6).toDouble()),
      );
    }
    notifyListeners();
  }

  /// Permite “inyectar” una lectura desde cualquier servicio futuro.
  void ingestReading({
    required double humedad,
    required double temp,
    DateTime? ts,
  }) {
    final when = ts ?? DateTime.now();
    _series24h.add(TimeSeriesPoint(when, humedad, temp));
    _series24h.removeWhere((p) => DateTime.now().difference(p.t).inHours > 24);

    if (_sensores.isEmpty) {
      _sensores.add(
        SensorInfo(
          id: 'S001',
          zona: 'Invernadero 1',
          online: true,
          humedad: humedad,
          temperatura: temp,
          ultimaLectura: when,
        ),
      );
    } else {
      _sensores[0] = _sensores[0].copyWith(
        online: true,
        humedad: humedad,
        temperatura: temp,
        ultimaLectura: when,
      );
    }

    _alertas.clear();
    if (humedad < 40) {
      _alertas.add(
        AlertItem(
          id: 'A-HUM-LOW',
          titulo: 'Humedad baja',
          detalle:
              'Lectura actual ${humedad.toStringAsFixed(1)}% (umbral 40%).',
          severidad: 'critical',
          fecha: when,
        ),
      );
    }
    notifyListeners();
  }

  void refrescar() => notifyListeners();
}
