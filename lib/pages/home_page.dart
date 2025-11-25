import 'package:flutter/material.dart';
import 'package:songbook/services/daos/song_dao.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/pages/song_page.dart';
import 'package:songbook/pages/add_song_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  String _query = "";
  String _sortField = "title";
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final dao = SongDao();
    final songs = await dao.getAllSongs();

    setState(() {
      _songs = songs;
      _filteredSongs = songs;
    });
  }

  void _filterSongs(String query) {
    setState(() {
      _query = query.toLowerCase();
      _filteredSongs = _songs.where((s) {
        return s.title.toLowerCase().contains(_query) ||
               s.artist.toLowerCase().contains(_query) || 
               s.structure.sections.any((sec) => sec.lyrics.any((l) => l.toLowerCase().contains(_query)));
      }).toList();
      _sortSongs();
    });
  }

  void _sortSongs() {
    _filteredSongs.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (_sortField) {
        case "id":
          valueA = a.id;
          valueB = b.id;
          break;
        case "artist":
          valueA = a.artist;
          valueB = b.artist;
          break;
        case "title":
        default:
          valueA = a.title;
          valueB = b.title;
      }

      return _ascending
          ? valueA.compareTo(valueB)
          : valueB.compareTo(valueA);
    });
  }

  void _changeSorting(String field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending;
      } else {
        _sortField = field;
        _ascending = true;
      }
      _sortSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Song List",
          style: TextStyle(
            fontFamily: 'Inter'
          ),
        ),
        backgroundColor: const Color(0xFF74A892),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF74A892),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSongPage()),
          );
          _loadSongs();
        },
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Szukaj (tytuł / artysta)",
                border: OutlineInputBorder(),
              ),
              onChanged: _filterSongs,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _sortButton("Tytuł", "title"),
              _sortButton("Artysta", "artist"),
              _sortButton("Added", "id"),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, i) {
                final song = _filteredSongs[i];

                return Dismissible(
                  key: Key(song.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 32),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Usunąć piosenkę?"),
                        content: Text("Czy na pewno chcesz usunąć „${song.title}”?"),
                        actions: [
                          TextButton(
                            child: Text("Anuluj"),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text("Usuń", style: TextStyle(color: Colors.red)),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    await SongDao().deleteSong(song.id!);
                    _loadSongs(); // odśwież listę
                  },
                  child: ListTile(
                    title: Text(
                      "${i + 1}. ${song.title}",
                      style: const TextStyle(fontFamily: "Inter"),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(fontFamily: "Inter"),
                    ),
                   onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SongPage(song: song)),
                    );
                    _loadSongs();
                  }
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortButton(String label, String field) {
    final isActive = _sortField == field;

    return TextButton.icon(
      onPressed: () => _changeSorting(field),
      icon: Icon(
        isActive
            ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.unfold_more,
        color: isActive ? const Color(0xFFff8400) : Colors.grey,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFFff8400) : Colors.grey,
        ),
      ),
    );
  }
}
