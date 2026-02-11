import 'package:flutter/material.dart';

import '../database/models/plant.dart';
import '../database/models/sensor_reading.dart';
import '../database/repositories/sensor_reading_repository.dart';

import '../services/notifications.dart';
import '../widgets/sensor_charts.dart';

class DetailScreen extends StatefulWidget {

  final Plant plant;

  const DetailScreen({super.key, required this.plant});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  late Future<List<SensorReading>> readings;

  @override
  void initState() {
    super.initState();

    readings =
        SensorReadingRepository()
            .getLastFiveDays(widget.plant.id);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text(widget.plant.plantName)),

      body: FutureBuilder(

        future: readings,

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final list = snapshot.data!;

          if (list.isEmpty) {
            return const Center(child: Text("No data"));
          }

          final latest = list.last;

          NotificationService.checkPlant(
            widget.plant,
            latest,
          );

          return SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text("🌡️ Temperature"),
                SensorChart(readings: list, type: "temp"),

                const SizedBox(height: 20),

                const Text("💧 Soil"),
                SensorChart(readings: list, type: "soil"),

                const SizedBox(height: 20),

                const Text("☀️ Light"),
                SensorChart(readings: list, type: "light"),

                const SizedBox(height: 30),

                Card(
                  child: ListTile(
                    title: const Text("Current"),
                    subtitle: Text(
                      "Temp: ${latest.temperature}\n"
                      "Soil: ${latest.soilMoisture}\n"
                      "Light: ${latest.light}",
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}