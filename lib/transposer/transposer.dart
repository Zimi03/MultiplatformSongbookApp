final List<String> sharpNotes = [
  "C", 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
];

final List<String> flatNotes = [
  "C", 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
];

final List<String> majorKeysWithFlats = [
  'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb'
];

final List<String> majorKeysWithSharps = [
  'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#'
];

final List<int> majorScalePattern = [2, 2, 1, 2, 2, 2, 1];

final Map<String, String> enharmonicEquivalents = {
  'C#': 'Db', 
  'Db': 'C#',
  'D#': 'Eb', 
  'Eb': 'D#',
  'F#': 'Gb',
  'Gb': 'F#',
  'G#': 'Ab', 
  'Ab': 'G#',
  'A#': 'Bb', 
  'Bb': 'A#'
};

bool keyUsesFlats(String key) {
  return majorKeysWithFlats.contains(key);
}

int findNoteIndex(String note, List<String> preferredList) {
  int index = preferredList.indexOf(note);
  if (index != -1) return index;
  
  String? equivalent = enharmonicEquivalents[note];
  if (equivalent != null) {
    return preferredList.indexOf(equivalent);
  }
  return -1;
}

String extractRootNote(String chord) {
  if (chord.length >= 2 && (chord[1] == 'b' || chord[1] == '#')) {
    return chord.substring(0, 2);
  }
  return chord.substring(0, 1);
}

String trasposeChordToChord(String chord, int semitoneDifference, List<String> notesToKey) {
  if (chord.contains('/')) {
    List<String> parts = chord.split('/');
    String rootChord = parts[0];
    String bassNote = parts[1];
    
    String rootNote = extractRootNote(rootChord);
    String actualBassNote = extractRootNote(bassNote);
    
    int rootIndex = notesToKey.indexOf(rootNote);
    int bassIndex = notesToKey.indexOf(actualBassNote);
    
    if (rootIndex == -1) rootIndex = notesToKey.indexOf(enharmonicEquivalents[rootNote] ?? '');
    if (bassIndex == -1) bassIndex = notesToKey.indexOf(enharmonicEquivalents[actualBassNote] ?? '');
    
    if (rootIndex == -1 || bassIndex == -1) {
      return chord;
    }
    
    int transposedRootIndex = (rootIndex + semitoneDifference) % notesToKey.length;
    int transposedBassIndex = (bassIndex + semitoneDifference) % notesToKey.length;
    
    String newRoot = notesToKey[transposedRootIndex];
    String newBass = notesToKey[transposedBassIndex];
    String extensions = rootChord.substring(rootNote.length);
    
    return '$newRoot$extensions/$newBass';
  }
  
  int currentIndex = notesToKey.indexOf(chord);
  if (currentIndex == -1) {
    currentIndex = notesToKey.indexOf(enharmonicEquivalents[chord] ?? '');
  }
  if (currentIndex == -1) return chord;

  int transposedIndex = (currentIndex + semitoneDifference) % notesToKey.length;
  return notesToKey[transposedIndex];
}

String transposeChordToNumber(String chord, String fromKey) {
  List<String> scale = generateMajorScale(fromKey);
  Map<String, String> noteToDegree = {
    scale[0]: "I",
    scale[1]: "II",
    scale[2]: "III",
    scale[3]: "IV",
    scale[4]: "V",
    scale[5]: "VI",
    scale[6]: "VII",
  };

  if(chord.contains('/')){
    List<String> parts = chord.split('/');
    String rootChord = parts[0];
    String bassNote = parts[1];
    
    String rootNote = extractRootNote(rootChord);
    String actualBassNote = extractRootNote(bassNote);
    
    
    int rootIndex = scale.indexOf(rootNote);
    int bassIndex = scale.indexOf(actualBassNote);
    
    
    if (rootIndex == -1 || bassIndex == -1) {
      return chord;
    }
    
    String? newRoot = noteToDegree[scale[rootIndex]];
    String newBass = (bassIndex - rootIndex + 1).toString();
    String extensions = rootChord.substring(rootNote.length);
    
    return '$newRoot$extensions/$newBass';
  }else{
    String rootNote = extractRootNote(chord);
    int rootIndex = scale.indexOf(rootNote);
    if (rootIndex == -1) {
      return chord;
    }
    String? newRoot = noteToDegree[scale[rootIndex]];
    String extensions = chord.substring(rootNote.length);
    
    return '$newRoot$extensions';
  }
}

