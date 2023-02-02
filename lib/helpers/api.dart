import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart' as Getx;
import 'package:knocky/controllers/settingsController.dart';
import 'package:knocky/models/ad.dart';
import 'package:knocky/models/alert.dart';
import 'package:knocky/models/events.dart';
import 'package:knocky/models/forum.dart';
import 'package:knocky/models/motd.dart';
import 'package:knocky/models/notification.dart';
import 'package:knocky/models/significantThreads.dart';
import 'package:knocky/models/subforumv2.dart' as SubforumV2;
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/thread.dart' as ThreadModel;
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/models/readThreads.dart';
import 'package:dio/dio.dart';
import 'package:knocky/models/userBans.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfileDetails.dart';
import 'package:knocky/models/userProfilePosts.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/models/userProfileThreads.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/models/v2/alerts.dart' as AlertsV2;
import 'package:knocky/models/v2/thread.dart';

class KnockoutAPI {
  static const DEFAULT_API_URL = "https://knockyauth.rekna.xyz/";
  static const QA_URL = "https://forums.stylepunch.club:3000/";
  static const CDN_URL = "https://cdn.knockout.chat/image";

  static const KNOCKOUT_SITE_URL = "https://knockout.chat/";
  static const QA_SITE_URL = "https://forums.stylepunch.club/";

  static bool _isDev = false;
  String currentEnv = 'knockout';

  final SettingsController settingsController =
      Getx.Get.put(SettingsController());

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

    GetStorage prefs = GetStorage();

    Map<String, dynamic> mHeaders = {
      'knockoutjwt': await prefs.read('jwt'),
      'Access-Control-Request-Headers': 'content-format-version,content-type',
      'content-format-version': '1',
    };

    if (headers != null) mHeaders.addAll(headers);
    String mBaseurl = prefs.read('env') == 'knockout'
        ? settingsController.apiEndpoint.value
        : QA_URL;

    Dio dio = new Dio();
    dio.options.baseUrl = mBaseurl;
    dio.options.contentType = ContentType.json.toString();
    dio.options.headers = mHeaders;
    dio.options.receiveDataWhenStatusError = true;
    if (!settingsController.showNSFWThreads.value) {
      dio.options.queryParameters = {'hideNsfw': 1};
    }

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

  Future<Forum> getSubforums() async {
    try {
      final response2 = await _request(url: 'subforum');
      return Forum.fromJson(response2.data);
    } on DioError catch (e) {
      throw e;
    } catch (error) {
      throw error;
    }
  }

  Future<SubforumV2.Subforum> getSubforumDetails(int id, {int page = 1}) async {
    final response = await _request(
        url: 'subforum/' + id.toString() + '/' + page.toString());
    return SubforumV2.subforumFromJson(json.encode(response.data));
  }

