import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/models/conversation.dart';
import 'package:knocky/models/message.dart';
import 'package:knocky/models/thread_user.dart';
import 'package:knocky/models/role.dart';

ThreadUser _makeUser({required int id, String username = 'user'}) {
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

Message _makeMessage({
  required int id,
  required int userId,
  String? readAt,
}) {
  return Message(
    id: id,
    conversationId: 1,
    user: _makeUser(id: userId),
    content: 'Message $id',
    readAt: readAt,
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z',
  );
}

void main() {
  final currentUserId = 10;
  final otherUserId = 20;

  group('Conversation.getOtherUsers', () {
    test('filters out current user', () {
      final conversation = Conversation(
        id: 1,
        messages: [],
        users: [
          _makeUser(id: currentUserId, username: 'me'),
          _makeUser(id: otherUserId, username: 'other'),
        ],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      final others = conversation.getOtherUsers(currentUserId);
      expect(others.length, 1);
      expect(others.first.id, otherUserId);
      expect(others.first.username, 'other');
    });

    test('returns empty when only current user', () {
      final conversation = Conversation(
        id: 1,
        messages: [],
        users: [_makeUser(id: currentUserId)],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.getOtherUsers(currentUserId), isEmpty);
    });

    test('returns multiple other users', () {
      final conversation = Conversation(
        id: 1,
        messages: [],
        users: [
          _makeUser(id: currentUserId),
          _makeUser(id: 20),
          _makeUser(id: 30),
        ],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.getOtherUsers(currentUserId).length, 2);
    });
  });

  group('Conversation.latestMessage', () {
    test('returns first message when messages exist', () {
      final conversation = Conversation(
        id: 1,
        messages: [
          _makeMessage(id: 3, userId: otherUserId),
          _makeMessage(id: 2, userId: currentUserId),
          _makeMessage(id: 1, userId: otherUserId),
        ],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.latestMessage, isNotNull);
      expect(conversation.latestMessage!.id, 3);
    });

    test('returns null when messages empty', () {
      final conversation = Conversation(
        id: 1,
        messages: [],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.latestMessage, isNull);
    });
  });

  group('Conversation.hasUnread', () {
    test('returns true when other user has unread message', () {
      final conversation = Conversation(
        id: 1,
        messages: [
          _makeMessage(id: 1, userId: otherUserId, readAt: null),
        ],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.hasUnread(currentUserId), isTrue);
    });

    test('returns false when all messages from others are read', () {
      final conversation = Conversation(
        id: 1,
        messages: [
          _makeMessage(
            id: 1,
            userId: otherUserId,
            readAt: '2024-01-01T00:00:00Z',
          ),
        ],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.hasUnread(currentUserId), isFalse);
    });

    test('ignores own unread messages', () {
      final conversation = Conversation(
        id: 1,
        messages: [
          _makeMessage(id: 1, userId: currentUserId, readAt: null),
        ],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.hasUnread(currentUserId), isFalse);
    });

    test('returns false when no messages', () {
      final conversation = Conversation(
        id: 1,
        messages: [],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.hasUnread(currentUserId), isFalse);
    });

    test('mixed read/unread from other user', () {
      final conversation = Conversation(
        id: 1,
        messages: [
          _makeMessage(
            id: 1,
            userId: otherUserId,
            readAt: '2024-01-01T00:00:00Z',
          ),
          _makeMessage(id: 2, userId: otherUserId, readAt: null),
        ],
        users: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      expect(conversation.hasUnread(currentUserId), isTrue);
    });
  });
}
