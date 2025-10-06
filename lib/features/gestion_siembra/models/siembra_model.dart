// --- Entidad Principal: SiembraModel ---
// Define la estructura de datos para una siembra.
class SiembraModel {
  final String id;
  final String lote;
  final String cultivo;
  final DateTime fechaSiembra;
  final String especificacion;
  final String tipoRiego;
  final String responsable;
  final List<TimelineEvent>
  timeline; // Lista de eventos para la línea de tiempo

  // Constructor para crear un objeto SiembraModel en el código
  SiembraModel({
    required this.id,
    required this.lote,
    required this.cultivo,
    required this.fechaSiembra,
    required this.especificacion,
    required this.tipoRiego,
    required this.responsable,
    this.timeline = const [], // Por defecto, la lista de eventos está vacía
  });

  /// factory SiembraModel.fromJson
  ///
  /// Este constructor especial "traduce" un mapa de datos (que viene de un JSON)
  /// a un objeto SiembraModel que nuestra aplicación puede entender.
  factory SiembraModel.fromJson(Map<String, dynamic> json) {
    return SiembraModel(
      id: json['id'] ?? '',
      lote: json['lote'] ?? 'Sin Lote',
      cultivo: json['cultivo'] ?? 'Sin Cultivo',
      fechaSiembra: DateTime.parse(json['fechaSiembra']),
      especificacion: json['especificacion'] ?? 'Sin especificación',
      tipoRiego: json['tipoRiego'] ?? 'No especificado',
      responsable: json['responsable'] ?? 'No asignado',
      // Si el JSON tuviera un timeline, aquí lo leeríamos
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((eventJson) => TimelineEvent.fromJson(eventJson))
              .toList() ??
          [],
    );
  }

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

// --- Sub-Entidad: TimelineEvent ---
// Define la estructura de cada evento en la línea de tiempo de una siembra.
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
