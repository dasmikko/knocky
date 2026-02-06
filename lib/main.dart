import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/knockout_api_service.dart';
import 'services/settings_service.dart';
import 'services/update_service.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/knockout_theme.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load settings
  final settings = SettingsService();
  await settings.load();

  // Initialize Firebase if user has consented
  if (settings.analyticsConsent) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  // Load API service and apply stored base URL
  final api = KnockoutApiService();
  api.setBaseUrl(settings.baseUrl);
  await api.loadToken();
  if (api.isAuthenticated) {
    api.getSyncData();
  }

  final updateService = UpdateService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: api),
        ChangeNotifierProvider.value(value: updateService),
      ],
      child: const MyApp(),
    ),
  );

  // Fire-and-forget: check for updates if last check was >24h ago
  updateService.checkForUpdateIfStale();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      title: 'Knocky',
      theme: KnockoutTheme.light(),
      darkTheme: KnockoutTheme.dark(),
      themeMode: settings.flutterThemeMode,
      navigatorObservers: [routeObserver],
      home: settings.hasSeenWelcome
          ? const HomeScreen(title: 'Knocky')
          : const WelcomeScreen(),
    );
  }
}
