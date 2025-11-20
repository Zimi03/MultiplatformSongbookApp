import 'package:flutter/material.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/models/song_structure.dart';
import 'package:songbook/pages/add_song_page.dart';
import 'package:songbook/transposer/transposer.dart';

class SongPage extends StatefulWidget {
  final Song song;

  const SongPage({super.key, required this.song});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final double _fontSize = 14;

  late String selectedKey;

  final List<String> allKeys = [
    'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#',
    'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb',
    'Numbers'
  ];

  @override
  void initState() {
    super.initState();
    selectedKey = widget.song.key; 
  }

  List<String> _transposeProgression(SongSection section) {
    return section.progression.map((line) {
      return transposeWholeProgression(
        line,
        section.key,
        selectedKey,
      );
    }).toList();
  }

  List<Widget> _buildSectionWidgets(SongSection section) {
    final transposed = _transposeProgression(section);
    final widgets = <Widget>[];

    for (int i = 0; i < section.lyrics.length; i++) {
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                section.lyrics[i],
                style: TextStyle(fontSize: _fontSize, fontFamily: "Inter"),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    transposed.length > i ? transposed[i] : "",
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.song.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF74A892),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddSongPage()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artist: ${widget.song.artist}',
                    style: TextStyle(fontSize: 18, fontFamily:'Inter', fontWeight: FontWeight.w700),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${widget.song.tempo} BPM',
                          style: TextStyle(fontSize: 18,fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      Text(widget.song.timeSignature,
                          style: TextStyle(fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Key:",
                    style: TextStyle(fontFamily: "Inter", fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  DropdownButton<String>(
                    value: selectedKey,
                    dropdownColor: Colors.white,
                    style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "Inter"),
                    items: allKeys.map((key) {
                      return DropdownMenuItem(
                        value: key,
                        child: Text(key),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedKey = value!;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 20),
              for (var section in widget.song.structure.sections) ...[
                Text(
                  section.name,
                  style: TextStyle(
                    fontSize: _fontSize + 4,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),

                // zamiast IIFE używamy helpera
                ..._buildSectionWidgets(section),

                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
