import 'package:flutter/material.dart';
import 'package:songbook/services/daos/song_dao.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/pages/song_page.dart';

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
               s.artist.toLowerCase().contains(_query);
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Szukaj (tytuł / artysta)",
              border: OutlineInputBorder(),
            ),
            onChanged: _filterSongs,
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _sortButton("ID", "id"),
            _sortButton("Tytuł", "title"),
            _sortButton("Artysta", "artist"),
          ],
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _filteredSongs.length,
            itemBuilder: (context, i) {
              final song = _filteredSongs[i];
              return ListTile(
                title: Text("${song.id}. ${song.title}", style: TextStyle(
                  fontFamily: "Montserrat",
                )),
                subtitle: Text(song.artist, style: TextStyle(fontFamily: "Montserrat"),),
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => SongPage(song: song),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
        color: isActive ? Color(0xFFff8400) : Colors.grey,
        ),
      label: Text(label, style: TextStyle(
        color: isActive ? Color(0xFFff8400) : Colors.grey,
      )),
    );
  }
}
