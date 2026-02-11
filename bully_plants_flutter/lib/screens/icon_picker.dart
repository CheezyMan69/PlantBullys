import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {

  final Function(String) onSelect;

  const IconPicker({super.key, required this.onSelect});

  static final icons = List.generate(
    10,
    (i) => "assets/plants/plant${i + 1}.png",
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Plant Icon")),

      body: GridView.builder(

        padding: const EdgeInsets.all(16),

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),

        itemCount: icons.length,

        itemBuilder: (context, i) {

          return GestureDetector(

            onTap: () {
              onSelect(icons[i]);
              Navigator.pop(context);
            },

            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),

                child: Image.asset(
                  icons[i],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}