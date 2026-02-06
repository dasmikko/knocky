import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/thread_response.dart';
import '../models/thread_post.dart';
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';
import '../widgets/animated_content_switcher.dart';
import '../widgets/bbcode_editor/bbcode_editor.dart';
import '../widgets/bottom_paginator.dart';
import '../widgets/post_card.dart';
import '../widgets/post_sheets.dart';
import '../widgets/rating_picker_dialog.dart';
import 'user_screen.dart';

class ThreadScreen extends StatefulWidget {
  final int threadId;
  final String threadTitle;
  final int? page;

  const ThreadScreen({
    super.key,
    required this.threadId,
    required this.threadTitle,
    this.page,
  });

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  ThreadResponse? _threadResponse;
  bool _isLoading = true;
  String? _error;
  late int _currentPage;
  late PageController _pageController;
  final Map<int, ThreadResponse> _pageCache = {};
  CancelToken? _pageCancelToken;

  // Scroll tracking for paginator
  final Map<int, ScrollController> _scrollControllers = {};
  final Map<int, GlobalKey<RefreshIndicatorState>> _refreshIndicatorKeys = {};
  final BottomPaginatorController _paginatorController =
      BottomPaginatorController();

  // Subscription state
  bool _isSubscribed = false;
  bool _isTogglingSubscription = false;

  // FAB position tracking
  bool _isPaginatorVisible = true;

