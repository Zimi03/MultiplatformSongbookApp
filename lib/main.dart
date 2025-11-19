import 'package:flutter/material.dart';
import 'package:songbook/transposer/transposer.dart' as transposer;
import 'package:songbook/pages/home_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
