import 'package:flutter/material.dart';
import '../database/models/plant.dart';
import '../database/repositories/plant_repository.dart';
import '../screens/icon_picker.dart';
import '../debug/seed_data.dart'

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() =>
      _AddPlantScreenState();
}

class _AddPlantScreenState
    extends State<AddPlantScreen> {

  final _nameController = TextEditingController();
  String? _iconPath;

  Future<void> _pickIcon() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IconPicker(
          onSelect: (icon) {
            setState(() {
              _iconPath = icon;
            });
          },
        ),
      ),
    );
  }

  Future<void> _savePlant() async {
  if (_nameController.text.isEmpty || _iconPath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fill all fields")),
    );
    return;
  }

  final plant = Plant(
    plantName: _nameController.text,
    iconPath: _iconPath!,
    minTemperature: 15,
    maxTemperature: 35,
    minHumidity: 30,
    maxHumidity: 80,
    minSoilMoisture: 20,
    maxSoilMoisture: 70,
    minLight: 100,
    maxLight: 800,
    createdAt: DateTime.now(),
  );

  try {
    final plantId = await PlantRepository().insert(plant);

    if (plantId > 0) {
      await SeedData.insertFakeReadings(plantId, count: 20);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plant saved! ID: $plantId'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save plant'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Plant")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Plant Name",
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickIcon,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Center(
                  child: _iconPath == null
                      ? const Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                        )
                      : Image.asset(
                          _iconPath!,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _savePlant,
              child:
                  const Text("Save Plant"),
            ),
          ],
        ),
      ),
    );
  }
}