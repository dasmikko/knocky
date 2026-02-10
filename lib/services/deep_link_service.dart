import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../screens/subforum_screen.dart';
import '../screens/thread_screen.dart';
import '../screens/user_screen.dart';

class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  Uri? _initialUri;

  DeepLinkService({required this.navigatorKey});

  Future<void> init() async {
    // Handle initial link (cold start via deep link)
    try {
      _initialUri = await _appLinks.getInitialLink();
      if (_initialUri != null) {
        _waitForNavigatorAndHandle(_initialUri!);
      }
    } catch (_) {}

    // Listen for links while app is running (warm start)
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        // Skip if this is the same URI we already handled on cold start
        if (_initialUri != null && uri == _initialUri) {
          _initialUri = null;
          return;
        }
        _handleDeepLink(uri);
      },
      onError: (_) {},
    );
  }

  Future<void> _waitForNavigatorAndHandle(Uri uri) async {
    // Poll until the navigator is attached (max ~3 seconds)
    for (var i = 0; i < 30; i++) {
      if (navigatorKey.currentState != null) {
        _handleDeepLink(uri);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _handleDeepLink(Uri uri) {
    final route = parseUri(uri);
    if (route == null) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(MaterialPageRoute(builder: (_) => route));
  }

  /// Parse a knockout.chat URI into a screen widget, or null if unrecognized.
  static Widget? parseUri(Uri uri) {
    if (uri.host != 'knockout.chat' && uri.host != 'www.knockout.chat') {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    switch (segments[0]) {
      case 'thread':
        if (segments.length >= 2) {
          final threadId = int.tryParse(segments[1]);
          if (threadId == null) return null;
          final page =
              segments.length >= 3 ? int.tryParse(segments[2]) : null;
          return ThreadScreen(
            threadId: threadId,
            threadTitle: '',
            page: page,
          );
        }
        return null;

      case 'subforum':
        if (segments.length >= 2) {
          final subforumId = int.tryParse(segments[1]);
          if (subforumId == null) return null;
          return SubforumScreen(
            subforumId: subforumId,
            subforumName: '',
          );
        }
        return null;

      case 'user':
        if (segments.length >= 2) {
          final userId = int.tryParse(segments[1]);
          if (userId == null) return null;
          return UserScreen(userId: userId);
        }
        return null;

      default:
        return null;
    }
  }
}
