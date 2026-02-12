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
                        builder: (_) => DetailScreen(plant: plant),
                      ),
                    );
                    _refresh();
                  },

                  onDelete: () async {

                    if (plant.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot delete plant: invalid ID'),
                        ),
                      );
                      return;
                    }

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Plant"),
                        content: Text(
                          'Are you sure you want to delete "${plant.plantName}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final rowsDeleted =
                    await PlantRepository().deleteById(plant.id!);

                    if (rowsDeleted > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('"${plant.plantName}" deleted successfully'),
                        ),
                      );
                      _refresh();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Delete failed.'),
                        ),
                      );
                    }
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
  final VoidCallback onDelete;

  const _PlantCard({
    required this.plant,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Card(
          elevation: 3,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          clipBehavior: Clip.antiAlias,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // IMAGE
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
                padding:
                const EdgeInsets.fromLTRB(10, 10, 10, 4),

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

              // DELETE BUTTON (still clickable)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),

                child: Center(
                  child: TextButton.icon(
                    onPressed: onDelete,

                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),

                    label: const Text("Delete"),

                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}