# CLAUDE.md - Knocky Codebase Guide

This document provides comprehensive guidance for AI assistants working with the Knocky codebase.

## Project Overview

**Knocky** is a Flutter-based cross-platform mobile/desktop client for the [Knockout.chat](https://knockout.chat) forum platform.

- **Language**: Dart 3.10.7+
- **Framework**: Flutter
- **State Management**: Provider (ChangeNotifier pattern)
- **HTTP Client**: Dio
- **API**: https://api.knockout.chat

## Directory Structure

```
lib/
├── main.dart              # App entry point, Provider setup
├── screens/               # Page-level widgets (15 screens)
├── services/              # API and business logic services
│   ├── knockout_api_service.dart  # Main API client (singleton)
│   ├── settings_service.dart      # User preferences
│   └── oembed_service.dart        # Embed preview handling
├── models/                # Data models with JSON serialization
├── widgets/               # Reusable UI components
│   └── bbcode_editor/     # Complex BBCode editor with toolbar
├── data/                  # Static data and constants
│   ├── role_colors.dart   # User role color mapping
│   ├── ratings.dart       # Post rating definitions
│   └── emotes.dart        # Forum emotes
└── theme/                 # App theming (light/dark)
```

## Key Commands

### Development

```bash
# Run the app
flutter run

# Run on specific platform
flutter run -d linux
flutter run -d chrome
flutter run -d android

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Get dependencies
flutter pub get
```

### Code Generation (REQUIRED after model changes)

```bash
# Generate JSON serialization code (one-time)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (continuous generation during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Building

```bash
# Build for platforms
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build linux        # Linux
flutter build windows      # Windows
flutter build macos        # macOS

# Generate app icons
flutter pub run flutter_launcher_icons
```

## Architecture Patterns

### State Management

The app uses Provider with ChangeNotifier for reactive state:

```dart
// Services are singletons provided at app root
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: SettingsService()),
      ChangeNotifierProvider.value(value: KnockoutApiService()),
    ],
    child: const MyApp(),
  ),
);

// Access in widgets
final api = context.read<KnockoutApiService>();      // One-time read
final settings = context.watch<SettingsService>();   // Reactive rebuild
```

### API Service Pattern

`KnockoutApiService` (`lib/services/knockout_api_service.dart`) is the main API client:

- Singleton pattern for app-wide access
- Dio HTTP client with interceptors
- JWT token management via `FlutterSecureStorage`
- Automatic token refresh from response cookies
- `notifyListeners()` called after state changes

```dart
// API methods follow this pattern:
Future<T> getSomething() async {
  try {
    final response = await _dio.get('/endpoint', options: _options);
    return T.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception('Error: ${e.message}');
  }
}
```

### Model Pattern

Models use `json_serializable` for JSON handling:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'example.g.dart';  // Generated file

@JsonSerializable()
class Example {
  final int id;
  final String name;

  @JsonKey(name: 'created_at')  // Custom JSON field name
  final DateTime createdAt;

  @JsonKey(defaultValue: false)  // Default for missing fields
  final bool isActive;

  Example({required this.id, required this.name, ...});

  factory Example.fromJson(Map<String, dynamic> json) => _$ExampleFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleToJson(this);
}
```

**Important**: After creating or modifying models, run `build_runner` to regenerate `.g.dart` files.

### Screen Pattern

Screens follow a consistent structure:

```dart
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key, required this.someId});
  final int someId;

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> with RouteAware {
  bool _isLoading = false;
  String? _errorMessage;
  SomeData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen - refresh data
    _refreshData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final api = context.read<KnockoutApiService>();
      final data = await api.getData(widget.someId);
      setState(() { _data = data; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading, error, and data states
  }
}
```

## Code Conventions

### Imports

Use relative imports for local files, package imports for external:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/knockout_api_service.dart';
import '../models/thread.dart';
```

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `camelCase` or `_camelCase` for private
- Models match API entities: `Thread`, `Post`, `User`, `Subforum`

### Widget Organization

- Place state variables at top of State class
- Group lifecycle methods together
- Private helper methods prefixed with `_`
- Build methods return Widget, helper methods build specific sections

### Error Handling

- API errors throw exceptions with descriptive messages
- Screens catch errors and display user-friendly messages
- Non-critical operations (like marking read) fail silently with logging

## Key Services

### KnockoutApiService

Main API client providing methods for:
- Authentication (`loadToken`, `setToken`, `clearToken`)
- Subforums (`getSubforums`, `getSubforumWithThreads`)
- Threads (`getLatestThreads`, `getPopularThreads`, `getThread`)
- Posts (`createPost`, `editPost`, `ratePost`)
- Users (`getUser`, `getUserProfile`, `getUserPosts`)
- Conversations (`getConversations`, `sendMessage`)
- Notifications (`getNotifications`, `markNotificationsRead`)
- Subscriptions (`subscribeToThread`, `unsubscribeFromThread`)
- Media uploads (`uploadImage`, `uploadVideo`)

### SettingsService

User preferences including:
- Theme mode (light/dark/system)
- NSFW content filter
- Other app settings

## Common Tasks

### Adding a New API Endpoint

1. Create/update model in `lib/models/`
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Add method to `KnockoutApiService`
4. Use in screen/widget with `context.read<KnockoutApiService>()`

### Adding a New Screen

1. Create file in `lib/screens/`
2. Follow the screen pattern with RouteAware mixin
3. Add navigation from parent screen using `Navigator.push()`

### Adding a New Widget

1. Create file in `lib/widgets/`
2. Accept data via constructor parameters
3. Use callbacks for user interactions (onTap, onSubmit, etc.)

### Modifying Theme

Edit `lib/theme/knockout_theme.dart` for app-wide styling.

## Testing

Tests are located in `test/`. Run with:

```bash
flutter test
```

Currently minimal test coverage - `widget_test.dart` contains a placeholder.

## Platform Support

| Platform | Status | Config Location |
|----------|--------|-----------------|
| Android  | Active | `android/` |
| iOS      | Active | `ios/` |
| Web      | Active | `web/` |
| Linux    | Active | `linux/` |
| Windows  | Active | `windows/` |
| macOS    | Active | `macos/` |

## Dependencies

Key packages (see `pubspec.yaml` for full list):

- `provider` - State management
- `dio` - HTTP client
- `json_annotation` / `json_serializable` - JSON serialization
- `flutter_secure_storage` - Secure token storage
- `flutter_bbcode` - BBCode rendering
- `cached_network_image` - Image caching
- `video_player` - Video playback
- `url_launcher` - External URL handling
- `font_awesome_flutter` - Icons

## IDE Setup

### VS Code

Launch configurations in `.vscode/launch.json`:
- Debug mode
- Profile mode
- Release mode

### Flutter Version

The project uses Flutter stable channel. FVM configuration in `.fvmrc`.

## Important Notes

1. **Always run build_runner** after modifying model classes
2. **Token handling is automatic** - API service intercepts responses for token refresh
3. **Use Provider** for state - avoid passing data through many widget layers
4. **RouteAware mixin** enables data refresh when returning to screens
5. **Check `isAuthenticated`** before making authenticated API calls
6. **Handle `CancelToken`** for paginated screens to avoid memory leaks

## Related Documentation

- `README.md` - Project overview and feature status
- `README_JSON.md` - Detailed JSON handling guide
- `SUBFORUM_FEATURE.md` - Subforum feature implementation details
