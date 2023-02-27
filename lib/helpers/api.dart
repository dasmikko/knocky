import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart' as Getx;
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/settingsController.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/ad.dart';
import 'package:knocky/models/alert.dart';
import 'package:knocky/models/events.dart';
import 'package:knocky/models/forum.dart';
import 'package:knocky/models/motd.dart';
import 'package:knocky/models/notification.dart';
import 'package:knocky/models/rule.dart';
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
import 'dart:convert' show JSON;

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
      {String? url,
      String type = 'get',
      Map<String, dynamic> headers = const {},
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

    mHeaders.addAll(headers);
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

  /**
   * A top handler for Dio errors.
   *
   * This should be added to all request calls...
   */
  void onDioErrorHandler(DioError error) {
    if (error.response?.statusCode == 401) {
      print('Invalid credentials!');
      AuthController authController = Getx.Get.put(AuthController());
      authController.logout(noSnackBar: true);
      KnockySnackbar.error(
          'Credentials are expired or invalid. Please login again!');
    }
  }

  Future<Forum> getSubforums() async {
    try {
      final response2 = await _request(url: 'subforum');
      return Forum.fromJson(response2.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    } catch (error) {
      throw error;
    }
  }

  Future<SubforumV2.Subforum> getSubforumDetails(int? id,
      {int page = 1}) async {
    try {
      final response = await _request(
          url: 'subforum/' + id.toString() + '/' + page.toString());
      return SubforumV2.subforumFromJson(json.encode(response.data));
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<ThreadModel.Thread> getThread(int? id, {int page = 1}) async {
    try {
      final response = await _request(
        url: 'v2/threads/' + id.toString() + '/' + page.toString(),
      );
      return ThreadModel.Thread.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<dynamic> authCheck() async {
    try {
      final response = await _request(
          url: 'user/authCheck', headers: {'content-format-version': 1});
      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future<AlertsV2.Alerts> getAlertsPaginated({int page = 1}) async {
    try {
      final response = await _request(url: 'v2/alerts/$page', type: 'get');
      return AlertsV2.Alerts.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<List<ThreadAlert>?> getAlerts() async {
    try {
      final response = await _request(url: 'alerts', type: 'get');
      return response.data
          .map<ThreadAlert>((json) => ThreadAlert.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> readThreads(DateTime lastseen, int? threadId) async {
    try {
      ReadThreads jsonToPost =
          new ReadThreads(lastSeen: lastseen, threadId: threadId);
      await _request(
          type: 'post', url: 'readThreads', data: jsonToPost.toJson());
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> readThreadsMarkUnread(int threadId) async {
    try {
      await _request(
          type: 'delete', url: 'readThreads', data: {'threadId': threadId});
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> createAlert(int? threadId, int? lastPostNumber) async {
    try {
      Alert jsonToPost =
          new Alert(threadId: threadId, lastPostNumber: lastPostNumber);
      await _request(type: 'post', url: 'alert', data: jsonToPost.toJson());
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<List<KnockoutEvent>?> getEvents() async {
    try {
      final response = await _request(type: 'get', url: 'events');

      return response.data
          .map<KnockoutEvent>((json) => KnockoutEvent.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> deleteThreadAlert(int? threadid) async {
    try {
      final response =
          await _request(url: '/v2/alerts/$threadid', type: 'delete');

      if (response.statusCode == 200) {}
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> subscribe(int? lastPostNumber, int? threadid) async {
    try {
      final response = await _request(
          url: 'alert',
          type: 'post',
          data: {'lastPostNumber': lastPostNumber, 'threadId': threadid});

      if (response.statusCode == 200) {}
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<bool?> ratePost(int? postId, String? rating) async {
    try {
      final response = await _request(
          url: 'v2/posts/$postId/ratings',
          type: 'put',
          data: {'rating': rating});

      bool? wasRejected = response.data['isRejected'];

      return wasRejected;
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<ThreadModel.ThreadPost> getPost(int postId) async {
    try {
      final response = await _request(type: 'get', url: 'post/$postId');
      return ThreadModel.ThreadPost.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> newPost(dynamic content, int? threadId) async {
    try {
      final SettingsController settingsController =
          Getx.Get.put(SettingsController());
      await _request(type: 'post', url: 'v2/posts', data: {
        'display_country': settingsController.flagPunchy.value,
        'app_name': 'knocky',
        'content': content.toString(),
        'thread_id': threadId,
      }, headers: {
        'content-type': 'application/json; charset=UTF-8',
      });
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> updatePost(String content, int? postId) async {
    try {
      await _request(type: 'put', url: 'v2/posts/$postId', data: {
        'content': content,
        'appname': 'Knocky',
      });
    } on DioError catch (e) {
      onDioErrorHandler(e);
      print(e.response);
    }
  }

  Future<List<SubforumThread>?> getSignificantThreads(
      SignificantThreads threadsToFetch) async {
    try {
      final endpoint = "v2/threads/${threadsToFetch.name.toLowerCase()}";
      final response = await _request(type: 'get', url: endpoint);
      print(response);
      return response.data
          .map<SubforumThread>((json) => SubforumThread.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<bool?> renameThread(int threadId, String newTitle) async {
    try {
      final response = await _request(
          url: 'thread',
          type: 'put',
          data: {'id': threadId, 'title': newTitle});

      bool? wasRejected = response.data['isRejected'];

      return wasRejected;
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<UserProfile> getUserProfile(int? userId) async {
    try {
      final response = await _request(
        url: 'user/' + userId.toString(),
        type: 'get',
      );
      return UserProfile.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<UserBans> getUserBans(int? userId) async {
    try {
      final response = await _request(
        url: 'user/' + userId.toString() + '/bans',
        type: 'get',
      );

      return UserBans.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<UserProfileDetails> getUserProfileDetails(int? userId) async {
    try {
      final response = await _request(
        url: 'v2/users/' + userId.toString() + '/profile',
        type: 'get',
      );

      return UserProfileDetails.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<List<UserProfileRating>?> getUserProfileTopRatings(int? userId) async {
    try {
      final response = await _request(
        url: 'user/' + userId.toString() + '/topRatings',
        type: 'get',
      );

      // For some fucked reason, I need to use jsonDecode here?!
      return jsonDecode(response.data)
          .map<UserProfileRating>((json) => UserProfileRating.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<UserProfilePosts> getUserPosts(int? userId, {int page = 1}) async {
    try {
      final response = await _request(
        url: 'user/$userId/posts/$page',
        type: 'get',
      );

      return UserProfilePosts.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<UserProfileThreads> getUserThreads(int? userId, {int page = 1}) async {
    try {
      final response = await _request(
        url: 'user/$userId/threads/$page',
        type: 'get',
      );

      return UserProfileThreads.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<SyncDataModel> getSyncData() async {
    try {
      final response = await _request(
        url: 'user/syncData',
        type: 'get',
      );
      return SyncDataModel.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<bool> markMentionsAsRead(List<int?> postIds) async {
    try {
      final response = await _request(
          url: 'mentions', type: 'put', data: {'postIds': postIds});

      if (response.statusCode == 200) return true;
      return false;
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<KnockoutAd> randomAd() async {
    try {
      final response = await _request(url: 'threadAds/random', type: 'get');

      return KnockoutAd.fromJson(response.data);
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<List<KnockoutMotd>?> motd() async {
    try {
      final response = await _request(url: 'motd', type: 'get');

      return response.data
          .map<KnockoutMotd>((json) => KnockoutMotd.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<List<NotificationModel>?> notifications() async {
    try {
      final response = await _request(url: 'v2/notifications', type: 'get');

      return response.data
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<List<KnockoutRule>?> rules() async {
    try {
      final response = await _request(url: 'v2/rules', type: 'get');

      return response.data
          .map<KnockoutRule>((json) => KnockoutRule.fromJson(json))
          .toList();
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }

  Future<void> createReport(int postId, String reportReason) async {
    try {
      final response = await _request(url: 'reports', type: 'post', data: {
        'postId': postId,
        'reportReason': reportReason,
      });
    } on DioError catch (e) {
      onDioErrorHandler(e);
      throw e;
    }
  }
}
