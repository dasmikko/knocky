import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/role_colors.dart';
import '../../models/sync_data.dart';
import '../../models/thread_ad.dart';
import '../../screens/events_screen.dart';
import '../../screens/latest_threads_screen.dart';
import '../../screens/ticker_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/popular_threads_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/user_screen.dart';
import '../../services/settings_service.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    this.syncData,
    this.currentAd,
  });

  final SyncData? syncData;
  final ThreadAd? currentAd;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          _HomeDrawerHeader(syncData: syncData),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.clock, size: 20),
            title: const Text('Latest threads'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LatestThreadsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.fire, size: 20),
            title: const Text('Popular threads'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PopularThreadsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20),
            title: const Text('Search'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.gear, size: 20),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.barsStaggered, size: 20),
            title: const Text('Ticker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TickerScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.calendar, size: 20),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventsScreen()),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.discord, size: 20),
            title: const Text('Discord'),
            onTap: () {
              Navigator.pop(context);
              launchUrl(
                Uri.parse('https://discord.gg/wjWpapC'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const Divider(),
          if (currentAd != null &&
              !context.watch<SettingsService>().disableAdInDrawer)
            _HomeDrawerAdTile(ad: currentAd!),
        ],
      ),
    );
  }
}

class _HomeDrawerHeader extends StatelessWidget {
  const _HomeDrawerHeader({this.syncData});

  final SyncData? syncData;

  @override
  Widget build(BuildContext context) {
    final data = syncData;
    if (data != null) {
      final avatarUrl = data.avatarUrl;
      final hasAvatar = avatarUrl.isNotEmpty && avatarUrl != 'none.webp';
      final bgUrl = data.backgroundUrl;
      final hasBg = bgUrl.isNotEmpty;

      return UserAccountsDrawerHeader(
        accountName: RoleColoredUsername(
          username: data.username,
          roleCode: data.role.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        accountEmail: const Text(''),
        currentAccountPicture: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserScreen(userId: data.id),
              ),
            );
          },
          child: CircleAvatar(
            backgroundImage: hasAvatar
                ? ExtendedNetworkImageProvider(
                    'https://cdn.knockout.chat/image/$avatarUrl',
                    cache: true,
                  )
                : null,
            child: hasAvatar ? null : const Icon(Icons.person, size: 36),
          ),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: hasBg
              ? DecorationImage(
                  image: ExtendedNetworkImageProvider(
                    'https://cdn.knockout.chat/image/$bgUrl',
                    cache: true,
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      );
    }

    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 80),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white),
            ),
            child: Text('Login'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeDrawerAdTile extends StatelessWidget {
  const _HomeDrawerAdTile({required this.ad});

  final ThreadAd ad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ExtendedImage.network(
            ad.imageUrl,
            cache: true,
            fit: BoxFit.contain,
            loadStateChanged: (state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                case LoadState.failed:
                  return const SizedBox.shrink();
                case LoadState.completed:
                  return null;
              }
            },
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchScreen(initialQuery: ad.query),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
