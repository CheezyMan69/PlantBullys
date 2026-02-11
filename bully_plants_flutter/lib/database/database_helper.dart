import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // 
  static const int _dbVersion = 2;

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
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, 
      onConfigure: _onConfigure,
    );
  }

  // Enable foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create tables (fresh install)
  Future<void> _onCreate(Database db, int version) async {

    // Plants table
    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_name TEXT NOT NULL,

        icon_path TEXT NOT NULL, --

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

        FOREIGN KEY (plant_id) 
        REFERENCES plants(id) 
        ON DELETE CASCADE
      )
    ''');

    // Index for faster queries
    await db.execute('''
      CREATE INDEX idx_readings_plant_time 
      ON sensor_readings(plant_id, recorded_at DESC)
    ''');
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {

    if (oldVersion < 2) {

      // Add icon_path column to existing plants table
      await db.execute('''
        ALTER TABLE plants 
        ADD COLUMN icon_path TEXT
      ''');

      // Optional: Set default icon for old plants
      await db.execute('''
        UPDATE plants
        SET icon_path = 'assets/plants/plant1.png'
        WHERE icon_path IS NULL
      ''');
    }
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}