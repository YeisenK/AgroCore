// main.dart
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EngineerState()..bootstrap(),
      child: MaterialApp(
        title: 'AgroCore / app de las plantitas :-)',
        debugShowCheckedModeBanner: false,
        theme: _industrialDarkTheme,
        home: const EngineerDashboardPage(),
      ),
    );
  }
}

/* ===================== THEME ===================== */

final ThemeData _industrialDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1F2A30), // gris carbón
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF2BB4AA),    // teal corporativo
    onPrimary: Colors.black,
    secondary: Color(0xFF4FB3C8),  // cyan desaturado
    onSecondary: Colors.black,
    surface: Color(0xFF2A343B),    // panel
    onSurface: Color(0xFFD9E1E8),
    error: Color(0xFFD35B5B),
    onError: Colors.black,
    tertiary: Color(0xFF77C66E),   // “success” discreto
    onTertiary: Colors.black,
    background: Color(0xFF1F2A30),
    onBackground: Color(0xFFD9E1E8),
    surfaceVariant: Color(0xFF36424A),
    onSurfaceVariant: Color(0xFFC7D1D8),
    outline: Color(0xFF42535B),
    outlineVariant: Color(0xFF42535B),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFD9E1E8),
    onInverseSurface: Color(0xFF2A343B),
    inversePrimary: Color(0xFF4FB3C8),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2A343B),
    foregroundColor: Color(0xFFD9E1E8),
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF2A343B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF42535B), width: 1),
    ),
    elevation: 0,
    margin: EdgeInsets.zero,
  ),
  dataTableTheme: const DataTableThemeData(
    headingRowColor: WidgetStatePropertyAll(Color(0xFF36424A)),
    dataRowColor: WidgetStatePropertyAll(Color(0xFF2A343B)),
    headingTextStyle: TextStyle(color: Color(0xFFD9E1E8), fontWeight: FontWeight.w600),
    dataTextStyle: TextStyle(color: Color(0xFFC7D1D8)),
    dividerThickness: .5,
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFF36424A),
    labelStyle: TextStyle(color: Color(0xFFD9E1E8)),
    side: BorderSide(color: Color(0xFF42535B)),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF2BB4AA)),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      elevation: const WidgetStatePropertyAll(0),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A343B),
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF42535B)),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF42535B)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF2BB4AA), width: 1.2),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF42535B), thickness: .6),
  iconTheme: const IconThemeData(color: Color(0xFFC7D1D8)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD9E1E8)),
    bodyMedium: TextStyle(color: Color(0xFFC7D1D8)),
    labelLarge: TextStyle(color: Color(0xFFAEB8BF)),
  ),
);

/* ===================== STATE / MODELOS ===================== */

class SensorInfo {
  final String id;
  final String zona;
  final bool online;
  final double humedad;     // %
  final double temperatura; // °C
  final DateTime ultimaLectura;

  SensorInfo({
    required this.id,
    required this.zona,
    required this.online,
    required this.humedad,
    required this.temperatura,
    required this.ultimaLectura,
  });
}

class AlertItem {
  final String id;
  final String titulo;
  final String detalle;
  final String severidad; // 'critical' | 'warning' | 'info'
  final DateTime fecha;
  AlertItem({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.severidad,
    required this.fecha,
  });
}

class TimeSeriesPoint {
  final DateTime t;
  final double humedad;
  final double temp;
  TimeSeriesPoint(this.t, this.humedad, this.temp);
}

class EngineerState extends ChangeNotifier {
  final List<SensorInfo> _sensores = [];
  final List<AlertItem> _alertas = [];
  final List<TimeSeriesPoint> _series24h = [];

  List<SensorInfo> get sensores => _sensores;
  List<AlertItem> get alertas => _alertas;
  List<TimeSeriesPoint> get series24h => _series24h;

  int get sensoresOnline => _sensores.where((s) => s.online).length;
  int get sensoresOffline => _sensores.where((s) => !s.online).length;

