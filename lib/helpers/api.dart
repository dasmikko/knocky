import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/models/readThreads.dart';
import 'package:dio/dio.dart';

class KnockoutAPI {
  static const KNOCKOUT_URL = "https://api.knockout.chat/";
  static const QA_URL = "https://forums.stylepunch.club:3000/";

  static bool _isDev = false;
  String currentEnv = 'knockout';

  static String baseurlSite =
      !_isDev ? "https://knockout.chat/" : "https://forums.stylepunch.club/";
  static String baseurl = !_isDev
      ? "https://api.knockout.chat/"
      : "https://forums.stylepunch.club:3000/";

  KnockoutAPI() {
    SharedPreferences.getInstance().then((prefs) {
      currentEnv = prefs.getString('env');
    });
    print(currentEnv);
  }

  Future<Response> _request ({String url, String type = 'get', Map<String, dynamic> headers, dynamic data}) async {
    if (url == null) {
      throw('URL not set!');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> mHeaders = {'Cookie': prefs.getString('cookieString')};
    if (headers != null) mHeaders.addAll(headers);

    String mBaseurl = prefs.getString('env') == 'knockout' ? KNOCKOUT_URL : QA_URL;

    Dio dio = new Dio();
    dio.options.baseUrl = mBaseurl;
    dio.options.contentType = ContentType.json;
    dio.options.headers = mHeaders;
    dio.options.receiveDataWhenStatusError = true;

    switch(type) {
      case 'get':
        return dio.get(url);
        break;
      case 'post':
        return dio.post(url, data: data);
        break;
      case 'delete':
        return dio.delete(url, data: data);
        break;
      case 'put': 
        return dio.put(url, data: data);
        break;
      default: 
        throw('unknown request type!');
    }
  }

  Future<List<Subforum>> getSubforums() async {
    final response2 = await _request(url: 'subforum');
    return response2.data['list'].map<Subforum>((json) => Subforum.fromJson(json)).toList();
  }

  Future<SubforumDetails> getSubforumDetails(int id, {int page = 1}) async {
    final response = await _request(url: 'subforum/' + id.toString() + '/' + page.toString());
    return SubforumDetails.fromJson(response.data);
  }

  Future<Thread> getThread(int id, {int page: 1}) async {
    final response = await _request(url: 'thread/' + id.toString() + '/' + page.toString());
    return Thread.fromJson(response.data);
  }

  Future<void> authCheck() async {
    print('Checking auth state...');
    final response = await _request(url: 'user/authCheck');
    print('Auth: ' + response.data);
        
  }

  Future<List<ThreadAlert>> getAlerts() async {
    final response = await _request(url: 'alert/list', type: 'post');
    return response.data.map<ThreadAlert>((json) => ThreadAlert.fromJson(json)).toList();
  }

  Future<void> readThreads(DateTime lastseen, int threadId) async {
    ReadThreads jsonToPost = new ReadThreads(lastSeen: lastseen, threadId: threadId);
    final response = await _request(type: 'post', url: 'readThreads', data: jsonToPost.toJson());   
    print(response.data);
  }

  Future<void> readThreadSubsciption(DateTime lastseen, int threadId) async {
    ReadThreads jsonToPost = new ReadThreads(lastSeen: lastseen, threadId: threadId);
    final response = await _request(type: 'post', url: 'alert', data: jsonToPost.toJson());
    print(response.data);
  }

  Future<List<ThreadAlert>> getEvents() async {
    final response = await http.get(baseurl + 'events', headers: {});

    final parsedJson =
        json.decode(response.body).cast<Map<String, dynamic>>();

    return parsedJson.map<ThreadAlert>((json) => ThreadAlert.fromJson(json)).toList();
  }

  Future<void> deleteThreadAlert(int threadid) async {
    print(threadid.toString());

    final response = await _request(
      url: 'alert',
      type: 'delete',
      data: {
      'threadId': threadid
    });

    if (response.statusCode == 200) {
      print(response.data);
    }
  }

  Future<void> subscribe(DateTime lastSeen, int threadid) async {
    print(threadid.toString());
    final response = await _request(
      url: 'alert',
      type: 'post',
      data: {
      'lastSeen': lastSeen.toIso8601String(),
      'threadId': threadid
    });

    print(response.data);

    if (response.statusCode == 200) {
      print(response.data);
    }
  }

  Future<bool> ratePost (int postId, String rating) async {
    final response = await _request(url: 'rating', type: 'put', data: {
      'postId': postId,
      'rating': rating
    });

    bool wasRejected = response.data['isRejected'];

    return wasRejected;
  }
}
