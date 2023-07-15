// To parse this JSON data, do
//
//     final bollsMeta = bollsMetaFromJson(jsonString);

import 'dart:convert';

Map<String, Map<String, BollsMeta>> bollsMetaFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) =>
        MapEntry<String, Map<String, BollsMeta>>(
            k,
            Map.from(v).map((k, v) =>
                MapEntry<String, BollsMeta>(k, BollsMeta.fromJson(v)))));

String bollsMetaToJson(Map<String, Map<String, BollsMeta>> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k,
        Map.from(v).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())))));

class BollsMeta {
  int bookid;
  int chronorder;
  String name;
  int chapters;

  BollsMeta({
    required this.bookid,
    required this.chronorder,
    required this.name,
    required this.chapters,
  });

  factory BollsMeta.fromJson(Map<String, dynamic> json) => BollsMeta(
        bookid: json["bookid"],
        chronorder: json["chronorder"],
        name: json["name"],
        chapters: json["chapters"],
      );

  Map<String, dynamic> toJson() => {
        "bookid": bookid,
        "chronorder": chronorder,
        "name": name,
        "chapters": chapters,
      };
}
