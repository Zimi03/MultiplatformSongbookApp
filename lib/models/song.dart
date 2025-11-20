import 'dart:convert';
import 'package:songbook/models/song_structure.dart';

class Song {
  final int? id;            
  final String title;
  final String artist;
  final int tempo;
  final String key;
  final String timeSignature;
  final SongStructure structure;

  Song({
    this.id,               
    required this.title,
    required this.artist,
    required this.tempo,
    required this.key,
    required this.timeSignature,
    required this.structure,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],      
      title: map['title'],
      artist: map['artist'],
      tempo: map['tempo'],
      key: map['key'],
      timeSignature: map['TimeSignature'],
      structure: SongStructure.fromJson(jsonDecode(map['structure'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,                  
      'title': title,
      'artist': artist,
      'tempo': tempo,
      'key': key,
      'TimeSignature': timeSignature,
      'structure': jsonEncode(structure.toJson()),
    };
  }
}
