import 'package:flutter/material.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/models/song_structure.dart';
import 'package:songbook/pages/edit_song_page.dart';
import 'package:songbook/transposer/transposer.dart';

class SongPage extends StatefulWidget {
  final Song song;

  const SongPage({super.key, required this.song});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late Song currentSong; // ← edytowalna kopia
  final double _fontSize = 16;
  late String selectedKey;

  final List<String> allKeys = [
    'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#',
    'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb',
    'Numbers'
  ];

  @override
  void initState() {
    super.initState();
    currentSong = widget.song;
    selectedKey = currentSong.key;
  }

  int _max(int a, int b) => a > b ? a : b;

  List<String> _transposeProgression(SongSection section, Song song) {
    return section.progression.map((line) {
      return transposeWholeProgression(
        line,
        song.key,
        selectedKey,
      );
    }).toList();
  }

  List<Widget> _buildSectionWidgets(SongSection section, Song song) {
    final transposed = _transposeProgression(section, song);
    final widgets = <Widget>[];

    int maxLines = _max(section.lyrics.length, transposed.length);

    for (int i = 0; i < maxLines; i++) {
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                i < section.lyrics.length ? section.lyrics[i] : "",
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
                    i < transposed.length ? transposed[i] : "",
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
          currentSong.title,
          style: TextStyle(fontSize: 24, fontFamily: "Inter"),
        ),
        backgroundColor: const Color(0xFF74A892),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedSong = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSongPage(song: currentSong),
                ),
              );

              if (updatedSong != null) {
                setState(() {
                  currentSong = updatedSong;
                  selectedKey = updatedSong.key;
                });
              }
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
                    'Artist: ${currentSong.artist}',
                    style: TextStyle(fontSize: 18, fontFamily:'Inter', fontWeight: FontWeight.w700),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${currentSong.tempo} BPM',
                          style: TextStyle(fontSize: 18,fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      Text(currentSong.timeSignature,
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

              SizedBox(height: 6),
              Divider(color: Colors.black, thickness: 1),
              SizedBox(height: 6),

              for (var section in currentSong.structure.sections) ...[
                Text(
                  section.name,
                  style: TextStyle(
                    fontSize: _fontSize + 4,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),

                ..._buildSectionWidgets(section, currentSong),

                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
