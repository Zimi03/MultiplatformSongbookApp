import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "songbook.db");

    return await openDatabase(
      path,
      version: 1,                 
      onCreate: _onCreate,
    );
  }

Future<void> _onCreate(Database db, int version) async {
  await db.execute("""
    CREATE TABLE songs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      artist TEXT,
      tempo INTEGER,
      key TEXT NOT NULL,
      TimeSignature TEXT,
      structure TEXT NOT NULL,
    );
  """);

  // --- seed data: "Krok za krokiem" ---
  final Map<String, dynamic> seedStructure = {
    "sections": [
      {
        "name": "ZWR 1",
        "key": "D",
        "lyrics": [
          "PRZEZ TWE CIAŁO PRZEZ ZASŁONĘ",
          "ŚMIAŁO WCHODZĘ DO ŚWIĄTYNI",
          "IDĘ NAPRZÓD ŻYWĄ DROGĄ",
          "CZYSTA TYLKO PRZEZ KREW TWOJĄ"
        ],
        "progression": [
          "| Bm7 | % |",
          "| G | Em7 |",
          "",
          ""
        ]
      },
      {
        "name": "REF",
        "key": "D",
        "lyrics": [
          "KROK ZA KROKIEM CORAZ BLIŻEJ.",
          "W BLASKU OCZY SWE ZAKRYWAM",
          "ZGINAM SIĘ I PADAM NISKO NA KOLANA",
          "JAK MAM PRZEŻYĆ TO SPOTKANIE",
          "DOTKNIJ OGNIEM UST MYCH PANIE",
          "CZY ME OCZY MOGĄ UJRZEĆ KRÓLA CHWAŁY."
        ],
        "progression": [
          "| G |",
          "| Bm7 |",
          "| D2/A | Em7 |",
          "| G |",
          "| Bm7 |",
          "| A | Em7 |"
        ]
      }
    ]
  };

  await db.insert('songs', {
    'title': 'Krok za krokiem',
    'artist': 'Fisheclectic',
    'tempo': 120,
    'key': 'D',
    'TimeSignature': '4/4',
    'structure': jsonEncode(seedStructure),
    // created_at i updated_at mają DEFAULT CURRENT_TIMESTAMP (jeśli zdefiniowane)
  });
}


  Future close() async {
    final db = await database;
    db.close();
  }
}
