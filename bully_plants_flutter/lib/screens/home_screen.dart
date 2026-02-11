import 'package:flutter/material.dart';

import '../database/models/plant.dart';
import '../database/repositories/plant_repository.dart';
import '../screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<Plant>> plants;

  @override
  void initState() {
    super.initState();
    plants = PlantRepository().getAll();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("My Plants 🌱")),

      body: FutureBuilder(

        future: plants,

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final list = snapshot.data!;

          return GridView.builder(

            padding: const EdgeInsets.all(12),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .8,
            ),

            itemCount: list.length,

            itemBuilder: (context, i) {

              final plant = list[i];

              return GestureDetector(

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(plant: plant),
                    ),
                  );
                },

                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_florist,
                        size: 60,
                        color: Colors.green,
                      ),
                    ),
                  ),


                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          plant.plantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}