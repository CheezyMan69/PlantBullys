import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/plant.dart';

class PlantRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insert a new plant
  Future<int> insert(Plant plant) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'plants',
      plant.toMap()..remove('id')..remove('created_at'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a plant by ID
  Future<Plant?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Plant.fromMap(maps.first);
    }
    return null;
  }

  // Get all plants
  Future<List<Plant>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('plants', orderBy: 'created_at DESC');
    return maps.map((map) => Plant.fromMap(map)).toList();
  }

  // Update a plant
  Future<int> update(Plant plant) async {
    final db = await _dbHelper.database;
    return await db.update(
      'plants',
      plant.toMap()..remove('created_at'),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  // Delete a plant
  Future<int> deleteById(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // Search plants by name
  Future<List<Plant>> searchByName(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'plants',
      where: 'plant_name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map((map) => Plant.fromMap(map)).toList();
  }
}
