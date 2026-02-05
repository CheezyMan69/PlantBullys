class SensorReading {
  final int? id;
  final int plantId;
  final double? temperature;
  final double? humidity;
  final double? soilMoisture;
  final double? light;
  final DateTime? recordedAt;

  SensorReading({
    this.id,
    required this.plantId,
    this.temperature,
    this.humidity,
    this.soilMoisture,
    this.light,
    this.recordedAt,
  });

  // Convert SensorReading to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plant_id': plantId,
      'temperature': temperature,
      'humidity': humidity,
      'soil_moisture': soilMoisture,
      'light': light,
      'recorded_at': recordedAt?.toIso8601String(),
    };
  }

  // Create SensorReading from database Map
  factory SensorReading.fromMap(Map<String, dynamic> map) {
    return SensorReading(
      id: map['id'] as int?,
      plantId: map['plant_id'] as int,
      temperature: map['temperature'] as double?,
      humidity: map['humidity'] as double?,
      soilMoisture: map['soil_moisture'] as double?,
      light: map['light'] as double?,
      recordedAt: map['recorded_at'] != null
          ? DateTime.parse(map['recorded_at'] as String)
          : null,
    );
  }

  // Create a copy with updated fields
  SensorReading copyWith({
    int? id,
    int? plantId,
    double? temperature,
    double? humidity,
    double? soilMoisture,
    double? light,
    DateTime? recordedAt,
  }) {
    return SensorReading(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      light: light ?? this.light,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
