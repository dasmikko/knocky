import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/data/ratings.dart';

void main() {
  group('getRatingByCode', () {
    test('returns correct rating for valid code', () {
      final rating = getRatingByCode('agree');
      expect(rating, isNotNull);
      expect(rating!.code, 'agree');
      expect(rating.name, 'Agree');
    });

    test('returns null for invalid code', () {
      expect(getRatingByCode('nonexistent'), isNull);
    });

    test('returns null for empty code', () {
      expect(getRatingByCode(''), isNull);
    });

    test('finds each known rating', () {
      const codes = [
        'agree', 'disagree', 'funny', 'friendly', 'kawaii', 'sad',
        'artistic', 'informative', 'idea', 'winner', 'glasses', 'late',
        'dumb', 'citation', 'optimistic', 'zing', 'yeet', 'rude',
        'confusing', 'scary',
      ];
      for (final code in codes) {
        expect(getRatingByCode(code), isNotNull, reason: 'Rating "$code" not found');
      }
    });
  });

  group('enabledRatings', () {
    test('excludes disabled ratings', () {
      final enabled = enabledRatings;
      expect(enabled.any((r) => r.code == 'dumb'), isFalse);
    });

    test('includes enabled ratings', () {
      final enabled = enabledRatings;
      expect(enabled.any((r) => r.code == 'agree'), isTrue);
      expect(enabled.any((r) => r.code == 'funny'), isTrue);
    });

    test('has fewer items than total ratings', () {
      expect(enabledRatings.length, lessThan(ratings.length));
    });
  });

  group('ratingMap', () {
    test('contains all ratings', () {
      expect(ratingMap.length, ratings.length);
    });

    test('lookup by code works', () {
      expect(ratingMap['agree']?.name, 'Agree');
      expect(ratingMap['funny']?.name, 'Funny');
    });

    test('returns null for missing key', () {
      expect(ratingMap['nonexistent'], isNull);
    });
  });
}
