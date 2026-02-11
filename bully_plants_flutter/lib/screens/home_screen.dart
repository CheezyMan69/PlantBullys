import 'package:flutter/material.dart';

import '../database/models/plant.dart';
import '../database/repositories/plant_repository.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<Plant>> _plantsFuture;

  @override
  void initState() {
    super.initState();

    // Load plants from SQLite
    _plantsFuture = PlantRepository().getAll();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Plants 🌱"),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Plant>>(

        future: _plantsFuture,

        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          // No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No plants added yet 🌱"),
            );
          }

          final plants = snapshot.data!;

          return GridView.builder(

            padding: const EdgeInsets.all(12),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),

            itemCount: plants.length,

            itemBuilder: (context, index) {

              final plant = plants[index];

              return _PlantCard(
                plant: plant,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(plant: plant),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {

  final Plant plant;
  final VoidCallback onTap;

  const _PlantCard({
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Card(

        elevation: 3,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          children: [

            // Plant icon
            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Image.asset(
                    plant.iconPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Name
            Padding(
              padding: const EdgeInsets.all(10),

              child: Text(
                plant.plantName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}