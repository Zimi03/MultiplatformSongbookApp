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

bool keyUsesFlats(String key) {
  return majorKeysWithFlats.contains(key);
}



List<String> generateMajorScale(String root) {
  List<String> scale = [];
  List<String> keys = sharpNotes.contains(root) ? sharpNotes : flatNotes;

  int startIndex = keys.indexOf(root);
  if (startIndex == -1) {
    throw ArgumentError('Invalid root note: $root');
  }
  scale.add(keys[startIndex]);
  while(scale.length < 7) {
    int step = majorScalePattern[scale.length - 1];
    startIndex = (startIndex + step) % keys.length;
    scale.add(keys[startIndex]);
  }
  return scale;
}

String transposeProgression(String progression, String fromKey, String toKey) {
  int fromIndex = keyUsesFlats(fromKey) ? sharpNotes.indexOf(fromKey) : flatNotes.indexOf(fromKey);
  int toIndex = keyUsesFlats(toKey) ? sharpNotes.indexOf(toKey) : flatNotes.indexOf(toKey);
  
  if(fromIndex == -1 || toIndex == -1) {
    throw ArgumentError('Invalid fromKey or toKey');
  }

  bool useFlats = flatNotes.contains(toKey);
  int semitoneDifference = (toIndex - fromIndex);
  String transposedProgression = '';

  for(int i = 0; i < progression.length; i++) {
    String chord = progression[i];
    int currentCordIndex = useFlats ? flatNotes.indexOf(chord) : sharpNotes.indexOf(chord);

    if(chord == ' ' || chord.isEmpty || chord == '|' || chord == '/' || currentCordIndex == -1) {
      transposedProgression += chord;
      continue;
    }
    
    String transposedChord = useFlats ? flatNotes[(flatNotes.indexOf(chord) + semitoneDifference) % 12] : sharpNotes[(sharpNotes.indexOf(chord) + semitoneDifference) % 12];
    transposedProgression += transposedChord;
  }
  return transposedProgression;
}

String transposeToNumbers(String progression, String key) {
  List<String> scale = generateMajorScale(key);
  Map<String, String> chordToNumber = {
    scale[0]: '1',
    scale[1]: '2',
    scale[2]: '3',
    scale[3]: '4',
    scale[4]: '5',
    scale[5]: '6',
    scale[6]: '7',
  };
  String numberedProgression = '';
  for(int i = 0; i < progression.length; i++) {
    String chord = progression[i];
    if(chord == ' ' || chord.isEmpty || chord == '|' || chord == '/') {
      numberedProgression += chord;
      continue;
    }
    String number = chordToNumber[chord] ?? chord;
    numberedProgression += number;
  }
  return numberedProgression;
}

String TransposeFromNubersToKey(String progression, String key) {
  List<String> scale = generateMajorScale(key);
  Map<String, String> numberToChord = {
    '1': scale[0],
    '2': scale[1],
    '3': scale[2],
    '4': scale[3],
    '5': scale[4],
    '6': scale[5],
    '7': scale[6],
  };
  String chordProgression = '';
  for(int i = 0; i < progression.length; i++) {
    String symbol = progression[i];
    if(symbol == ' ' || symbol.isEmpty || symbol == '|' || symbol == '/') {
      chordProgression += symbol;
      continue;
    }
    String chord = numberToChord[symbol] ?? symbol;
    chordProgression += chord;
  }
  return chordProgression;
}

void Test(String progression, String fromKey, String toKey) {
  List<String> notes = keyUsesFlats(toKey) ? flatNotes : sharpNotes;
  int semitoneDifference = (notes.indexOf(toKey) - notes.indexOf(fromKey)) % notes.length;
  RegExp chordRegex = toKey == 'Numbers' ? RegExp(r'[A-G][b#]?/[A-G][b#]?'):RegExp(r'[A-G][b#]?');

  print('Input progression: $progression');
  String outputProgression = '|';
  List<String> barList = progression.split('|');
  for(String bar in barList) {
    if(bar.length > 1){
      List<String> chordParts = bar.split(' ');

      for(String part in chordParts) {
        chordRegex.allMatches(part).forEach((match) {
          String chord = match.group(0) ?? '';
          String transposed = transposedChord(chord, semitoneDifference, notes);
          part = part.replaceFirst(chord, transposed);
        });
        if(part.isEmpty) {
          continue;
        }
        outputProgression += '$part ';
      }
    } else {
      outputProgression += bar;
    }
    if(bar.isEmpty || bar ==' ') continue;
    outputProgression += '|';  

  }
  print('output progression: $outputProgression');
}

String transposedChord(String chord, int semitoneDifference, List<String> notes) {
  int currentIndex = notes.indexOf(chord);
  if(currentIndex == -1) {
    return chord; // Return the original chord if not found
  }
  int transposedIndex = (currentIndex + semitoneDifference) % notes.length;
  return notes[transposedIndex];
}

void main() {
  // print(generateMajorScale("Bb")); 
  String progression = '| Dmaj7 /|F#| ';
  // String transposedPrograssion = transposeProgression(progression, 'D', 'A'); 
  // String numberedProgression = transposeToNumbers(progression, 'D');
  // String fromNumbersToKey = TransposeFromNubersToKey(numberedProgression, 'F');
  // print(progression);
  // print(transposedPrograssion);// Example usage
  // print(numberedProgression);
  // // print(fromNumbersToKey);
  // String chord = 'D';
  // int semitoneDifference = -3; // Example: transposing down 3 semit
  // bool useFlats = true;
  // String transposed = transposedChord(chord, semitoneDifference, useFlats);
  // print('Transposed Chord: $transposed');
  Test(progression, 'D', 'A');
}