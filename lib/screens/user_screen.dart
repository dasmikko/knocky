import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../data/ratings.dart';
import '../data/role_colors.dart';
import '../models/post.dart';
import '../models/thread_user.dart';
import '../models/user_posts_response.dart';
import '../models/user_profile.dart';
import '../models/user_threads_response.dart';
import '../services/knockout_api_service.dart';
import '../widgets/bbcode_renderer.dart';
import '../widgets/user_thread_list_item.dart';
import 'conversation_screen.dart';
import 'thread_screen.dart';

class UserScreen extends StatefulWidget {
  final int userId;

  const UserScreen({super.key, required this.userId});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  ThreadUser? _user;
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        context.read<KnockoutApiService>().getUser(widget.userId),
        context.read<KnockoutApiService>().getUserProfile(widget.userId),
      ]);
      setState(() {
        _user = results[0] as ThreadUser;
        _profile = results[1] as UserProfile?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date);
    } catch (e) {
      return '';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildHeader() {
    final headerUrl = _profile?.header;
    final hasHeader = headerUrl != null && headerUrl.isNotEmpty;

    final avatarUrl = _user!.avatarUrl;
    final hasAvatar = avatarUrl.isNotEmpty && avatarUrl != 'none.webp';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Header image
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            image: hasHeader
                ? DecorationImage(
                    image: CachedNetworkImageProvider(
                      'https://cdn.knockout.chat/image/$headerUrl',
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        // Avatar overlapping the header
        Positioned(
          bottom: -32,
          left: 16,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: CircleAvatar(
              radius: 29,
              backgroundImage: hasAvatar
                  ? CachedNetworkImageProvider(
                      'https://cdn.knockout.chat/image/$avatarUrl',
                    )
                  : null,
              child: hasAvatar ? null : const Icon(Icons.person, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username and role row
          Row(
            children: [
              Expanded(
                child: RoleColoredUsername(
                  username: _user!.username,
                  roleCode: _user!.role.code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Pronouns and title
          if (_user!.pronouns != null && _user!.pronouns!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _user!.pronouns!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
          if (_user!.title != null && _user!.title!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _user!.title!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Stats row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatItem(
                  Icons.calendar_today,
                  'Joined ${_formatDate(_user!.createdAt)}',
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.chat_bubble_outline,
                  '${_user!.posts} posts',
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.forum_outlined,
                  '${_user!.threads} threads',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bio
        if (_profile?.bio != null && _profile!.bio!.isNotEmpty) ...[
          const Text(
            'Bio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_profile!.bio!, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
        ],
        // Social links
        if (_profile?.social != null) ..._buildSocialLinks(),
      ],
    );
  }

  List<Widget> _buildSocialLinks() {
    final social = _profile!.social!;
    final links = <Widget>[];

    if (social.website != null && social.website!.isNotEmpty) {
      links.add(_buildSocialTile(
        Icons.language, 'Website', social.website!, social.website!,
      ));
    }

    if (social.steam != null && social.steam!.url != null && social.steam!.url!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.steam, 'Steam',
        social.steam!.name ?? 'Steam Profile',
        social.steam!.url!,
      ));
    }

    if (social.discord != null && social.discord!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.discord, 'Discord', social.discord!, '',
        onTap: () {
          Clipboard.setData(ClipboardData(text: social.discord!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied ${social.discord} to clipboard')),
          );
        },
      ));
    }

    if (social.github != null && social.github!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.github, 'GitHub',
        social.github!, 'https://github.com/${social.github}',
      ));
    }

    if (social.gitlab != null && social.gitlab!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.gitlab, 'GitLab',
        social.gitlab!, 'https://gitlab.com/${social.gitlab}',
      ));
    }

    if (social.twitter != null && social.twitter!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.xTwitter, 'Twitter',
        '@${social.twitter}', 'https://x.com/${social.twitter}',
      ));
    }

    if (social.bluesky != null && social.bluesky!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.bluesky, 'Bluesky',
        social.bluesky!, 'https://bsky.app/profile/${social.bluesky}',
      ));
    }

    if (social.fediverse != null && social.fediverse!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.mastodon, 'Fediverse', social.fediverse!, '',
        onTap: () {
          Clipboard.setData(ClipboardData(text: social.fediverse!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied ${social.fediverse} to clipboard')),
          );
        },
      ));
    }

    if (social.youtube != null && social.youtube!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.youtube, 'YouTube',
        social.youtube!, 'https://youtube.com/@${social.youtube}',
      ));
    }

    if (social.twitch != null && social.twitch!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.twitch, 'Twitch',
        social.twitch!, 'https://twitch.tv/${social.twitch}',
      ));
    }

    if (social.tumblr != null && social.tumblr!.isNotEmpty) {
      links.add(_buildSocialTile(
        FontAwesomeIcons.tumblr, 'Tumblr',
        social.tumblr!, 'https://${social.tumblr}.tumblr.com',
      ));
    }

    if (links.isEmpty) return [];

    return [
      const Text(
        'Social',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...links,
    ];
  }

  Widget _buildSocialTile(
    IconData icon,
    String label,
    String display,
    String url, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(display, style: const TextStyle(fontSize: 14)),
      subtitle: Text(label, style: const TextStyle(fontSize: 11)),
      onTap: onTap ?? (url.isNotEmpty ? () => _launchUrl(url) : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('Error: $_error', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.envelope, size: 20),
            tooltip: 'Send message',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(recipient: _user),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Profile header
            _buildHeader(),
            _buildUserInfo(),
            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Posts'),
                Tab(text: 'Threads'),
              ],
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(),
                  _UserPostsTab(userId: widget.userId),
                  _UserThreadsTab(userId: widget.userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Separate widget for user posts tab to manage its own state
class _UserPostsTab extends StatefulWidget {
  final int userId;

  const _UserPostsTab({required this.userId});

  @override
  State<_UserPostsTab> createState() => _UserPostsTabState();
}

class _UserPostsTabState extends State<_UserPostsTab>
    with AutomaticKeepAliveClientMixin {
  UserPostsResponse? _postsResponse;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  CancelToken? _cancelToken;
  final Map<int, UserPostsResponse> _pageCache = {};
  late PageController _pageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadPosts();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (_pageCache.containsKey(_currentPage)) {
      setState(() {
        _postsResponse = _pageCache[_currentPage];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getUserPosts(
        widget.userId,
        _currentPage,
        cancelToken: _cancelToken,
      );
      if (mounted) {
        setState(() {
          _postsResponse = response;
          _pageCache[_currentPage] = response;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<UserPostsResponse?> _loadPage(int page) async {
    if (_pageCache.containsKey(page)) {
      return _pageCache[page];
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getUserPosts(
        widget.userId,
        page,
        cancelToken: _cancelToken,
      );
      if (mounted) {
        setState(() {
          _pageCache[page] = response;
        });
      }
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return null;
      return null;
    } catch (e) {
      return null;
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= (_postsResponse?.totalPages ?? 1)) {
      _pageController.animateToPage(
        page - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
    });
    if (!_pageCache.containsKey(_currentPage)) {
      _loadPage(_currentPage);
    }
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'en_short');
    } catch (e) {
      return '';
    }
  }

  Widget _buildPostCard(Post post) {
    final threadInfo = post.threadInfo;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: threadInfo != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThreadScreen(
                      threadId: threadInfo.id,
                      threadTitle: threadInfo.title,
                      page: post.page,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thread info header
              if (threadInfo != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        threadInfo.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '#${post.threadPostNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(post.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const Divider(height: 16),
              ],
              // Post content
              BbcodeRenderer(
                content: post.content,
                postId: post.id,
              ),
              // Ratings
              if (post.ratings.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildRatings(post.ratings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatings(List<dynamic> postRatings) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: postRatings.take(5).map<Widget>((r) {
        final ratingData = r as Map<String, dynamic>;
        final code = (ratingData['rating'] as String? ?? '').toLowerCase();
        final count = ratingData['count'] as int? ?? 0;
        final rating = ratingMap[code];

        return Tooltip(
          message: '${rating?.name ?? code}: $count',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rating != null)
                  Image.asset(
                    rating.assetPath,
                    width: 14,
                    height: 14,
                    filterQuality: FilterQuality.high,
                  )
                else
                  const Icon(Icons.star, size: 12),
                const SizedBox(width: 3),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _refreshCurrentPage() async {
    _pageCache.remove(_currentPage);
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getUserPosts(
        widget.userId,
        _currentPage,
        cancelToken: _cancelToken,
      );
      if (mounted) {
        setState(() {
          _postsResponse = response;
          _pageCache[_currentPage] = response;
        });
      }
    } catch (_) {
      // Silently fail on refresh
    }
  }

  Widget _buildPageContent(int page) {
    final pageData = _pageCache[page];

    if (pageData == null) {
      _loadPage(page);
      return const Center(child: CircularProgressIndicator());
    }

    if (pageData.posts.isEmpty) {
      return const Center(child: Text('No posts'));
    }

    return RefreshIndicator(
      onRefresh: _refreshCurrentPage,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: pageData.posts.length,
        itemBuilder: (context, index) => _buildPostCard(pageData.posts[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && _postsResponse == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _postsResponse == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text('Error: $_error', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPosts, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_postsResponse == null || _postsResponse!.posts.isEmpty) {
      return const Center(child: Text('No posts yet'));
    }

    final totalPages = _postsResponse!.totalPages;
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: totalPages,
          itemBuilder: (context, index) => _buildPageContent(index + 1),
        ),
        // Pagination controls
        if (hasPagination)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () => _goToPage(_currentPage - 1)
                          : null,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_currentPage / $totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < totalPages
                          ? () => _goToPage(_currentPage + 1)
                          : null,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Separate widget for user threads tab to manage its own state
class _UserThreadsTab extends StatefulWidget {
  final int userId;

  const _UserThreadsTab({required this.userId});

  @override
  State<_UserThreadsTab> createState() => _UserThreadsTabState();
}

class _UserThreadsTabState extends State<_UserThreadsTab>
    with AutomaticKeepAliveClientMixin {
  UserThreadsResponse? _threadsResponse;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  CancelToken? _cancelToken;
  final Map<int, UserThreadsResponse> _pageCache = {};
  late PageController _pageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadThreads();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    if (_pageCache.containsKey(_currentPage)) {
      setState(() {
        _threadsResponse = _pageCache[_currentPage];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getUserThreads(
        widget.userId,
        _currentPage,
        cancelToken: _cancelToken,
      );
      if (mounted) {
        setState(() {
          _threadsResponse = response;
          _pageCache[_currentPage] = response;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<UserThreadsResponse?> _loadPage(int page) async {
    if (_pageCache.containsKey(page)) {
      return _pageCache[page];
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getUserThreads(
        widget.userId,
        page,
        cancelToken: _cancelToken,
      );
      if (mounted) {
        setState(() {
          _pageCache[page] = response;
        });
      }
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return null;
      return null;
    } catch (e) {
      return null;
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= (_threadsResponse?.totalPages ?? 1)) {
      _pageController.animateToPage(
        page - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
    });
    if (!_pageCache.containsKey(_currentPage)) {
      _loadPage(_currentPage);
    }
  }

  Future<void> _refreshCurrentPage() async {
    _pageCache.remove(_currentPage);
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getUserThreads(
        widget.userId,
        _currentPage,
        cancelToken: _cancelToken,
      );
      if (mounted) {
        setState(() {
          _threadsResponse = response;
          _pageCache[_currentPage] = response;
        });
      }
    } catch (_) {
      // Silently fail on refresh
    }
  }

  Widget _buildPageContent(int page) {
    final pageData = _pageCache[page];

    if (pageData == null) {
      _loadPage(page);
      return const Center(child: CircularProgressIndicator());
    }

    if (pageData.threads.isEmpty) {
      return const Center(child: Text('No threads'));
    }

    return RefreshIndicator(
      onRefresh: _refreshCurrentPage,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: pageData.threads.length,
        itemBuilder: (context, index) =>
            UserThreadListItem(thread: pageData.threads[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && _threadsResponse == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _threadsResponse == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text('Error: $_error', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadThreads, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_threadsResponse == null || _threadsResponse!.threads.isEmpty) {
      return const Center(child: Text('No threads yet'));
    }

    final totalPages = _threadsResponse!.totalPages;
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: totalPages,
          itemBuilder: (context, index) => _buildPageContent(index + 1),
        ),
        // Pagination controls
        if (hasPagination)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () => _goToPage(_currentPage - 1)
                          : null,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_currentPage / $totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < totalPages
                          ? () => _goToPage(_currentPage + 1)
                          : null,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
