import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/notifiers/siembra_notifier.dart';

class SiembraFormScreen extends StatefulWidget {
  // --- CAMBIO 1: Acepta una siembra opcional ---
  final SiembraModel? siembra;

  const SiembraFormScreen({super.key, this.siembra});

  @override
  State<SiembraFormScreen> createState() => _SiembraFormScreenState();
}

class _SiembraFormScreenState extends State<SiembraFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- CAMBIO 2: Controladores declarados (no inicializados) ---
  late TextEditingController _loteController;
  late TextEditingController _cultivoController;
  late TextEditingController _especificacionController;
  late TextEditingController _tipoRiegoController;
  late TextEditingController _responsableController;
  DateTime? _fechaSeleccionada;

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    // --- CAMBIO 3: Lógica para pre-llenar los campos ---
    if (widget.siembra != null) {
      // MODO EDICIÓN: Llenamos los campos con los datos existentes.
      _isEditMode = true;
      _loteController = TextEditingController(text: widget.siembra!.lote);
      _cultivoController = TextEditingController(text: widget.siembra!.cultivo);
      _especificacionController = TextEditingController(
        text: widget.siembra!.especificacion,
      );
      _tipoRiegoController = TextEditingController(
        text: widget.siembra!.tipoRiego,
      );
      _responsableController = TextEditingController(
        text: widget.siembra!.responsable,
      );
      _fechaSeleccionada = widget.siembra!.fechaSiembra;
    } else {
      // MODO CREACIÓN: Los campos empiezan vacíos.
      _isEditMode = false;
      _loteController = TextEditingController();
      _cultivoController = TextEditingController();
      _especificacionController = TextEditingController();
      _tipoRiegoController = TextEditingController();
      _responsableController = TextEditingController();
    }
  }

  // --- CAMBIO 4: Lógica de guardado unificada ---
  void _guardarFormulario() {
    // Validamos el formulario
    if (!_formKey.currentState!.validate() || _fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos obligatorios.'),
        ),
      );
      return;
    }

    final notifier = Provider.of<SiembraNotifier>(context, listen: false);

    // Creamos el modelo con los datos del formulario
    final siembraGuardada = SiembraModel(
      // Si editamos, re-usamos el ID. Si creamos, generamos uno nuevo.
      id: _isEditMode ? widget.siembra!.id : const Uuid().v4(),
      lote: _loteController.text,
      cultivo: _cultivoController.text,
      fechaSiembra: _fechaSeleccionada!,
      especificacion: _especificacionController.text,
      tipoRiego: _tipoRiegoController.text,
      responsable: _responsableController.text,
      // Si editamos, conservamos el timeline. Si creamos, lo dejamos vacío.
      timeline: _isEditMode ? widget.siembra!.timeline : [],
    );

    // Llamamos a la función correspondiente del notifier
    if (_isEditMode) {
      notifier.actualizarSiembra(siembraGuardada);
    } else {
      notifier.addSiembra(siembraGuardada);
    }

    Navigator.of(context).pop(); // Cerramos el formulario
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- CAMBIO 5: Título dinámico ---
        title: Text(_isEditMode ? 'Editar Siembra' : 'Agregar Siembra'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _loteController, // El controlador ya tiene el valor
                decoration: const InputDecoration(labelText: 'Lote *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller:
                    _cultivoController, // El controlador ya tiene el valor
                decoration: const InputDecoration(labelText: 'Cultivo *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller:
                    _especificacionController, // El controlador ya tiene el valor
                decoration: const InputDecoration(labelText: 'Especificación'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller:
                    _tipoRiegoController, // El controlador ya tiene el valor
                decoration: const InputDecoration(labelText: 'Tipo de Riego'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller:
                    _responsableController, // El controlador ya tiene el valor
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 20),
              // Campo de fecha (también se pre-llena)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaSeleccionada == null
                          ? 'Fecha de siembra *'
                          : 'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _seleccionarFecha,
                    child: Text(_isEditMode ? 'Cambiar' : 'Seleccionar'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _guardarFormulario,
                icon: const Icon(Icons.save),
                // --- CAMBIO 6: Texto del botón dinámico ---
                label: Text(
                  _isEditMode ? 'Guardar Cambios' : 'Guardar Siembra',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
