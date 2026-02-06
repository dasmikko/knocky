import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/services/knockout_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KnockoutApiService service;

  setUp(() {
    service = KnockoutApiService();

    // Mock the FlutterSecureStorage method channel so storage calls don't fail
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        // Return null for all storage operations (read, write, delete)
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  group('isAuthenticated', () {
    test('returns false after clearToken', () async {
      await service.clearToken();
      expect(service.isAuthenticated, isFalse);
    });
  });

  group('isSubscribedToThread', () {
    test('returns false when syncData is null', () {
      expect(service.isSubscribedToThread(1), isFalse);
    });
  });

  group('handleTokenRefresh', () {
    test('does nothing when no Set-Cookie header', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        headers: Headers(),
      );

      // Should not throw
      service.handleTokenRefresh(response);
    });

    test('does nothing when Set-Cookie does not contain knockoutJwt', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        headers: Headers.fromMap({
          'set-cookie': ['otherCookie=value; Path=/; HttpOnly'],
        }),
      );

      service.handleTokenRefresh(response);
      // No exception thrown
    });

    test('extracts JWT from Set-Cookie header', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        headers: Headers.fromMap({
          'set-cookie': [
            'knockoutJwt=eyJhbGciOiJIUzI1NiJ9.test.signature; Path=/; HttpOnly; Secure',
          ],
        }),
      );

      // Clear first so we know it starts unauthenticated
      await service.clearToken();
      expect(service.isAuthenticated, isFalse);

      service.handleTokenRefresh(response);
      expect(service.isAuthenticated, isTrue);
    });

    test('ignores empty JWT value', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        headers: Headers.fromMap({
          'set-cookie': ['knockoutJwt=; Path=/; HttpOnly'],
        }),
      );

      await service.clearToken();
      service.handleTokenRefresh(response);
      expect(service.isAuthenticated, isFalse);
    });

    test('picks knockoutJwt from multiple cookies', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        headers: Headers.fromMap({
          'set-cookie': [
            'session=abc123; Path=/',
            'knockoutJwt=newtoken123; Path=/; HttpOnly',
            'tracking=xyz; Path=/',
          ],
        }),
      );

      await service.clearToken();
      service.handleTokenRefresh(response);
      expect(service.isAuthenticated, isTrue);
    });
  });

  group('defaultBaseUrl', () {
    test('is the Knockout.chat API URL', () {
      expect(
        KnockoutApiService.defaultBaseUrl,
        'https://api.knockout.chat',
      );
    });
  });
}
