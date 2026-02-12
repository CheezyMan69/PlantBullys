import 'package:flutter/material.dart';

import '../database/models/plant.dart';
import '../database/repositories/plant_repository.dart';
import 'detail_screen.dart';
import 'add_plant_screen.dart';

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
    _loadPlants();
  }

  void _loadPlants() {
    _plantsFuture = PlantRepository().getAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadPlants();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Plants 🌱"),
        centerTitle: true,
      ),

      // ➕ ADD PLANT BUTTON
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPlantScreen(),
            ),
          );

          // Reload after adding
          if (result == true) {
            _refresh();
          }
        },
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
                textAlign: TextAlign.center,
              ),
            );
          }

          // Empty
          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No plants added yet 🌱",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final plants = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,

            child: GridView.builder(

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

                  onTap: () async {

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailScreen(plant: plant),
                      ),
                    );

                    // Reload when returning
                    _refresh();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------
// PLANT CARD
// --------------------------------------------------

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

        clipBehavior: Clip.antiAlias,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            // IMAGE AREA
            Expanded(
              child: Container(

                padding: const EdgeInsets.all(12),
                color: Colors.green[100],

                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,

                    child: Image.asset(

                      plant.iconPath,

                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,

                      // Fallback if image missing
                      errorBuilder:
                          (context, error, stack) {
                        return const Icon(
                          Icons.local_florist,
                          size: 40,
                          color: Colors.green,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // NAME
            Padding(
              padding: const EdgeInsets.all(10),

              child: Text(

                plant.plantName,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}