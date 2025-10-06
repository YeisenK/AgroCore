import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

// Importamos el modelo de datos con el que vamos a trabajar
import 'package:main/features/gestion_siembra/models/siembra_model.dart';

class MockSiembraRepository {
  // Caché para guardar los datos en memoria una vez leídos del JSON.
  // Así no tenemos que leer el archivo del disco cada vez.
  List<SiembraModel>? _cachedSiembras;

  // Instancia del generador de IDs únicos.
  final _uuid = const Uuid();

  /// Obtiene la lista de siembras.
  /// La primera vez las lee del archivo JSON, las siguientes veces las devuelve de la memoria (caché).
  Future<List<SiembraModel>> getSiembras() async {
    // Simula la latencia de una petición a una API o base de datos.
    await Future.delayed(const Duration(seconds: 1));

    // Si ya tenemos los datos en caché, los devolvemos directamente.
    if (_cachedSiembras != null) {
      return _cachedSiembras!;
    }

    // Si no están en caché, los leemos del archivo JSON.
    final jsonString = await rootBundle.loadString('assets/mock/siembras.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    print(
      '📦 [REPOSITORIO] JSON decodificado. Número de elementos: ${jsonList.length}',
    );
    // Convertimos la lista de mapas JSON a una lista de SiembraModel.

    // Guardamos los datos leídos en nuestra caché para futuras peticiones.
    _cachedSiembras = jsonList
        .map((json) => SiembraModel.fromJson(json))
        .toList();

    if (_cachedSiembras!.isNotEmpty) {
      print(
        '✅ [REPOSITORIO] Modelos parseados. Primer lote: ${_cachedSiembras!.first.lote}',
      );
    }

    return _cachedSiembras!;
  }

  /// Añade una nueva siembra a nuestra lista en memoria.
  Future<void> addSiembra(SiembraModel siembra) async {
    // Simula el tiempo que tardaría en guardar en una base de datos.
    await Future.delayed(const Duration(milliseconds: 500));

    // Si la caché no ha sido inicializada, la cargamos primero.
    if (_cachedSiembras == null) {
      await getSiembras();
    }

    // Creamos una nueva instancia de la siembra con un ID único y un evento inicial en el timeline.
    final nuevaSiembraConId = SiembraModel(
      id: _uuid.v4(), // Generamos un ID único y aleatorio
      lote: siembra.lote,
      cultivo: siembra.cultivo,
      fechaSiembra: siembra.fechaSiembra,
      especificacion: siembra.especificacion,
      tipoRiego: siembra.tipoRiego,
      responsable: siembra.responsable,
      timeline: [
        TimelineEvent(
          titulo: 'Siembra Iniciada',
          descripcion: 'Lote creado en el sistema.',
          fecha: siembra.fechaSiembra,
        ),
      ],
    );

    // Añadimos la nueva siembra a nuestra lista en memoria.
    _cachedSiembras!.add(nuevaSiembraConId);
  }
}
