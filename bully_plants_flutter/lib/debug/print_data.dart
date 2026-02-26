import '../database/models/plant.dart';
import '../database/models/sensor_reading.dart';
import '../database/repositories/plant_repository.dart';
import '../database/repositories/sensor_reading_repository.dart';

class DebugPrint {
  static Future<void> printAllPlants() async {
    final plants = await PlantRepository().getAll();
    
    print('========== PLANTS (${plants.length}) ==========');
    for (final plant in plants) {
      print('ID: ${plant.id}');
      print('Name: ${plant.plantName}');
      print('Temp: ${plant.minTemperature} - ${plant.maxTemperature}');
      print('Humidity: ${plant.minHumidity} - ${plant.maxHumidity}');
      print('Soil: ${plant.minSoilMoisture} - ${plant.maxSoilMoisture}');
      print('Light: ${plant.minLight} - ${plant.maxLight}');
      print('---');
    }
  }

  static Future<void> printReadings(int plantId) async {
    final readings = await SensorReadingRepository().getByPlantId(plantId, limit: 10);
    
    print('========== READINGS for Plant $plantId (${readings.length}) ==========');
    for (final r in readings) {
      print('ID: ${r.id} | Temp: ${r.temperature} | Soil: ${r.soilMoisture} | Light: ${r.light} | Time: ${r.recordedAt}');
    }
  }

  static Future<void> printAll() async {
    await printAllPlants();
    
    final plants = await PlantRepository().getAll();
    for (final plant in plants) {
      await printReadings(plant.id!);
    }
  }
}