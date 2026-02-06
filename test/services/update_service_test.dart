import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/services/update_service.dart';

void main() {
  group('UpdateService.parseSemver', () {
    test('parses standard version', () {
      expect(UpdateService.parseSemver('1.2.3'), [1, 2, 3]);
    });

    test('strips v prefix', () {
      expect(UpdateService.parseSemver('v1.2.3'), [1, 2, 3]);
    });

    test('handles two-part version', () {
      expect(UpdateService.parseSemver('1.2'), [1, 2, 0]);
    });

    test('handles single-part version', () {
      expect(UpdateService.parseSemver('5'), [5, 0, 0]);
    });

    test('handles non-numeric parts', () {
      expect(UpdateService.parseSemver('a.b.c'), [0, 0, 0]);
    });

    test('handles empty string', () {
      expect(UpdateService.parseSemver(''), [0, 0, 0]);
    });

    test('handles v prefix only', () {
      expect(UpdateService.parseSemver('v'), [0, 0, 0]);
    });

    test('handles zero version', () {
      expect(UpdateService.parseSemver('0.0.0'), [0, 0, 0]);
    });

    test('handles large numbers', () {
      expect(UpdateService.parseSemver('100.200.300'), [100, 200, 300]);
    });
  });

  group('UpdateService.isNewer', () {
    test('newer major version', () {
      expect(UpdateService.isNewer('2.0.0', '1.0.0'), isTrue);
    });

    test('newer minor version', () {
      expect(UpdateService.isNewer('1.1.0', '1.0.0'), isTrue);
    });

    test('newer patch version', () {
      expect(UpdateService.isNewer('1.0.1', '1.0.0'), isTrue);
    });

    test('equal versions', () {
      expect(UpdateService.isNewer('1.0.0', '1.0.0'), isFalse);
    });

    test('older major version', () {
      expect(UpdateService.isNewer('1.0.0', '2.0.0'), isFalse);
    });

    test('older minor version', () {
      expect(UpdateService.isNewer('1.0.0', '1.1.0'), isFalse);
    });

    test('older patch version', () {
      expect(UpdateService.isNewer('1.0.0', '1.0.1'), isFalse);
    });

    test('newer minor overrides older patch', () {
      expect(UpdateService.isNewer('1.2.0', '1.1.9'), isTrue);
    });

    test('newer major overrides older minor and patch', () {
      expect(UpdateService.isNewer('2.0.0', '1.9.9'), isTrue);
    });

    test('handles v prefix on both', () {
      expect(UpdateService.isNewer('v2.0.0', 'v1.0.0'), isTrue);
    });

    test('handles v prefix on remote only', () {
      expect(UpdateService.isNewer('v2.0.0', '1.0.0'), isTrue);
    });

    test('handles v prefix on local only', () {
      expect(UpdateService.isNewer('2.0.0', 'v1.0.0'), isTrue);
    });
  });
}
