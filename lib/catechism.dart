import 'dart:io';

import 'package:catechism/models/bollsMeta.dart';
import 'package:catechism/models/catechism.dart';
import 'package:dotenv/dotenv.dart';

Map<String, BollsMeta>? translationMeta;

Future<Catechism> loadCatechismData() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access a specific environment variable
  var source = env['SOURCE']!;

  File jsonFile = File(source);
  String jsonString = await jsonFile.readAsString();

  Catechism data = catechismFromJson(jsonString);
  return data;
}

Future loadTranslationData() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access a specific environment variable
  var translation = env['TRANSLATION'];
  var referenceMetadata = env['REFERENCE_META']!;

  if (["ESV", "NIV"].contains(translation)) {
    File jsonFile = File(referenceMetadata);
    String jsonString = await jsonFile.readAsString();

    translationMeta = bollsMetaFromJson(jsonString)[translation]!;
  }
}

List<Map<String, dynamic>> parseAndFormatReference(
  String reference,
  int proofId,
  int? lastBookId,
  String? lastBookName,
) {
  reference = reference.trim();

  List<Map<String, dynamic>> formattedReferences = [];
  int bookId;
  String verseRange;

  // check is book name is present or you need to default to lastBookId
  bool referenceIncludesBookName = reference.split(":")[0].length > 3;

  String bookName;

  if (referenceIncludesBookName) {
    // Split the reference into book name and verse range
    List<String> parts = reference.split(' ');
    bool bookHasVolumes =
        ["1", "2", "3"].contains(parts[0]); // e.g 1 John, 2 Timothy

    List<String> verseParts = parts.sublist(bookHasVolumes ? 2 : 1);

    // Colossians 3:18-4:1 //21
    // Extract the book name and verse range
    bookName =
        bookHasVolumes ? "${parts[0]} ${parts[1]}" : parts[0]; //Colossians
    verseRange = verseParts.join(" "); //3:18-4:1

    if (translationMeta == null) {
      throw Exception('Translation meta has not been loaded');
    }

    // Get the translation schema for the book
    BollsMeta meta = translationMeta!.entries
        .firstWhere((entry) => entry.key == bookName)
        .value;

    // Extract the book ID
    bookId = meta.bookid;
  } else {
    // use last book ID
    bookId = lastBookId!; //last book id should definitely not be null

    //set verseRange to entire reference
    verseRange = reference;
    bookName = lastBookName ?? "";

    reference = "$bookName $reference";
  }

  // Extract the chapter number //3:18-4:1

  List<String> components = verseRange.split(':');

  if (components.length == 3) {
    // references overflow
    // e.g 3:18-4:1

    List<String> verseBounds = verseRange.split('-');

    List<String> startChapterComponents = verseBounds[0].split(":");
    List<String> endChapterComponents = verseBounds[1].split(":");

    int startChapter = int.parse(startChapterComponents[0]);
    int endChapter = int.parse(endChapterComponents[0]);

    for (var currentChapter = startChapter;
        currentChapter <= endChapter;
        currentChapter++) {
      List<int> verses = [];

      if (currentChapter == startChapter) {
        int startVerse = int.parse(startChapterComponents[1]);

        verses =
            List<int>.generate(177 - startVerse, (index) => index + startVerse);
      } else if (currentChapter == endChapter) {
        int endVerse = int.parse(endChapterComponents[1]);

        verses = List<int>.generate(endVerse, (index) => index + 1);
      } else {
        verses = List<int>.generate(177, (index) => index + 1);
      }

      Map<String, dynamic> formattedReference = {
        "translation": 'ESV', //should be translation name
        "book": bookId,
        "book_name": bookName,
        "reference": reference,
        "proof_id": proofId,
        "chapter": currentChapter,
        "verses": verses,
      };

      formattedReferences.add(formattedReference);
    }
  } else if (components.length == 2) {
    // references DON'T overflow
    // e.g 3:18-21 or 3:18 or 3:4-5, 7, 9 or 3:4-5, 7-9, 12

    int chapter = int.parse(components[0]);
    List<int> verses = [];

    for (var verseRanges in components[1].split(", ")) {
      int startVerse = int.parse(verseRanges.split('-').first);
      int endVerse = int.parse(verseRanges.split('-').last);

      verses.addAll(
        List<int>.generate(
            endVerse - startVerse + 1, (index) => startVerse + index),
      );
    }

    Map<String, dynamic> formattedReference = {
      "translation": 'ESV', //should be translation name
      "book": bookId,
      "book_name": bookName,
      "reference": reference,
      "proof_id": proofId,
      "chapter": chapter,
      "verses": verses,
    };

    formattedReferences.add(formattedReference);
  } else {
    // references an entire chapter
    // e.g 3

    List<int> verses = List<int>.generate(177, (index) => index + 1);

    int chapter = int.parse(components[0]);

    Map<String, dynamic> formattedReference = {
      "translation": 'ESV', //should be translation name
      "book": bookId,
      "book_name": bookName,
      "reference": reference,
      "proof_id": proofId,
      "chapter": chapter,
      "verses": verses,
    };

    formattedReferences.add(formattedReference);
    // print(formattedReferences);
  }

  // print(formattedReferences);

  return formattedReferences;
}
