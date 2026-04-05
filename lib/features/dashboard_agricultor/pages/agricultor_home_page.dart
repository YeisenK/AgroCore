import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/core/widgets/app_shell.dart';
import '../../../app/data/auth/auth_controller.dart';

class _RoleSwitcherAction extends StatelessWidget {
  const _RoleSwitcherAction();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final roles = auth.currentUser?.roles ?? const <String>[];

    if (roles.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Volver a selección de usuario',
      icon: const Icon(Icons.switch_account),
      onPressed: () => context.go(auth.preferredHome()),
    );
  }
}

class AgricultorHomePage extends StatefulWidget {
  const AgricultorHomePage({super.key});

  @override
  State<AgricultorHomePage> createState() => _AgricultorHomePageState();
}

class _AgricultorHomePageState extends State<AgricultorHomePage> {
  // Controladores
  Timer? _refreshTimer;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final Random _random = Random();

  // Estado
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 0;
  String _selectedOrderFilter = 'Todos';
  double _chartInterval = 4.0;

  // Datos de sensores
  int _activeOrders = 0;
  int _upcomingDeliveries = 0;
  
  // Datos de sensores específicos
  double _currentSoilMoisture = 0.0;
  double _currentTemperature = 0.0;
  double _currentAirHumidity = 0.0;
  
  final List<FlSpot> _soilMoistureData = [];
  final List<FlSpot> _temperatureData = [];
  final List<FlSpot> _airHumidityData = [];
  
  final List<Map<String, dynamic>> _recentOrders = [];
  final List<Map<String, dynamic>> _alerts = [];

  // Lista de sensores simulados
  final List<Map<String, dynamic>> _sensors = [
    {
      'id': 'YL69_001',
      'name': 'Sensor Humedad Suelo',
      'type': 'YL-69',
      'location': 'Sector Norte - Tomates',
      'online': true,
      'lastReading': 65.5,
      'unit': '%'
    },
    {
      'id': 'DHT11_001',
      'name': 'Sensor Ambiental',
      'type': 'DHT11',
      'location': 'Sector Norte - Tomates',
      'online': true,
      'lastReading': 24.2,
      'unit': '°C'
    },
    {
      'id': 'YL69_002',
      'name': 'Sensor Humedad Suelo',
      'type': 'YL-69',
      'location': 'Sector Sur - Lechugas',
      'online': true,
      'lastReading': 72.3,
      'unit': '%'
    },
  ];

