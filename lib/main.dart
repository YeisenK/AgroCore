import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFF2A2A40),
        ),
      ),
      home: const PlantInventoryPage(),
    );
  }
}

// PÁGINA DE INVENTARIO DE PLANTAS
class PlantInventoryPage extends StatefulWidget {
  const PlantInventoryPage({super.key});

  @override
  State<PlantInventoryPage> createState() => _PlantInventoryPageState();
}

class _PlantInventoryPageState extends State<PlantInventoryPage> {
  final Random _random = Random();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todas';

  // Tipos de plantas reales para agricultura
  final List<String> _plantTypes = [
    'Maíz', 'Frijol', 'Trigo', 'Arroz', 'Sorgo',
    'Tomate', 'Chile', 'Cebolla', 'Zanahoria', 'Lechuga',
    'Papa', 'Calabaza', 'Pepino', 'Brócoli', 'Coliflor',
    'Espinaca', 'Acelga', 'Rábano', 'Betabel', 'Apio'
  ];

  // Datos de ejemplo para las plantas
  final List<Map<String, dynamic>> _invernaderoA = [];
  final List<Map<String, dynamic>> _invernaderoB = [];

  @override
  void initState() {
    super.initState();
    _initializePlantData();
  }

  void _initializePlantData() {
    // Invernadero A - 30 plantas
    for (int i = 1; i <= 30; i++) {
      final plantType = _getRandomPlantType();
      _invernaderoA.add({
        'id': 'IA-P${i.toString().padLeft(2, '0')}',
        'nombre': 'Planta A-$i',
        'tipo': plantType,
        'variedad': _getRandomVariety(plantType),
        'estado': _getRandomPlantState(),
        'seccion': 'Invernadero A',
        'subseccion': 'Sector ${((i - 1) ~/ 6) + 1}',
        'fila': 'Fila ${((i - 1) % 6) + 1}',
        'pedidoAsociado': _getRandomOrderId(),
        'fechaSiembra': _getRandomDate(),
        'diasCrecimiento': _random.nextInt(90) + 10,
        'humedad': '${65 + _random.nextInt(25)}%',
        'temperatura': '${22 + _random.nextInt(8)}°C',
        'ph': (6.0 + _random.nextDouble() * 1.5).toStringAsFixed(1),
        'nutrientes': _getRandomNutrientLevel(),
        'produccionEstimada': '${_random.nextInt(20) + 5}kg',
        'cuidadosEspeciales': _getRandomCare(),
        'imagen': _getPlantImage(plantType),
      });
    }

    // Invernadero B - 30 plantas
    for (int i = 1; i <= 30; i++) {
      final plantType = _getRandomPlantType();
      _invernaderoB.add({
        'id': 'IB-P${i.toString().padLeft(2, '0')}',
        'nombre': 'Planta B-$i',
        'tipo': plantType,
        'variedad': _getRandomVariety(plantType),
        'estado': _getRandomPlantState(),
        'seccion': 'Invernadero B',
        'subseccion': 'Sector ${((i - 1) ~/ 6) + 1}',
        'fila': 'Fila ${((i - 1) % 6) + 1}',
        'pedidoAsociado': _getRandomOrderId(),
        'fechaSiembra': _getRandomDate(),
        'diasCrecimiento': _random.nextInt(90) + 10,
        'humedad': '${65 + _random.nextInt(25)}%',
        'temperatura': '${22 + _random.nextInt(8)}°C',
        'ph': (6.0 + _random.nextDouble() * 1.5).toStringAsFixed(1),
        'nutrientes': _getRandomNutrientLevel(),
        'produccionEstimada': '${_random.nextInt(20) + 5}kg',
        'cuidadosEspeciales': _getRandomCare(),
        'imagen': _getPlantImage(plantType),
      });
    }
  }

  // Métodos auxiliares para generar datos aleatorios
  String _getRandomPlantType() {
    return _plantTypes[_random.nextInt(_plantTypes.length)];
  }

