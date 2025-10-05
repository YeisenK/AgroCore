import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
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
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Simulador de datos en tiempo real
  Timer? _timer;
  final Random _random = Random();
  
  // Estados mejorados
  bool _isLoading = false;
  String? _errorMessage;
  bool _isConnected = true;
  String _connectionStatus = 'Conectado';
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  String _selectedOrderFilter = 'Todos';
  double _chartInterval = 4.0;
  
  // Datos iniciales
  int _activeOrders = 12;
  int _upcomingDeliveries = 5;
  double _avgHumidity = 68.0;
  double _currentTemperature = 24.5;
  
  final List<FlSpot> _humidityData = [];
  final List<FlSpot> _temperatureData = [];
  
  List<Map<String, dynamic>> _recentOrders = [
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
  ];
  
  List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'mensaje': 'Humedad baja en Invernadero 2', 
      'nivel': 'Alto',
      'fecha': 'Hoy 08:30 AM',
      'detalles': 'La humedad ha bajado al 45%. Se recomienda activar el sistema de riego.',
      'resuelta': false
    },
    {
      'id': 2,
      'mensaje': 'Sensor S011 sin reporte', 
      'nivel': 'Medio',
      'fecha': 'Ayer 05:45 PM',
      'detalles': 'El sensor de temperatura en el invernadero 3 no reporta datos desde hace 2 horas.',
      'resuelta': false
    },
  ];

  // Controladores para búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeChartData();
    
    // Simular actualizaciones en tiempo real cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateData();
    });

    // Simular cambios de conexión
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _simulateConnectionChanges();
    });
  }

  void _initializeChartData() {
    // Generar datos iniciales para las últimas 24 horas
    for (int i = 0; i < 24; i++) {
      _humidityData.add(FlSpot(
        i.toDouble(), 
        60 + _random.nextDouble() * 20 // Humedad entre 60-80%
      ));
      _temperatureData.add(FlSpot(
        i.toDouble(), 
        18 + _random.nextDouble() * 12 // Temperatura entre 18-30°C
      ));
    }
  }

  Future<void> _updateData() async {
    if (!_isConnected) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Simular delay de API
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        // Actualizar KPIs con valores aleatorios (simulando datos reales)
        _activeOrders = 10 + _random.nextInt(5);
        _upcomingDeliveries = 3 + _random.nextInt(4);
        _avgHumidity = 65 + _random.nextDouble() * 10;
        _currentTemperature = 18 + _random.nextDouble() * 12;
        
        // Actualizar datos del gráfico (desplazar datos y agregar nuevo)
        if (_humidityData.length >= 24) _humidityData.removeAt(0);
        if (_temperatureData.length >= 24) _temperatureData.removeAt(0);
        
        // Agregar nuevo dato manteniendo el rango de 24 horas
        const lastX = 23.0;
        _humidityData.add(FlSpot(lastX, 60 + _random.nextDouble() * 20));
        _temperatureData.add(FlSpot(lastX, 18 + _random.nextDouble() * 12));
        
        // Renumerar los puntos X para mantener el rango 0-23
        for (int i = 0; i < _humidityData.length; i++) {
          _humidityData[i] = FlSpot(i.toDouble(), _humidityData[i].y);
          _temperatureData[i] = FlSpot(i.toDouble(), _temperatureData[i].y);
        }
        
        // Simular ocasionalmente nuevas alertas (5% de probabilidad)
        if (_random.nextDouble() < 0.05 && _alerts.length < 10) {
          List<String> alertTypes = [
            'Humedad crítica en Invernadero ${_random.nextInt(5) + 1}',
            'Temperatura fuera de rango en Zona ${_random.nextInt(3) + 1}',
            "Sensor S${_random.nextInt(100).toString().padLeft(3, '0')} sin reporte",
            'Riego automático activado en Sector ${_random.nextInt(8) + 1}',
            'Necesidad de fertilizante detectada'
          ];
          
          List<String> levels = ['Bajo', 'Medio', 'Alto'];
          
          _alerts.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'mensaje': alertTypes[_random.nextInt(alertTypes.length)],
            'nivel': levels[_random.nextInt(levels.length)],
            'fecha': "Hoy ${_random.nextInt(24).toString().padLeft(2, '0')}:${_random.nextInt(60).toString().padLeft(2, '0')}",
            'detalles': 'Esta es una alerta generada automáticamente por el sistema de monitoreo.',
            'resuelta': false
          });
        }
        
        // Simular actualización de estado de pedidos
        if (_random.nextDouble() < 0.1 && _recentOrders.isNotEmpty) {
          int index = _random.nextInt(_recentOrders.length);
          List<String> estados = ['Programado', 'Preparando', 'En camino', 'Entregado'];
          _recentOrders[index]['estado'] = estados[_random.nextInt(estados.length)];
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error actualizando datos: $e';
      });
    }
  }

  void _simulateConnectionChanges() {
    // Simular cambios de conexión (10% de probabilidad de desconexión)
    if (_random.nextDouble() < 0.1) {
      setState(() {
        _isConnected = !_isConnected;
        _connectionStatus = _isConnected ? 'Conectado' : 'Desconectado';
        
        if (!_isConnected) {
          _alerts.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'mensaje': 'Pérdida de conexión con el servidor',
            'nivel': 'Alto',
            'fecha': 'Ahora',
            'detalles': 'El sistema ha perdido conexión con el servidor principal. Los datos mostrados pueden no estar actualizados.',
            'resuelta': false
          });
        } else {
          _alerts.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'mensaje': 'Conexión restablecida con el servidor',
            'nivel': 'Medio',
            'fecha': 'Ahora',
            'detalles': 'La conexión con el servidor se ha restablecido correctamente. Sincronizando datos...',
            'resuelta': false
          });
        }
      });
      
      // Auto-reconexión después de 15 segundos si está desconectado
      if (!_isConnected) {
        Timer(const Duration(seconds: 15), () {
          if (mounted) {
            setState(() {
              _isConnected = true;
              _connectionStatus = 'Conectado';
            });
          }
        });
      }
    }
  }

  void _addNewOrder() {
    setState(() {
      List<String> clientes = [
        'Mercado Central',
        'Tienda Orgánica',
        'Distribuidora Verde',
        'Supermercado Ecológico',
        'Restaurante La Huerta'
      ];
      
      List<String> horas = [
        'Hoy 10:00 AM', 
        'Hoy 02:30 PM', 
        'Mañana 09:00 AM', 
        'Mañana 11:45 AM'
      ];
      
      List<String> productos = [
        'Tomates (30kg), Lechugas (20kg)',
        'Zanahorias (25kg), Cebollas (15kg)',
        'Pepinos (40kg), Pimientos (20kg)',
        'Berenjenas (15kg), Calabacines (25kg)'
      ];
      
      List<String> direcciones = [
        'Av. Central 123, Ciudad',
        'Calle Secundaria 456, Pueblo',
        'Plaza Mayor 789, Villa',
        'Camino Rural 321, Aldea'
      ];

      List<String> totales = [
        '\$750.00',
        '\$520.00',
        '\$980.00',
        '\$640.00'
      ];
      
      _recentOrders.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'cliente': clientes[_random.nextInt(clientes.length)],
        'fecha': horas[_random.nextInt(horas.length)],
        'estado': 'Programado',
        'productos': productos[_random.nextInt(productos.length)],
        'direccion': direcciones[_random.nextInt(direcciones.length)],
        'total': totales[_random.nextInt(totales.length)]
      });
    });
    
    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nuevo pedido agregado a la base de datos'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resolveAlert(int alertId) {
    setState(() {
      final alertIndex = _alerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _alerts[alertIndex]['resuelta'] = true;
        // Mover alerta resuelta al final
        final resolvedAlert = _alerts.removeAt(alertIndex);
        _alerts.add(resolvedAlert);
      }
    });
    
    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta marcada como resuelta'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteAlert(int alertId) {
    setState(() {
      _alerts.removeWhere((alert) => alert['id'] == alertId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta eliminada'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedOrderFilter == 'Todos') {
      return _recentOrders;
    }
    return _recentOrders.where((order) => order['estado'] == _selectedOrderFilter).toList();
  }

  List<Map<String, dynamic>> get _searchedOrders {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _filteredOrders;
    }
    return _filteredOrders.where((order) {
      return order['cliente'].toLowerCase().contains(query) ||
             order['productos'].toLowerCase().contains(query) ||
             order['direccion'].toLowerCase().contains(query);
    }).toList();
  }

  String _convertOrdersToCsv() {
    final StringBuffer csv = StringBuffer();
    csv.writeln('ID,Cliente,Fecha,Estado,Productos,Dirección,Total');
    
    for (final order in _recentOrders) {
      csv.writeln('${order['id']},${order['cliente']},${order['fecha']},'
          '${order['estado']},"${order['productos']}","${order['direccion']}",${order['total']}');
    }
    
    return csv.toString();
  }

  void _exportOrders() {
    final csvData = _convertOrdersToCsv();
    // En una aplicación real, aquí usarías share_plus o file_saver
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datos Exportados'),
        content: SingleChildScrollView(
          child: Text(
            'Se han exportado ${_recentOrders.length} pedidos.\n\n'
            'Pega estos datos en un archivo .csv:\n\n$csvData',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Agricultor - Tiempo Real'),
        backgroundColor: const Color(0xFF12121D),
        actions: [
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
            onPressed: _updateData,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: Icon(_isConnected ? Icons.cloud_done : Icons.cloud_off),
            onPressed: () {
              setState(() {
                _isConnected = !_isConnected;
                _connectionStatus = _isConnected ? 'Conectado' : 'Desconectado';
              });
            },
            tooltip: _connectionStatus,
          ),
        ],
      ),
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
                        onPressed: _updateData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: [
                    // Página 1: Dashboard principal
                    _buildDashboardPage(),
                    
                    // Página 2: Pedidos
                    _buildOrdersPage(),
                    
                    // Página 3: Alertas
                    _buildAlertsPage(),
                    
                    // Página 4: Configuración
                    _buildSettingsPage(),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: _addNewOrder,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildDashboardPage() {
    final unresolvedAlerts = _alerts.where((alert) => !alert['resuelta']).toList();
    final recentOrders = _recentOrders.take(3).toList();

    return RefreshIndicator(
      onRefresh: _updateData,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado de conexión
              Row(
                children: [
                  Icon(
                    _isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: _isConnected ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _connectionStatus,
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Actualizado: ${DateTime.now().toString().substring(11, 19)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              /// KPIs en tiempo real - Responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        KpiCard(
                          title: 'Pedidos activos', 
                          value: _activeOrders.toString(),
                          icon: Icons.shopping_cart,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 10),
                        KpiCard(
                          title: 'Próximas entregas', 
                          value: _upcomingDeliveries.toString(),
                          icon: Icons.local_shipping,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(height: 10),
                        KpiCard(
                          title: 'Humedad Prom.', 
                          value: '${_avgHumidity.toStringAsFixed(1)}%',
                          icon: Icons.water_drop,
                          color: Colors.tealAccent,
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        KpiCard(
                          title: 'Pedidos activos', 
                          value: _activeOrders.toString(),
                          icon: Icons.shopping_cart,
                          color: Colors.blueAccent,
                        ),
                        KpiCard(
                          title: 'Próximas entregas', 
                          value: _upcomingDeliveries.toString(),
                          icon: Icons.local_shipping,
                          color: Colors.greenAccent,
                        ),
                        KpiCard(
                          title: 'Humedad Prom.', 
                          value: '${_avgHumidity.toStringAsFixed(1)}%',
                          icon: Icons.water_drop,
                          color: Colors.tealAccent,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Métricas en tiempo real
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricCard(
                        'Temperatura Actual',
                        '${_currentTemperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        _currentTemperature > 28 ? Colors.redAccent : 
                        _currentTemperature < 20 ? Colors.blueAccent : Colors.orangeAccent,
                      ),
                      _buildMetricCard(
                        'Humedad Actual',
                        '${(_avgHumidity + _random.nextDouble() * 5 - 2.5).toStringAsFixed(1)}%',
                        Icons.water_drop,
                        _avgHumidity < 50 ? Colors.orangeAccent : Colors.tealAccent,
                      ),
                      _buildMetricCard(
                        'Alertas Activas',
                        unresolvedAlerts.length.toString(),
                        Icons.warning,
                        unresolvedAlerts.isEmpty ? Colors.green : Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Gráfico humedad y temperatura en tiempo real
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🌡 Humedad y Temperatura últimas 24h',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildIntervalSelector(),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
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
                                // Mostrar etiquetas según el intervalo configurado
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
                          /// Línea de Humedad
                          LineChartBarData(
                            isCurved: true,
                            spots: _humidityData,
                            color: Colors.tealAccent,
                            barWidth: 3,
                            belowBarData: BarAreaData(show: true, color: Colors.tealAccent.withOpacity(0.1)),
                          ),
                          /// Línea de Temperatura
                          LineChartBarData(
                            isCurved: true,
                            spots: _temperatureData,
                            color: Colors.orangeAccent,
                            barWidth: 3,
                            belowBarData: BarAreaData(show: true, color: Colors.orangeAccent.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Pedidos recientes
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
              ...recentOrders.map((pedido) => PedidoTile(
                pedido: pedido,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(pedido: pedido),
                    ),
                  );
                },
              )).toList(),
              const SizedBox(height: 10),
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

              const SizedBox(height: 20),

              /// Alertas activas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('⚠️ Alertas activas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Badge(
                    label: Text(unresolvedAlerts.length.toString()),
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.notifications, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                        _pageController.jumpToPage(2);
                      },
                      tooltip: 'Ver todas las alertas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...unresolvedAlerts.take(2).map((alerta) => AlertTile(
                alerta: alerta,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertDetailPage(alerta: alerta),
                    ),
                  );
                },
              )).toList(),
              if (unresolvedAlerts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No hay alertas activas',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersPage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📦 Todos los Pedidos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewOrder,
                    tooltip: 'Nuevo pedido',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _exportOrders,
                    tooltip: 'Exportar pedidos',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar pedidos...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8.0,
              children: ['Todos', 'Programado', 'Preparando', 'En camino', 'Entregado']
                  .map((filter) => FilterChip(
                        label: Text(filter),
                        selected: _selectedOrderFilter == filter,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedOrderFilter = selected ? filter : 'Todos';
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          
          Text(
            'Mostrando ${_searchedOrders.length} de ${_recentOrders.length} pedidos',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: _searchedOrders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron pedidos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _updateData,
                    child: ListView.builder(
                      itemCount: _searchedOrders.length,
                      itemBuilder: (context, index) {
                        return PedidoTile(
                          pedido: _searchedOrders[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailPage(pedido: _searchedOrders[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    final unresolvedAlerts = _alerts.where((alert) => !alert['resuelta']).toList();
    final resolvedAlerts = _alerts.where((alert) => alert['resuelta']).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️ Todas las Alertas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          if (unresolvedAlerts.isNotEmpty) ...[
            Row(
              children: [
                const Text('Alertas Activas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unresolvedAlerts.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: _alerts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay alertas registradas',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _updateData,
                    child: ListView(
                      children: [
                        ...unresolvedAlerts.map((alerta) => AlertTile(
                              alerta: alerta,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlertDetailPage(alerta: alerta),
                                  ),
                                );
                              },
                              onResolve: () => _resolveAlert(alerta['id']),
                              onDelete: () => _deleteAlert(alerta['id']),
                            )).toList(),
                        if (resolvedAlerts.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text('Alertas Resueltas', 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  resolvedAlerts.length.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...resolvedAlerts.map((alerta) => AlertTile(
                                alerta: alerta,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlertDetailPage(alerta: alerta),
                                    ),
                                  );
                                },
                                onDelete: () => _deleteAlert(alerta['id']),
                              )).toList(),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚙️ Configuración',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud, color: Colors.tealAccent),
              title: const Text('Estado de Conexión'),
              subtitle: Text(_connectionStatus),
              trailing: Switch(
                value: _isConnected,
                onChanged: (value) {
                  setState(() {
                    _isConnected = value;
                    _connectionStatus = _isConnected ? 'Conectado' : 'Desconectado';
                  });
                },
                activeThumbColor: Colors.teal,
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orangeAccent),
              title: const Text('Notificaciones'),
              subtitle: const Text('Configurar alertas y notificaciones'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _showNotificationSettings();
              },
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.purpleAccent),
              title: const Text('Preferencias de Gráficos'),
              subtitle: const Text('Personalizar visualización de datos'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _showChartSettings();
              },
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.data_usage, color: Colors.greenAccent),
              title: const Text('Sincronización de Datos'),
              subtitle: const Text('Configurar frecuencia de actualización'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _showSyncSettings();
              },
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blueAccent),
              title: const Text('Acerca de'),
              subtitle: const Text('Información de la aplicación'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return DropdownButton<double>(
      value: _chartInterval,
      icon: const Icon(Icons.timeline),
      items: [1.0, 2.0, 4.0, 6.0, 12.0].map((interval) {
        return DropdownMenuItem<double>(
          value: interval,
          child: Text('Cada ${interval.toInt()}h'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _chartInterval = value!;
        });
      },
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Notificaciones'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aquí puedes configurar tus preferencias de notificaciones:'),
              SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.water_drop, color: Colors.teal),
                title: Text('Alertas de humedad'),
                trailing: Switch(value: true, onChanged: null),
              ),
              ListTile(
                leading: Icon(Icons.thermostat, color: Colors.orange),
                title: Text('Alertas de temperatura'),
                trailing: Switch(value: true, onChanged: null),
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.blue),
                title: Text('Notificaciones de pedidos'),
                trailing: Switch(value: true, onChanged: null),
              ),
              ListTile(
                leading: Icon(Icons.timer, color: Colors.green),
                title: Text('Recordatorios'),
                trailing: Switch(value: false, onChanged: null),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración guardada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChartSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Gráficos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personaliza la visualización de los gráficos:'),
              SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.timeline, color: Colors.purple),
                title: Text('Tipo de gráfico'),
                subtitle: Text('Línea (actual)'),
              ),
              ListTile(
                leading: Icon(Icons.palette, color: Colors.purple),
                title: Text('Colores del tema'),
                subtitle: Text('Automático'),
              ),
              ListTile(
                leading: Icon(Icons.straighten, color: Colors.purple),
                title: Text('Unidades de medida'),
                subtitle: Text('Métrico'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSyncSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sincronización de Datos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configura la frecuencia de actualización:'),
              SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.update, color: Colors.green),
                title: Text('Tiempo real'),
                subtitle: Text('3 segundos (actual)'),
              ),
              ListTile(
                leading: Icon(Icons.update, color: Colors.green),
                title: Text('Cada 30 segundos'),
                subtitle: Text('Modo balanceado'),
              ),
              ListTile(
                leading: Icon(Icons.update, color: Colors.green),
                title: Text('Cada 5 minutos'),
                subtitle: Text('Modo ahorro'),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.green),
                title: Text('Manual'),
                subtitle: Text('Solo al actualizar'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Agricultor v1.0.0'),
              SizedBox(height: 10),
              Text('Aplicación para monitoreo en tiempo real de datos agrícolas.'),
              SizedBox(height: 15),
              Text('Características principales:'),
              Text('• Monitoreo de humedad y temperatura'),
              Text('• Gestión de pedidos en tiempo real'),
              Text('• Sistema de alertas inteligentes'),
              Text('• Interfaz responsive y moderna'),
              Text('• Búsqueda y filtrado avanzado'),
              SizedBox(height: 10),
              Text('Desarrollado con Flutter y Dart'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

/// Página de detalle de pedido
class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> pedido;
  
  const OrderDetailPage({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    Color estadoColor;
    IconData estadoIcon;
    
    switch (pedido['estado']) {
      case 'Programado':
        estadoColor = Colors.blue;
        estadoIcon = Icons.schedule;
        break;
      case 'Preparando':
        estadoColor = Colors.orange;
        estadoIcon = Icons.build;
        break;
      case 'En camino':
        estadoColor = Colors.green;
        estadoIcon = Icons.local_shipping;
        break;
      case 'Entregado':
        estadoColor = Colors.grey;
        estadoIcon = Icons.check_circle;
        break;
      default:
        estadoColor = Colors.white;
        estadoIcon = Icons.help;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido #${pedido["id"].toString().substring(0, 8)}"),
        backgroundColor: const Color(0xFF12121D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(estadoIcon, color: estadoColor),
                        const SizedBox(width: 10),
                        Text("Estado: ${pedido["estado"]}", 
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: estadoColor)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Cliente', pedido['cliente']),
                    _buildDetailRow('Fecha de entrega', pedido['fecha']),
                    _buildDetailRow('Productos', pedido['productos']),
                    _buildDetailRow('Dirección', pedido['direccion']),
                    _buildDetailRow('Total', pedido['total']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Acciones:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de edición en desarrollo')),
                    );
                  },
                  label: const Text('Editar Pedido'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pedido marcado como entregado')),
                    );
                  },
                  label: const Text('Marcar Entregado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Página de detalle de alerta
class AlertDetailPage extends StatelessWidget {
  final Map<String, dynamic> alerta;
  
  const AlertDetailPage({super.key, required this.alerta});

  @override
  Widget build(BuildContext context) {
    Color nivelColor;
    IconData nivelIcon;
    
    switch (alerta['nivel']) {
      case 'Alto':
        nivelColor = Colors.redAccent;
        nivelIcon = Icons.error;
        break;
      case 'Medio':
        nivelColor = Colors.orangeAccent;
        nivelIcon = Icons.warning;
        break;
      case 'Bajo':
        nivelColor = Colors.yellowAccent;
        nivelIcon = Icons.info;
        break;
      default:
        nivelColor = Colors.white;
        nivelIcon = Icons.help;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Alerta #${alerta["id"].toString().substring(0, 8)}"),
        backgroundColor: const Color(0xFF12121D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF402A2A),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(nivelIcon, color: nivelColor),
                        const SizedBox(width: 10),
                        Text(alerta['nivel'], 
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: nivelColor)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(alerta['mensaje'], 
                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),
                    _buildAlertDetailRow('Fecha', alerta['fecha']),
                    _buildAlertDetailRow('Detalles', alerta['detalles']),
                    if (alerta['resuelta'] == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 5),
                            Text('RESUELTA', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Acciones:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alerta marcada como resuelta')),
                    );
                    Navigator.pop(context);
                  },
                  label: const Text('Marcar Resuelta'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_off),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alerta silenciada por 24 horas')),
                    );
                    Navigator.pop(context);
                  },
                  label: const Text('Silenciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Widgets personalizados

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class PedidoTile extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final VoidCallback? onTap;
  
  const PedidoTile({
    super.key, 
    required this.pedido,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color estadoColor;
    IconData estadoIcon;
    
    switch (pedido['estado']) {
      case 'Programado':
        estadoColor = Colors.blue;
        estadoIcon = Icons.schedule;
        break;
      case 'Preparando':
        estadoColor = Colors.orange;
        estadoIcon = Icons.build;
        break;
      case 'En camino':
        estadoColor = Colors.green;
        estadoIcon = Icons.local_shipping;
        break;
      case 'Entregado':
        estadoColor = Colors.grey;
        estadoIcon = Icons.check_circle;
        break;
      default:
        estadoColor = Colors.white;
        estadoIcon = Icons.help;
    }
    
    return Card(
      child: ListTile(
        leading: Icon(estadoIcon, color: estadoColor),
        title: Text(pedido['cliente']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Entrega: ${pedido["fecha"]}"),
            Text(pedido['productos'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pedido['total'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent)),
            const SizedBox(height: 4),
            Text(pedido['estado'], style: TextStyle(color: estadoColor, fontSize: 12)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  final Map<String, dynamic> alerta;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;
  final VoidCallback? onDelete;
  
  const AlertTile({
    super.key, 
    required this.alerta,
    this.onTap,
    this.onResolve,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (alerta['nivel']) {
      case 'Alto':
        color = Colors.redAccent;
        icon = Icons.error;
        break;
      case 'Medio':
        color = Colors.orangeAccent;
        icon = Icons.warning;
        break;
      case 'Bajo':
        color = Colors.yellowAccent;
        icon = Icons.info;
        break;
      default:
        color = Colors.white;
        icon = Icons.help;
    }

    final isResolved = alerta['resuelta'] == true;

    return Card(
      color: isResolved ? const Color(0xFF2A402A) : const Color(0xFF402A2A),
      child: ListTile(
        leading: Icon(icon, color: isResolved ? Colors.green : color),
        title: Text(
          alerta['mensaje'], 
          style: TextStyle(
            color: Colors.white, 
            fontSize: 14,
            decoration: isResolved ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          "Nivel: ${alerta["nivel"]} - ${alerta["fecha"]}", 
          style: TextStyle(
            color: isResolved ? Colors.green : color, 
            fontSize: 12,
            decoration: isResolved ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onResolve != null && !isResolved)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: onResolve,
                tooltip: 'Marcar como resuelta',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Eliminar alerta',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
