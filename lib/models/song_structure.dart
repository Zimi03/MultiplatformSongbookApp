class SongStructure {
  final List<SongSection> sections;

  SongStructure({required this.sections});

  factory SongStructure.fromJson(Map<String, dynamic> json) {
    return SongStructure(
      sections: (json['sections'] as List)
          .map((sectionJson) => SongSection.fromJson(sectionJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}


class SongSection {
  final String name;
  final List<String> lyrics;
  final List<String> progression;

  SongSection({required this.name, required this.lyrics, required this.progression});

  factory SongSection.fromJson(Map<String, dynamic> json) {
    return SongSection(
      name: json['name'],
      lyrics: List<String>.from(json['lyrics']),
      progression: List<String>.from(json['progression']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lyrics': lyrics,
      'progression': progression,
    };
  }
}