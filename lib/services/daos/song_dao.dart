import 'package:sqflite/sqflite.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/services/database_helper.dart';

class SongDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  SongDao();

  Future<int> insertSong(Song song) async {
    final db = await _dbHelper.database;

    final map = song.toMap();
    map.remove('id'); 

    return await db.insert(
      'songs',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Song>> getAllSongs() async {
    final db = await _dbHelper.database;
    final maps = await db.query('songs');
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  Future<Song?> getSong(int id) async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('songs', where: "id = ?", whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Song.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSong(Song song) async {
    final db = await _dbHelper.database;

    if (song.id == null) {
      throw ArgumentError("Cannot update a song without an ID");
    }

    return await db.update(
      'songs',
      song.toMap(),
      where: "id = ?",
      whereArgs: [song.id],
    );
  }

  Future<int> deleteSong(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'songs',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
