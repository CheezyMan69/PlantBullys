class Plant {
  final int? id;
  final String plantName;

  // ✅ NEW: path to custom plant icon
  final String iconPath;

  final int? perenualId;
  final double? minTemperature;
  final double? maxTemperature;
  final double? minHumidity;
  final double? maxHumidity;
  final double? minSoilMoisture;
  final double? maxSoilMoisture;
  final double? minLight;
  final double? maxLight;
  final DateTime? createdAt;

  Plant({
    this.id,
    required this.plantName,
    required this.iconPath, // ✅ REQUIRED

    this.perenualId,
    this.minTemperature,
    this.maxTemperature,
    this.minHumidity,
    this.maxHumidity,
    this.minSoilMoisture,
    this.maxSoilMoisture,
    this.minLight,
    this.maxLight,
    this.createdAt,
  });

  // Convert Plant to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plant_name': plantName,

      // ✅ SAVE ICON
      'icon_path': iconPath,

      'perenual_id': perenualId,
      'min_temperature': minTemperature,
      'max_temperature': maxTemperature,
      'min_humidity': minHumidity,
      'max_humidity': maxHumidity,
      'min_soil_moisture': minSoilMoisture,
      'max_soil_moisture': maxSoilMoisture,
      'min_light': minLight,
      'max_light': maxLight,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create Plant from database Map
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as int?,
      plantName: map['plant_name'] as String,

      // ✅ LOAD ICON
      iconPath: map['icon_path'] as String,

      perenualId: map['perenual_id'] as int?,
      minTemperature: (map['min_temperature'] as num?)?.toDouble(),
      maxTemperature: (map['max_temperature'] as num?)?.toDouble(),
      minHumidity: (map['min_humidity'] as num?)?.toDouble(),
      maxHumidity: (map['max_humidity'] as num?)?.toDouble(),
      minSoilMoisture: (map['min_soil_moisture'] as num?)?.toDouble(),
      maxSoilMoisture: (map['max_soil_moisture'] as num?)?.toDouble(),
      minLight: (map['min_light'] as num?)?.toDouble(),
      maxLight: (map['max_light'] as num?)?.toDouble(),

      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Create a copy with updated fields
  Plant copyWith({
    int? id,
    String? plantName,
    String? iconPath, // ✅

    int? perenualId,
    double? minTemperature,
    double? maxTemperature,
    double? minHumidity,
    double? maxHumidity,
    double? minSoilMoisture,
    double? maxSoilMoisture,
    double? minLight,
    double? maxLight,
    DateTime? createdAt,
  }) {
    return Plant(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,

      // ✅
      iconPath: iconPath ?? this.iconPath,

      perenualId: perenualId ?? this.perenualId,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      minSoilMoisture: minSoilMoisture ?? this.minSoilMoisture,
      maxSoilMoisture: maxSoilMoisture ?? this.maxSoilMoisture,
      minLight: minLight ?? this.minLight,
      maxLight: maxLight ?? this.maxLight,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}