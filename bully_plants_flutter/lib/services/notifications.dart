import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../database/models/plant.dart';
import '../database/models/sensor_reading.dart';

class NotificationService {

  static final _plugin =
      FlutterLocalNotificationsPlugin();

  static final _rng = Random();

  static Future init() async {

    const android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings =
        InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  static final Map<String, List<String>> insults = {

    "dry": [
      "You want me to mummify?",
      "Water. Me. Now.",
      "Desert cosplay?",
      "Hydration pls."
    ],

    "cold": [
      "I'm freezing.",
      "Turn on heat.",
      "Plant abuse."
    ],

    "hot": [
      "I'm cooking.",
      "Help.",
      "Too hot."
    ],

    "dark": [
      "This is a cave.",
      "Where sun?",
      "Photosynthesis dying."
    ]
  };

  static void checkPlant(
    Plant plant,
    SensorReading reading,
  ) {

    List<String> issues = [];

    if (reading.soilMoisture! < plant.minSoilMoisture!)
      issues.add("dry");

    if (reading.temperature! < plant.minTemperature!)
      issues.add("cold");

    if (reading.temperature! > plant.maxTemperature!)
      issues.add("hot");

    if (reading.light! < plant.minLight!)
      issues.add("dark");

    if (issues.isEmpty) return;

    final t = issues[_rng.nextInt(issues.length)];
    final msg =
        insults[t]![_rng.nextInt(insults[t]!.length)];

    _send(msg);
  }

  static Future _send(String msg) async {

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        "plant_alerts",
        "Plant Alerts",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      0,
      "🚨 Plant Emergency",
      msg,
      details,
    );
  }
}