class Plant {
  final String id;
  final String nombre;
  final String tipo;
  final String variedad;
  final String estado;
  final String seccion;
  final String subseccion;
  final String fila;
  final String pedidoAsociado;
  final String fechaSiembra;
  final int diasCrecimiento;
  final String humedad;
  final String temperatura;
  final String ph;
  final String nutrientes;
  final String produccionEstimada;
  final String cuidadosEspeciales;
  final String imagen;

  Plant({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.variedad,
    required this.estado,
    required this.seccion,
    required this.subseccion,
    required this.fila,
    required this.pedidoAsociado,
    required this.fechaSiembra,
    required this.diasCrecimiento,
    required this.humedad,
    required this.temperatura,
    required this.ph,
    required this.nutrientes,
    required this.produccionEstimada,
    required this.cuidadosEspeciales,
    required this.imagen,
  });
}
