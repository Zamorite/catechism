import 'dart:io';
import 'dart:typed_data';

import 'package:catechism/catechism.dart' as catechism;
import 'package:catechism/models/catechism.dart';
import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> main() async {
  // has to be called first
  var env = await catechism.loadEnv();

  // Access a specific environment variable
  var translation = env['TRANSLATION'];

  final Uint8List barlowRegularFontData =
      File('fonts/Barlow-Regular.ttf').readAsBytesSync();
  final barlowRegularFont =
      pw.Font.ttf(barlowRegularFontData.buffer.asByteData());

  final Uint8List barlowSemiBoldFontData =
      File('fonts/Barlow-SemiBold.ttf').readAsBytesSync();
  final barlowSemiBoldFont =
      pw.Font.ttf(barlowSemiBoldFontData.buffer.asByteData());

  final Uint8List barlowBoldFontData =
      File('fonts/Barlow-Bold.ttf').readAsBytesSync();
  final barlowBoldFont = pw.Font.ttf(barlowBoldFontData.buffer.asByteData());

  final Uint8List battambangBoldFontData =
      File('fonts/Battambang-Bold.ttf').readAsBytesSync();
  final battambangBoldFont =
      pw.Font.ttf(battambangBoldFontData.buffer.asByteData());

  await catechism.loadTranslationData();

  final book = await catechism.loadCatechismData();
  final pdf = pw.Document();

  final tsBookTitle = pw.TextStyle(
    font: barlowBoldFont,
    fontSize: 68,
    height: 80,
  );

  final tsQuestionNo = pw.TextStyle(
    font: battambangBoldFont,
    fontSize: 12,
    height: 16,
  );

  final tsMainQuestion = pw.TextStyle(
    font: battambangBoldFont,
    fontSize: 17,
    height: 24,
  );

  final tsMainAnswer = pw.TextStyle(
    font: barlowRegularFont,
    fontSize: 12,
    height: 16,
  );

  final tsRefText = pw.TextStyle(
    font: barlowRegularFont,
    fontSize: 12,
    height: 16,
  );

  final tsCoverCaption = pw.TextStyle(
    font: barlowRegularFont,
    fontSize: 12,
    height: 16,
  );

  final tsCoverCaptionEmphasis = pw.TextStyle(
    font: barlowBoldFont,
    fontSize: 12,
    height: 16,
  );

  final tsRefTitle = pw.TextStyle(
    font: barlowSemiBoldFont,
    fontSize: 12,
    height: 16,
  );

  final tsCaption = pw.TextStyle(
    font: barlowRegularFont,
    fontSize: 10,
    height: 16,
  );

  final tsPageNo = pw.TextStyle(
    font: barlowSemiBoldFont,
    fontSize: 10,
    height: 16,
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (pw.Context context) => pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Padding(
          padding: pw.EdgeInsets.only(
            right: 57,
            bottom: 57,
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                book.metadata.title.replaceAll(' ', '\n'),
                style: tsBookTitle,
                textAlign: pw.TextAlign.right,
              ),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex("#F3F3F3"),
                  // border: pw.Border.all(),
                ),
                // width: 338,
                child: pw.Container(
                  // width: 338,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text: "with Bible verses in ",
                      children: [
                        pw.TextSpan(
                          text: "$translation",
                          style: tsCoverCaptionEmphasis,
                        ),
                      ],
                      style: tsCoverCaption,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      header: (context) {
        return pw.Anchor(
          name: "table_of_content_${context.pageNumber}",
          child: pw.Container(
            width: 740,
            child: pw.Padding(
              padding: pw.EdgeInsets.only(
                bottom: 30,
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    "The Heidelberg Catechism",
                    // textAlign: pw.TextAlign.left,
                    style: tsQuestionNo,
                  ),
                  pw.Text(
                    "Table of Content",
                    // textAlign: pw.TextAlign.left,
                    style: tsMainQuestion,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      footer: (context) {
        return pw.Container(
          width: 740,
          // decoration: pw.BoxDecoration(
          //   color: PdfColor.fromHex("#D9D9D9"),
          //   // border: pw.Border.all(),
          // ),
          child: pw.RichText(
            text: pw.TextSpan(
              text: "Page ",
              style: tsCaption,
              children: [
                pw.TextSpan(
                  text: "${context.pageNumber}",
                  style: tsPageNo,
                )
              ],
            ),
            textAlign: pw.TextAlign.right,
          ),
        );
      },
      // width: 740,
      build: (context) {
        return [
          pw.Container(
            // decoration: pw.BoxDecoration(
            //   border: pw.Border.all(
            //     color: PdfColors.red,
            //   ),
            // ),
            child: pw.Wrap(
              direction: pw.Axis.vertical,
              spacing: 15,
              runSpacing: 50,
              children: book.content
                  .mapIndexed(
                    (index, question) => pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex("#F3F3F3"),
                        // border: pw.Border.all(),
                      ),
                      width: 338,
                      child: pw.Wrap(
                        children: [
                          pw.Link(
                            destination: "section_${index + 1}",
                            child: pw.Container(
                              width: 338,
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: pw.EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: pw.Text("${index + 1}."),
                                  ),
                                  pw.Expanded(
                                    child: pw.Text(
                                      question.question,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ];
      },
    ),
  );

  // for (var section in book.content.sublist(0, 5)) {
  // for (var i = 0; i < 7; i++) {
  for (var i = 0; i < book.content.length; i++) {
    Content section = book.content[i];
    int questionNo = i + 1;

    await section.getProofReferences();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) {
          return pw.Anchor(
            name: "section_${section.number}",
            child: pw.Container(
              width: 740,
              // decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Padding(
                padding: pw.EdgeInsets.only(
                  bottom: 30,
                ),
                child: pw.Column(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 12),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            "Question $questionNo",
                            // textAlign: pw.TextAlign.left,
                            style: tsQuestionNo,
                          ),
                          pw.Text(
                            section.question,
                            textAlign: pw.TextAlign.center,
                            style: tsMainQuestion,
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: section.answerAsList
                              .mapIndexed(
                                (index, point) => pw.WidgetSpan(
                                  child: pw.Link(
                                    destination:
                                        "section_${section.number}_proof_${index + 1}",
                                    child: pw.RichText(
                                      text: pw.TextSpan(
                                        text: "$point ",
                                        style: tsMainAnswer, //tsRefText,
                                        children: [
                                          pw.TextSpan(
                                            text: "[${index + 1}]  ",
                                            style: tsCaption,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        footer: (context) {
          return pw.Container(
              width: 740,
              // decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Link(
                    destination: "table_of_content_2",
                    child: pw.Text(
                      "Table of Content",
                      style: tsCaption,
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      text: "Page ",
                      style: tsCaption,
                      children: [
                        pw.TextSpan(
                          text: "${context.pageNumber}",
                          style: tsPageNo,
                        )
                      ],
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ));
        },
        // width: 740,
        build: (context) {
          return [
            // pw.Container(
            //   // decoration: pw.BoxDecoration(
            //   //   border: pw.Border.all(
            //   //     color: PdfColors.red,
            //   //   ),
            //   // ),
            //   child:
            pw.Wrap(
              direction: pw.Axis.vertical,
              spacing: 15,
              runSpacing: 50,
              children: section.allVerses
                  .map(
                    (referencedVerses) => pw.Container(
                      // decoration: pw.BoxDecoration(border: pw.Border.all()),
                      width: 338,
                      child: pw.Wrap(
                        children: [
                          pw.Container(
                            width: 338,
                            padding: pw.EdgeInsets.only(
                              bottom: 1,
                            ),
                            child: pw.Anchor(
                              name:
                                  "section_${section.number}_proof_${referencedVerses.proofId}",
                              child: pw.RichText(
                                text: pw.TextSpan(
                                  text: "${referencedVerses.reference} ",
                                  children: [
                                    pw.TextSpan(
                                      text: "[${referencedVerses.proofId}]",
                                      style: tsCaption,
                                    ),
                                  ],
                                  style: tsRefTitle,
                                ),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                          ),
                          pw.Partition(
                            width: 338,
                            child: pw.RichText(
                              text: pw.TextSpan(
                                children: referencedVerses.verses.mapIndexed(
                                  (index, verse) {
                                    return pw.TextSpan(
                                      text: "${verse.verse}. ",
                                      style: tsPageNo,
                                      children: [
                                        pw.TextSpan(
                                          text:
                                              "${verse.text.replaceAll("<br/>", "\n")} ",
                                          style: tsRefText,
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            // ),
          ];
        },
      ),
    );
  }

  final file = File('${book.metadata.title} with $translation references.pdf');
  await file.writeAsBytes(await pdf.save());
}
