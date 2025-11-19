import 'package:sqflite/sqflite.dart';
import 'package:songbook/models/song.dart';

class SongDao {
  final Database db;

  SongDao(this.db);

  Future<int> insertSong(Song song) async {
    return await db.insert(
      'songs',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Song>> getAllSongs() async {
    final List<Map<String, dynamic>> maps = await db.query('songs');

    return maps.map((map) => Song.fromMap(map)).toList();
  }

  Future<Song?> getSong(int id) async {
    final List<Map<String, dynamic>> maps =
        await db.query('songs', where: "id = ?", whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Song.fromMap(maps.first);
    }
    return null;
  }


  Future<int> updateSong(Song song) async {
    return await db.update(
      'songs',
      song.toMap(),
      where: "id = ?",
      whereArgs: [song.id],
    );
  }

  Future<int> deleteSong(int id) async {
    return await db.delete(
      'songs',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
