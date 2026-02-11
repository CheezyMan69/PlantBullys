import 'dart:convert';
import 'package:http/http.dart' as http;

import '../database/models/plant.dart';
import '../database/models/sensor_reading.dart';
import '../database/repositories/plant_repository.dart';
import '../database/repositories/sensor_reading_repository.dart';

class SyncService {

  static const baseUrl = "http://";

  static Future syncPlants() async {

    final res =
        await http.get(Uri.parse("$baseUrl/plants"));

    final data = jsonDecode(res.body);

    final repo = PlantRepository();

    for (var p in data) {
      await repo.insert(Plant.fromMap(p));
    }
  }

  static Future syncReadings() async {

    final res =
        await http.get(Uri.parse("$baseUrl/readings"));

    final data = jsonDecode(res.body);

    final repo = SensorReadingRepository();

    for (var r in data) {
      await repo.insert(SensorReading.fromMap(r));
    }
  }

  static Future syncAll() async {

    await syncPlants();
    await syncReadings();
  }
}