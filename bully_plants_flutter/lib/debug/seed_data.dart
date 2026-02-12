import 'dart:math';
import '../database/models/sensor_reading.dart';
import '../database/repositories/sensor_reading_repository.dart';

class SeedData {
  static Future<void> insertFakeReadings(int plantId, {int count = 20}) async {
    final repo = SensorReadingRepository();
    final random = Random();

    for (int i = 0; i < count; i++) {
      final reading = SensorReading(
        plantId: plantId,
        temperature: 20 + random.nextDouble() * 15,
        humidity: 40 + random.nextDouble() * 40,
        soilMoisture: 20 + random.nextDouble() * 50,
        light: 100 + random.nextDouble() * 700,
      );
      await repo.insert(reading);

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}