// To parse this JSON data, do
//
//     final catechism = catechismFromJson(jsonString);

import 'dart:convert';

import 'package:catechism/catechism.dart';
import 'package:catechism/models/verseResponse.dart';
import 'package:catechism/network/requests.dart';

Catechism catechismFromJson(String str) => Catechism.fromJson(json.decode(str));

String catechismToJson(Catechism data) => json.encode(data.toJson());

const List<List<ReferencedVerses>> emptyVerses = [];

class Catechism {
  Metadata metadata;
  List<Content> content;

  Catechism({
    required this.metadata,
    required this.content,
  });

  factory Catechism.fromJson(Map<String, dynamic> json) => Catechism(
        metadata: Metadata.fromJson(json["Metadata"]),
        content:
            List<Content>.from(json["Data"].map((x) => Content.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Metadata": metadata.toJson(),
        "Data": List<dynamic>.from(content.map((x) => x.toJson())),
      };
}

class Content {
  int number;
  String question;
  String answer;
  String answerWithProofs;
  List<Proof> proofs;

  List<List<ReferencedVerses>> versesPerProof = [];

  List<String> get answerAsList {
    List<String> array = answerWithProofs.split('[').map(
      (element) {
        if (element.contains(']')) {
          return element.substring(element.indexOf(']') + 1).trim();
        } else {
          return element;
        }
      },
    ).toList();

    // Remove empty elements from the array
    array.removeWhere((element) => element.isEmpty);

    return array;
  }

  List<ReferencedVerses> get allVerses =>
      versesPerProof.expand((list) => list).toList();

  Future getProofReferences() async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    for (var proof in proofs) {
      List<String> splitReferences = proof.references.split("; ");
      int? lastBookId;
      String? bookName;

      List<Map<String, dynamic>> formattedReferences = splitReferences
          .map(
            (reference) {
              print("reference: $reference");

              List<Map<String, dynamic>> formattedReference =
                  parseAndFormatReference(
                reference,
                proof.id,
                lastBookId,
                bookName,
              );

              lastBookId = formattedReference.last["book"];
              bookName = formattedReference.last["book_name"];

              return formattedReference;
            },
          )
          .toList() //gives a list of lists => List<List<Map<String, dynamic>>>
          .expand(
            (list) => list,
          ) // merges lists into one big list => List<Map<String, dynamic>>
          .toList();

      versesPerProof = [
        ...versesPerProof,
        await getVerses(formattedReferences)
      ];
    }

    stopwatch.stop();

    final executionTime = stopwatch.elapsed.inMilliseconds;
    print("Completed #$number in ${executionTime}ms");
  }

  Content({
    required this.number,
    required this.question,
    required this.answer,
    required this.answerWithProofs,
    required this.proofs,
    this.versesPerProof = emptyVerses,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        number: json["number"],
        question: json["question"],
        answer: json["answer"],
        answerWithProofs: json["answerWithProofs"],
        proofs: List<Proof>.from(json["proofs"].map((x) => Proof.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "question": question,
        "answer": answer,
        "answerWithProofs": answerWithProofs,
        "proofs": List<dynamic>.from(proofs.map((x) => x.toJson())),
      };
}

class Proof {
  int id;
  String references;

  Proof({
    required this.id,
    required this.references,
  });

  factory Proof.fromJson(Map<String, dynamic> json) => Proof(
        id: json["id"],
        references: json["references"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "References": references,
      };
}

class Metadata {
  String title;
  List<String> alternativeTitles;
  String year;
  List<String> authors;
  String location;
  String originalLanguage;
  String originStory;
  String sourceUrl;
  String sourceAttribution;
  String creedFormat;

  Metadata({
    required this.title,
    required this.alternativeTitles,
    required this.year,
    required this.authors,
    required this.location,
    required this.originalLanguage,
    required this.originStory,
    required this.sourceUrl,
    required this.sourceAttribution,
    required this.creedFormat,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        title: json["Title"],
        alternativeTitles:
            List<String>.from(json["AlternativeTitles"].map((x) => x)),
        year: json["Year"],
        authors: List<String>.from(json["Authors"].map((x) => x)),
        location: json["Location"],
        originalLanguage: json["OriginalLanguage"],
        originStory: json["OriginStory"],
        sourceUrl: json["SourceUrl"],
        sourceAttribution: json["SourceAttribution"],
        creedFormat: json["CreedFormat"],
      );

  Map<String, dynamic> toJson() => {
        "Title": title,
        "AlternativeTitles":
            List<dynamic>.from(alternativeTitles.map((x) => x)),
        "Year": year,
        "Authors": List<dynamic>.from(authors.map((x) => x)),
        "Location": location,
        "OriginalLanguage": originalLanguage,
        "OriginStory": originStory,
        "SourceUrl": sourceUrl,
        "SourceAttribution": sourceAttribution,
        "CreedFormat": creedFormat,
      };
}

class ReferencedVerses {
  String reference;
  int proofId;
  List<VerseResponse> verses;

  ReferencedVerses({
    required this.reference,
    required this.proofId,
    required this.verses,
  });

  factory ReferencedVerses.from(
    List<VerseResponse> verses,
    String reference,
    int proofId,
  ) =>
      ReferencedVerses(
        reference: reference,
        proofId: proofId,
        verses: verses,
      );
}
