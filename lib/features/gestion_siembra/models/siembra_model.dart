// lib/features/gestion_siembra/models/siembra_model.dart

// --- NUEVA CLASE PARA LOS DETALLES ---
class DetalleSiembraModel {
  final String cultivo;
  final String especificacion;
  final int cantidad; // Es buena idea añadir la cantidad

  DetalleSiembraModel({
    required this.cultivo,
    required this.especificacion,
    required this.cantidad,
  });

  // Métodos para convertir desde/hacia JSON
  factory DetalleSiembraModel.fromJson(Map<String, dynamic> json) {
    return DetalleSiembraModel(
      cultivo: json['cultivo'] ?? 'Sin Cultivo',
      especificacion: json['especificacion'] ?? 'Sin Especificación',
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cultivo': cultivo,
      'especificacion': especificacion,
      'cantidad': cantidad,
    };
  }
}

// --- CLASE SiembraModel MODIFICADA ---
class SiembraModel {
  final String id;
  final int lote; // El número de lote general
  final DateTime fechaSiembra;
  final String tipoRiego;
  final String responsable;
  final List<TimelineEvent> timeline;

  // --- CAMBIO: Ya no hay 'cultivo', ahora hay una LISTA de 'detalles' ---
  final List<DetalleSiembraModel> detalles;

  SiembraModel({
    required this.id,
    required this.lote,
    required this.fechaSiembra,
    required this.tipoRiego,
    required this.responsable,
    this.timeline = const [],
    required this.detalles, // La lista de detalles es ahora requerida
  });

  factory SiembraModel.fromJson(Map<String, dynamic> json) {
    var detallesList = <DetalleSiembraModel>[];
    if (json['detalles'] != null && json['detalles'] is List) {
      detallesList = (json['detalles'] as List)
          .map((item) => DetalleSiembraModel.fromJson(item))
          .toList();
    }

    return SiembraModel(
      id: json['id'].toString(),
      lote: int.tryParse(json['lote'].toString()) ?? 0,
      fechaSiembra: DateTime.parse(json['fechaSiembra']),
      tipoRiego: json['tipoRiego'] ?? 'No especificado',
      responsable: json['responsable'] ?? 'No asignado',
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((eventJson) => TimelineEvent.fromJson(eventJson))
              .toList() ??
          [],
      detalles: detallesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote': lote,
      'fechaSiembra': fechaSiembra.toIso8601String(),
      'tipoRiego': tipoRiego,
      'responsable': responsable,
      'timeline': timeline.map((event) => event.toJson()).toList(),
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }
}

// ... (Tu clase TimelineEvent se queda igual) ...
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