  String _getRandomVariety(String plantType) {
    final varieties = {
      'Maíz': ['Criollo', 'Híbrido', 'Dulce', 'Palomero', 'Forrajero'],
      'Frijol': ['Negro', 'Bayo', 'Pinto', 'Flor de Mayo', 'Peruano'],
      'Trigo': ['Cristalino', 'Suave', 'Duro', 'Invernal', 'Primaveral'],
      'Arroz': ['Integral', 'Blanco', 'Jazmín', 'Basmati', 'Arbóreo'],
      'Sorgo': ['Grano', 'Forrajero', 'Azucarado', 'Dulce', 'Blanco'],
      'Tomate': ['Cherry', 'Roma', 'Beefsteak', 'Heirloom', 'Cereza'],
      'Chile': ['Jalapeño', 'Serrano', 'Habanero', 'Poblano', 'Bell'],
      'Cebolla': ['Blanca', 'Morada', 'Amarilla', 'Vidalia', 'Chalota'],
      'Zanahoria': ['Nantes', 'Imperator', 'Chantenay', 'Baby', 'Morada'],
      'Lechuga': ['Romana', 'Iceberg', 'Butterhead', 'Oak Leaf', 'Lollo Rosso'],
      'Papa': ['Blanca', 'Roja', 'Russet', 'Yukon', 'Fingerling'],
      'Calabaza': ['Butternut', 'Acorn', 'Spaghetti', 'Kabocha', 'Delicata'],
      'Pepino': ['Persa', 'Armenio', 'Limon', 'English', 'Pickling'],
      'Brócoli': ['Calabrese', 'Romanesco', 'Sprouting', 'Chinese', 'Purple'],
      'Coliflor': ['Blanca', 'Verde', 'Morada', 'Romanesco', 'Orange'],
      'Espinaca': ['Savoy', 'Flat-leaf', 'Baby', 'New Zealand', 'Malabar'],
      'Acelga': ['Verde', 'Roja', 'Arcoíris', 'Lucullus', 'Fordhook'],
      'Rábano': ['Rojo', 'Blanco', 'Daikon', 'Black Spanish', 'Watermelon'],
      'Betabel': ['Rojo', 'Dorado', 'Chioggia', 'Cylindra', 'Baby'],
      'Apio': ['Pascal', 'Tango', 'Golden', 'Chinese', 'Leaf'],
    };
    return varieties[plantType]?[_random.nextInt(5)] ?? 'Tradicional';
  }

  String _getRandomPlantState() {
    final states = ['Excelente', 'Bueno', 'Regular', 'Necesita Atención'];
    return states[_random.nextInt(states.length)];
  }

  String _getRandomOrderId() {
    final orders = ['ORD-001', 'ORD-002', 'ORD-003', 'ORD-004', 'ORD-005', 'ORD-006'];
    return orders[_random.nextInt(orders.length)];
  }

  String _getRandomDate() {
    final day = _random.nextInt(28) + 1;
    final month = _random.nextInt(12) + 1;
    return '2024-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String _getRandomNutrientLevel() {
    final levels = ['Bajo', 'Óptimo', 'Alto', 'Excesivo'];
    return levels[_random.nextInt(levels.length)];
  }

  String _getRandomCare() {
    final cares = [
      'Riego cada 2 días',
      'Fertilizar semanalmente',
      'Control de plagas necesario',
      'Poda requerida',
      'Soporte de crecimiento',
      'Sin cuidados especiales',
      'Control de humedad crítico',
      'Protección contra heladas',
      'Rotación de cultivo',
      'Acolchado necesario'
    ];
    return cares[_random.nextInt(cares.length)];
  }

  String _getPlantImage(String plantType) {
    final images = {
      'Maíz': '🌽',
      'Frijol': '🫘',
      'Trigo': '🌾',
      'Arroz': '🍚',
      'Sorgo': '🌾',
      'Tomate': '🍅',
      'Chile': '🌶️',
      'Cebolla': '🧅',
      'Zanahoria': '🥕',
      'Lechuga': '🥬',
      'Papa': '🥔',
      'Calabaza': '🎃',
      'Pepino': '🥒',
      'Brócoli': '🥦',
      'Coliflor': '🪸',
      'Espinaca': '🌿',
      'Acelga': '🍃',
      'Rábano': '🌱',
      'Betabel': '🍠',
      'Apio': '🥬',
    };
    return images[plantType] ?? '🌱';
  }

