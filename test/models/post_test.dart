import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/models/post.dart';
import 'package:knocky/models/post_thread_info.dart';
import 'package:knocky/models/thread_user.dart';
import 'package:knocky/models/role.dart';

/// Helper to create a minimal ThreadUser for testing.
ThreadUser _makeUser({int id = 1, String username = 'testuser'}) {
  return ThreadUser(
    id: id,
    role: Role(
      id: 1,
      code: 'basic-user',
      description: 'Basic User',
      permissionCodes: [],
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-01-01T00:00:00Z',
    ),
    username: username,
    avatarUrl: '',
    backgroundUrl: '',
    posts: 0,
    threads: 0,
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z',
    banned: false,
    isBanned: false,
  );
}

/// Helper to create a Post with a given thread value.
Post _makePost({required dynamic thread}) {
  return Post(
    id: 1,
    threadId: 100,
    page: 1,
    content: 'Test content',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z',
    userId: 1,
    ratings: [],
    bans: [],
    threadPostNumber: 1,
    user: _makeUser(),
    thread: thread,
  );
}

void main() {
  group('Post.threadInfo', () {
    test('returns PostThreadInfo when thread is an object', () {
      final threadInfo = PostThreadInfo(
        id: 42,
        title: 'Test Thread',
        iconId: 1,
        subforumId: 2,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );
      final post = _makePost(thread: threadInfo);

      expect(post.threadInfo, isNotNull);
      expect(post.threadInfo!.id, 42);
      expect(post.threadInfo!.title, 'Test Thread');
    });

    test('returns null when thread is an int', () {
      final post = _makePost(thread: 42);
      expect(post.threadInfo, isNull);
    });

    test('returns null when thread is 0', () {
      final post = _makePost(thread: 0);
      expect(post.threadInfo, isNull);
    });
  });

  group('Post.threadIdValue', () {
    test('returns int value when thread is int', () {
      final post = _makePost(thread: 42);
      expect(post.threadIdValue, 42);
    });

    test('returns id from PostThreadInfo when thread is object', () {
      final threadInfo = PostThreadInfo(
        id: 99,
        title: 'Thread',
        iconId: 1,
        subforumId: 2,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );
      final post = _makePost(thread: threadInfo);
      expect(post.threadIdValue, 99);
    });

    test('returns 0 when thread is unexpected type', () {
      final post = _makePost(thread: 'unexpected');
      expect(post.threadIdValue, 0);
    });

    test('returns 0 when thread is null-like', () {
      final post = _makePost(thread: null);
      expect(post.threadIdValue, 0);
    });
  });

  group('Post JSON serialization', () {
    test('fromJson handles thread as int', () {
      final json = {
        'id': 1,
        'threadId': 100,
        'page': 1,
        'content': 'Hello',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'userId': 1,
        'ratings': [],
        'bans': [],
        'threadPostNumber': 1,
        'user': {
          'id': 1,
          'role': {
            'id': 1,
            'code': 'basic-user',
            'description': 'Basic',
            'permissionCodes': [],
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
          'username': 'user1',
          'avatarUrl': '',
          'backgroundUrl': '',
          'posts': 0,
          'threads': 0,
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
          'banned': false,
          'isBanned': false,
        },
        'thread': 42,
      };

      final post = Post.fromJson(json);
      expect(post.threadIdValue, 42);
      expect(post.threadInfo, isNull);
    });

    test('fromJson handles thread as object', () {
      final json = {
        'id': 1,
        'threadId': 100,
        'page': 1,
        'content': 'Hello',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'userId': 1,
        'ratings': [],
        'bans': [],
        'threadPostNumber': 1,
        'user': {
          'id': 1,
          'role': {
            'id': 1,
            'code': 'basic-user',
            'description': 'Basic',
            'permissionCodes': [],
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
          'username': 'user1',
          'avatarUrl': '',
          'backgroundUrl': '',
          'posts': 0,
          'threads': 0,
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
          'banned': false,
          'isBanned': false,
        },
        'thread': {
          'id': 99,
          'title': 'Test Thread',
          'iconId': 1,
          'subforumId': 2,
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
        },
      };

      final post = Post.fromJson(json);
      expect(post.threadIdValue, 99);
      expect(post.threadInfo, isNotNull);
      expect(post.threadInfo!.title, 'Test Thread');
    });

    test('fromJson handles null thread', () {
      final json = {
        'id': 1,
        'threadId': 100,
        'page': 1,
        'content': 'Hello',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'userId': 1,
        'ratings': [],
        'bans': [],
        'threadPostNumber': 1,
        'user': {
          'id': 1,
          'role': {
            'id': 1,
            'code': 'basic-user',
            'description': 'Basic',
            'permissionCodes': [],
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
          'username': 'user1',
          'avatarUrl': '',
          'backgroundUrl': '',
          'posts': 0,
          'threads': 0,
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
          'banned': false,
          'isBanned': false,
        },
        'thread': null,
      };

      final post = Post.fromJson(json);
      expect(post.threadIdValue, 0);
    });

    test('toJson round-trips with int thread', () {
      final post = _makePost(thread: 42);
      final json = post.toJson();
      expect(json['thread'], 42);
    });

    test('toJson round-trips with PostThreadInfo thread', () {
      final threadInfo = PostThreadInfo(
        id: 99,
        title: 'Thread',
        iconId: 1,
        subforumId: 2,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );
      final post = _makePost(thread: threadInfo);
      final json = post.toJson();
      expect(json['thread'], isA<Map<String, dynamic>>());
      expect((json['thread'] as Map<String, dynamic>)['id'], 99);
    });
  });
}
