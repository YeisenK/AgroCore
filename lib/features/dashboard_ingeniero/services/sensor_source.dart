abstract class SensorSource {
  Stream<SensorSample> stream(); // push periódico
}

class SensorSample {
  final double humedad;
  final double temp;
  final DateTime ts;
  SensorSample(this.humedad, this.temp, this.ts);
}

class MockSensorSource implements SensorSource {
  @override
  Stream<SensorSample> stream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      final now = DateTime.now();
      final h = 50 + (now.second % 10); // 50..59
      final t = 22 + (now.second % 5); // 22..26
      yield SensorSample(h.toDouble(), t.toDouble(), now);
    }
  }
}
