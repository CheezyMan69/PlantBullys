import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/sensor_reading.dart';

class SensorReadingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insert a new reading
  Future<int> insert(SensorReading reading) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'sensor_readings',
      reading.toMap()..remove('id')..remove('recorded_at'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get latest reading for a plant
  Future<SensorReading?> getLatest(int plantId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sensor_readings',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SensorReading.fromMap(maps.first);
    }
    return null;
  }

  // Get readings for a plant with optional limit
  Future<List<SensorReading>> getByPlantId(int plantId, {int limit = 100}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sensor_readings',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
    return maps.map((map) => SensorReading.fromMap(map)).toList();
  }

  // Get readings within a date range
  Future<List<SensorReading>> getByDateRange(
    int plantId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sensor_readings',
      where: 'plant_id = ? AND recorded_at BETWEEN ? AND ?',
      whereArgs: [plantId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'recorded_at DESC',
    );
    return maps.map((map) => SensorReading.fromMap(map)).toList();
  }

  // Calculate days since last watered (moisture peak)
  Future<int?> getDaysSinceLastWatered(int plantId, double moistureThreshold) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT julianday('now') - julianday(recorded_at) AS days_ago
      FROM sensor_readings
      WHERE plant_id = ? AND soil_moisture >= ?
      ORDER BY recorded_at DESC
      LIMIT 1
    ''', [plantId, moistureThreshold]);

    if (result.isNotEmpty && result.first['days_ago'] != null) {
      return (result.first['days_ago'] as double).toInt();
    }
    return null; // No watering event found
  }

  // Delete old readings (keep last N days)
  Future<int> deleteOldReadings(int plantId, int keepDays) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    return await db.delete(
      'sensor_readings',
      where: 'plant_id = ? AND recorded_at < ?',
      whereArgs: [plantId, cutoffDate.toIso8601String()],
    );
  }

  // Delete all readings for a plant
  Future<int> deleteByPlantId(int plantId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'sensor_readings',
      where: 'plant_id = ?',
      whereArgs: [plantId],
    );
  }

  // Get readings from the last 5 days
  Future<List<SensorReading>> getLastFiveDays(int plantId) async {
    final db = await _dbHelper.database;
    final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
    final maps = await db.query(
      'sensor_readings',
      where: 'plant_id = ? AND recorded_at >= ?',
      whereArgs: [plantId, fiveDaysAgo.toIso8601String()],
      orderBy: 'recorded_at ASC',
    );
    return maps.map((map) => SensorReading.fromMap(map)).toList();
  }

  // Get average readings for a plant (useful for trends)
  Future<Map<String, double?>> getAverages(int plantId, {int lastNReadings = 10}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        AVG(temperature) as avg_temp,
        AVG(humidity) as avg_humidity,
        AVG(soil_moisture) as avg_moisture,
        AVG(light) as avg_light
      FROM (
        SELECT temperature, humidity, soil_moisture, light
        FROM sensor_readings
        WHERE plant_id = ?
        ORDER BY recorded_at DESC
        LIMIT ?
      )
    ''', [plantId, lastNReadings]);

    if (result.isNotEmpty) {
      return {
        'temperature': result.first['avg_temp'] as double?,
        'humidity': result.first['avg_humidity'] as double?,
        'soilMoisture': result.first['avg_moisture'] as double?,
        'light': result.first['avg_light'] as double?,
      };
    }
    return {};
  }
}
