import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/plant_inventory_controller.dart';
import '../models/plant_model.dart';

class PlantInventoryPage extends StatelessWidget {
  const PlantInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = PlantInventoryController();
        controller.initData();
        return controller;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🌿 Inventario de Plantas'),
          backgroundColor: const Color(0xFF12121D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/dashboard/ingeniero'),
          ),
        ),
        body: const _PlantInventoryBody(),
      ),
    );
  }
}

class _PlantInventoryBody extends StatelessWidget {
  const _PlantInventoryBody();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PlantInventoryController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar planta...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF2A2A40),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: ctrl.updateSearch,
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildSection('Invernadero A', ctrl.filteredA),
              const SizedBox(height: 16),
              _buildSection('Invernadero B', ctrl.filteredB),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Plant> plants) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: const Color(0xFF2A2A40),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (_, i) => _buildCard(plants[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Plant p) {
    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(p.imagen, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 4),
            Text(p.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(p.tipo, style: const TextStyle(color: Colors.tealAccent, fontSize: 12)),
            Text(p.estado, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
