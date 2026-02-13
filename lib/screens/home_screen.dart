import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:knocky/screens/events_screen.dart';
import 'package:knocky/screens/login_screen.dart';
import 'package:knocky/screens/latest_threads_screen.dart';
import 'package:knocky/screens/popular_threads_screen.dart';
import 'package:knocky/screens/search_screen.dart';
import 'package:knocky/screens/settings_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/role_colors.dart';
import '../models/motd.dart';
import '../services/update_service.dart';
import '../models/notification.dart';
import '../models/sync_data.dart';
import '../models/thread_ad.dart';
import '../services/deep_link_service.dart';
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';
import '../models/subforum.dart';
import '../main.dart';
import '../widgets/animated_content_switcher.dart';
import '../widgets/notifications_overlay.dart';
import '../widgets/subscriptions_overlay.dart';
import '../widgets/sliding_banner.dart';
import '../widgets/subforum_list_item.dart';
import 'subforum_screen.dart';
import 'thread_screen.dart';
import 'user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final GlobalKey _notificationButtonKey = GlobalKey();
  final GlobalKey _subscriptionsButtonKey = GlobalKey();
  List<Subforum>? _subforums;
  bool _isLoading = false;
  String? _errorMessage;
  List<KnockyNotification>? _notifications;
  OverlayEntry? _notificationOverlay;
  OverlayEntry? _subscriptionsOverlay;
  ThreadAd? _currentAd;
  Timer? _adRefreshTimer;
  bool _updateBannerDismissed = false;
  Motd? _motd;
  bool _motdVisible = false;

  static const _adRefreshDuration = Duration(minutes: 5);
  static const _motdDismissedKey = 'motd_dismissed';

  int get _unreadNotificationCount =>
      _notifications?.where((n) => !n.read).length ?? 0;

  int get _unreadSubscriptionsCount {
    final apiService = context.read<KnockoutApiService>();
    return apiService.syncData?.subscriptions
            .where((s) => s.unreadPosts > 0)
            .length ??
        0;
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSubforums();
    _loadNotificationCount();
    _loadRandomAd();
    _loadMotd();
    _adRefreshTimer = Timer.periodic(
      _adRefreshDuration,
      (_) => _loadRandomAd(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> _loadMotd() async {
    final apiService = context.read<KnockoutApiService>();
    try {
      final motd = await apiService.getMotd();
      if (!mounted || motd == null || motd.message.isEmpty) return;
      final dismissedId = await _storage.read(key: _motdDismissedKey);
      final dismissed = dismissedId != null && int.tryParse(dismissedId) != null
          ? int.parse(dismissedId) >= motd.id
          : false;
      setState(() {
        _motd = motd;
        _motdVisible = !dismissed;
      });
    } catch (_) {}
  }

  void _openMotdLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri != null) {
      final route = DeepLinkService.parseUri(uri);
      if (route != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => route));
        return;
      }
    }
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  Future<void> _dismissMotd() async {
    if (_motd == null) return;
    setState(() => _motdVisible = false);
    await _storage.write(key: _motdDismissedKey, value: _motd!.id.toString());
  }

  Future<void> _loadRandomAd() async {
    final apiService = context.read<KnockoutApiService>();
    final ad = await apiService.getRandomAd();
    if (mounted && ad != null) {
      setState(() => _currentAd = ad);
    }
  }

  Future<void> _loadNotificationCount() async {
    final apiService = context.read<KnockoutApiService>();
    if (!apiService.isAuthenticated) return;

    try {
      final notifications = await apiService.getNotifications();
      if (mounted) {
        setState(() => _notifications = notifications);
      }
    } catch (_) {}
  }

  Future<void> _loadSubforums() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<KnockoutApiService>();
      final settings = context.read<SettingsService>();
      final subforums = await apiService.getSubforums(
        showNsfw: settings.showNsfw,
      );
      setState(() {
        _subforums = subforums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _notificationOverlay?.remove();
    _subscriptionsOverlay?.remove();
    _adRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen
    _refreshSyncData();
    _loadNotificationCount();
    _loadMotd();
  }

  Future<void> _refreshSyncData() async {
    final apiService = context.read<KnockoutApiService>();
    if (apiService.isAuthenticated) {
      try {
        await apiService.getSyncData();
      } catch (_) {
        // Ignore errors - sync data will use cached version
      }
    }
  }

  void _toggleNotificationsOverlay() {
    if (_notificationOverlay != null) {
      _closeNotificationsOverlay();
    } else {
      _showNotificationsOverlay();
    }
  }

  void _showNotificationsOverlay() {
    final renderBox =
        _notificationButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _notificationOverlay = OverlayEntry(
      builder: (context) => NotificationsOverlay(
        onClose: _closeNotificationsOverlay,
        anchorPosition: position,
        anchorSize: size,
      ),
    );
    Overlay.of(context).insert(_notificationOverlay!);
  }

  void _closeNotificationsOverlay() {
    _notificationOverlay?.remove();
    _notificationOverlay = null;
    _loadNotificationCount();
  }

  void _toggleSubscriptionsOverlay() {
    if (_subscriptionsOverlay != null) {
      _closeSubscriptionsOverlay();
    } else {
      _showSubscriptionsOverlay();
    }
  }

  void _showSubscriptionsOverlay() {
    final renderBox =
        _subscriptionsButtonKey.currentContext?.findRenderObject()
            as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _subscriptionsOverlay = OverlayEntry(
      builder: (context) => SubscriptionsOverlay(
        onClose: _closeSubscriptionsOverlay,
        anchorPosition: position,
        anchorSize: size,
      ),
    );
    Overlay.of(context).insert(_subscriptionsOverlay!);
  }

  void _closeSubscriptionsOverlay() {
    _subscriptionsOverlay?.remove();
    _subscriptionsOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<KnockoutApiService>();
    final updateService = context.watch<UpdateService>();
    final syncData = apiService.syncData;
    final showUpdateBanner =
        updateService.availableUpdate != null && !_updateBannerDismissed;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (syncData != null) _buildSubscriptionsButton(),
          if (syncData != null) _buildNotificationButton(),
        ],
      ),
      body: Column(
        children: [
          if (_motd != null && _motd!.message.isNotEmpty)
            SlidingBanner(
              visible: _motdVisible,
              child: MaterialBanner(
                backgroundColor: Colors.blue,
                content: Text(
                  _motd!.message,
                  style: const TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.campaign, color: Colors.white),
                actions: [
                  TextButton(
                    onPressed: _dismissMotd,
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  if (_motd!.hasButton)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () => _openMotdLink(_motd!.buttonLink!),
                      child: Text(_motd!.buttonName!),
                    ),
                ],
              ),
            ),
          SlidingBanner(
            visible: showUpdateBanner,
            child: MaterialBanner(
              content: Text(
                'Update available — v${updateService.availableUpdate?.version ?? ''}',
              ),
              leading: const Icon(Icons.system_update),
              actions: [
                TextButton(
                  onPressed: () =>
                      setState(() => _updateBannerDismissed = true),
                  child: const Text('Dismiss'),
                ),
                TextButton(
                  onPressed: () => updateService.launchUpdate(),
                  child: const Text('Download'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      drawer: _buildDrawer(syncData, apiService),
    );
  }

  Widget _buildSubscriptionsButton() {
    final count = _unreadSubscriptionsCount;
    return Badge(
      key: _subscriptionsButtonKey,
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : count.toString()),
      offset: const Offset(-3, 5),
      child: IconButton(
        icon: const FaIcon(FontAwesomeIcons.newspaper, size: 20),
        onPressed: _toggleSubscriptionsOverlay,
      ),
    );
  }

  Widget _buildNotificationButton() {
    final count = _unreadNotificationCount;
    return Badge(
      key: _notificationButtonKey,
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : count.toString()),
      offset: const Offset(-3, 5),
      child: IconButton(
        icon: const FaIcon(FontAwesomeIcons.bell, size: 20),
        onPressed: _toggleNotificationsOverlay,
      ),
    );
  }

  Widget _buildDrawerHeader(SyncData? syncData) {
    if (syncData != null) {
      final avatarUrl = syncData.avatarUrl;
      final hasAvatar = avatarUrl.isNotEmpty && avatarUrl != 'none.webp';
      final bgUrl = syncData.backgroundUrl;
      final hasBg = bgUrl.isNotEmpty;

      return UserAccountsDrawerHeader(
        accountName: RoleColoredUsername(
          username: syncData.username,
          roleCode: syncData.role.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        accountEmail: const Text(''),
        currentAccountPicture: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserScreen(userId: syncData.id),
              ),
            );
          },
          child: CircleAvatar(
            backgroundImage: hasAvatar
                ? CachedNetworkImageProvider(
                    'https://cdn.knockout.chat/image/$avatarUrl',
                  )
                : null,
            child: hasAvatar ? null : const Icon(Icons.person, size: 36),
          ),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: hasBg
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    'https://cdn.knockout.chat/image/$bgUrl',
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

  Widget _buildDrawer(SyncData? syncData, KnockoutApiService apiService) {
    return Drawer(
      child: ListView(
        children: [
          _buildDrawerHeader(syncData),
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
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
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
          if (_currentAd != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: _currentAd!.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
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
                              builder: (context) => SearchScreen(
                                initialQuery: _currentAd!.query,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedContentSwitcher<List<Subforum>>(
      isLoading: _isLoading,
      data: _subforums,
      isEmpty: (data) => data.isEmpty,
      emptyWidget: const Center(child: Text('No subforums found')),
      errorMessage: _errorMessage,
      onRetry: _loadSubforums,
      contentBuilder: (subforums) => RefreshIndicator(
        onRefresh: _loadSubforums,
        child: ListView.builder(
          itemCount: subforums.length,
          itemBuilder: (context, index) {
            final subforum = subforums[index];
            final lastPost = subforum.lastPost;
            final threadInfo = lastPost?.threadInfo;
            return SubforumListItem(
              subforum: subforum,
              index: index,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubforumScreen(
                      subforumId: subforum.id,
                      subforumName: subforum.name,
                    ),
                  ),
                );
              },
              onLastPostTap: threadInfo != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThreadScreen(
                            threadId: threadInfo.id,
                            threadTitle: threadInfo.title,
                          ),
                        ),
                      );
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