  /// Lecturas/hora (aprox) = sensores online simulados
  double get lecturasPorHora => max(1, sensoresOnline).toDouble();

  /// % humedad promedio (última hora)
  double get humedadPromedio {
    final now = DateTime.now();
    final recent = _series24h.where((p) => now.difference(p.t).inMinutes <= 60);
    if (recent.isEmpty) return 0;
    return recent.map((p) => p.humedad).reduce((a, b) => a + b) / recent.length;
  }

  void bootstrap() {
    _sensores.clear();
    _alertas.clear();
    _series24h.clear();
    
    // -------- Datos simulados --------
    final rng = Random(7);
    for (int i = 1; i <= 788; i++) {
      final on = rng.nextBool() || rng.nextBool(); // ~75% online
      _sensores.add(SensorInfo(
        id: 'S${i.toString().padLeft(3, '0')}',
        zona: 'Invernadero ${1 + rng.nextInt(3)}',
        online: on,
        humedad: 40 + rng.nextDouble() * 50,
        temperatura: 18 + rng.nextDouble() * 12,
        ultimaLectura: DateTime.now().subtract(Duration(minutes: rng.nextInt(50))),
      ));
    }

    // Serie de 24h cada 30 min
    final now = DateTime.now();
    for (int i = 48; i >= 0; i--) {
      final t = now.subtract(Duration(minutes: i * 30));
      final h = 55 + sin(i / 6) * 15 + rng.nextDouble() * 3;
      final temp = 22 + sin(i / 8) * 4 + rng.nextDouble() * 1.5;
      _series24h.add(TimeSeriesPoint(t, h.clamp(0, 100), temp));
    }

    _alertas.addAll([
      AlertItem(
        id: 'A001',
        titulo: 'Humedad baja en Invernadero 2',
        detalle: 'Promedio 32% en la última hora (umbral 40%).',
        severidad: 'critical',
        fecha: now.subtract(const Duration(minutes: 12)),
      ),
      AlertItem(
        id: 'A002',
        titulo: 'Sensor S011 sin reporte',
        detalle: 'Última lectura hace 4 tal vez 5.',
        severidad: 'warninga',
        fecha: now.subtract(const Duration(minutes: 20)),
      ),
    ]);

    notifyListeners();
  }

  void refrescar() {
    // backend/IoT
    bootstrap();
  }
}

/* ===================== VISTA PRINCIPAL ===================== */