String transposeNumberToChord(String number, String toKey) {
  List<String> scale = generateMajorScale(toKey);
  Map<String, String> degreeToNote = {
    "I": scale[0],
    "II": scale[1],
    "III": scale[2],
    "IV": scale[3],
    "V": scale[4],
    "VI": scale[5],
    "VII": scale[6],
  };

  if (number.contains('/')) {
    List<String> parts = number.split('/');
    String rootNumber = parts[0];
    String bassDegree = parts[1];
    
    String rootDegree = rootNumber.replaceAll(RegExp(r'[^IViv]'), '');
    String extensions = rootNumber.substring(rootDegree.length);
    
    String? rootNote = degreeToNote[rootDegree];
    if (rootNote == null) {
      return number;
    }
    
    int bassInterval = int.tryParse(bassDegree) ?? -1;
    if (bassInterval < 1 || bassInterval > 7) {
      return number;
    }
    
    int rootIndex = scale.indexOf(rootNote);
    int actualBassIndex = (rootIndex + bassInterval - 1) % 7;
    String bassNote = scale[actualBassIndex];
    
    return '$rootNote$extensions/$bassNote';
  } else {
    String rootDegree = number.replaceAll(RegExp(r'[^IViv]'), '');
    String extensions = number.substring(rootDegree.length);
    
    String? rootNote = degreeToNote[rootDegree];
    if (rootNote == null) {
      return number;
    }
    
    return '$rootNote$extensions';
  }
}

String transposeWholeProgression(String progression, String fromKey, String toKey) {
  List<String> notesFromKey = keyUsesFlats(fromKey) ? flatNotes : sharpNotes;
  List<String> notesToKey = keyUsesFlats(toKey) ? flatNotes : sharpNotes;

  bool isChordToNumber = toKey == 'Numbers';
  bool isNumberToChord = fromKey == 'Numbers';

  int semitoneDifference = 0;
  if (!isChordToNumber && !isNumberToChord) {
    semitoneDifference = (notesToKey.indexOf(toKey) - notesFromKey.indexOf(fromKey)) % notesFromKey.length;
  }

  // Wybierz regex na podstawie typu transpozycji
  RegExp chordRegex = isNumberToChord
      ? RegExp(r'[IViv]+(?:[^ /\|]*)?(?:/[0-9]+)?|/')
      : RegExp(r'[A-G][b#]?(?:[^ /\|]*)?(?:/[A-G][b#]?)?|/');

  print('Input progression: $progression');
  String outputProgression = '|';
  List<String> barList = progression.split('|');
  
  for (String bar in barList) {
    if (bar.isEmpty || bar == ' ') continue;
    
    List<String> chordParts = bar.split(' ');
    for (int i = 0; i < chordParts.length; i++) {
      String part = chordParts[i];
      
      if (part == '/') {
        outputProgression += '/';
      } else {
        chordRegex.allMatches(part).forEach((match) {
          String chord = match.group(0) ?? '';
          String transposed = '';

          if(isNumberToChord){
            transposed = transposeNumberToChord(chord, toKey);
          }else if(isChordToNumber){
            transposed = transposeChordToNumber(chord, fromKey);
          }else{
            transposed = trasposeChordToChord(chord, semitoneDifference, notesToKey);
          }

          part = part.replaceFirst(chord, transposed);
        });
        outputProgression += part;
      }
      
      if (i < chordParts.length - 1) {
        outputProgression += ' ';
      }
    }
    outputProgression += '|';
  }
  
  print('output progression: $outputProgression');
  return outputProgression;
}

List<String> generateMajorScale(String root) {
  List<String> scale = [];
  List<String> keys = sharpNotes.contains(root) ? sharpNotes : flatNotes;

  int startIndex = keys.indexOf(root);
  if (startIndex == -1) {
    throw ArgumentError('Invalid root note: $root');
  }
  
  scale.add(keys[startIndex]);
  while (scale.length < 7) {
    int step = majorScalePattern[scale.length - 1];
    startIndex = (startIndex + step) % keys.length;
    scale.add(keys[startIndex]);
  }
  return scale;
}