// To parse this JSON data, do
//
//     final verseResponse = verseResponseFromJson(jsonString);

import 'dart:convert';

import 'package:catechism/models/catechism.dart';
import 'package:collection/collection.dart';

List<List<VerseResponse>> verseResponseFromJson(String str) =>
    List<List<VerseResponse>>.from(
      json.decode(str).map(
            (x) => List<VerseResponse>.from(
              x.map(
                (x) => VerseResponse.fromJson(x),
              ),
            ),
          ),
    );

List<ReferencedVerses> verseResponseFromMap(
  List<dynamic> data,
  List<String> references,
  List<int> proofIds,
) {
  return List<ReferencedVerses>.from(
    data.mapIndexed(
      (index, list) {
        return ReferencedVerses.from(
          list.map<VerseResponse>(
            (item) {
              return VerseResponse.fromJson(item);
            },
          ).toList(),
          references[index],
          proofIds[index],
        );
      },
    ),
  );
}

String verseResponseToJson(List<List<VerseResponse>> data) => json.encode(
      List<dynamic>.from(
        data.map(
          (x) => List<dynamic>.from(
            x.map(
              (x) => x.toJson(),
            ),
          ),
        ),
      ),
    );

class VerseResponse {
  int pk;
  String translation;
  int book;
  int chapter;
  int verse;
  String text;

  VerseResponse({
    required this.pk,
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory VerseResponse.fromJson(Map<String, dynamic> json) => VerseResponse(
        pk: json["pk"],
        translation: json["translation"],
        book: json["book"],
        chapter: json["chapter"],
        verse: json["verse"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "pk": pk,
        "translation": translation,
        "book": book,
        "chapter": chapter,
        "verse": verse,
        "text": text,
      };
}
