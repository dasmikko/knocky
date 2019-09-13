import 'dart:convert';
import 'dart:io';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/models/events.dart';
import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/models/readThreads.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfilePosts.dart';
import 'package:knocky/models/userProfileThreads.dart';

class KnockoutAPI {
  static const KNOCKOUT_URL = "https://api.knockout.chat/";
  static const QA_URL = "https://forums.stylepunch.club:3000/";

  static const KNOCKOUT_SITE_URL = "https://knockout.chat/";
  static const QA_SITE_URL = "https://forums.stylepunch.club/";

  static bool _isDev = false;
  String currentEnv = 'knockout';

  static String baseurlSite =
      !_isDev ? "https://knockout.chat/" : "https://forums.stylepunch.club/";
  static String baseurl = !_isDev
      ? "https://api.knockout.chat/"
      : "https://forums.stylepunch.club:3000/";

  Future<Response> _request(
      {String url,
      String type = 'get',
      Map<String, dynamic> headers,
      dynamic data}) async {
    if (url == null) {
      throw ('URL not set!');
    }

    Box box = await AppHiveBox.getBox();

    Map<String, dynamic> mHeaders = {
      'Cookie': await box.get('cookieString'),
      'Access-Control-Request-Headers': 'content-format-version,content-type',
      'content-format-version': '1'
    };
    if (headers != null) mHeaders.addAll(headers);

    String mBaseurl =
        await box.get('env') == 'knockout' ? KNOCKOUT_URL : QA_URL;

    Dio dio = new Dio();
    dio.options.baseUrl = mBaseurl;
    dio.options.contentType = ContentType.json;
    dio.options.headers = mHeaders;
    dio.options.receiveDataWhenStatusError = true;

    switch (type) {
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
        throw ('unknown request type!');
    }
  }

  Future<List<Subforum>> getSubforums() async {
    try {
      final response2 = await _request(url: 'subforum');
      return response2.data['list']
          .map<Subforum>((json) => Subforum.fromJson(json))
          .toList();
    } on DioError catch (e) {
      throw e;
    }
  }

  Future<SubforumDetails> getSubforumDetails(int id, {int page = 1}) async {
    try {
      final response = await _request(
          url: 'subforum/' + id.toString() + '/' + page.toString());
      return SubforumDetails.fromJson(response.data);
    } on DioError catch (e) {
      print(e);
      return null;
    }
  }

  Future<Thread> getThread(int id, {int page: 1}) async {
    final response =
        await _request(url: 'thread/' + id.toString() + '/' + page.toString());
    return Thread.fromJson(response.data);
  }

  Future<dynamic> authCheck() async {
    try {
      final response = await _request(
          url: 'user/authCheck', headers: {'content-format-version': 1});
      return response.data;
    } on DioError catch (e) {
      return e.response.data;
    }
  }

  Future<List<ThreadAlert>> getAlerts() async {
    try {
      final response = await _request(url: 'alert/list', type: 'post');
      return response.data
          .map<ThreadAlert>((json) => ThreadAlert.fromJson(json))
          .toList();
    } on DioError catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> readThreads(DateTime lastseen, int threadId) async {
    ReadThreads jsonToPost =
        new ReadThreads(lastSeen: lastseen, threadId: threadId);
    await _request(type: 'post', url: 'readThreads', data: jsonToPost.toJson());
  }

  Future<void> readThreadSubsciption(DateTime lastseen, int threadId) async {
    ReadThreads jsonToPost =
        new ReadThreads(lastSeen: lastseen, threadId: threadId);
    await _request(type: 'post', url: 'alert', data: jsonToPost.toJson());
  }

  Future<List<KnockoutEvent>> getEvents() async {
    final response = await _request(type: 'get', url: 'events');

    return response.data
        .map<KnockoutEvent>((json) => KnockoutEvent.fromJson(json))
        .toList();
  }

  Future<void> deleteThreadAlert(int threadid) async {
    final response = await _request(
        url: 'alert', type: 'delete', data: {'threadId': threadid});

    if (response.statusCode == 200) {}
  }

  Future<void> subscribe(DateTime lastSeen, int threadid) async {
    final response = await _request(
        url: 'alert',
        type: 'post',
        data: {'lastSeen': lastSeen.toIso8601String(), 'threadId': threadid});

    if (response.statusCode == 200) {}
  }

  Future<bool> ratePost(int postId, String rating) async {
    final response = await _request(
        url: 'rating', type: 'put', data: {'postId': postId, 'rating': rating});

    bool wasRejected = response.data['isRejected'];

    return wasRejected;
  }

  Future<void> newPost(dynamic content, int threadId) async {
    print(content);
    print(threadId);
    try {
      await _request(type: 'post', url: 'post', data: {
        'content': json.encode(content).toString(),
        'thread_id': threadId,
      }, headers: {
        'content-type': 'application/json; charset=UTF-8',
        'content-format-version': '1'
      });
    } on DioError catch (e) {
      print(e);
      print(e.response);
    }
  }

  Future<void> updatePost(dynamic content, int postId, int threadId) async {
    try {
      await _request(type: 'put', url: 'post', data: {
        'content': json.encode(content).toString(),
        'id': postId,
        'thread_id': threadId
      });
    } on DioError catch (e) {
      print(e);
      print(e.response);
    }
  }

  Future<List<SubforumThreadLatestPopular>> latestThreads() async {
    final response = await _request(type: 'get', url: 'thread/latest');

    print(response);

    return response.data['list']
        .map<SubforumThreadLatestPopular>(
            (json) => SubforumThreadLatestPopular.fromJson(json))
        .toList();
  }

  Future<List<SubforumThreadLatestPopular>> popularThreads() async {
    final response = await _request(type: 'get', url: 'thread/popular');

    print(response);

    return response.data['list']
        .map<SubforumThreadLatestPopular>(
            (json) => SubforumThreadLatestPopular.fromJson(json))
        .toList();
  }

  Future<bool> renameThread(int threadId, String newTitle) async {
    final response = await _request(
        url: 'thread', type: 'put', data: {'id': threadId, 'title': newTitle});

    bool wasRejected = response.data['isRejected'];

    return wasRejected;
  }

  Future<UserProfile> getUserProfile(int userId) async {
    final response = await _request(
        url: 'user/${userId}', type: 'get',);

    return UserProfile.fromJson(response.data);
  }

  Future<UserProfilePosts> getUserProfilePosts(int userId) async {
    final response = await _request(
        url: 'user/${userId}/posts', type: 'get',);

    return UserProfilePosts.fromJson(response.data);
  }

  Future<UserProfileThreads> getUserProfileThreads(int userId) async {
    final response = await _request(
        url: 'user/${userId}/threads', type: 'get',);

    return UserProfileThreads.fromJson(response.data);
  }

  Future<SyncDataModel> getSyncData() async {
    final response = await _request(
        url: 'user/syncData', type: 'get',);

    return SyncDataModel.fromJson(response.data);
  }

  Future<bool> markMentionsAsRead(List<int> postIds) async {
    final response = await _request(
        url: 'mentions', type: 'put', data: {'postIds': postIds});

    if (response.statusCode == 200) return true;
    return false;
  }
}
