import 'package:flutter/material.dart';
import 'package:songbook/transposer/transposer.dart' as transposer;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tonacje durowe')),
        body: ListView.builder(
          itemCount: transposer.sharpNotes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(transposer.sharpNotes[index]),
            );
          },
        ),
      ),    
    );
  }
}
