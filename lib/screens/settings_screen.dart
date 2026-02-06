import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/firebase_options.dart';
import 'package:knocky/services/knockout_api_service.dart';
import 'package:knocky/services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showUpdateDialog(BuildContext context, UpdateService updateService) {
    final update = updateService.availableUpdate!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update available — v${update.version}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (update.releaseName.isNotEmpty &&
                  update.releaseName != update.version)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    update.releaseName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (update.body.isNotEmpty) Text(update.body),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              updateService.launchUpdate();
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showBaseUrlDialog(
    BuildContext context,
    SettingsService settings,
    KnockoutApiService apiService,
  ) {
    final controller = TextEditingController(text: settings.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Base URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://api.example.com',
            labelText: 'Base URL',
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                await settings.setBaseUrl(url);
                apiService.setBaseUrl(url);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final apiService = context.watch<KnockoutApiService>();
    final updateService = context.watch<UpdateService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _ThemeModeTile(
                currentMode: settings.themeMode,
                onChanged: (mode) => settings.setThemeMode(mode),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Content',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.visibility_off),
                title: const Text('Show NSFW Content'),
                subtitle: const Text('Display adult content in listings'),
                value: settings.showNsfw,
                onChanged: (value) => settings.setShowNsfw(value),
              ),
              SwitchListTile(
                secondary: const FaIcon(FontAwesomeIcons.flag, size: 20),
                title: const Text('FlagPunchy™'),
                subtitle: const Text('Show your country on your posts'),
                value: settings.showCountryFlags,
                onChanged: (value) => settings.setShowCountryFlags(value),
              ),
              SwitchListTile(
                secondary: const FaIcon(FontAwesomeIcons.bell, size: 20),
                title: const Text('AutoSub™'),
                subtitle: const Text('Subscribe to threads when you reply'),
                value: settings.autoSubscribe,
                onChanged: (value) => settings.setAutoSubscribe(value),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Privacy',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.analytics_outlined),
                title: const Text('Analytics'),
                subtitle: const Text(
                  'Help improve Knocky by sharing anonymous install data',
                ),
                value: settings.analyticsConsent,
                onChanged: (value) async {
                  await settings.setAnalyticsConsent(value);
                  if (value) {
                    await Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    );
                    await FirebaseAnalytics.instance
                        .setAnalyticsCollectionEnabled(true);
                  } else {
                    if (Firebase.apps.isNotEmpty) {
                      await FirebaseAnalytics.instance
                          .setAnalyticsCollectionEnabled(false);
                    }
                  }
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Advanced',
            children: [
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('API Base URL'),
                subtitle: Text(
                  settings.baseUrl,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _showBaseUrlDialog(context, settings, apiService),
              ),
              if (settings.baseUrl != KnockoutApiService.defaultBaseUrl)
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Reset to default'),
                  subtitle: Text(KnockoutApiService.defaultBaseUrl),
                  onTap: () async {
                    await settings.resetBaseUrl();
                    apiService.setBaseUrl(settings.baseUrl);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API URL reset to default'),
                        ),
                      );
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('Reset dismissed MOTD'),
                subtitle: const Text('Show the message of the day again'),
                onTap: () async {
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'motd_dismissed');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('MOTD will show again')),
                    );
                  }
                },
              ),
            ],
          ),
          if (apiService.isAuthenticated)
            _SettingsSection(
              title: 'Account',
              children: [
                ListTile(
                  title: Text('Logout'),
                  leading: const FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    size: 20,
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await apiService.clearToken();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Logged out'),
                            backgroundColor: Colors.blueGrey.shade700,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          _SettingsSection(
            title: 'About',
            children: [
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '...';
                  final buildNumber = snapshot.data?.buildNumber ?? '';
                  return ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Version'),
                    subtitle: Text(
                      buildNumber.isNotEmpty
                          ? '$version ($buildNumber)'
                          : version,
                    ),
                  );
                },
              ),
              ListTile(
                leading: updateService.isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        updateService.availableUpdate != null
                            ? Icons.system_update
                            : Icons.refresh,
                      ),
                title: const Text('Check for updates'),
                subtitle: Text(
                  updateService.isChecking
                      ? 'Checking...'
                      : updateService.availableUpdate != null
                      ? 'Update available (v${updateService.availableUpdate!.version})'
                      : updateService.error ?? 'Up to date',
                ),
                onTap: updateService.isChecking
                    ? null
                    : () async {
                        await updateService.checkForUpdate();
                        if (context.mounted &&
                            updateService.availableUpdate != null) {
                          _showUpdateDialog(context, updateService);
                        }
                      },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Open-source licenses'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Knocky',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A section header with grouped settings tiles
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Theme mode selection tile
class _ThemeModeTile extends StatelessWidget {
  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeModeTile({required this.currentMode, required this.onChanged});

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.light:
        return Icons.light_mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getThemeIcon(currentMode)),
      title: const Text('Theme'),
      subtitle: Text(currentMode.label),
      onTap: () => _showThemePicker(context),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            RadioGroup<AppThemeMode>(
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppThemeMode.values
                    .map(
                      (mode) => RadioListTile<AppThemeMode>(
                        value: mode,
                        title: Text(mode.label),
                        subtitle: Text(mode.description),
                        secondary: Icon(_getThemeIcon(mode)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
