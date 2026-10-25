import 'package:flutter/material.dart';

import 'screens/map_screen.dart';

void main() {
  runApp(const GoogleMapsLocationApp());
}

class GoogleMapsLocationApp extends StatelessWidget {
  const GoogleMapsLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps & Location',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