  List<Map<String, dynamic>> get _filteredInvernaderoA {
    final query = _searchController.text.toLowerCase();
    var filtered = _invernaderoA;

    if (_selectedFilter != 'Todas') {
      filtered = filtered.where((plant) => plant['estado'] == _selectedFilter).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((plant) =>
          plant['nombre'].toLowerCase().contains(query) ||
          plant['tipo'].toLowerCase().contains(query) ||
          plant['variedad'].toLowerCase().contains(query) ||
          plant['pedidoAsociado'].toLowerCase().contains(query) ||
          plant['subseccion'].toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _filteredInvernaderoB {
    final query = _searchController.text.toLowerCase();
    var filtered = _invernaderoB;

    if (_selectedFilter != 'Todas') {
      filtered = filtered.where((plant) => plant['estado'] == _selectedFilter).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((plant) =>
          plant['nombre'].toLowerCase().contains(query) ||
          plant['tipo'].toLowerCase().contains(query) ||
          plant['variedad'].toLowerCase().contains(query) ||
          plant['pedidoAsociado'].toLowerCase().contains(query) ||
          plant['subseccion'].toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('🌿 Inventario de Plantas Agrícolas'),
        backgroundColor: const Color(0xFF12121D),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por tipo, variedad, pedido o ubicación...',
                    prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A40),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Excelente', 'Bueno', 'Regular', 'Necesita Atención']
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: _selectedFilter == filter,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = selected ? filter : 'Todas';
                                  });
                                },
                                backgroundColor: const Color(0xFF2A2A40),
                                selectedColor: Colors.teal.withOpacity(0.3),
                                labelStyle: TextStyle(
                                  color: _selectedFilter == filter ? Colors.tealAccent : Colors.white70,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Mostrando ${_filteredInvernaderoA.length + _filteredInvernaderoB.length} de 60 plantas',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                _buildStatsChip(_filteredInvernaderoA.length, 'Invernadero A'),
                const SizedBox(width: 8),
                _buildStatsChip(_filteredInvernaderoB.length, 'Invernadero B'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contenido principal
          Expanded(
            child: ListView(
              children: [
                // Sección Invernadero A
                _buildPlantSection('🏭 Invernadero A - Cultivos Variados', _filteredInvernaderoA),
                const SizedBox(height: 20),
                
                // Sección Invernadero B
                _buildPlantSection('🏭 Invernadero B - Hortalizas', _filteredInvernaderoB),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChip(int count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(fontSize: 12, color: Colors.tealAccent),
      ),
    );
  }

  Widget _buildPlantSection(String title, List<Map<String, dynamic>> plants) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: const Color(0xFF2A2A40),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${plants.length} plantas',
                      style: const TextStyle(fontSize: 12, color: Colors.tealAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (plants.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No se encontraron plantas\nque coincidan con los filtros',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    return _buildPlantCard(plants[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    Color estadoColor;
    String estadoText;

    switch (plant['estado']) {
      case 'Excelente':
        estadoColor = Colors.green;
        estadoText = 'Excelente';
        break;
      case 'Bueno':
        estadoColor = Colors.blue;
        estadoText = 'Bueno';
        break;
      case 'Regular':
        estadoColor = Colors.orange;
        estadoText = 'Regular';
        break;
      case 'Necesita Atención':
        estadoColor = Colors.red;
        estadoText = 'Atención';
        break;
      default:
        estadoColor = Colors.grey;
        estadoText = 'N/A';
    }

    return Card(
      elevation: 2,
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showPlantDetails(plant),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji de la planta
              Text(
                plant['imagen'],
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
              
              // ID de la planta
              Text(
                plant['id'],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Tipo de planta
              Text(
                plant['tipo'],
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Variedad
              Text(
                plant['variedad'],
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Estado con color
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: estadoColor.withOpacity(0.5), width: 0.5),
                ),
                child: Text(
                  estadoText,
                  style: TextStyle(
                    fontSize: 8,
                    color: estadoColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 2),
              
              // Pedido asociado
              Text(
                'Ped: ${plant['pedidoAsociado']}',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.orangeAccent,
                ),
              ),
              
              // Ubicación
              Text(
                '${plant['subseccion']} • ${plant['fila']}',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlantDetails(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2A2A40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(plant['imagen'], style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant['tipo'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Variedad: ${plant['variedad']}',
                            style: const TextStyle(fontSize: 14, color: Colors.tealAccent),
                          ),
                          Text(
                            plant['id'],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Información básica
                _buildDetailSection('📋 Información Básica', [
                  _buildDetailItem('Estado', plant['estado']),
                  _buildDetailItem('Sección', plant['seccion']),
                  _buildDetailItem('Subsección', plant['subseccion']),
                  _buildDetailItem('Fila', plant['fila']),
                  _buildDetailItem('Fecha Siembra', plant['fechaSiembra']),
                  _buildDetailItem('Días Crecimiento', '${plant['diasCrecimiento']} días'),
                ]),
                
                const SizedBox(height: 20),
                
                // Condiciones
                _buildDetailSection('🌡️ Condiciones Actuales', [
                  _buildDetailItem('Humedad', plant['humedad']),
                  _buildDetailItem('Temperatura', plant['temperatura']),
                  _buildDetailItem('pH', plant['ph']),
                  _buildDetailItem('Nivel Nutrientes', plant['nutrientes']),
                ]),
                
                const SizedBox(height: 20),
                
                // Producción y Pedido
                _buildDetailSection('📦 Producción y Pedido', [
                  _buildDetailItem('Producción Estimada', plant['produccionEstimada']),
                  _buildDetailItem('Pedido Asociado', plant['pedidoAsociado']),
                  _buildDetailItem('Cuidados Especiales', plant['cuidadosEspeciales']),
                ]),
                
                const SizedBox(height: 24),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showOrderInfo(plant['pedidoAsociado']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Ver Pedido'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderInfo(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📦 Pedido $orderId'),
        backgroundColor: const Color(0xFF2A2A40),
        content: Text(
          'Información del pedido $orderId\n\n'
          'Cliente: Cliente Asociado\n'
          'Estado: En proceso\n'
          'Fecha entrega: Próximos días\n'
          'Productos: Varios cultivos agrícolas',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }
}
