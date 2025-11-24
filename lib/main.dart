import 'package:flutter/material.dart';
import 'package:songbook/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Songbook",
      theme: ThemeData(
        primaryColor: const Color(0xFF74A892),
      ),
      home: const HomePage(),
    );
  }
} 
