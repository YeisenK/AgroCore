import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../misc/pages/panel_page.dart';
import '../../../app/data/auth/auth_controller.dart';
import '../controllers/engineer_state.dart';
import '../models/sensor_models.dart';

class IngenieroHomePage extends StatelessWidget {
  const IngenieroHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EngineerState>();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;

    return PanelPage(
      title: 'Ingeniero',
      actions: [
        _RoleSwitcherAction(),
        IconButton(
          tooltip: 'Refrescar',
          onPressed: () => context.read<EngineerState>().refrescar(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      slivers: [
        // KPIs
        SliverToBoxAdapter(
          child: isMobile
              ? Column(
                  children: [
                    _KpiCard(
                      title: 'Sensores en línea',
                      value: s.sensoresOnline.toString(),
                      icon: Icons.sensors,
                    ),
                    const SizedBox(height: 12),
                    _KpiCard(
                      title: 'Sensores fuera de línea',
                      value: s.sensoresOffline.toString(),
                      icon: Icons.sensors_off,
                    ),
                    const SizedBox(height: 12),
                    _KpiCard(
                      title: 'Lecturas por hora',
                      value: s.lecturasPorHora.toStringAsFixed(0),
                      icon: Icons.speed,
                    ),
                    const SizedBox(height: 12),
                    _KpiCard(
                      title: 'Humedad promedio (1h)',
                      value: '${s.humedadPromedio.toStringAsFixed(1)}%',
                      icon: Icons.water_drop,
                    ),
                  ],
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _KpiCard(
                      title: 'Sensores en línea',
                      value: s.sensoresOnline.toString(),
                      icon: Icons.sensors,
                    ),
                    _KpiCard(
                      title: 'Sensores fuera de línea',
                      value: s.sensoresOffline.toString(),
                      icon: Icons.sensors_off,
                    ),
                    _KpiCard(
                      title: 'Lecturas por hora',
                      value: s.lecturasPorHora.toStringAsFixed(0),
                      icon: Icons.speed,
                    ),
                    _KpiCard(
                      title: 'Humedad promedio (1h)',
                      value: '${s.humedadPromedio.toStringAsFixed(1)}%',
                      icon: Icons.water_drop,
                    ),
                  ],
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Gráfica + Alertas
        SliverToBoxAdapter(
          child: isMobile
              ? Column(
                  children: [
                    _ChartCard(series: s.series24h),
                    const SizedBox(height: 16),
                    _AlertsCard(alertas: s.alertas),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _ChartCard(series: s.series24h),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _AlertsCard(alertas: s.alertas),
                    ),
                  ],
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Tabla de sensores
        SliverToBoxAdapter(
          child: _SensorsTable(sensores: s.sensores, dense: isTablet),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

/* ---------- Acción para cambiar de rol ---------- */

class _RoleSwitcherAction extends StatelessWidget {
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

/* ---------- Widgets internos ---------- */

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
    final divider = Theme.of(context).dividerColor;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: divider, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: divider),
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
    final t = Theme.of(context).textTheme;
    final divider = Theme.of(context).dividerColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: divider, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimas 24 horas', style: t.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: divider, strokeWidth: .6),
                    getDrawingVerticalLine: (_) =>
                        FlLine(color: divider, strokeWidth: .6),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) => Text(
                          v.toInt().toString(),
                          style: t.labelSmall?.copyWith(
                            color: t.labelSmall?.color?.withOpacity(.8),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval:
                            (series.length / 4).floorToDouble().clamp(1, 999),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= series.length) {
                            return const SizedBox.shrink();
                          }
                          final dt = series[i].t;
                          final lbl =
                              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                          return Text(lbl,
                              style: t.labelSmall?.copyWith(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: divider, width: .6),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 2,
                      color: cs.primary,
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (int i = 0; i < series.length; i++)
                          FlSpot(i.toDouble(), series[i].humedad),
                      ],
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 2,
                      color: cs.secondary,
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
                _LegendDot(label: 'Humedad (%)', color: cs.primary),
                const SizedBox(width: 12),
                _LegendDot(label: 'Temperatura (°C)', color: cs.secondary),
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
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: t.labelMedium),
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
      case 'critical':
        return cs.error;
      case 'warning':
        return cs.tertiary;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final divider = Theme.of(context).dividerColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: divider, width: 1),
      ),
      child: Column(
        children: [
          ListTile(title: Text('Alertas', style: t.titleMedium)),
          Divider(height: 1, color: divider),
          if (alertas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sin alertas.', style: t.bodyMedium),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertas.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: divider),
              itemBuilder: (context, i) {
                final a = alertas[i];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: _sevColor(context, a.severidad),
                        width: 3,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber),
                    title: Text(
                      a.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyLarge,
                    ),
                    subtitle: Text(
                      a.detalle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium,
                    ),
                    trailing: Text(
                      timeAgo(a.fecha),
                      style: t.labelSmall,
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
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: divider, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Sensores', style: t.titleMedium),
            subtitle: Text('Estado y última lectura', style: t.bodySmall),
            trailing: IconButton(
              tooltip: 'Exportar',
              onPressed: () {/* exportar csv opcional */},
              icon: const Icon(Icons.file_download),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataTextStyle: t.bodyMedium?.copyWith(height: dense ? 1.0 : 1.4),
              headingTextStyle: t.labelLarge,
              dividerThickness: 1,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider, width: 1)),
              ),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Zona')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Humedad (%)')),
                DataColumn(label: Text('Temp (°C)')),
                DataColumn(label: Text('Última lectura')),
              ],
              rows: [
                for (final s in sensores)
                  DataRow(
                    cells: [
                      DataCell(Text(s.id)),
                      DataCell(Text(s.zona)),
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              s.online ? Icons.circle : Icons.circle_outlined,
                              size: 10,
                              color: s.online ? cs.tertiary : cs.error,
                            ),
                            const SizedBox(width: 6),
                            Text(s.online ? 'En línea' : 'Fuera de línea'),
                          ],
                        ),
                      ),
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
