import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:knocky/helpers/hiveHelper.dart';

class TwitterHelper {
  final String _consumerKey = 'qXC7OJ0rq2VzNjXwn0SQgq9N1';
  final String _consumerSecret = 'HfSJty2qZEBCDXo7cJ4CMHWLLqWv0blMoFutveGzmVqEEdEGlZ';

  void getBearerToken () async {
    var bytes = utf8.encode(_consumerKey + ':' + _consumerSecret);
    var base64Str = base64.encode(bytes);

    try {
      http.Response httpResponse = await http.post('https://api.twitter.com/oauth2/token', headers: {
      'Authorization':
          'Basic ${base64Str}',
      'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
    }, body: 'grant_type=client_credentials');
      Map json = jsonDecode(httpResponse.body);
      AppHiveBox.getBox().then((Box box) {
        box.put('twitterBearerToken', json['access_token']);
      });
    } catch (e) {
      print('Error');
    }
  }

  Future<Map<String, dynamic>> getTweet (int tweetId) async {
    Box box = await AppHiveBox.getBox();
    String bearerToken = await box.get('twitterBearerToken');

    try {
      http.Response httpResponse = await http.get('https://api.twitter.com/1.1/statuses/show.json?id=' + tweetId.toString(), headers: {
        'Authorization':
            'Bearer ${bearerToken}',
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
      });

      Map<String, dynamic> jsonMap = jsonDecode(httpResponse.body);
      return jsonMap;
    } catch (e) {
      print('Error');
      return null;
    }
  }
}