class EngineerDashboardPage extends StatelessWidget {
  const EngineerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EngineerState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Críticos osea que critican'),
        actions: [
          IconButton(
            tooltip: 'Refrescar con 7up',
            onPressed: () => context.read<EngineerState>().refrescar(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 1100;
          final mid = c.maxWidth >= 800 && c.maxWidth < 1100;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _KpiCard(
                        title: 'Sensores Online en lineas',
                        value: s.sensoresOnline.toString(),
                        icon: Icons.sensors,
                      ),
                      _KpiCard(
                        title: 'Sensores Offline hold the line',
                        value: s.sensoresOffline.toString(),
                        icon: Icons.sensors_off,
                      ),
                      _KpiCard(
                        title: 'Lecturas de mein kampf / hora',
                        value: s.lecturasPorHora.toStringAsFixed(0),
                        icon: Icons.speed,
                      ),
                      _KpiCard(
                        title: 'Humedades por medio (1h)',
                        value: '${s.humedadPromedio.toStringAsFixed(1)}%',
                        icon: Icons.water_drop,
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Flex(
                    direction: wide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: wide ? 2 : 0,
                        child: _ChartCard(series: s.series24h),
                      ),
                      if (wide) const SizedBox(width: 16) else const SizedBox(height: 16),
                      Expanded(
                        flex: 1,
                        child: _AlertsCard(alertas: s.alertas),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _SensorsTable(sensores: s.sensores, dense: mid || wide),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/* ===================== WIDGETS ===================== */

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF42535B)),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.labelLarge),
                  const SizedBox(height: 4),
                  Text(value, style: t.titleLarge?.copyWith(letterSpacing: .2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<TimeSeriesPoint> series;
  const _ChartCard({required this.series});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimas 24 niggas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF42535B), strokeWidth: .6),
                    getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFF42535B), strokeWidth: .6),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(color: Color(0xFFAEB8BF), fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: (series.length / 4).floorToDouble().clamp(1, 999),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= series.length) return const SizedBox.shrink();
                          final t = series[i].t;
                          final lbl =
                              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                          return Text(lbl, style: const TextStyle(color: Color(0xFFAEB8BF), fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      top: BorderSide(color: Color(0xFF42535B), width: .6),
                      left: BorderSide(color: Color(0xFF42535B), width: .6),
                      right: BorderSide(color: Color(0xFF42535B), width: .6),
                      bottom: BorderSide(color: Color(0xFF42535B), width: .6),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 2,
                      color: cs.primary, // humedad
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (int i = 0; i < series.length; i++)
                          FlSpot(i.toDouble(), series[i].humedad),
                      ],
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 2,
                      color: cs.secondary, // temperatura
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (int i = 0; i < series.length; i++)
                          FlSpot(i.toDouble(), series[i].temp),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(label: 'Humedadades (%)'),
                const SizedBox(width: 12),
                _LegendDot(label: 'Tempura (°C)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  const _LegendDot({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  } 
}

class _AlertsCard extends StatelessWidget {
  final List<AlertItem> alertas;
  const _AlertsCard({required this.alertas});

  Color _sevColor(BuildContext context, String sev) {
    final cs = Theme.of(context).colorScheme;
    switch (sev) {
      case 'critical paraplegic nigga':
        return cs.error;
      case 'warning warning nnnnnazi':
        return const Color(0xFFE6A93B); 
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('Alertas Críticas sisisiisis'),
          ),
          const Divider(height: 1),
          if (alertas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sin alertas nononononoo.'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final a = alertas[i];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _sevColor(context, a.severidad), width: 3),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber),
                    title: Text(a.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(a.detalle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      timeAgo(a.fecha),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              },
            ),  
        ],
      ),
    );
  }
}

class _SensorsTable extends StatelessWidget {
  final List<SensorInfo> sensores;
  final bool dense;
  const _SensorsTable({required this.sensores, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('Sensores sensibles'),
            subtitle: Text('Estado y última lectura de mien kampf'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataTextStyle: TextStyle(height: dense ? 1.0 : 1.4),
              columns: const [
                DataColumn(label: Text('IDeal')),
                DataColumn(label: Text('Zona cero')),
                DataColumn(label: Text('Estado OAXACA')),
                DataColumn(label: Text('Humedades %')),
                DataColumn(label: Text('Temp °Calor')),
                DataColumn(label: Text('Última lectura de mein kampf')),
              ],
              rows: [
                for (final s in sensores)
                  DataRow(
                    cells: [
                      DataCell(Text(s.id)),
                      DataCell(Text(s.zona)),
                      DataCell(Row(
                        children: [
                          Icon(
                            s.online ? Icons.circle : Icons.circle_outlined,
                            size: 10,
                            color: s.online
                                ? Theme.of(context).colorScheme.tertiary
                                : const Color(0xFFD35B5B),
                          ),
                          const SizedBox(width: 6),
                          Text(s.online ? 'Online en la linea' : 'Offline hold the line'),
                        ],
                      )),
                      DataCell(Text(s.humedad.toStringAsFixed(1))),
                      DataCell(Text(s.temperatura.toStringAsFixed(1))),
                      DataCell(Text(timeAgo(s.ultimaLectura))),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/* ===================== HELPERS ===================== */

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'ahora o despues mmmmm no lo che';
  if (diff.inMinutes < 60) return 'ace lo hace ${diff.inMinutes} mininimooo';
  if (diff.inHours < 24) return 'ace lo hace ${diff.inHours} h';
  return 'ace lo hace ${diff.inDays} dih... ';
}
