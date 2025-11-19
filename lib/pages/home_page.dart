import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tonacje durowe'), backgroundColor: const Color(0xFF74A892)),
      body: Center(
        child: Text('Welcome to the Home Page'),
      ),
    );
  }
}