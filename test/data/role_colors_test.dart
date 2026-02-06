import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/data/role_colors.dart';

void main() {
  group('getRoleColor', () {
    test('banned-user returns red regardless of brightness', () {
      const expected = Color(0xFFE04545);
      expect(getRoleColor('banned-user', brightness: Brightness.dark), expected);
      expect(getRoleColor('banned-user', brightness: Brightness.light), expected);
    });

    test('basic-user returns blue, varying by brightness', () {
      expect(
        getRoleColor('basic-user', brightness: Brightness.dark),
        const Color(0xFF3FACFF),
      );
      expect(
        getRoleColor('basic-user', brightness: Brightness.light),
        const Color(0xFF3B9AE3),
      );
    });

    test('limited-user returns same as basic-user', () {
      expect(
        getRoleColor('limited-user', brightness: Brightness.dark),
        getRoleColor('basic-user', brightness: Brightness.dark),
      );
      expect(
        getRoleColor('limited-user', brightness: Brightness.light),
        getRoleColor('basic-user', brightness: Brightness.light),
      );
    });

    test('gold-user returns gold', () {
      const expected = Color(0xFFFCBE20);
      expect(getRoleColor('gold-user'), expected);
    });

    test('paid-gold-user returns gold', () {
      const expected = Color(0xFFFCBE20);
      expect(getRoleColor('paid-gold-user'), expected);
    });

    test('admin returns gold', () {
      const expected = Color(0xFFFCBE20);
      expect(getRoleColor('admin'), expected);
    });

    test('moderator returns green, varying by brightness', () {
      expect(
        getRoleColor('moderator', brightness: Brightness.dark),
        const Color(0xFF41FF74),
      );
      expect(
        getRoleColor('moderator', brightness: Brightness.light),
        const Color(0xFF12AB1A),
      );
    });

    test('moderator-in-training returns lighter green', () {
      expect(
        getRoleColor('moderator-in-training', brightness: Brightness.dark),
        const Color(0xFF4CCF6F),
      );
      expect(
        getRoleColor('moderator-in-training', brightness: Brightness.light),
        const Color(0xFF30B655),
      );
    });

    test('orange-user returns orange regardless of brightness', () {
      const expected = Color(0xFFF07C00);
      expect(getRoleColor('orange-user', brightness: Brightness.dark), expected);
      expect(getRoleColor('orange-user', brightness: Brightness.light), expected);
    });

    test('null role code returns default blue', () {
      expect(
        getRoleColor(null, brightness: Brightness.dark),
        const Color(0xFF3FACFF),
      );
      expect(
        getRoleColor(null, brightness: Brightness.light),
        const Color(0xFF3B9AE3),
      );
    });

    test('unknown role code returns default blue', () {
      expect(
        getRoleColor('unknown-role', brightness: Brightness.dark),
        const Color(0xFF3FACFF),
      );
    });

    test('defaults to dark brightness', () {
      expect(
        getRoleColor('basic-user'),
        const Color(0xFF3FACFF),
      );
    });
  });

  group('hasGoldGradient', () {
    test('returns true for gold-user', () {
      expect(hasGoldGradient('gold-user'), isTrue);
    });

    test('returns true for paid-gold-user', () {
      expect(hasGoldGradient('paid-gold-user'), isTrue);
    });

    test('returns true for admin', () {
      expect(hasGoldGradient('admin'), isTrue);
    });

    test('returns false for basic-user', () {
      expect(hasGoldGradient('basic-user'), isFalse);
    });

    test('returns false for moderator', () {
      expect(hasGoldGradient('moderator'), isFalse);
    });

    test('returns false for null', () {
      expect(hasGoldGradient(null), isFalse);
    });

    test('returns false for empty string', () {
      expect(hasGoldGradient(''), isFalse);
    });
  });
}
