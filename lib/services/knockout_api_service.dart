import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import '../models/alerts_response.dart';
import '../models/calendar_event.dart';
import '../models/motd.dart';
import '../models/conversation.dart';
import '../models/thread_ad.dart';
import '../models/thread_search_response.dart';
import '../models/notification.dart';
import '../models/subforum.dart';
import '../models/subforum_response.dart';
import '../models/sync_data.dart';
import '../models/thread.dart';
import '../models/thread_response.dart';
import '../models/thread_user.dart';
import '../models/user_posts_response.dart';
import '../models/user_profile.dart';
import '../models/user_threads_response.dart';

class KnockoutApiService extends ChangeNotifier {
  static final KnockoutApiService _instance = KnockoutApiService._internal();
  factory KnockoutApiService() => _instance;

  KnockoutApiService._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: defaultBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          handleTokenRefresh(response);
          handler.next(response);
        },
      ),
    );
  }

  /// Extract and save refreshed token from Set-Cookie header
  @visibleForTesting
  void handleTokenRefresh(Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader == null || setCookieHeader.isEmpty) return;

    for (final cookie in setCookieHeader) {
      if (cookie.startsWith('knockoutJwt=')) {
        // Extract the token value (before the first semicolon)
        final tokenPart = cookie.split(';').first;
        final newToken = tokenPart.substring('knockoutJwt='.length);

        if (newToken.isNotEmpty && newToken != _jwt) {
          log('Token refreshed by server');
          setToken(newToken);
        }
        break;
      }
    }
  }

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _jwt;
  SyncData? _cachedSyncData;

  bool get isAuthenticated => _jwt != null;
  SyncData? get syncData => _cachedSyncData;

  Future<void> loadToken() async {
    _jwt = await _storage.read(key: 'jwt');
  }

  Future<void> setToken(String token) async {
    _jwt = token;
    await _storage.write(key: 'jwt', value: token);
    notifyListeners();
  }

  Future<void> clearToken() async {
    _jwt = null;
    _cachedSyncData = null;
    await _storage.delete(key: 'jwt');
    notifyListeners();
  }

  static const String defaultBaseUrl = 'https://api.knockout.chat';

  /// Update the base URL used for all API requests
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Options get _options =>
      Options(headers: {if (_jwt != null) 'Cookie': 'knockoutJwt=$_jwt'});

  /// Fetch sync data for the logged-in user and cache it
  Future<SyncData> getSyncData() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _dio.get(
        '/user/syncData',
        queryParameters: {'t': timestamp},
        options: _options,
      );

      _cachedSyncData = SyncData.fromJson(response.data);
      notifyListeners();
      return _cachedSyncData!;
    } on DioException catch (e) {
      throw Exception('Error fetching sync data: ${e.message}');
    }
  }

  /// Fetch list of subforums
  Future<List<Subforum>> getSubforums({bool showNsfw = false}) async {
    try {
      final response = await _dio.get(
        '/v2/subforums',
        queryParameters: {if (!showNsfw) 'hideNsfw': 1},
        options: _options,
      );

      final dynamic jsonData = response.data;

      // Handle if response is a list directly
      if (jsonData is List) {
        return jsonData.map((json) => Subforum.fromJson(json)).toList();
      }

      // Handle if response is an object with a list property
      if (jsonData is Map<String, dynamic>) {
        // Try common property names
        if (jsonData.containsKey('subforums')) {
          final List<dynamic> subforumsList = jsonData['subforums'];
          return subforumsList.map((json) => Subforum.fromJson(json)).toList();
        } else if (jsonData.containsKey('data')) {
          final List<dynamic> subforumsList = jsonData['data'];
          return subforumsList.map((json) => Subforum.fromJson(json)).toList();
        }
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception('Error fetching subforums: ${e.message}');
    }
  }

  /// Example method for getting a single subforum by ID
  Future<Subforum> getSubforum(String id) async {
    try {
      final response = await _dio.get('/v2/subforums/$id', options: _options);

      return Subforum.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching subforum: ${e.message}');
    }
  }

  /// Fetch subforum details with threads
  Future<SubforumResponse> getSubforumWithThreads(
    int subforumId,
    int page, {
    bool showNsfw = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/v2/subforums/$subforumId/$page',
        queryParameters: {if (!showNsfw) 'hideNsfw': 1},
        options: _options,
        cancelToken: cancelToken,
      );

      return SubforumResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw Exception('Error fetching subforum with threads: ${e.message}');
    }
  }

  /// Fetch latest threads
  Future<List<Thread>> getLatestThreads({bool showNsfw = false}) async {
    try {
      final response = await _dio.get(
        '/v2/threads/latest',
        queryParameters: {if (!showNsfw) 'hideNsfw': 1},
        options: _options,
      );

      final List<dynamic> jsonData = response.data;
      final List<Thread> threads = [];
      for (int i = 0; i < jsonData.length; i++) {
        try {
          threads.add(Thread.fromJson(jsonData[i] as Map<String, dynamic>));
        } catch (e, stackTrace) {
          log(
            'Failed to parse latest thread at index $i: $e',
            error: e,
            stackTrace: stackTrace,
          );
          log('Raw JSON for thread at index $i: ${jsonData[i]}');
        }
      }
      return threads;
    } on DioException catch (e) {
      throw Exception('Error fetching latest threads: ${e.message}');
    }
  }

  /// Fetch popular threads
  Future<List<Thread>> getPopularThreads({bool showNsfw = false}) async {
    try {
      final response = await _dio.get(
        '/v2/threads/popular',
        queryParameters: {if (!showNsfw) 'hideNsfw': 1},
        options: _options,
      );

      final List<dynamic> jsonData = response.data;
      return jsonData
          .map((json) => Thread.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error fetching popular threads: ${e.message}');
    }
  }

  /// Fetch user by ID
  Future<ThreadUser> getUser(int userId) async {
    try {
      final response = await _dio.get('/user/$userId', options: _options);

      return ThreadUser.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching user: ${e.message}');
    }
  }

  /// Fetch user profile by ID
  Future<UserProfile?> getUserProfile(int userId) async {
    try {
      final response = await _dio.get(
        '/v2/users/$userId/profile',
        options: _options,
      );

      if (response.data == null ||
          response.data is! Map ||
          (response.data as Map).isEmpty) {
        return null;
      }
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching user profile: ${e.message}');
    }
  }

  /// Fetch user's posts with pagination
  Future<UserPostsResponse> getUserPosts(
    int userId,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/user/$userId/posts/$page',
        options: _options,
        cancelToken: cancelToken,
      );

      return UserPostsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw Exception('Error fetching user posts: ${e.message}');
    }
  }

  /// Fetch user's created threads with pagination
  Future<UserThreadsResponse> getUserThreads(
    int userId,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/user/$userId/threads/$page',
        options: _options,
        cancelToken: cancelToken,
      );

      return UserThreadsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw Exception('Error fetching user threads: ${e.message}');
    }
  }

  /// Fetch thread with posts
  Future<ThreadResponse> getThread(
    int threadId,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/v2/threads/$threadId/$page',
        options: _options,
        cancelToken: cancelToken,
      );

      return ThreadResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw Exception('Error fetching thread: ${e.message}');
    }
  }

  /// Fetch user's subscribed threads (alerts)
  Future<AlertsResponse> getAlerts(int page, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get(
        '/v2/alerts/$page',
        options: _options,
        cancelToken: cancelToken,
      );

      return AlertsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw Exception('Error fetching alerts: ${e.message}');
    }
  }

  /// Mark thread as read up to a specific post number
  Future<void> markThreadRead(int threadId, int lastPostNumber) async {
    if (!isAuthenticated) return;

    try {
      await _dio.post(
        '/v2/read-threads',
        data: {'threadId': threadId, 'lastPostNumber': lastPostNumber},
        options: _options,
      );
    } on DioException catch (e) {
      // Silently fail - this is not critical functionality
      log('Error marking thread as read: ${e.message}');
    }
  }

  /// Mark thread as unread (delete read status)
  Future<bool> markThreadUnread(int threadId) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.delete('/v2/read-threads/$threadId', options: _options);
      return true;
    } on DioException catch (e) {
      log('Error marking thread as unread: ${e.message}');
      return false;
    }
  }

  /// Subscribe to a thread
  Future<bool> subscribeToThread(int threadId, int lastPostNumber) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.post(
        '/v2/alerts',
        data: {'threadId': threadId, 'lastPostNumber': lastPostNumber},
        options: _options,
      );
      await getSyncData(); // Refresh sync data
      return true;
    } on DioException catch (e) {
      log('Error subscribing to thread: ${e.message}');
      log('Status: ${e.response?.statusCode}');
      log('Response: ${e.response?.data}');
      return false;
    }
  }

  /// Unsubscribe from a thread
  Future<bool> unsubscribeFromThread(int threadId) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.delete('/v2/alerts/$threadId', options: _options);
      await getSyncData(); // Refresh sync data
      return true;
    } on DioException catch (e) {
      log('Error unsubscribing from thread: ${e.message}');
      log('Status: ${e.response?.statusCode}');
      log('Response: ${e.response?.data}');
      return false;
    }
  }

  /// Check if user is subscribed to a thread
  bool isSubscribedToThread(int threadId) {
    final syncData = _cachedSyncData;
    if (syncData == null) return false;
    return syncData.subscriptionIds.contains(threadId);
  }

  /// Fetch user's conversations
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dio.get('/conversations', options: _options);

      final List<dynamic> jsonData = response.data;
      return jsonData
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error fetching conversations: ${e.message}');
    }
  }

  /// Fetch user's notifications
  Future<List<KnockyNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/v2/notifications', options: _options);

      final List<dynamic> jsonData = response.data;
      final notifications = <KnockyNotification>[];
      for (final json in jsonData) {
        try {
          notifications.add(
            KnockyNotification.fromJson(json as Map<String, dynamic>),
          );
        } catch (_) {
          // Skip notifications that fail to parse
        }
      }
      return notifications;
    } on DioException catch (e) {
      throw Exception('Error fetching notifications: ${e.message}');
    }
  }

  /// Mark notifications as read by their IDs
  Future<bool> markNotificationsRead(List<int> notificationIds) async {
    if (!isAuthenticated || notificationIds.isEmpty) return false;

    try {
      await _dio.put(
        '/v2/notifications',
        data: {'notificationIds': notificationIds},
        options: _options,
      );
      return true;
    } on DioException catch (e) {
      log('Error marking notifications as read: ${e.message}');
      return false;
    }
  }

  /// Fetch a single conversation with all messages
  Future<Conversation> getConversation(int conversationId) async {
    try {
      final response = await _dio.get(
        '/conversations/$conversationId',
        options: _options,
      );

      return Conversation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching conversation: ${e.message}');
    }
  }

  /// Send a message in a conversation
  Future<bool> sendMessage({
    required int receivingUserId,
    required String content,
    int? conversationId,
  }) async {
    if (!isAuthenticated) return false;

    try {
      final data = <String, dynamic>{
        'receivingUserId': receivingUserId,
        'content': content,
      };
      if (conversationId != null) {
        data['conversationId'] = conversationId;
      }

      await _dio.post('/messages', data: data, options: _options);
      return true;
    } on DioException catch (e) {
      log('Error sending message: ${e.message}');
      return false;
    }
  }

  /// Search for users by username
  Future<List<ThreadUser>> searchUsers(String filter) async {
    try {
      final response = await _dio.get(
        '/users/',
        queryParameters: {'filter': filter},
        options: _options,
      );

      final List<dynamic> usersJson = response.data['users'] ?? [];
      return usersJson
          .map((json) => ThreadUser.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error searching users: ${e.message}');
    }
  }

  /// Archive (delete) a conversation
  Future<bool> archiveConversation(int conversationId) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.post(
        '/conversations/$conversationId/archive',
        options: _options,
      );
      return true;
    } on DioException catch (e) {
      log('Error archiving conversation: ${e.message}');
      return false;
    }
  }

  /// Mark messages as read up to the given message ID
  Future<void> markMessagesRead(int lastMessageId) async {
    if (!isAuthenticated) return;

    try {
      await _dio.put('/messages/$lastMessageId', options: _options);
    } on DioException catch (e) {
      log('Error marking messages as read: ${e.message}');
    }
  }

  /// Create a new post in a thread
  Future<bool> createPost({
    required int threadId,
    required String content,
    bool displayCountryInfo = false,
  }) async {
    if (!isAuthenticated) {
      debugPrint('createPost: Not authenticated');
      return false;
    }

    debugPrint('createPost: threadId=$threadId, contentLength=${content.length}');
    debugPrint('createPost: content preview: ${content.substring(0, content.length > 100 ? 100 : content.length)}');

    try {
      final response = await _dio.post(
        '/v2/posts',
        data: {
          'thread_id': threadId,
          'content': content,
          'display_country_info': displayCountryInfo,
        },
        options: _options.copyWith(
          headers: {...?_options.headers, 'Content-Format-Version': '1'},
        ),
      );
      debugPrint('createPost: Success, status=${response.statusCode}');
      return true;
    } on DioException catch (e) {
      debugPrint('createPost: Error - ${e.message}');
      debugPrint('createPost: Status code - ${e.response?.statusCode}');
      debugPrint('createPost: Response data - ${e.response?.data}');
      debugPrint('createPost: Request data - ${e.requestOptions.data}');
      return false;
    }
  }

  /// Rate a post
  Future<bool> ratePost(int postId, String ratingCode) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.put(
        '/v2/posts/$postId/ratings',
        data: {'rating': ratingCode},
        options: _options,
      );
      return true;
    } on DioException catch (e) {
      log('Error rating post: ${e.message}');
      return false;
    }
  }

  /// Remove rating from a post
  Future<bool> unratePost(int postId) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.delete('/v2/posts/$postId/ratings', options: _options);
      return true;
    } on DioException catch (e) {
      log('Error unrating post: ${e.message}');
      return false;
    }
  }

  /// Edit a post
  Future<bool> editPost(int postId, String content) async {
    if (!isAuthenticated) return false;

    try {
      await _dio.put(
        '/v2/posts/$postId',
        data: {'content': content},
        options: _options,
      );
      return true;
    } on DioException catch (e) {
      log('Error editing post: ${e.message}');
      return false;
    }
  }

  /// Upload an image from device
  /// Returns the full URL of the uploaded image, or null on failure
  Future<String?> uploadImage(
    XFile file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    if (!isAuthenticated) return null;

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path, filename: file.name),
      });

      final response = await _dio.post(
        '/postImages',
        data: formData,
        options: Options(
          headers: {
            if (_jwt != null) 'Cookie': 'knockoutJwt=$_jwt',
            'Content-Type': 'multipart/form-data',
            'Content-Format-Version': '1',
          },
        ),
        onSendProgress: onProgress,
      );

      final fileName = response.data['fileName'] as String?;
      if (fileName != null) {
        return 'https://cdn.knockout.chat/image/$fileName';
      }
      return null;
    } on DioException catch (e) {
      log('Error uploading image: ${e.message}');
      if (e.response != null) {
        log('Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Upload a video from device
  /// Returns the full URL of the uploaded video, or null on failure
  Future<String?> uploadVideo(
    XFile file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    if (!isAuthenticated) return null;

    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(file.path, filename: file.name),
      });

      final response = await _dio.post(
        '/v2/postVideos/',
        data: formData,
        options: Options(
          headers: {
            if (_jwt != null) 'Cookie': 'knockoutJwt=$_jwt',
            'Content-Type': 'multipart/form-data',
            'Content-Format-Version': '1',
          },
        ),
        onSendProgress: onProgress,
      );

      final baseName = response.data['baseName'] as String?;
      final availableFormats = response.data['availableFormats'] as List?;
      if (baseName != null && availableFormats != null && availableFormats.isNotEmpty) {
        final format = availableFormats.first as String;
        return 'https://cdn.knockout.chat/video/$baseName.$format';
      }
      return null;
    } on DioException catch (e) {
      log('Error uploading video: ${e.message}');
      if (e.response != null) {
        log('Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Search for threads
  Future<ThreadSearchResponse> searchThreads({
    required String title,
    int page = 1,
    String sortBy = 'relevance',
    String sortOrder = 'desc',
    bool locked = false,
    int? subforumId,
    int? userId,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'page': page,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'locked': locked,
      };
      if (subforumId != null) data['subforum_id'] = subforumId;
      if (userId != null) data['user_id'] = userId;

      final response = await _dio.post(
        '/v2/threadsearch',
        data: data,
        options: _options,
      );

      return ThreadSearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error searching threads: ${e.message}');
    }
  }

  /// Get a random thread ad
  Future<ThreadAd?> getRandomAd() async {
    try {
      final response = await _dio.get('/v2/threadAds/random');
      return ThreadAd.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('Error fetching random ad: ${e.message}');
      return null;
    }
  }

  /// Fetch the current Message of the Day.
  Future<Motd?> getMotd() async {
    try {
      final response = await _dio.get('/motd');
      if (response.data == null) return null;
      return Motd.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('Error fetching MOTD: ${e.message}');
      return null;
    }
  }

  /// Fetch calendar events for a date range
  Future<List<CalendarEvent>> getCalendarEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/v2/calendarEvents',
        queryParameters: {
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
        },
        options: _options,
      );

      final List<dynamic> jsonData = response.data;
      debugPrint('Fetched ${jsonData.length} calendar events');
      final List<CalendarEvent> events = [];
      for (int i = 0; i < jsonData.length; i++) {
        try {
          events.add(CalendarEvent.fromJson(jsonData[i] as Map<String, dynamic>));
        } catch (e, stackTrace) {
          debugPrint('Failed to parse calendar event at index $i: $e');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Raw JSON for event at index $i: ${jsonData[i]}');
        }
      }
      return events;
    } on DioException catch (e) {
      debugPrint('Error fetching calendar events: ${e.message}');
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      throw Exception('Error fetching calendar events: ${e.response?.statusCode ?? e.message}');
    }
  }
}
