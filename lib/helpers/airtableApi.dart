import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform;

class AirTableApi {
  Dio dio = new Dio();

  Future<void> testCall() async {
    try {
      Response response = await dio.get(
        'https://api.airtable.com/v0/appi7bKmcLBaiCGLi/Installs',
        options: Options(headers: {
          'Authorization': 'Bearer key7XvYCKgryKnNAa',
        }),
      );
      print('Airtable response');
      print(response);
    } on DioError catch (e) {
      print(e.request.headers.toString());
      print(e.response.data);
      return e.response.data;
    }

    return;
  }

  Future<void> writeRecord() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String platform = Platform.isIOS ? 'ios' : 'android';
    String version = packageInfo.version;

    String dataString = '''
    {
      "records": [
        {
          "fields": {
            "Platform": "$platform",
            "Version": "$version"
          }
        },
      ]
    }
    ''';

    try {
      Response response = await dio.post(
        'https://api.airtable.com/v0/appi7bKmcLBaiCGLi/Installs',
        options: Options(
          headers: {
            'Authorization': 'Bearer key7XvYCKgryKnNAa',
            'Content-Type': 'application/json'
          },
        ),
        data: dataString,
      );
      print('Airtable response');
      print(response);
    } on DioError catch (e) {
      print(e.request.headers.toString());
      print(e.response.data);
      return e.response.data;
    }

    return;
  }
}
