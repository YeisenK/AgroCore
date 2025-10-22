import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/core/widgets/kpi_card.dart';
import '../../../app/core/widgets/pedido_tile.dart';
import '../../../app/core/widgets/alert_tile.dart';
import '../../../app/core/widgets/order_detail_page.dart';
import '../../../app/core/widgets//alert_detail_page.dart';

class AgricultorHomePage extends StatefulWidget {
  const AgricultorHomePage({super.key});

  @override
  State<AgricultorHomePage> createState() => _AgricultorHomePageState();
}

class _AgricultorHomePageState extends State<AgricultorHomePage> {
  // Simulador de datos en tiempo real
  Timer? _timer;
  final Random _random = Random();

  // Estados
  bool _isLoading = false;
  String? _errorMessage;
  bool _isConnected = true;
  String _connectionStatus = 'Conectado';
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  String _selectedOrderFilter = 'Todos';
  double _chartInterval = 4.0;

  // KPIs
  int _activeOrders = 12;
  int _upcomingDeliveries = 5;
  double _avgHumidity = 68.0;
  double _currentTemperature = 24.5;

  // Series
  final List<FlSpot> _humidityData = [];
  final List<FlSpot> _temperatureData = [];

  // Datos simulados
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

  // Controladores
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeChartData();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _updateData());
    Timer.periodic(const Duration(seconds: 10), (_) => _simulateConnectionChanges());
  }

  void _initializeChartData() {
    for (int i = 0; i < 24; i++) {
      _humidityData.add(FlSpot(i.toDouble(), 60 + _random.nextDouble() * 20));
      _temperatureData.add(FlSpot(i.toDouble(), 18 + _random.nextDouble() * 12));
    }
  }

  Future<void> _updateData() async {
    if (!_isConnected) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _activeOrders = 10 + _random.nextInt(5);
        _upcomingDeliveries = 3 + _random.nextInt(4);
        _avgHumidity = 65 + _random.nextDouble() * 10;
        _currentTemperature = 18 + _random.nextDouble() * 12;

        if (_humidityData.length >= 24) _humidityData.removeAt(0);
        if (_temperatureData.length >= 24) _temperatureData.removeAt(0);

        const lastX = 23.0;
        _humidityData.add(FlSpot(lastX, 60 + _random.nextDouble() * 20));
        _temperatureData.add(FlSpot(lastX, 18 + _random.nextDouble() * 12));

        for (int i = 0; i < _humidityData.length; i++) {
          _humidityData[i] = FlSpot(i.toDouble(), _humidityData[i].y);
          _temperatureData[i] = FlSpot(i.toDouble(), _temperatureData[i].y);
        }

        if (_random.nextDouble() < 0.05 && _alerts.length < 10) {
          final alertTypes = [
            'Humedad crítica en Invernadero ${_random.nextInt(5) + 1}',
            'Temperatura fuera de rango en Zona ${_random.nextInt(3) + 1}',
            "Sensor S${_random.nextInt(100).toString().padLeft(3, '0')} sin reporte",
            'Riego automático activado en Sector ${_random.nextInt(8) + 1}',
            'Necesidad de fertilizante detectada'
          ];
          final levels = ['Bajo', 'Medio', 'Alto'];

          _alerts.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'mensaje': alertTypes[_random.nextInt(alertTypes.length)],
            'nivel': levels[_random.nextInt(levels.length)],
            'fecha':
                "Hoy ${_random.nextInt(24).toString().padLeft(2, '0')}:${_random.nextInt(60).toString().padLeft(2, '0')}",
            'detalles': 'Esta es una alerta generada automáticamente por el sistema de monitoreo.',
            'resuelta': false
          });
        }

        if (_random.nextDouble() < 0.1 && _recentOrders.isNotEmpty) {
          int index = _random.nextInt(_recentOrders.length);
          final estados = ['Programado', 'Preparando', 'En camino', 'Entregado'];
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
    if (_random.nextDouble() < 0.1) {
      setState(() {
        _isConnected = !_isConnected;
        _connectionStatus = _isConnected ? 'Conectado' : 'Desconectado';

        _alerts.insert(
          0,
          {
            'id': DateTime.now().millisecondsSinceEpoch,
            'mensaje': _isConnected
                ? 'Conexión restablecida con el servidor'
                : 'Pérdida de conexión con el servidor',
            'nivel': _isConnected ? 'Medio' : 'Alto',
            'fecha': 'Ahora',
            'detalles': _isConnected
                ? 'La conexión con el servidor se ha restablecido correctamente. Sincronizando datos...'
                : 'Se perdió la conexión. Los datos podrían no estar actualizados.',
            'resuelta': false
          },
        );
      });

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
      final clientes = [
        'Mercado Central',
        'Tienda Orgánica',
        'Distribuidora Verde',
        'Supermercado Ecológico',
        'Restaurante La Huerta'
      ];
      final horas = ['Hoy 10:00 AM', 'Hoy 02:30 PM', 'Mañana 09:00 AM', 'Mañana 11:45 AM'];
      final productos = [
        'Tomates (30kg), Lechugas (20kg)',
        'Zanahorias (25kg), Cebollas (15kg)',
        'Pepinos (40kg), Pimientos (20kg)',
        'Berenjenas (15kg), Calabacines (25kg)'
      ];
      final direcciones = [
        'Av. Central 123, Ciudad',
        'Calle Secundaria 456, Pueblo',
        'Plaza Mayor 789, Villa',
        'Camino Rural 321, Aldea'
      ];
      final totales = ['\$750.00', '\$520.00', '\$980.00', '\$640.00'];

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nuevo pedido agregado'), duration: Duration(seconds: 2)),
    );
  }

  void _resolveAlert(int alertId) {
    setState(() {
      final i = _alerts.indexWhere((a) => a['id'] == alertId);
      if (i != -1) {
        _alerts[i]['resuelta'] = true;
        final moved = _alerts.removeAt(i);
        _alerts.add(moved);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta marcada como resuelta')),
    );
  }

  void _deleteAlert(int alertId) {
    setState(() => _alerts.removeWhere((a) => a['id'] == alertId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta eliminada')),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedOrderFilter == 'Todos') return _recentOrders;
    return _recentOrders.where((o) => o['estado'] == _selectedOrderFilter).toList();
  }

  List<Map<String, dynamic>> get _searchedOrders {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _filteredOrders;
    return _filteredOrders.where((o) {
      return o['cliente'].toLowerCase().contains(q) ||
          o['productos'].toLowerCase().contains(q) ||
          o['direccion'].toLowerCase().contains(q);
    }).toList();
  }

  String _convertOrdersToCsv() {
    final b = StringBuffer()..writeln('ID,Cliente,Fecha,Estado,Productos,Dirección,Total');
    for (final o in _recentOrders) {
      b.writeln(
          '${o['id']},${o['cliente']},${o['fecha']},${o['estado']},"${o['productos']}","${o['direccion']}",${o['total']}');
    }
    return b.toString();
  }

  void _exportOrders() {
    final csv = _convertOrdersToCsv();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Datos Exportados'),
        content: SingleChildScrollView(
          child: Text(
            'Se han exportado ${_recentOrders.length} pedidos.\n\n'
            'Pega estos datos en un archivo .csv:\n\n$csv',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
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
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _updateData, tooltip: 'Actualizar datos'),
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
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _updateData, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _selectedIndex = i),
                  children: [
                    _buildDashboardPage(),
                    _buildOrdersPage(),
                    _buildAlertsPage(),
                    _buildSettingsPage(),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addNewOrder,
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ---------- Secciones de páginas ----------
  Widget _buildDashboardPage() {
    final unresolvedAlerts = _alerts.where((a) => !a['resuelta']).toList();
    final recentOrders = _recentOrders.take(3).toList();

    return RefreshIndicator(
      onRefresh: _updateData,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado conexión
              Row(
                children: [
                  Icon(_isConnected ? Icons.cloud_done : Icons.cloud_off,
                      color: _isConnected ? Colors.green : Colors.red, size: 16),
                  const SizedBox(width: 5),
                  Text(_connectionStatus,
                      style: TextStyle(color: _isConnected ? Colors.green : Colors.red, fontSize: 14)),
                  const Spacer(),
                  Text('Actualizado: ${DateTime.now().toString().substring(11, 19)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),

              // KPIs responsive
              LayoutBuilder(
                builder: (context, c) {
                  final kpis = [
                    KpiCard(title: 'Pedidos activos', value: '$_activeOrders', icon: Icons.shopping_cart),
                    KpiCard(title: 'Próximas entregas', value: '$_upcomingDeliveries', icon: Icons.local_shipping),
                    KpiCard(title: 'Humedad Prom.', value: '${_avgHumidity.toStringAsFixed(1)}%', icon: Icons.water_drop),
                  ];
                  if (c.maxWidth < 600) {
                    return Column(children: [
                      kpis[0], const SizedBox(height: 10),
                      kpis[1], const SizedBox(height: 10),
                      kpis[2],
                    ]);
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: kpis,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Métricas
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
                        _currentTemperature > 28
                            ? Colors.redAccent
                            : _currentTemperature < 20
                                ? Colors.blueAccent
                                : Colors.orangeAccent,
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

              // Gráfico
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
                              getTitlesWidget: (v, _) {
                                if (v % _chartInterval == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('${v.toInt()}h', style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) =>
                                  v % 20 == 0 ? Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)) : const Text(''),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: 23,
                        minY: 0,
                        maxY: 80,
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: _humidityData,
                            color: Colors.tealAccent,
                            barWidth: 3,
                            belowBarData:
                                BarAreaData(show: true, color: Colors.tealAccent.withOpacity(0.1)),
                          ),
                          LineChartBarData(
                            isCurved: true,
                            spots: _temperatureData,
                            color: Colors.orangeAccent,
                            barWidth: 3,
                            belowBarData:
                                BarAreaData(show: true, color: Colors.orangeAccent.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pedidos recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📦 Pedidos recientes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add, size: 20), onPressed: _addNewOrder),
                ],
              ),
              const SizedBox(height: 10),
              ...recentOrders.map((p) => PedidoTile(
                    pedido: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderDetailPage(pedido: p)),
                    ),
                  )),
              const SizedBox(height: 10),
              if (_recentOrders.length > 3)
                TextButton(
                  onPressed: () {
                    setState(() => _selectedIndex = 1);
                    _pageController.jumpToPage(1);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Ver todos los pedidos'), Icon(Icons.arrow_forward, size: 16)],
                  ),
                ),

              const SizedBox(height: 20),

              // Alertas
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
                        setState(() => _selectedIndex = 2);
                        _pageController.jumpToPage(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...unresolvedAlerts.take(2).map((a) => AlertTile(
                    alerta: a,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlertDetailPage(alerta: a)),
                    ),
                  )),
              if (unresolvedAlerts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No hay alertas activas', style: TextStyle(color: Colors.green))),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📦 Todos los Pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(children: [
              IconButton(icon: const Icon(Icons.add), onPressed: _addNewOrder),
              IconButton(icon: const Icon(Icons.download), onPressed: _exportOrders),
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
                  onRefresh: _updateData,
                  child: ListView.builder(
                    itemCount: _searchedOrders.length,
                    itemBuilder: (_, i) => PedidoTile(
                      pedido: _searchedOrders[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrderDetailPage(pedido: _searchedOrders[i])),
                      ),
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
        const Text('⚠️ Todas las Alertas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (unresolved.isNotEmpty) ...[
          Row(children: [
            const Text('Alertas Activas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
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
                      Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay alertas registradas', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _updateData,
                  child: ListView(
                    children: [
                      ...unresolved.map((a) => AlertTile(
                            alerta: a,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AlertDetailPage(alerta: a)),
                            ),
                            onResolve: () => _resolveAlert(a['id']),
                            onDelete: () => _deleteAlert(a['id']),
                          )),
                      if (resolved.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('Alertas Resueltas',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 10),
                        ...resolved.map((a) => AlertTile(
                              alerta: a,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AlertDetailPage(alerta: a)),
                              ),
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
            leading: const Icon(Icons.cloud, color: Colors.tealAccent),
            title: const Text('Estado de Conexión'),
            subtitle: Text(_connectionStatus),
            trailing: Switch(
              value: _isConnected,
              onChanged: (v) => setState(() {
                _isConnected = v;
                _connectionStatus = v ? 'Conectado' : 'Desconectado';
              }),
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
            onTap: _showNotificationSettings,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.purpleAccent),
            title: const Text('Preferencias de Gráficos'),
            subtitle: const Text('Personalizar visualización de datos'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: _showChartSettings,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.data_usage, color: Colors.greenAccent),
            title: const Text('Sincronización de Datos'),
            subtitle: const Text('Configurar frecuencia de actualización'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: _showSyncSettings,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info, color: Colors.blueAccent),
            title: const Text('Acerca de'),
            subtitle: const Text('Información de la aplicación'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showAboutDialog(context),
          ),
        ),
      ]),
    );
  }

  // ---------- diálogos / util ----------
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

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configuración de Notificaciones'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aquí puedes configurar tus preferencias de notificaciones:'),
              SizedBox(height: 15),
              ListTile(leading: Icon(Icons.water_drop, color: Colors.teal), title: Text('Alertas de humedad')),
              ListTile(leading: Icon(Icons.thermostat, color: Colors.orange), title: Text('Alertas de temperatura')),
              ListTile(leading: Icon(Icons.shopping_cart, color: Colors.blue), title: Text('Notificaciones de pedidos')),
              ListTile(leading: Icon(Icons.timer, color: Colors.green), title: Text('Recordatorios')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showChartSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configuración de Gráficos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personaliza la visualización de los gráficos:'),
              SizedBox(height: 15),
              ListTile(leading: Icon(Icons.timeline, color: Colors.purple), title: Text('Tipo de gráfico: Línea')),
              ListTile(leading: Icon(Icons.palette, color: Colors.purple), title: Text('Colores del tema: Automático')),
              ListTile(leading: Icon(Icons.straighten, color: Colors.purple), title: Text('Unidades de medida: Métrico')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showSyncSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sincronización de Datos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configura la frecuencia de actualización:'),
              SizedBox(height: 15),
              ListTile(leading: Icon(Icons.update, color: Colors.green), title: Text('Tiempo real: 3 segundos')),
              ListTile(leading: Icon(Icons.update, color: Colors.green), title: Text('Cada 30 segundos (balanceado)')),
              ListTile(leading: Icon(Icons.update, color: Colors.green), title: Text('Cada 5 minutos (ahorro)')),
              ListTile(leading: Icon(Icons.settings, color: Colors.green), title: Text('Manual: solo al actualizar')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Acerca de'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Agricultor v1.0.0'),
              SizedBox(height: 10),
              Text('Aplicación para monitoreo en tiempo real de datos agrícolas.'),
              SizedBox(height: 15),
              Text('Características:'),
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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
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
