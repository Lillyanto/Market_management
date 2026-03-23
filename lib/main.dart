import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MarketManagementApp());
}

class MarketManagementApp extends StatelessWidget {
  const MarketManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}