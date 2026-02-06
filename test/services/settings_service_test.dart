import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/services/settings_service.dart';

void main() {
  group('AppThemeMode.fromString', () {
    test('parses "dark"', () {
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
    });

    test('parses "light"', () {
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
    });

    test('parses "system"', () {
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
    });

    test('returns system for null', () {
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
    });

    test('returns system for unknown string', () {
      expect(AppThemeMode.fromString('unknown'), AppThemeMode.system);
    });

    test('returns system for empty string', () {
      expect(AppThemeMode.fromString(''), AppThemeMode.system);
    });
  });

  group('AppThemeMode.toThemeMode', () {
    test('system maps to ThemeMode.system', () {
      expect(AppThemeMode.system.toThemeMode(), ThemeMode.system);
    });

    test('dark maps to ThemeMode.dark', () {
      expect(AppThemeMode.dark.toThemeMode(), ThemeMode.dark);
    });

    test('light maps to ThemeMode.light', () {
      expect(AppThemeMode.light.toThemeMode(), ThemeMode.light);
    });
  });

  group('AppThemeMode properties', () {
    test('all modes have labels', () {
      for (final mode in AppThemeMode.values) {
        expect(mode.label, isNotEmpty);
      }
    });

    test('all modes have descriptions', () {
      for (final mode in AppThemeMode.values) {
        expect(mode.description, isNotEmpty);
      }
    });
  });
}
