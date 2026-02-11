import 'package:flutter/material.dart';


import 'screens/home_screen.dart';
import 'services/notifications.dart';
import 'services/mqtt_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await MqttService().connect();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Plant Monitor",
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
      ),
      home: const HomeScreen(),
    );
  }
}