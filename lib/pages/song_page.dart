import 'package:flutter/material.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/pages/add_song_page.dart';

class SongPage extends StatefulWidget {
  final Song song;

  const SongPage({super.key, required this.song});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  double _fontSize = 16;
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
                MaterialPageRoute(
                  builder: (context) => AddSongPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Artist: ${widget.song.artist}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(('Tempo: ${widget.song.tempo.toString()} BPM'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ('Time Signature: ${widget.song.timeSignature}'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(var section in widget.song.structure.sections) ...[
                          Text(
                            section.name,
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          for (int i = 0; i < section.lyrics.length; i++) ...[
                            Text(
                              section.lyrics[i],
                              style: TextStyle(fontSize: _fontSize),
                            ),
                            SizedBox(height: 4),
                          ],
                          SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(var section in widget.song.structure.sections) ...[
                          Text(
                            section.name,
                            style: TextStyle(
                              fontSize: _fontSize - 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          for (int i = 0; i < section.progression.length; i++) ...[
                            Text(
                              section.progression[i],
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontFamily: 'CourierNew',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                          SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
