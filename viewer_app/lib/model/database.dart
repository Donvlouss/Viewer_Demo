// ignore_for_file: constant_identifier_names

enum TagConfig {
  Class,
  Language,
  Parody,
  Character,
  Group_,
  Artist,
  Male,
  Female,
  Other
}

TagConfig? toEnum(String text) {
  for (var tag in TagConfig.values) {
    if (tag.toString().split('.').last == text) {
      return tag;
    }
  }
  return null;
}
