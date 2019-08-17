import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImgurHelper {
  final String imgurClientId = DotEnv().env['IMGUR_CLIENTID'];
  final String apiUrl = "https://api.imgur.com/3/upload";

  Dio dio = new Dio();

  Future<Response> uploadImage(File file, Function onProgressCallback) async {
    // Binary data
    String fileAsBase64 = base64Encode(file.readAsBytesSync());

    FormData formData = new FormData.from({
      "image": fileAsBase64,
    });

    try {
      Response response = await dio.post(
        apiUrl,
        options: Options(headers: {
          'Authorization': 'Client-ID ' + DotEnv().env['IMGUR_CLIENTID']
        }),
        data: formData,
        onSendProgress: onProgressCallback,
      );
      return response;
    } on DioError catch (e) {
      print(e.request.headers.toString());
      print(e.response.data);
      return e.response.data;
    }
  }
}