  // Debounce timer for marking thread as read
  Timer? _markAsReadTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.page ?? 1;
    _pageController = PageController(initialPage: _currentPage - 1);
    _paginatorController.onVisibilityChanged = (visible) {
      setState(() => _isPaginatorVisible = visible);
    };
    // Defer API calls to after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiService = context.read<KnockoutApiService>();
      setState(() {
        _isSubscribed = apiService.isSubscribedToThread(widget.threadId);
      });
      _loadThread();
    });
  }

  @override
  void dispose() {
    _pageCancelToken?.cancel();
    _markAsReadTimer?.cancel();
    _pageController.dispose();
    _paginatorController.onVisibilityChanged = null;
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  ScrollController _getScrollController(int page) {
    if (!_scrollControllers.containsKey(page)) {
      final controller = ScrollController();
      controller.addListener(() => _paginatorController.onScroll(controller));
      _scrollControllers[page] = controller;
    }
    return _scrollControllers[page]!;
  }

  GlobalKey<RefreshIndicatorState> _getRefreshIndicatorKey(int page) {
    if (!_refreshIndicatorKeys.containsKey(page)) {
      _refreshIndicatorKeys[page] = GlobalKey<RefreshIndicatorState>();
    }
    return _refreshIndicatorKeys[page]!;
  }

  Future<void> _loadThread() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<KnockoutApiService>();
      final response = await apiService.getThread(
        widget.threadId,
        _currentPage,
      );
      _pageController.dispose();
      _pageController = PageController(initialPage: _currentPage - 1);
      setState(() {
        _threadResponse = response;
        _pageCache[_currentPage] = response;
        _isLoading = false;
      });
      _markPageAsRead(response);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Refresh the current page with pull-to-refresh indicator
  Future<void> _refreshSilently() async {
    // Trigger the pull-to-refresh indicator
    _refreshIndicatorKeys[_currentPage]?.currentState?.show();
  }

  /// Actual refresh logic called by RefreshIndicator
  Future<void> _doRefresh(int page) async {
    try {
      final apiService = context.read<KnockoutApiService>();
      final response = await apiService.getThread(
        widget.threadId,
        page,
      );
      if (mounted) {
        setState(() {
          _threadResponse = response;
          _pageCache[page] = response;
        });
        _markPageAsRead(response);
      }
    } catch (_) {
      // Silently fail - keep existing data
    }
  }

  Future<ThreadResponse?> _loadPage(int page) async {
    if (_pageCache.containsKey(page)) {
      return _pageCache[page];
    }

    _pageCancelToken?.cancel();
    _pageCancelToken = CancelToken();

    try {
      final apiService = context.read<KnockoutApiService>();
      final response = await apiService.getThread(
        widget.threadId,
        page,
        cancelToken: _pageCancelToken,
      );
      if (!mounted) return null;
      setState(() {
        _pageCache[page] = response;
      });
      _markPageAsRead(response);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return null;
      return null;
    } catch (e) {
      return null;
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= (_threadResponse?.totalPages ?? 1)) {
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
    _paginatorController.onPageChanged();

    // Cancel any pending mark as read timer
    _markAsReadTimer?.cancel();

    // Debounce mark as read - only trigger after page has fully settled
    _markAsReadTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      final page = _pageController.page;
      // Check if page has fully settled (is a whole number)
      if (page != null && (page - page.roundToDouble()).abs() < 0.01) {
        timer.cancel();
        _markAsReadTimer = null;
        if (_pageCache.containsKey(_currentPage)) {
          _markPageAsRead(_pageCache[_currentPage]!);
        }
      }
    });

    if (!_pageCache.containsKey(_currentPage)) {
      _loadPage(_currentPage);
    }
  }

  void _markPageAsRead(ThreadResponse response) {
    if (response.posts.isEmpty) return;
    final apiService = context.read<KnockoutApiService>();
    if (!apiService.isAuthenticated) return;

    final lastPostOnPage = response.posts.last;
    final readThread = response.readThread;

    // If readThread is null, user has never read this thread - mark as read
    if (readThread == null) {
      apiService.markThreadRead(
        widget.threadId,
        lastPostOnPage.threadPostNumber,
      );
      return;
    }

    // No unread posts (firstUnreadId == -1 means all read)
    if (readThread.firstUnreadId == -1) return;

    // Only mark as read if this page contains the first unread post or later
    if (lastPostOnPage.id < readThread.firstUnreadId) return;

    apiService.markThreadRead(widget.threadId, lastPostOnPage.threadPostNumber);
  }

  Future<void> _toggleSubscription() async {
    final apiService = context.read<KnockoutApiService>();
    if (_isTogglingSubscription || !apiService.isAuthenticated) return;

    final wasSubscribed = _isSubscribed;
    setState(() => _isTogglingSubscription = true);

    bool success;
    if (_isSubscribed) {
      success = await apiService.unsubscribeFromThread(widget.threadId);
    } else {
      final lastPostId = _pageCache[_currentPage]?.posts.last.id ?? 0;
      success = await apiService.subscribeToThread(widget.threadId, lastPostId);
    }

    if (mounted) {
      setState(() {
        if (success) _isSubscribed = !_isSubscribed;
        _isTogglingSubscription = false;
      });

      final message = success
          ? (wasSubscribed
                ? 'Unsubscribed from thread'
                : 'Subscribed to thread')
          : (wasSubscribed ? 'Failed to unsubscribe' : 'Failed to subscribe');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> _showCreatePostSheet() async {
    final editorController = BbcodeEditorController();
    final apiService = context.read<KnockoutApiService>();
    final settingsService = context.read<SettingsService>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => CreatePostSheet(
        editorController: editorController,
        threadId: widget.threadId,
        apiService: apiService,
        settingsService: settingsService,
      ),
    );

    if (result == true && mounted) {
      // Clear cache and refresh to get updated page count
      _pageCache.clear();
      await _refreshSilently();
      // Go to the last page where the new post will appear
      final totalPages = _threadResponse?.totalPages ?? 1;
      if (_currentPage != totalPages) {
        _currentPage = totalPages;
        _pageController.jumpToPage(totalPages - 1);
        await _refreshSilently();
      }
      // Auto-subscribe if setting is enabled and not already subscribed
      if (settingsService.autoSubscribe && !_isSubscribed) {
        final lastPostNumber =
            _threadResponse?.posts.lastOrNull?.threadPostNumber ?? 1;
        final success =
            await apiService.subscribeToThread(widget.threadId, lastPostNumber);
        if (success && mounted) {
          setState(() => _isSubscribed = true);
        }
      }
      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = _scrollControllers[_currentPage];
        if (controller != null && controller.hasClients) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _editPost(ThreadPost post) async {
    final editorController = BbcodeEditorController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => EditPostSheet(
        editorController: editorController,
        postId: post.id,
        initialContent: post.content,
        apiService: context.read<KnockoutApiService>(),
      ),
    );

    if (result == true && mounted) {
      // Refresh the current page to show the updated post
      await _refreshSilently();
    }
  }

  Future<void> _quotePost(ThreadPost post) async {
    final editorController = BbcodeEditorController();

    // Strip existing quotes to prevent quote pyramids
    final strippedContent = stripQuotes(post.content);

    // Build the quote tag with all metadata
    final quoteTag =
        '[quote mentionsUser="${post.userId}" '
        'postId="${post.id}" '
        'threadPage="$_currentPage" '
        'threadId="${widget.threadId}" '
        'username="${post.user.username}"]'
        '$strippedContent'
        '[/quote]\n\n';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => CreatePostSheet(
        editorController: editorController,
        threadId: widget.threadId,
        apiService: context.read<KnockoutApiService>(),
        settingsService: context.read<SettingsService>(),
        initialContent: quoteTag,
      ),
    );

    if (result == true && mounted) {
      // Clear cache and refresh to get updated page count
      _pageCache.clear();
      await _refreshSilently();
      // Go to the last page where the new post will appear
      final totalPages = _threadResponse?.totalPages ?? 1;
      if (_currentPage != totalPages) {
        _currentPage = totalPages;
        _pageController.jumpToPage(totalPages - 1);
        await _refreshSilently();
      }
      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = _scrollControllers[_currentPage];
        if (controller != null && controller.hasClients) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _ratePost(
    ThreadPost post, {
    bool hasExistingRating = false,
  }) async {
    final apiService = context.read<KnockoutApiService>();
    if (!apiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to rate posts')),
      );
      return;
    }

    final result = await showRatingPickerDialog(
      context,
      showUnrate: hasExistingRating,
    );
    if (result == null || !mounted) return;

    bool success;
    String message;

    if (result.unrate) {
      success = await apiService.unratePost(post.id);
      message = success ? 'Rating removed' : 'Failed to remove rating';
    } else {
      success = await apiService.ratePost(post.id, result.rating!.code);
      message = success
          ? 'Rated as ${result.rating!.name}'
          : 'Failed to rate post';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
      if (success) {
        // Refresh the page to show updated ratings
        await _refreshSilently();
      }
    }
  }

  Widget _buildPostCard(ThreadPost post) {
    final apiService = context.watch<KnockoutApiService>();
    final userRating = _getUserRating(post.ratings);
    final isOwnPost = post.userId == apiService.syncData?.id;

    return PostCard(
      post: post,
      isAuthenticated: apiService.isAuthenticated,
      isOwnPost: isOwnPost,
      userRatingCode: userRating,
      onQuote: () => _quotePost(post),
      onEdit: () => _editPost(post),
      onRate: () => _ratePost(post, hasExistingRating: userRating != null),
      onShowRatingUsers: _showRatingUsers,
    );
  }

  void _showRatingUsers(
    String ratingName,
    String? ratingAssetPath,
    List<dynamic> users,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (ratingAssetPath != null)
                    Image.asset(
                      ratingAssetPath,
                      width: 24,
                      height: 24,
                      filterQuality: FilterQuality.high,
                    )
                  else
                    const Icon(Icons.star, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    ratingName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${users.length} ${users.length == 1 ? 'user' : 'users'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index] as Map<String, dynamic>;
                  final username = user['username'] as String? ?? 'Unknown';
                  final userId = user['id'] as int?;
                  final avatarUrl = user['avatarUrl'] as String?;
                  final hasAvatar =
                      avatarUrl != null &&
                      avatarUrl.isNotEmpty &&
                      avatarUrl != 'none.webp';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundImage: hasAvatar
                          ? CachedNetworkImageProvider(
                              'https://cdn.knockout.chat/image/$avatarUrl',
                            )
                          : null,
                      child: hasAvatar
                          ? null
                          : const Icon(Icons.person, size: 18),
                    ),
                    title: Text(username),
                    onTap: () {
                      Navigator.pop(context);
                      if (userId != null) {
                        Navigator.push(
                          this.context,
                          MaterialPageRoute(
                            builder: (context) => UserScreen(userId: userId),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if current user has rated a post and return the rating code
  String? _getUserRating(List<dynamic> postRatings) {
    final currentUserId = context.read<KnockoutApiService>().syncData?.id;
    if (currentUserId == null) return null;

    for (final r in postRatings) {
      final ratingData = r as Map<String, dynamic>;
      final users = ratingData['users'] as List<dynamic>? ?? [];
      for (final user in users) {
        final userId = (user as Map<String, dynamic>)['id'] as int?;
        if (userId == currentUserId) {
          return (ratingData['rating'] as String? ?? '').toLowerCase();
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = _threadResponse?.title ?? widget.threadTitle;
    final totalPages = _threadResponse?.totalPages ?? 1;
    final hasPagination = totalPages > 1;
    final apiService = context.watch<KnockoutApiService>();

    // Calculate FAB offset when paginator is visible
    final fabBottomOffset = hasPagination && _isPaginatorVisible
        ? BottomPaginator.paginatorHeight + 8
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (apiService.isAuthenticated)
            IconButton(
              icon: _isTogglingSubscription
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FaIcon(
                      _isSubscribed
                          ? FontAwesomeIcons.solidBell
                          : FontAwesomeIcons.bell,
                      size: 20,
                    ),
              onPressed: _isTogglingSubscription ? null : _toggleSubscription,
              tooltip: _isSubscribed ? 'Unsubscribe' : 'Subscribe',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final threadUrl =
                  'https://knockout.chat/thread/${widget.threadId}/$_currentPage';
              switch (value) {
                case 'refresh':
                  _refreshSilently();
                case 'share':
                  SharePlus.instance.share(
                    ShareParams(uri: Uri.parse(threadUrl)),
                  );
                case 'open_browser':
                  launchUrl(
                    Uri.parse(threadUrl),
                    mode: LaunchMode.externalApplication,
                  );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'open_browser',
                child: ListTile(
                  leading: Icon(Icons.open_in_browser),
                  title: Text('Open in browser'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: apiService.isAuthenticated && _threadResponse != null
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(bottom: fabBottomOffset),
              child: FloatingActionButton(
                onPressed: _showCreatePostSheet,
                tooltip: 'New Post',
                child: const FaIcon(FontAwesomeIcons.pen, size: 20),
              ),
            )
          : null,
      body: AnimatedContentSwitcher<ThreadResponse>(
        isLoading: _isLoading,
        data: _threadResponse,
        isEmpty: (data) => data.posts.isEmpty,
        emptyWidget: const Center(child: Text('No posts available')),
        errorMessage: _error,
        onRetry: _loadThread,
        contentBuilder: (response) => Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: totalPages,
              itemBuilder: (context, index) {
                return _buildPageContent(index + 1, hasPagination);
              },
            ),
            BottomPaginator(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChanged: _goToPage,
              controller: _paginatorController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int page, bool hasPagination) {
    final pageData = _pageCache[page];

    if (pageData == null) {
      _loadPage(page);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: pageData == null
          ? const Center(
              key: ValueKey('loading'),
              child: CircularProgressIndicator(),
            )
          : pageData.posts.isEmpty
              ? const Center(
                  key: ValueKey('empty'),
                  child: Text('No posts available'),
                )
              : _buildPostList(page, pageData, hasPagination),
    );
  }

  Widget _buildPostList(int page, ThreadResponse pageData, bool hasPagination) {
    final scrollController = _getScrollController(page);
    final bottomPadding = BottomPaginator.getBottomPadding(
      context,
      hasPagination: hasPagination,
    );

    return RefreshIndicator(
      key: _getRefreshIndicatorKey(page),
      onRefresh: () => _doRefresh(page),
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: bottomPadding),
        itemCount: pageData.posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(pageData.posts[index]);
        },
      ),
    );
  }
}