  Future<ThreadModel.Thread> getThread(int id, {int page = 1}) async {
    final response = await _request(
      url: 'v2/threads/' + id.toString() + '/' + page.toString(),
    );
    return ThreadModel.Thread.fromJson(response.data);
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

  Future<AlertsV2.Alerts> getAlertsPaginated({int page = 1}) async {
    try {
      final response = await _request(url: 'v2/alerts/$page', type: 'get');
      return AlertsV2.Alerts.fromJson(response.data);
    } on DioError catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<ThreadAlert>> getAlerts() async {
    try {
      final response = await _request(url: 'alerts', type: 'get');
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

  Future<void> createAlert(int threadId, int lastPostNumber) async {
    Alert jsonToPost =
        new Alert(threadId: threadId, lastPostNumber: lastPostNumber);
    await _request(type: 'post', url: 'alert', data: jsonToPost.toJson());
  }

  Future<List<KnockoutEvent>> getEvents() async {
    final response = await _request(type: 'get', url: 'events');

    return response.data
        .map<KnockoutEvent>((json) => KnockoutEvent.fromJson(json))
        .toList();
  }

  Future<void> deleteThreadAlert(int threadid) async {
    final response =
        await _request(url: '/v2/alerts/$threadid', type: 'delete');

    if (response.statusCode == 200) {}
  }

  Future<void> subscribe(int lastPostNumber, int threadid) async {
    final response = await _request(
        url: 'alert',
        type: 'post',
        data: {'lastPostNumber': lastPostNumber, 'threadId': threadid});

    if (response.statusCode == 200) {}
  }

  Future<bool> ratePost(int postId, String rating) async {
    final response = await _request(
        url: 'v2/posts/$postId/ratings', type: 'put', data: {'rating': rating});

    bool wasRejected = response.data['isRejected'];

    return wasRejected;
  }

  Future<ThreadModel.ThreadPost> getPost(int postId) async {
    final response = await _request(type: 'get', url: 'post/$postId');
    return ThreadModel.ThreadPost.fromJson(response.data);
  }

  Future<void> newPost(dynamic content, int threadId) async {
    try {
      await _request(type: 'post', url: 'post', data: {
        'displayCountryInfo': false,
        'appName': 'knocky',
        'content': content.toString(),
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

  Future<void> updatePost(String content, int postId) async {
    try {
      await _request(type: 'put', url: 'v2/posts/$postId', data: {
        'content': content,
        'appname': 'Knocky',
      });
    } on DioError catch (e) {
      print(e);
      print(e.response);
    }
  }

  Future<List<SubforumThread>> getSignificantThreads(
      SignificantThreads threadsToFetch) async {
    final endpoint = "v2/threads/${threadsToFetch.name.toLowerCase()}";
    final response = await _request(type: 'get', url: endpoint);
    print(response);
    return response.data
        .map<SubforumThread>((json) => SubforumThread.fromJson(json))
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
      url: 'user/' + userId.toString(),
      type: 'get',
    );
    return UserProfile.fromJson(response.data);
  }

  Future<UserBans> getUserBans(int userId) async {
    final response = await _request(
      url: 'user/' + userId.toString() + '/bans',
      type: 'get',
    );

    return UserBans.fromJson(response.data);
  }

  Future<UserProfileDetails> getUserProfileDetails(int userId) async {
    final response = await _request(
      url: 'v2/users/' + userId.toString() + '/profile',
      type: 'get',
    );

    return UserProfileDetails.fromJson(response.data);
  }

  Future<List<UserProfileRating>> getUserProfileTopRatings(int userId) async {
    final response = await _request(
      url: 'user/' + userId.toString() + '/topRatings',
      type: 'get',
    );

    return response.data
        .map<UserProfileRating>((json) => UserProfileRating.fromJson(json))
        .toList();
  }

  Future<UserProfilePosts> getUserPosts(int userId, {int page = 1}) async {
    final response = await _request(
      url: 'user/$userId/posts/$page',
      type: 'get',
    );

    return UserProfilePosts.fromJson(response.data);
  }

  Future<UserProfileThreads> getUserThreads(int userId, {int page = 1}) async {
    final response = await _request(
      url: 'user/$userId/threads/$page',
      type: 'get',
    );

    return UserProfileThreads.fromJson(response.data);
  }

  Future<SyncDataModel> getSyncData() async {
    final response = await _request(
      url: 'user/syncData',
      type: 'get',
    );
    return SyncDataModel.fromJson(response.data);
  }

  Future<bool> markMentionsAsRead(List<int> postIds) async {
    final response = await _request(
        url: 'mentions', type: 'put', data: {'postIds': postIds});

    if (response.statusCode == 200) return true;
    return false;
  }

  Future<KnockoutAd> randomAd() async {
    final response = await _request(url: 'threadAds/random', type: 'get');

    return KnockoutAd.fromJson(response.data);
  }

  Future<List<KnockoutMotd>> motd() async {
    final response = await _request(url: 'motd', type: 'get');

    return response.data
        .map<KnockoutMotd>((json) => KnockoutMotd.fromJson(json))
        .toList();
  }

  Future<List<NotificationModel>> notifications() async {
    final response = await _request(url: 'v2/notifications', type: 'get');

    return response.data
        .map<NotificationModel>((json) => NotificationModel.fromJson(json))
        .toList();
  }
}
