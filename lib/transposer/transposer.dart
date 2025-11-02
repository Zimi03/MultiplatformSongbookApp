final List<String> majorKeys = [
  "C", 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
];

final List<String> majorKeysFlat = [
  "C", 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
];

final List<int> majorScalePattern = [2, 2, 1, 2, 2, 2, 1];

List<String> generateMajorScale(String root) {
  List<String> scale = [];
  List<String> keys = majorKeys.contains(root) ? majorKeys : majorKeysFlat;

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
  int fromIndex = majorKeys.contains(fromKey) ? majorKeys.indexOf(fromKey) : majorKeysFlat.indexOf(fromKey);
  int toIndex = majorKeys.contains(toKey) ? majorKeys.indexOf(toKey) : majorKeysFlat.indexOf(toKey);
  
  if(fromIndex == -1 || toIndex == -1) {
    throw ArgumentError('Invalid fromKey or toKey');
  }

  bool useFlats = majorKeysFlat.contains(toKey);
  int semitoneDifference = (toIndex - fromIndex);
  String transposedProgression = '';

  for(int i = 0; i < progression.length; i++) {
    String chord = progression[i];
    int currentCordIndex = useFlats ? majorKeysFlat.indexOf(chord) : majorKeys.indexOf(chord);
    print('Processing chord: $chord');

    if(chord == ' ' || chord.isEmpty || chord == '|' || chord == '/' || currentCordIndex == -1) {
      transposedProgression += chord;
      continue;
    }
    
    String transposedChord = useFlats ? majorKeysFlat[(majorKeysFlat.indexOf(chord) + semitoneDifference) % 12] : majorKeys[(majorKeys.indexOf(chord) + semitoneDifference) % 12];
    transposedProgression += transposedChord;
  }
  return transposedProgression;
}
void main() {
  print(generateMajorScale("Bb")); 
  String progression = '|Dmaj7 / / Bm|A|';
  String transposedPrograssion = transposeProgression(progression, 'D', 'Bb'); 
  print(progression);
  print(transposedPrograssion);// Example usage
}