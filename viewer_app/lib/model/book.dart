// To parse this JSON data, do
//
//     final bookConfig = bookConfigFromJson(jsonString);

import 'dart:convert';

BookConfig bookConfigFromJson(String str) =>
    BookConfig.fromJson(json.decode(str));

String bookConfigToJson(BookConfig data) => json.encode(data.toJson());

BookConfig createAFailedBook() {
  return BookConfig.fromJson({
    "id": 0,
    "title": "Book Error",
    "bookConfigClass": "None",
    "pages": 0,
    "pageList": <String>[],
    "url": "",
    "language": <String>[],
    "parody": <String>[],
    "character": <String>[],
    "group": <String>[],
    "artist": <String>[],
    "male": <String>[],
    "female": <String>[],
    "other": <String>[],
    "isSearched": false,
  });
}

class BookConfig {
  int id;
  String title;
  String bookConfigClass;
  int pages;
  List<String> pageList;
  String url;
  List<String> language;
  List<String> parody;
  List<String> character;
  List<String> group;
  List<String> artist;
  List<String> male;
  List<String> female;
  List<String> other;
  bool isSearched;

  BookConfig({
    required this.id,
    required this.title,
    required this.bookConfigClass,
    required this.pages,
    required this.pageList,
    required this.url,
    required this.language,
    required this.parody,
    required this.character,
    required this.group,
    required this.artist,
    required this.male,
    required this.female,
    required this.other,
    required this.isSearched,
  });

  factory BookConfig.fromJson(Map<String, dynamic> json) => BookConfig(
        id: json["id"],
        title: json["title"],
        bookConfigClass: json["class"],
        pages: json["pages"],
        pageList: List<String>.from(json["page_list"].map((x) => x)),
        url: json["url"],
        language: List<String>.from(json["language"].map((x) => x)),
        parody: List<String>.from(json["parody"].map((x) => x)),
        character: List<String>.from(json["character"].map((x) => x)),
        group: List<String>.from(json["group"].map((x) => x)),
        artist: List<String>.from(json["artist"].map((x) => x)),
        male: List<String>.from(json["male"].map((x) => x)),
        female: List<String>.from(json["female"].map((x) => x)),
        other: List<String>.from(json["other"].map((x) => x)),
        isSearched: json["is_searched"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "class": bookConfigClass,
        "pages": pages,
        "page_list": List<dynamic>.from(pageList.map((x) => x)),
        "url": url,
        "language": List<dynamic>.from(language.map((x) => x)),
        "parody": List<dynamic>.from(parody.map((x) => x)),
        "character": List<dynamic>.from(character.map((x) => x)),
        "group": List<dynamic>.from(group.map((x) => x)),
        "artist": List<dynamic>.from(artist.map((x) => x)),
        "male": List<dynamic>.from(male.map((x) => x)),
        "female": List<dynamic>.from(female.map((x) => x)),
        "other": List<dynamic>.from(other.map((x) => x)),
        "is_searched": isSearched,
      };
}