  // Getter para pedidos filtrados y buscados
  List<Map<String, dynamic>> get _searchedOrders {
    var filtered = _recentOrders;
    
    // Aplicar filtro de estado
    if (_selectedOrderFilter != 'Todos') {
      filtered = filtered.where((order) => 
        order['estado'] == _selectedOrderFilter
      ).toList();
    }
    
    // Aplicar búsqueda
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((order) =>
        order['cliente'].toString().toLowerCase().contains(query) ||
        order['productos'].toString().toLowerCase().contains(query) ||
        order['estado'].toString().toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    
    // Configurar actualización automática cada 10 segundos (más rápido para sensores)
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshData();
    });
  }

  // Cargar datos iniciales
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadKPIData(),
        _loadChartData(),
        _loadOrdersData(),
        _loadAlertsData(),
        _loadSensorsData(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Actualizar datos
  Future<void> _refreshData() async {
    if (_isLoading) return;

    try {
      await Future.wait([
        _loadKPIData(),
        _loadChartData(),
        _loadAlertsData(),
        _loadSensorsData(),
      ]);
    } catch (e) {
      print('Error en refresh automático: $e');
    }
  }

  // Cargar datos de KPIs con sensores reales
  Future<void> _loadKPIData() async {
    // Simulación de datos reales de sensores
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      // Datos realistas para agricultura
      _currentSoilMoisture = 60.0 + _random.nextDouble() * 20; // 60-80%
      _currentTemperature = 20.0 + _random.nextDouble() * 12;  // 20-32°C
      _currentAirHumidity = 45.0 + _random.nextDouble() * 25;  // 45-70%
      
      _activeOrders = 8 + _random.nextInt(7); // 8-15 pedidos
      _upcomingDeliveries = 3 + _random.nextInt(4); // 3-7 entregas
    });
  }

  // Cargar datos para gráficos
  Future<void> _loadChartData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    setState(() {
      // Generar datos históricos si está vacío
      if (_soilMoistureData.isEmpty) {
        final now = DateTime.now();
        for (int i = 0; i < 24; i++) {
          final time = now.subtract(Duration(hours: 23 - i));
          
          // Datos realistas para sensores
          double soilMoisture = 60.0 + _random.nextDouble() * 15; // YL-69: 60-75%
          double temperature = 22.0 + _random.nextDouble() * 8;   // DHT11: 22-30°C
          double airHumidity = 50.0 + _random.nextDouble() * 20;  // DHT11: 50-70%
          
          _soilMoistureData.add(FlSpot(i.toDouble(), soilMoisture));
          _temperatureData.add(FlSpot(i.toDouble(), temperature));
          _airHumidityData.add(FlSpot(i.toDouble(), airHumidity));
        }
      } else {
        // Actualizar con nuevos datos en tiempo real
        if (_soilMoistureData.length >= 24) _soilMoistureData.removeAt(0);
        if (_temperatureData.length >= 24) _temperatureData.removeAt(0);
        if (_airHumidityData.length >= 24) _airHumidityData.removeAt(0);
        
        // Agregar nuevos datos manteniendo el rango de 24 horas
        const lastX = 23.0;
        _soilMoistureData.add(FlSpot(lastX, _currentSoilMoisture));
        _temperatureData.add(FlSpot(lastX, _currentTemperature));
        _airHumidityData.add(FlSpot(lastX, _currentAirHumidity));
        
        // Renumerar los puntos X para mantener el rango 0-23
        for (int i = 0; i < _soilMoistureData.length; i++) {
          _soilMoistureData[i] = FlSpot(i.toDouble(), _soilMoistureData[i].y);
          _temperatureData[i] = FlSpot(i.toDouble(), _temperatureData[i].y);
          _airHumidityData[i] = FlSpot(i.toDouble(), _airHumidityData[i].y);
        }
      }
    });
  }

  // Cargar datos de pedidos
  Future<void> _loadOrdersData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      _recentOrders.clear();
      _recentOrders.addAll([
        {
          'id': 1,
          'cliente': 'Supermercado Oaxaca', 
          'fecha': 'Hoy 10:00 AM', 
          'estado': 'En camino',
          'productos': 'Tomates (50kg), Lechugas (30kg)',
          'direccion': 'Av. Principal 123, Oaxaca',
          'total': '\$1,250.00'
        },
        {
          'id': 2,
          'cliente': 'Restaurante Istmo', 
          'fecha': 'Hoy 01:30 PM', 
          'estado': 'Preparando',
          'productos': 'Zanahorias (20kg), Cebollas (15kg)',
          'direccion': 'Calle Reforma 456, Istmo',
          'total': '\$650.00'
        },
        {
          'id': 3,
          'cliente': 'Mercado Juárez', 
          'fecha': 'Mañana 09:00 AM', 
          'estado': 'Programado',
          'productos': 'Pepinos (40kg), Pimientos (25kg)',
          'direccion': 'Plaza Central 789, Juárez',
          'total': '\$890.00'
        },
      ]);
    });
  }

  // Cargar datos de alertas específicas para sensores
  Future<void> _loadAlertsData() async {
    await Future.delayed(const Duration(milliseconds: 350));
    
    // Generar alertas basadas en los datos actuales de sensores
    final newAlerts = <Map<String, dynamic>>[];
    
    // Alertas de humedad del suelo (YL-69)
    if (_currentSoilMoisture < 30) {
      newAlerts.add({
        'id': DateTime.now().millisecondsSinceEpoch + 1,
        'mensaje': 'Humedad del suelo muy baja',
        'nivel': 'Alto',
        'fecha': 'Ahora',
        'detalles': 'Humedad del suelo: ${_currentSoilMoisture.toStringAsFixed(1)}%. Se recomienda riego inmediato.',
        'resuelta': false,
        'sensor': 'YL69_001',
        'tipo': 'humedad_suelo'
      });
    } else if (_currentSoilMoisture > 85) {
      newAlerts.add({
        'id': DateTime.now().millisecondsSinceEpoch + 2,
        'mensaje': 'Suelo saturado de agua',
        'nivel': 'Medio',
        'fecha': 'Ahora',
        'detalles': 'Humedad del suelo: ${_currentSoilMoisture.toStringAsFixed(1)}%. Considerar reducir riego.',
        'resuelta': false,
        'sensor': 'YL69_001',
        'tipo': 'humedad_suelo'
      });
    }
    
    // Alertas de temperatura (DHT11)
    if (_currentTemperature < 15) {
      newAlerts.add({
        'id': DateTime.now().millisecondsSinceEpoch + 3,
        'mensaje': 'Temperatura muy baja',
        'nivel': 'Medio',
        'fecha': 'Ahora',
        'detalles': 'Temperatura: ${_currentTemperature.toStringAsFixed(1)}°C. Riesgo para cultivos tropicales.',
        'resuelta': false,
        'sensor': 'DHT11_001',
        'tipo': 'temperatura'
      });
    } else if (_currentTemperature > 35) {
      newAlerts.add({
        'id': DateTime.now().millisecondsSinceEpoch + 4,
        'mensaje': 'Temperatura muy alta',
        'nivel': 'Alto',
        'fecha': 'Ahora',
        'detalles': 'Temperatura: ${_currentTemperature.toStringAsFixed(1)}°C. Riesgo de estrés térmico.',
        'resuelta': false,
        'sensor': 'DHT11_001',
        'tipo': 'temperatura'
      });
    }
    
    // Alertas de humedad ambiental (DHT11)
    if (_currentAirHumidity < 40) {
      newAlerts.add({
        'id': DateTime.now().millisecondsSinceEpoch + 5,
        'mensaje': 'Humedad ambiental baja',
        'nivel': 'Bajo',
        'fecha': 'Ahora',
        'detalles': 'Humedad ambiental: ${_currentAirHumidity.toStringAsFixed(1)}%. Considerar humidificación.',
        'resuelta': false,
        'sensor': 'DHT11_001',
        'tipo': 'humedad_ambiental'
      });
    }

    setState(() {
      // Mantener solo las últimas 10 alertas
      if (_alerts.length + newAlerts.length > 10) {
        _alerts.removeRange(0, (_alerts.length + newAlerts.length) - 10);
      }
      
      // Agregar nuevas alertas al inicio
      _alerts.insertAll(0, newAlerts);
    });
  }

  // Cargar datos de sensores
  Future<void> _loadSensorsData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    
    setState(() {
      // Actualizar estado de sensores (simular desconexiones ocasionales)
      for (var sensor in _sensors) {
        if (_random.nextDouble() < 0.05) { // 5% de probabilidad de desconexión
          sensor['online'] = !sensor['online'];
        }
        
        // Actualizar lecturas
        if (sensor['type'] == 'YL-69') {
          sensor['lastReading'] = 60.0 + _random.nextDouble() * 20;
        } else if (sensor['type'] == 'DHT11') {
          sensor['lastReading'] = 22.0 + _random.nextDouble() * 10;
        }
      }
    });
  }

  // Acciones
  Future<void> _addNewOrder() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidad de crear pedido - Por implementar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _resolveAlert(int alertId) async {
    setState(() {
      final alertIndex = _alerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _alerts[alertIndex]['resuelta'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Alerta marcada como resuelta'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  Future<void> _deleteAlert(int alertId) async {
    setState(() {
      _alerts.removeWhere((alert) => alert['id'] == alertId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Alerta eliminada'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Dashboard Agricultor - Sensores YL69/DHT11',
      actions: [
        const _RoleSwitcherAction(),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'Actualizar datos',
        ),
      ],
      body: _isLoading && _recentOrders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Bottom Navigation Bar personalizado
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                          _buildNavItem(1, Icons.shopping_cart, 'Pedidos'),
                          _buildNavItem(2, Icons.warning, 'Alertas'),
                          _buildNavItem(3, Icons.settings, 'Configuración'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        children: [
                          _buildDashboardPage(),
                          _buildOrdersPage(),
                          _buildAlertsPage(),
                          _buildSettingsPage(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Material(
        color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPage() {
    final unresolvedAlerts = _alerts.where((alert) => !alert['resuelta']).toList();
    final recentOrders = _recentOrders.take(3).toList();
    final onlineSensors = _sensors.where((sensor) => sensor['online']).length;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado del sistema
              _buildSystemStatus(onlineSensors),
              const SizedBox(height: 10),
              
              // KPIs de sensores
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        KpiCard(
                          title: 'Humedad Suelo', 
                          value: '${_currentSoilMoisture.toStringAsFixed(1)}%',
                          icon: Icons.grass,
                          color: Colors.brown,
                        ),
                        const SizedBox(height: 10),
                        KpiCard(
                          title: 'Temperatura', 
                          value: '${_currentTemperature.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 10),
                        KpiCard(
                          title: 'Humedad Aire', 
                          value: '${_currentAirHumidity.toStringAsFixed(1)}%',
                          icon: Icons.water_drop,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        KpiCard(
                          title: 'Humedad Suelo', 
                          value: '${_currentSoilMoisture.toStringAsFixed(1)}%',
                          icon: Icons.grass,
                          color: Colors.brown,
                        ),
                        KpiCard(
                          title: 'Temperatura', 
                          value: '${_currentTemperature.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat,
                          color: Colors.orange,
                        ),
                        KpiCard(
                          title: 'Humedad Aire', 
                          value: '${_currentAirHumidity.toStringAsFixed(1)}%',
                          icon: Icons.water_drop,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Sensores activos
              _buildSensorsGrid(),
              const SizedBox(height: 20),

              // Gráfico de sensores
              if (_soilMoistureData.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📊 Métricas de Sensores - Últimas 24h',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildIntervalSelector(),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % _chartInterval == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('${value.toInt()}h', style: const TextStyle(fontSize: 10)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 20 == 0) {
                                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          minX: 0,
                          maxX: 23,
                          minY: 0,
                          maxY: 80,
                          lineBarsData: [
                            // Humedad del suelo (YL-69)
                            LineChartBarData(
                              isCurved: true,
                              spots: _soilMoistureData,
                              color: Colors.brown,
                              barWidth: 3,
                            ),
                            // Temperatura (DHT11)
                            LineChartBarData(
                              isCurved: true,
                              spots: _temperatureData,
                              color: Colors.orange,
                              barWidth: 3,
                            ),
                            // Humedad ambiental (DHT11)
                            LineChartBarData(
                              isCurved: true,
                              spots: _airHumidityData,
                              color: Colors.blue,
                              barWidth: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Leyenda del gráfico
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('Humedad Suelo', Colors.brown),
                      _buildLegendItem('Temperatura', Colors.orange),
                      _buildLegendItem('Humedad Aire', Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Alertas críticas
              if (unresolvedAlerts.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🚨 Alertas Activas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Badge(
                      label: Text(unresolvedAlerts.length.toString()),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...unresolvedAlerts.take(2).map((alerta) => SensorAlertTile(
                  alerta: alerta,
                  onTap: () => _showAlertDetailDialog(alerta),
                  onResolve: () => _resolveAlert(alerta['id']),
                )),
                const SizedBox(height: 20),
              ],

              // Pedidos recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📦 Pedidos recientes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: _addNewOrder,
                    tooltip: 'Agregar nuevo pedido',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (recentOrders.isNotEmpty) ...[
                ...recentOrders.map((pedido) => PedidoTile(
                  pedido: pedido,
                  onTap: () => context.push('/pedidos/${pedido['id']}'),
                )),
                if (_recentOrders.length > 3)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      _pageController.jumpToPage(1);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ver todos los pedidos'),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
              ] else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No hay pedidos recientes'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus(int onlineSensors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.sensors,
              color: onlineSensors == _sensors.length ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Sensores: $onlineSensors/${_sensors.length} en línea',
              style: TextStyle(
                color: onlineSensors == _sensors.length ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Actualizado: ${DateTime.now().toString().substring(11, 19)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📡 Sensores Activos', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: _sensors.length,
          itemBuilder: (context, index) {
            final sensor = _sensors[index];
            return SensorCard(sensor: sensor);
          },
        ),
      ],
    );
  }

  Widget _buildOrdersPage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📦 Todos los Pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(children: [
              IconButton(icon: const Icon(Icons.add), onPressed: _addNewOrder),
            ]),
          ],
        ),
        const SizedBox(height: 10),

        // Búsqueda
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar pedidos...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),

        // Filtros
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.0,
            children: ['Todos', 'Programado', 'Preparando', 'En camino', 'Entregado']
                .map((f) => FilterChip(
                      label: Text(f),
                      selected: _selectedOrderFilter == f,
                      onSelected: (sel) => setState(() => _selectedOrderFilter = sel ? f : 'Todos'),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),

        Text('Mostrando ${_searchedOrders.length} de ${_recentOrders.length} pedidos',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),

        Expanded(
          child: _searchedOrders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No se encontraron pedidos', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: ListView.builder(
                    itemCount: _searchedOrders.length,
                    itemBuilder: (_, i) => PedidoTile(
                      pedido: _searchedOrders[i],
                      onTap: () => context.push('/pedidos/${_searchedOrders[i]['id']}'),
                    ),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _buildAlertsPage() {
    final unresolved = _alerts.where((a) => !a['resuelta']).toList();
    final resolved = _alerts.where((a) => a['resuelta']).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚠️ Alertas del Sistema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (unresolved.isNotEmpty) ...[
          Row(children: [
            const Text('Alertas Activas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(unresolved.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: _alerts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text('No hay alertas activas', style: TextStyle(fontSize: 16, color: Colors.green)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: ListView(
                    children: [
                      ...unresolved.map((a) => SensorAlertTile(
                            alerta: a,
                            onTap: () => _showAlertDetailDialog(a),
                            onResolve: () => _resolveAlert(a['id']),
                            onDelete: () => _deleteAlert(a['id']),
                          )),
                      if (resolved.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Alertas Resueltas',
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: Theme.of(context).colorScheme.tertiary
                            )),
                        const SizedBox(height: 10),
                        ...resolved.map((a) => SensorAlertTile(
                              alerta: a,
                              onTap: () => _showAlertDetailDialog(a),
                              onDelete: () => _deleteAlert(a['id']),
                            )),
                      ],
                    ],
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚙️ Configuración', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            subtitle: const Text('Configurar alertas y notificaciones'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showNotificationSettings(context),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Preferencias de Gráficos'),
            subtitle: const Text('Personalizar visualización de datos'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showChartSettings(context),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Sincronización de Datos'),
            subtitle: const Text('Configurar frecuencia de actualización'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showSyncSettings(context),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sensors),
            title: const Text('Gestión de Sensores'),
            subtitle: const Text('Configurar y monitorear sensores'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showSensorsSettings(context),
          ),
        ),
      ]),
    );
  }

  // Utilidades
  Widget _buildIntervalSelector() {
    return DropdownButton<double>(
      value: _chartInterval,
      icon: const Icon(Icons.timeline),
      items: [1.0, 2.0, 4.0, 6.0, 12.0]
          .map((i) => DropdownMenuItem<double>(value: i, child: Text('Cada ${i.toInt()}h')))
          .toList(),
      onChanged: (v) => setState(() => _chartInterval = v!),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showAlertDetailDialog(Map<String, dynamic> alerta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alerta['mensaje']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alerta['detalles']),
              const SizedBox(height: 16),
              Text('Sensor: ${alerta['sensor']}'),
              Text('Tipo: ${alerta['tipo']}'),
              Text('Nivel: ${alerta['nivel']}'),
              Text('Fecha: ${alerta['fecha']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (!alerta['resuelta'])
            TextButton(
              onPressed: () {
                _resolveAlert(alerta['id']);
                Navigator.pop(context);
              },
              child: const Text('Marcar Resuelta'),
            ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configuración de Notificaciones'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: Icon(Icons.water_drop), title: Text('Alertas de humedad del suelo')),
              ListTile(leading: Icon(Icons.thermostat), title: Text('Alertas de temperatura')),
              ListTile(leading: Icon(Icons.air), title: Text('Alertas de humedad ambiental')),
              ListTile(leading: Icon(Icons.shopping_cart), title: Text('Notificaciones de pedidos')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showChartSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configuración de Gráficos'),
        content: const Text('Personaliza la visualización de los gráficos de sensores.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showSyncSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sincronización de Datos'),
        content: const Text('Configura la frecuencia de actualización de datos de sensores.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showSensorsSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Gestión de Sensores'),
        content: const Text('Configura y monitorea el estado de tus sensores YL-69 y DHT11.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }
}

// Widgets específicos para sensores
class SensorCard extends StatelessWidget {
  final Map<String, dynamic> sensor;

  const SensorCard({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: sensor['online'] ? Colors.white : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  sensor['online'] ? Icons.sensors : Icons.sensors_off,
                  color: sensor['online'] ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    sensor['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sensor['online'] ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sensor['type'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${sensor['lastReading'].toStringAsFixed(1)}${sensor['unit']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sensor['online'] ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sensor['location'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorAlertTile extends StatelessWidget {
  final Map<String, dynamic> alerta;
  final VoidCallback onTap;
  final VoidCallback? onResolve;
  final VoidCallback? onDelete;

  const SensorAlertTile({
    super.key,
    required this.alerta,
    required this.onTap,
    this.onResolve,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color getSeverityColor(String nivel) {
      switch (nivel) {
        case 'Alto': return Colors.red;
        case 'Medio': return Colors.orange;
        case 'Bajo': return Colors.yellow;
        default: return Colors.grey;
      }
    }

    IconData getSeverityIcon(String nivel) {
      switch (nivel) {
        case 'Alto': return Icons.error;
        case 'Medio': return Icons.warning;
        case 'Bajo': return Icons.info;
        default: return Icons.help;
      }
    }

    final isResolved = alerta['resuelta'] ?? false;

    return Card(
      color: getSeverityColor(alerta['nivel']).withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          isResolved ? Icons.check_circle : getSeverityIcon(alerta['nivel']),
          color: isResolved ? Colors.green : getSeverityColor(alerta['nivel']),
        ),
        title: Text(alerta['mensaje']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alerta['detalles']),
            const SizedBox(height: 4),
            Text('Sensor: ${alerta['sensor']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isResolved && onResolve != null)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: onResolve,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            const Icon(Icons.arrow_forward),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// Widgets auxiliares (mantener los mismos)
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class PedidoTile extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final VoidCallback onTap;

  const PedidoTile({
    super.key,
    required this.pedido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: _getStatusColor(pedido['estado'])),
        title: Text(pedido['cliente']),
        subtitle: Text('${pedido['fecha']} - ${pedido['estado']}'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Entregado':
        return Colors.green;
      case 'En camino':
        return Colors.blue;
      case 'Preparando':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
