import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Rutas de paquete corregidas
import 'package:main/features/gestion_siembra/models/siembra_model.dart';
import 'package:main/features/gestion_siembra/notifiers/siembra_notifier.dart';

class SiembraFormScreen extends StatefulWidget {
  const SiembraFormScreen({super.key});

  @override
  State<SiembraFormScreen> createState() => _SiembraFormScreenState();
}

class _SiembraFormScreenState extends State<SiembraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loteController = TextEditingController();
  final _especificacionController = TextEditingController();
  final _cultivoController = TextEditingController();

  DateTime? _fechaSeleccionada;
  String? _riegoSeleccionado;

  // Datos de ejemplo para los menús desplegables

  final List<String> _tiposRiego = ['Aspersión', 'Manual'];
  final _responsableController = TextEditingController();

  @override
  void dispose() {
    _loteController.dispose();
    _especificacionController.dispose();
    _responsableController.dispose();
    _cultivoController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final nuevaSiembra = SiembraModel(
        id: '',
        lote: _loteController.text,
        cultivo: _cultivoController.text,
        fechaSiembra: _fechaSeleccionada!,
        especificacion: _especificacionController.text,
        tipoRiego: _riegoSeleccionado!,
        responsable: _responsableController.text,
        timeline: [],
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await Provider.of<SiembraNotifier>(
        context,
        listen: false,
      ).addSiembra(nuevaSiembra);

      if (mounted) {
        Navigator.pop(context); // Cierra el diálogo de carga
        Navigator.pop(context); // Cierra el formulario
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Siembra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _loteController,
              decoration: const InputDecoration(
                labelText: 'Lote',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'El lote es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cultivoController,
              decoration: const InputDecoration(
                labelText: 'Cultivo',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization
                  .sentences, // Pone en mayúscula la primera letra
              validator: (value) => (value == null || value.isEmpty)
                  ? 'El cultivo es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _especificacionController,
              decoration: const InputDecoration(
                labelText: 'Especificación',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La especificación es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha de Siembra',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
                hintText: _fechaSeleccionada == null
                    ? 'Seleccione una fecha'
                    : DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
              ),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (fecha != null) {
                  setState(() => _fechaSeleccionada = fecha);
                }
              },
              validator: (value) =>
                  _fechaSeleccionada == null ? 'La fecha es obligatoria' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _riegoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Riego',
                border: OutlineInputBorder(),
              ),
              items: _tiposRiego
                  .map(
                    (riego) =>
                        DropdownMenuItem(value: riego, child: Text(riego)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _riegoSeleccionado = value),
              validator: (value) =>
                  value == null ? 'Seleccione un tipo de riego' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller:
                  _responsableController, // Usa el controlador que creamos
              decoration: const InputDecoration(
                labelText: 'Responsable',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization
                  .words, // Para que ponga mayúsculas en los nombres
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Asigne un responsable'
                  : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Siembra'),
            ),
          ],
        ),
      ),
    );
  }
}
