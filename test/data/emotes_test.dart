import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/data/emotes.dart';

void main() {
  group('getEmoteByCode', () {
    test('returns correct emote for valid code', () {
      final emote = getEmoteByCode('smile');
      expect(emote, isNotNull);
      expect(emote!.code, 'smile');
    });

    test('returns null for invalid code', () {
      expect(getEmoteByCode('nonexistent'), isNull);
    });

    test('returns null for empty code', () {
      expect(getEmoteByCode(''), isNull);
    });

    test('finds emote with title', () {
      final emote = getEmoteByCode('asdfghjkl');
      expect(emote, isNotNull);
      expect(emote!.title, "asdfghjkl;'");
    });

    test('finds emote with dark variant', () {
      final emote = getEmoteByCode('chillout');
      expect(emote, isNotNull);
      expect(emote!.assetPathDark, isNotNull);
    });
  });

  group('visibleEmotes', () {
    test('excludes hidden emotes', () {
      final visible = visibleEmotes;
      final hiddenCodes = ['ass', 'suicide', 'toadleave'];
      for (final code in hiddenCodes) {
        expect(
          visible.any((e) => e.code == code),
          isFalse,
          reason: 'Hidden emote "$code" should not appear in visibleEmotes',
        );
      }
    });

    test('includes non-hidden emotes', () {
      final visible = visibleEmotes;
      expect(visible.any((e) => e.code == 'smile'), isTrue);
      expect(visible.any((e) => e.code == 'happy'), isTrue);
    });

    test('has fewer items than total emotes', () {
      expect(visibleEmotes.length, lessThan(emotes.length));
    });
  });

  group('emoteMap', () {
    test('contains all emotes', () {
      expect(emoteMap.length, emotes.length);
    });

    test('lookup by code works', () {
      expect(emoteMap['smile']?.code, 'smile');
      expect(emoteMap['happy']?.code, 'happy');
    });

    test('returns null for missing key', () {
      expect(emoteMap['nonexistent'], isNull);
    });
  });
}
