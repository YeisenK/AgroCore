/// Define la estructura de datos para una siembra.
class SiembraModel {
  /// El ID único de la siembra, como String.
  final String id;
  final String lote;
  final String cultivo;
  final DateTime fechaSiembra;
  final String especificacion;
  final String tipoRiego;
  final String responsable;
  final List<TimelineEvent> timeline;

  SiembraModel({
    required this.id,
    required this.lote,
    required this.cultivo,
    required this.fechaSiembra,
    required this.especificacion,
    required this.tipoRiego,
    required this.responsable,
    this.timeline = const [],
  });

  /// Constructor factory que crea una instancia de SiembraModel a partir de un mapa JSON.
  factory SiembraModel.fromJson(Map<String, dynamic> json) {
    return SiembraModel(
      id: json['id'].toString(),
      lote: json['lote'] ?? 'Sin Lote',
      cultivo: json['cultivo'] ?? 'Sin Cultivo',
      fechaSiembra: DateTime.parse(json['fechaSiembra']),
      especificacion: json['especificacion'] ?? 'Sin especificación',
      tipoRiego: json['tipoRiego'] ?? 'No especificado',
      responsable: json['responsable'] ?? 'No asignado',
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((eventJson) => TimelineEvent.fromJson(eventJson))
              .toList() ??
          [],
    );
  }

  /// Método que convierte el objeto SiembraModel a un mapa JSON.
  /// ESTA ES LA FUNCIÓN QUE TE FALTA Y CAUSA EL ERROR.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote': lote,
      'cultivo': cultivo,
      'fechaSiembra': fechaSiembra.toIso8601String(),
      'especificacion': especificacion,
      'tipoRiego': tipoRiego,
      'responsable': responsable,
      'timeline': timeline.map((event) => event.toJson()).toList(),
    };
  }
}

/// Define la estructura para eventos en la línea de tiempo.
class TimelineEvent {
  final String titulo;
  final String descripcion;
  final DateTime fecha;

  TimelineEvent({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      titulo: json['titulo'] ?? 'Evento',
      descripcion: json['descripcion'] ?? '',
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
    };
  }
}
