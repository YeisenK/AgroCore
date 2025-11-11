import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/notifiers/siembra_notifier.dart';

class SiembraFormScreen extends StatefulWidget {
  final SiembraModel? siembra;

  const SiembraFormScreen({super.key, this.siembra});

  @override
  State<SiembraFormScreen> createState() => _SiembraFormScreenState();
}

class _SiembraFormScreenState extends State<SiembraFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _loteController;
  late TextEditingController _responsableController;
  DateTime? _fechaSeleccionada;

  bool _isEditMode = false;

  final List<String> _tiposRiegoDisponibles = ['Aspersor', 'Manual', 'Goteo'];
  String? _tipoRiegoSeleccionado;

  List<DetalleSiembraModel> _detallesDeSiembra = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = (widget.siembra != null);

    if (_isEditMode) {
      _loteController = TextEditingController(
        text: widget.siembra!.lote.toString(),
      );
      if (_tiposRiegoDisponibles.contains(widget.siembra!.tipoRiego)) {
        _tipoRiegoSeleccionado = widget.siembra!.tipoRiego;
      }
      _responsableController = TextEditingController(
        text: widget.siembra!.responsable,
      );
      _fechaSeleccionada = widget.siembra!.fechaSiembra;
      _detallesDeSiembra = List.from(widget.siembra!.detalles);
    } else {
      _loteController = TextEditingController();
      _tipoRiegoSeleccionado = null;
      _responsableController = TextEditingController();
      _detallesDeSiembra = [];
    }
  }

  void _guardarFormulario() {
    // Validamos los campos generales (Lote, Fecha)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa los campos generales.'),
        ),
      );
      return;
    }

    // Validación extra: ¿Añadió al menos un cultivo?
    if (_detallesDeSiembra.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes añadir al menos un cultivo.')),
      );
      return;
    }

    final notifier = Provider.of<SiembraNotifier>(context, listen: false);
    final int loteComoInt = int.tryParse(_loteController.text) ?? 0;

    final siembraGuardada = SiembraModel(
      id: _isEditMode ? widget.siembra!.id : const Uuid().v4(),
      lote: loteComoInt,
      fechaSiembra: _fechaSeleccionada!,
      tipoRiego: _tipoRiegoSeleccionado ?? 'No especificado',
      responsable: _responsableController.text,
      timeline: _isEditMode
          ? widget.siembra!.timeline
          : [
              TimelineEvent(
                titulo: 'Siembra Iniciada',
                descripcion: 'Lote creado.',
                fecha: _fechaSeleccionada!,
              ),
            ],
      detalles: _detallesDeSiembra,
    );

    if (_isEditMode) {
      notifier.actualizarSiembra(siembraGuardada);
    } else {
      notifier.addSiembra(siembraGuardada);
    }

    Navigator.of(context).pop();
  }

  /// Función para mostrar el "sub-diálogo" para añadir un cultivo
  void _mostrarDialogoDetalle() async {
    final nuevoDetalle = await showDialog<DetalleSiembraModel>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _AddDetalleDialog();
      },
    );

    if (nuevoDetalle != null) {
      setState(() {
        _detallesDeSiembra.add(nuevoDetalle);
      });
    }
  }

  /// Función para mostrar el calendario
  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Restringido a días pasados
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(24.0),
      constraints: BoxConstraints(
        maxWidth: 500,
        maxHeight: screenSize.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditMode ? 'Editar Siembra' : 'Agregar Siembra',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // --- Formulario Principal (Maestro) ---
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _loteController,
                  decoration: const InputDecoration(labelText: 'Lote *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obligatorio';
                    final loteInt = int.tryParse(v);
                    if (loteInt == null) return 'Debe ser un número válido';

                    final notifier = Provider.of<SiembraNotifier>(
                      context,
                      listen: false,
                    );
                    final idToIgnore = _isEditMode ? widget.siembra!.id : null;
                    if (notifier.checkLoteExists(
                      loteInt,
                      siembraIdToIgnore: idToIgnore,
                    )) {
                      return 'Este número de lote ya existe.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoRiegoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Tipo de Riego'),
                  items: _tiposRiegoDisponibles.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoRiegoSeleccionado = newValue;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _responsableController,
                  decoration: const InputDecoration(labelText: 'Responsable'),
                ),
                const SizedBox(height: 20),

                // --- ✅ AQUÍ ESTÁ EL CAMPO DE FECHA QUE FALTABA ---
                FormField<DateTime>(
                  validator: (value) => (_fechaSeleccionada == null)
                      ? 'Debes seleccionar una fecha'
                      : null,
                  builder: (FormFieldState<DateTime> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              child: Text(
                                _isEditMode ? 'Cambiar' : 'Seleccionar',
                              ),
                            ),
                          ],
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 12.0,
                            ),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // --- ✅ FIN DEL CAMPO DE FECHA ---
              ],
            ),
          ),

          const Divider(height: 32),

          Text(
            'Cultivos Añadidos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Añadir Cultivo'),
            onPressed: _mostrarDialogoDetalle,
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _detallesDeSiembra.isEmpty
                ? const Center(
                    child: Text(
                      'Aún no has añadido cultivos.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _detallesDeSiembra.length,
                    itemBuilder: (context, index) {
                      final detalle = _detallesDeSiembra[index];
                      return ListTile(
                        title: Text(detalle.cultivo),
                        subtitle: Text(
                          '${detalle.especificacion} - Cantidad: ${detalle.cantidad}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _detallesDeSiembra.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),

          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _guardarFormulario,
                child: Text(
                  _isEditMode ? 'Guardar Cambios' : 'Guardar Siembra',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PARA EL "SUB-DIÁLOGO" DE AÑADIR CULTIVO ---
// (Este widget se queda igual, no necesita cambios)

class _AddDetalleDialog extends StatefulWidget {
  @override
  __AddDetalleDialogState createState() => __AddDetalleDialogState();
}

class __AddDetalleDialogState extends State<_AddDetalleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _especificacionController = TextEditingController();
  final _cantidadController = TextEditingController();

  final List<String> _cultivosDisponibles = [
    'Tomate',
    'Chile',
    'Calabaza',
    'Aguacate',
    'Maíz',
    'Frijol',
    'Lechuga',
  ];
  String? _cultivoSeleccionado;

  void _guardarDetalle() {
    if (_formKey.currentState!.validate()) {
      final nuevoDetalle = DetalleSiembraModel(
        cultivo: _cultivoSeleccionado!,
        especificacion: _especificacionController.text.isNotEmpty
            ? _especificacionController.text
            : 'N/A', // Valor por defecto
        cantidad: int.tryParse(_cantidadController.text) ?? 0,
      );
      Navigator.of(context).pop(nuevoDetalle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir Cultivo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _cultivoSeleccionado,
              decoration: const InputDecoration(labelText: 'Cultivo *'),
              items: _cultivosDisponibles.map((String cultivo) {
                return DropdownMenuItem<String>(
                  value: cultivo,
                  child: Text(cultivo),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _cultivoSeleccionado = newValue;
                });
              },
              validator: (value) =>
                  (value == null) ? 'Selecciona un cultivo' : null,
            ),
            TextFormField(
              controller: _especificacionController,
              decoration: const InputDecoration(labelText: 'Especificación'),
              // No es obligatorio, así que no tiene validador
            ),
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad *'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Define una cantidad';
                if (int.tryParse(v) == 0) return 'La cantidad no puede ser 0';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _guardarDetalle, child: const Text('Añadir')),
      ],
    );
  }
}
