import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'plant_monitor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  // Enable foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Plants table
    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_name TEXT NOT NULL,
        perenual_id INTEGER,
        min_temperature REAL,
        max_temperature REAL,
        min_humidity REAL,
        max_humidity REAL,
        min_soil_moisture REAL,
        max_soil_moisture REAL,
        min_light REAL,
        max_light REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Sensor readings table
    await db.execute('''
      CREATE TABLE sensor_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_id INTEGER NOT NULL,
        temperature REAL,
        humidity REAL,
        soil_moisture REAL,
        light REAL,
        recorded_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (plant_id) REFERENCES plants(id) ON DELETE CASCADE
      )
    ''');

    // Index for faster queries
    await db.execute('''
      CREATE INDEX idx_readings_plant_time 
      ON sensor_readings(plant_id, recorded_at DESC)
    ''');
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
