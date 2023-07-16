import 'dart:convert';
import 'dart:io';

import 'package:catechism/models/catechism.dart';
import 'package:catechism/models/verseResponse.dart';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

Future<List<ReferencedVerses>> getVerses(
// Future<List<ReferencedVerses>> getVersesWithDio(
  List<Map<String, dynamic>> payload,
) async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access a specific environment variable
  var baseUrl = env['BASE_URL'];
  // var apiKey = env['API_KEY'];

  var dio = Dio();
  var url = '$baseUrl/get-verses/';

  // dio.interceptors.add(
  //   PrettyDioLogger(
  //     requestHeader: true,
  //     requestBody: true,
  //     responseBody: true,
  //     responseHeader: false,
  //     error: true,
  //     compact: true,
  //     maxWidth: 90,
  //   ),
  // );

  try {
    var response = await dio.post(
      url,
      data: payload,
      options: Options(
        followRedirects: false,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      ),
    );

    if (response.statusCode == 200) {
      // Request successful, parse the response
      var data = response.data;
      // Do something with the data

      return verseResponseFromMap(
        data,
        payload
            .map<String>(
              (batch) => batch["reference"],
            )
            .toList(),
        payload
            .map<int>(
              (batch) => batch["proof_id"],
            )
            .toList(),
      );
    } else {
      // Request failed, handle the error
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    // Error occurred during the request
    print('Error: $e');
  }

  return [];
}

// Future<List<ReferencedVerses>> getVerses(
Future<List<ReferencedVerses>> getVersesWithHttp(
  List<Map<String, dynamic>> payload,
) async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access a specific environment variable
  var baseUrl = env['BASE_URL'];
  // var apiKey = env['API_KEY'];

  var url = '$baseUrl/get-verses/';

  var headers = {'Content-Type': 'application/json'};
  var request = http.Request('POST', Uri.parse(url));
  request.body = jsonEncode(payload);

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var responseBytes = await response.stream.bytesToString();

    print(responseBytes);

    var data = jsonDecode(responseBytes);
    // Do something with the data
    // print(response);

    return verseResponseFromMap(
      data,
      payload
          .map<String>(
            (batch) => batch["reference"],
          )
          .toList(),
      payload
          .map<int>(
            (batch) => batch["proof_id"],
          )
          .toList(),
    );
  } else {
    print(response.reasonPhrase);
  }

  return [];
}
