import 'package:flutter/material.dart';
import 'package:songbook/models/song.dart';
import 'package:songbook/models/song_structure.dart';
import 'package:songbook/services/daos/song_dao.dart';

class EditSongPage extends StatefulWidget {
  final Song song;

  EditSongPage({required this.song});

  @override
  State<EditSongPage> createState() => _EditSongPageState();
}

class _EditSongPageState extends State<EditSongPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleCtrl;
  late TextEditingController artistCtrl;
  late TextEditingController tempoCtrl;

  late String selectedKey;
  late String selectedTime;

  List<Map<String, TextEditingController>> sections = [];

  final progressionRegex = RegExp(
    r'^(\|\s*([^\|]+?)\s*)+\|$'
  );



  String? validateProgression(String? value) {
    if (value == null || value.trim().isEmpty) return null; // allow empty if user wants no chords

    final lines = value.split("\n");

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (!progressionRegex.hasMatch(line.trim())) {
        return "Niepoprawny format progresji w linii:\n$line\n"
            "Użyj: | akord / % | ...";
      }
    }

    return null; // OK
  }

  @override
  void initState() {
    super.initState();

    // wypełnienie pól
    titleCtrl = TextEditingController(text: widget.song.title);
    artistCtrl = TextEditingController(text: widget.song.artist);
    tempoCtrl = TextEditingController(text: widget.song.tempo.toString());

    selectedKey = widget.song.key;
    selectedTime = widget.song.timeSignature;

    // wypełnianie sekcji
    for (var sec in widget.song.structure.sections) {
      sections.add({
        "name": TextEditingController(text: sec.name),
        "lyrics": TextEditingController(text: sec.lyrics.join("\n")),
        "progression": TextEditingController(text: sec.progression.join("\n")),
      });
    }

    if (sections.isEmpty) addNewSection();
  }

  void addNewSection() {
    setState(() {
      sections.add({
        "name": TextEditingController(),
        "lyrics": TextEditingController(),
        "progression": TextEditingController(),
      });
    });
  }

  Future<void> saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    List<SongSection> songSections = sections.map((sec) {
      List<String> lyricsLines =
          sec["lyrics"]!.text.split("\n").where((line) => line.trim().isNotEmpty).toList();

      List<String> progressionLines =
          sec["progression"]!.text.split("\n").where((line) => line.trim().isNotEmpty).toList();

      return SongSection(
        name: sec["name"]!.text.trim(),
        lyrics: lyricsLines,
        progression: progressionLines,
      );
    }).toList();

    SongStructure structure = SongStructure(sections: songSections);

    Song updated = Song(
      id: widget.song.id,
      title: titleCtrl.text.trim(),
      artist: artistCtrl.text.trim(),
      tempo: int.tryParse(tempoCtrl.text.trim()) ?? 120,
      key: selectedKey,
      timeSignature: selectedTime,
      structure: structure,
    );
 
    await SongDao().updateSong(updated);
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj piosenkę", style: TextStyle(fontFamily: "Inter")),
        backgroundColor: Color(0xFF74A892),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewSection,
        backgroundColor: Color(0xFF74A892),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // --- główne pola ---
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: "Tytuł"),
                  validator: (v) => v!.isEmpty ? "Podaj tytuł" : null,
                ),
                TextFormField(
                  controller: artistCtrl,
                  decoration: InputDecoration(labelText: "Autor"),
                ),
                TextFormField(
                  controller: tempoCtrl,
                  decoration: InputDecoration(labelText: "Tempo (BPM)"),
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 16),

                // TONACJA
                DropdownButtonFormField<String>(
                  initialValue: selectedKey,
                  decoration: InputDecoration(labelText: "Tonacja"),
                  items: [
                    "C", "G", "D", "A", "E", "B", "F#", "C#",
                    "F", "Bb", "Eb", "Ab", "Db", "Gb",
                    "Numbers"
                  ].map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                  onChanged: (v) => setState(() => selectedKey = v!),
                ),

                // METRUM
                TextFormField(
                  initialValue: selectedTime,
                  decoration: InputDecoration(labelText: "Metrum (np. 4/4)"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Podaj metrum";

                    final regex = RegExp(r'^\d+\/\d+$');
                    if (!regex.hasMatch(value.trim())) {
                      return "Metrum musi mieć format liczba/liczba (np. 4/4)";
                    }

                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value.trim();
                    });
                  },
                ),

                SizedBox(height: 24),

                Text(
                  "Sekcje",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12),

                for (int i = 0; i < sections.length; i++) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sekcja ${i + 1}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            if (sections.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    sections.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),

                        TextFormField(
                          controller: sections[i]["name"],
                          decoration: InputDecoration(labelText: "Nazwa sekcji"),
                        ),

                        TextFormField(
                          controller: sections[i]["lyrics"],
                          decoration: InputDecoration(labelText: "Tekst (każda linia osobno)"),
                          maxLines: null,
                        ),

                        TextFormField(
                          controller: sections[i]["progression"],
                          decoration: InputDecoration(
                            labelText: "Progresja (akordy w taktach, np. | Cmaj7 | Am7 D7 |)",
                            errorMaxLines: 3,
                          ),
                          validator: validateProgression,
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 32),

                ElevatedButton(
                  onPressed: saveSong,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8400),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Zapisz zmiany",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
