import 'package:flutter_test/flutter_test.dart';
import 'package:agrocore_app/features/dashboard_ingeniero/controllers/engineer_state.dart';

void main() {
  test('humedad promedio calcula > 0 con puntos simulados', () {
    final st = EngineerState()..bootstrap();
    expect(st.series24h.isNotEmpty, true);
    expect(st.humedadPromedio >= 0, true);
  });

  test('alerta por humedad baja se dispara', () {
    final st = EngineerState()..bootstrap();
    st.ingestReading(humedad: 30, temp: 22);
    expect(st.alertas.any((a) => a.id == 'A-HUM-LOW'), true);
  });
}
