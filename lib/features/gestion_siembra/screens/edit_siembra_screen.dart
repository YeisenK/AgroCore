import 'package:flutter/material.dart';
import '../models/siembra_model.dart';

class EditSiembraScreen extends StatefulWidget {
  final SiembraModel siembra;

  const EditSiembraScreen({super.key, required this.siembra});

  @override
  State<EditSiembraScreen> createState() => _EditSiembraScreenState();
}

class _EditSiembraScreenState extends State<EditSiembraScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _loteController;
  late TextEditingController _cultivoController;
  late TextEditingController _especificacionController;
  late TextEditingController _tipoRiegoController;
  late TextEditingController _responsableController;
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos de la siembra existente en los controladores del formulario.
    _loteController = TextEditingController(text: widget.siembra.lote);
    _cultivoController = TextEditingController(text: widget.siembra.cultivo);
    _especificacionController = TextEditingController(
      text: widget.siembra.especificacion,
    );
    _tipoRiegoController = TextEditingController(
      text: widget.siembra.tipoRiego,
    );
    _responsableController = TextEditingController(
      text: widget.siembra.responsable,
    );
    _fechaSeleccionada = widget.siembra.fechaSiembra;
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

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      // Creamos un nuevo objeto SiembraModel con los datos actualizados.
      final siembraActualizada = SiembraModel(
        id: widget.siembra.id, // Mantenemos el mismo ID
        lote: _loteController.text,
        cultivo: _cultivoController.text,
        fechaSiembra: _fechaSeleccionada!,
        especificacion: _especificacionController.text,
        tipoRiego: _tipoRiegoController.text,
        responsable: _responsableController.text,
        timeline: widget.siembra.timeline, // Mantenemos el timeline existente
      );
      // Devolvemos el objeto actualizado a la pantalla anterior.
      Navigator.of(context).pop(siembraActualizada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Siembra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (Los TextFormField son iguales que en AddSiembraScreen) ...
              TextFormField(
                controller: _loteController,
                decoration: const InputDecoration(labelText: 'Lote *'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cultivoController,
                decoration: const InputDecoration(labelText: 'Cultivo *'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _especificacionController,
                decoration: const InputDecoration(labelText: 'Especificación'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipoRiegoController,
                decoration: const InputDecoration(labelText: 'Tipo de Riego'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _responsableController,
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 20),
              FormField<DateTime>(
                validator: (v) =>
                    _fechaSeleccionada == null ? 'Selecciona una fecha' : null,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                            ),
                          ),
                          TextButton(
                            onPressed: _seleccionarFecha,
                            child: const Text('Cambiar'),
                          ),
                        ],
                      ),
                      if (state.hasError)
                        Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
