import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'knockout_api_service.dart';

/// Available theme modes
enum AppThemeMode {
  system('System', 'Follow system theme'),
  dark('Dark', 'Always use dark theme'),
  light('Light', 'Always use light theme');

  final String label;
  final String description;

  const AppThemeMode(this.label, this.description);

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
    }
  }

  static AppThemeMode fromString(String? value) {
    switch (value) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
        return AppThemeMode.light;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

/// Settings service for app preferences
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys
  static const String _themeKey = 'theme_mode';
  static const String _nsfwKey = 'show_nsfw';
  static const String _countryFlagsKey = 'show_country_flags';
  static const String _autoSubscribeKey = 'auto_subscribe';
  static const String _baseUrlKey = 'api_base_url';
  static const String _analyticsConsentKey = 'analytics_consent';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';

  // Current values
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _showNsfw = false;
  bool _showCountryFlags = false;
  bool _autoSubscribe = false;
  String _baseUrl = KnockoutApiService.defaultBaseUrl;
  bool _analyticsConsent = false;
  bool _hasSeenWelcome = false;

  // Getters
  AppThemeMode get themeMode => _themeMode;
  ThemeMode get flutterThemeMode => _themeMode.toThemeMode();
  bool get showNsfw => _showNsfw;
  bool get showCountryFlags => _showCountryFlags;
  bool get autoSubscribe => _autoSubscribe;
  String get baseUrl => _baseUrl;
  bool get analyticsConsent => _analyticsConsent;
  bool get hasSeenWelcome => _hasSeenWelcome;

  /// Load all settings from storage
  Future<void> load() async {
    final themeValue = await _storage.read(key: _themeKey);
    _themeMode = AppThemeMode.fromString(themeValue);

    final nsfwValue = await _storage.read(key: _nsfwKey);
    _showNsfw = nsfwValue == 'true';

    final countryFlagsValue = await _storage.read(key: _countryFlagsKey);
    _showCountryFlags = countryFlagsValue == 'true';

    final autoSubscribeValue = await _storage.read(key: _autoSubscribeKey);
    _autoSubscribe = autoSubscribeValue == 'true';

    final baseUrlValue = await _storage.read(key: _baseUrlKey);
    if (baseUrlValue != null && baseUrlValue.isNotEmpty) {
      _baseUrl = baseUrlValue;
    }

    final analyticsConsentValue =
        await _storage.read(key: _analyticsConsentKey);
    _analyticsConsent = analyticsConsentValue == 'true';

    final hasSeenWelcomeValue = await _storage.read(key: _hasSeenWelcomeKey);
    _hasSeenWelcome = hasSeenWelcomeValue == 'true';

    notifyListeners();
  }

  /// Set the theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storage.write(key: _themeKey, value: mode.name);
    notifyListeners();
  }

  /// Set whether to show NSFW content
  Future<void> setShowNsfw(bool show) async {
    if (_showNsfw == show) return;
    _showNsfw = show;
    await _storage.write(key: _nsfwKey, value: show.toString());
    notifyListeners();
  }

  /// Set whether to show country flags on posts
  Future<void> setShowCountryFlags(bool show) async {
    if (_showCountryFlags == show) return;
    _showCountryFlags = show;
    await _storage.write(key: _countryFlagsKey, value: show.toString());
    notifyListeners();
  }

  /// Set whether to auto-subscribe to threads on reply
  Future<void> setAutoSubscribe(bool value) async {
    if (_autoSubscribe == value) return;
    _autoSubscribe = value;
    await _storage.write(key: _autoSubscribeKey, value: value.toString());
    notifyListeners();
  }

  /// Set the API base URL
  Future<void> setBaseUrl(String url) async {
    if (_baseUrl == url) return;
    _baseUrl = url;
    await _storage.write(key: _baseUrlKey, value: url);
    notifyListeners();
  }

  /// Reset the API base URL to default
  Future<void> resetBaseUrl() async {
    await setBaseUrl(KnockoutApiService.defaultBaseUrl);
  }

  /// Set analytics consent
  Future<void> setAnalyticsConsent(bool value) async {
    if (_analyticsConsent == value) return;
    _analyticsConsent = value;
    await _storage.write(key: _analyticsConsentKey, value: value.toString());
    notifyListeners();
  }

  /// Set whether the welcome screen has been shown
  Future<void> setHasSeenWelcome(bool value) async {
    if (_hasSeenWelcome == value) return;
    _hasSeenWelcome = value;
    await _storage.write(key: _hasSeenWelcomeKey, value: value.toString());
    notifyListeners();
  }
}
