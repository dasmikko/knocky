import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/update_info.dart';

/// Service that checks GitHub releases for app updates.
class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  static const String _repo = 'dasmikko/knocky';
  static const String _lastCheckKey = 'update_last_check';
  static const Duration _checkInterval = Duration(hours: 24);

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com',
    headers: {'Accept': 'application/vnd.github.v3+json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UpdateInfo? _availableUpdate;
  bool _isChecking = false;
  String? _error;

  UpdateInfo? get availableUpdate => _availableUpdate;
  bool get isChecking => _isChecking;
  String? get error => _error;

  /// Check for update only if the last check was more than [_checkInterval] ago.
  /// Fails silently — intended for auto-check on app launch.
  Future<void> checkForUpdateIfStale() async {
    try {
      final lastCheck = await _storage.read(key: _lastCheckKey);
      if (lastCheck != null) {
        final lastCheckTime = DateTime.tryParse(lastCheck);
        if (lastCheckTime != null &&
            DateTime.now().difference(lastCheckTime) < _checkInterval) {
          return;
        }
      }
      await checkForUpdate();
    } catch (_) {
      // Silently ignore errors on auto-check
    }
  }

  /// Check GitHub for the latest release and compare with current version.
  Future<void> checkForUpdate() async {
    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/repos/$_repo/releases/latest');
      final info = UpdateInfo.fromGitHubRelease(response.data);
      final packageInfo = await PackageInfo.fromPlatform();

      if (isNewer(info.version, packageInfo.version)) {
        _availableUpdate = info;
      } else {
        _availableUpdate = null;
      }

      await _storage.write(
        key: _lastCheckKey,
        value: DateTime.now().toIso8601String(),
      );
    } on DioException catch (e) {
      _error = e.response?.statusCode == 404
          ? 'No releases found'
          : 'Could not reach GitHub';
    } catch (e) {
      _error = 'Failed to check for updates';
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Open the download URL (APK asset or release page) in the browser.
  Future<void> launchUpdate() async {
    if (_availableUpdate == null) return;
    final url = _availableUpdate!.downloadUrl.isNotEmpty
        ? _availableUpdate!.downloadUrl
        : _availableUpdate!.htmlUrl;
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Compare two semver strings. Returns true if [remote] is newer than [local].
  @visibleForTesting
  static bool isNewer(String remote, String local) {
    final remoteParts = parseSemver(remote);
    final localParts = parseSemver(local);
    for (int i = 0; i < 3; i++) {
      if (remoteParts[i] > localParts[i]) return true;
      if (remoteParts[i] < localParts[i]) return false;
    }
    return false;
  }

  @visibleForTesting
  static List<int> parseSemver(String version) {
    final cleaned = version.startsWith('v') ? version.substring(1) : version;
    final parts = cleaned.split('.');
    return List.generate(3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }
}
