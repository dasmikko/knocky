import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/knockout_api_service.dart';
import 'services/settings_service.dart';
import 'services/deep_link_service.dart';
import 'services/update_service.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/knockout_theme.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Load settings
  final settings = SettingsService();
  await settings.load();

  // Initialize Firebase if user has consented (only on supported platforms)
  if (settings.analyticsConsent) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 5));
      }
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance.logAppOpen();
    } catch (_) {
      // Firebase init failed — continue without analytics
    }
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

  // Initialize deep link handling
  DeepLinkService(navigatorKey: navigatorKey).init();

  // Fire-and-forget: check for updates if last check was >24h ago
  updateService.checkForUpdateIfStale();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Knocky',
      theme: KnockoutTheme.light(),
      darkTheme: KnockoutTheme.dark(),
      themeMode: settings.flutterThemeMode,
      navigatorObservers: [routeObserver],
      // Some dependencies (extended_image, flutter_bbcode, table_calendar,
      // ...) still use package:flutter/material.dart. The
      // bridge maps our material_ui theme and localizations onto the legacy
      // types so their widgets pick up the app theme. Remove once they've
      // migrated to material_ui.
      // ignore: deprecated_member_use
      builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
      home: settings.hasSeenWelcome
          ? const HomeScreen(title: 'Knocky')
          : const WelcomeScreen(),
    );
  }
}
