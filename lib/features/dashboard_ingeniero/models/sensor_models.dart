class SensorInfo {
  final String id;
  final String zona;
  final bool online;
  final double humedad;
  final double temperatura;
  final DateTime ultimaLectura;

  SensorInfo({
    required this.id,
    required this.zona,
    required this.online,
    required this.humedad,
    required this.temperatura,
    required this.ultimaLectura,
  });

  SensorInfo copyWith({
    String? id,
    String? zona,
    bool? online,
    double? humedad,
    double? temperatura,
    DateTime? ultimaLectura,
  }) {
    return SensorInfo(
      id: id ?? this.id,
      zona: zona ?? this.zona,
      online: online ?? this.online,
      humedad: humedad ?? this.humedad,
      temperatura: temperatura ?? this.temperatura,
      ultimaLectura: ultimaLectura ?? this.ultimaLectura,
    );
  }
}

class AlertItem {
  final String id;
  final String titulo;
  final String detalle;
  final String severidad;
  final DateTime fecha;
  AlertItem({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.severidad,
    required this.fecha,
  });
}

class TimeSeriesPoint {
  final DateTime t;
  final double humedad;
  final double temp;
  TimeSeriesPoint(this.t, this.humedad, this.temp);
}

/// Utilidad simple para tiempos relativos
String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  return 'hace ${diff.inDays} d';
}
