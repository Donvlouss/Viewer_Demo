// ignore_for_file: non_constant_identifier_names

import 'package:viewer_app/model/database.dart';

enum QueryType { and, or, not }

class QueryModel {
  late final TagConfig name;
  final String value;

  QueryModel(this.name, this.value);
  QueryModel.Class({required this.value}) {
    name = TagConfig.Class;
  }
  QueryModel.Language({required this.value}) {
    name = TagConfig.Language;
  }
  QueryModel.Parody({required this.value}) {
    name = TagConfig.Parody;
  }
  QueryModel.Character({required this.value}) {
    name = TagConfig.Character;
  }
  QueryModel.Group({required this.value}) {
    name = TagConfig.Group_;
  }
  QueryModel.Artist({required this.value}) {
    name = TagConfig.Artist;
  }
  QueryModel.Male({required this.value}) {
    name = TagConfig.Male;
  }
  QueryModel.Female({required this.value}) {
    name = TagConfig.Female;
  }
  QueryModel.Other({required this.value}) {
    name = TagConfig.Other;
  }

  Map<String, String> toJson() =>
      {"name": name.toString().split('.').last, "value": value};
}
