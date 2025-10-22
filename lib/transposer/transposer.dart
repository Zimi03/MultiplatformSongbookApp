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

void main() {
  print(generateMajorScale("Bb"));  // Example usage
}