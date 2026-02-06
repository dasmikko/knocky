import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/alerts_response.dart';
import '../services/knockout_api_service.dart';
import '../widgets/bottom_paginator.dart';
import '../widgets/thread_list_item.dart';
import 'thread_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  AlertsResponse? _alertsResponse;
  bool _isLoading = true;
  String? _error;
  late int _currentPage;
  late PageController _pageController;
  final Map<int, AlertsResponse> _pageCache = {};
  CancelToken? _pageCancelToken;

  // Scroll tracking for paginator
  final Map<int, ScrollController> _scrollControllers = {};
  final BottomPaginatorController _paginatorController =
      BottomPaginatorController();

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _pageController = PageController(initialPage: _currentPage - 1);
    _loadAlerts();
  }

  @override
  void dispose() {
    _pageCancelToken?.cancel();
    _pageController.dispose();
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

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await context.read<KnockoutApiService>().getAlerts(_currentPage);
      _pageController.dispose();
      _pageController = PageController(initialPage: _currentPage - 1);
      setState(() {
        _alertsResponse = response;
        _pageCache[_currentPage] = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<AlertsResponse?> _loadPage(int page) async {
    if (_pageCache.containsKey(page)) {
      return _pageCache[page];
    }

    _pageCancelToken?.cancel();
    _pageCancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getAlerts(
        page,
        cancelToken: _pageCancelToken,
      );
      if (!mounted) return null;
      setState(() {
        _pageCache[page] = response;
      });
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return null;
      return null;
    } catch (e) {
      return null;
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= (_alertsResponse?.totalPages ?? 1)) {
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
    if (!_pageCache.containsKey(_currentPage)) {
      _loadPage(_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscriptions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscriptions')),
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
                onPressed: _loadAlerts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_alertsResponse == null || _alertsResponse!.alerts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscriptions')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.bellSlash, size: 40, color: Colors.grey),
              SizedBox(height: 16),
              Text('No subscriptions'),
              SizedBox(height: 8),
              Text(
                'Subscribe to threads to see them here',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final totalPages = _alertsResponse?.totalPages ?? 1;
    final hasPagination = totalPages > 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions'), actions: [

        ],
      ),
      body: Stack(
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
    );
  }

  Widget _buildPageContent(int page, bool hasPagination) {
    final pageData = _pageCache[page];

    if (pageData == null) {
      _loadPage(page);
      return const Center(child: CircularProgressIndicator());
    }

    if (pageData.alerts.isEmpty) {
      return const Center(child: Text('No subscriptions on this page'));
    }

    final scrollController = _getScrollController(page);
    final bottomPadding = BottomPaginator.getBottomPadding(
      context,
      hasPagination: hasPagination,
    );

    return RefreshIndicator(
      onRefresh: () async {
        _pageCache.remove(page);
        await _loadPage(page);
      },
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: bottomPadding),
        itemCount: pageData.alerts.length,
        itemBuilder: (context, index) {
          final alert = pageData.alerts[index];
          final thread = alert.thread;
          return ThreadListItem(
            thread: thread,
            showCreatedTime: false,
            unreadPosts: alert.unreadPosts,
            onUnreadTap: () {
              final lastPostNumber = thread.postCount - alert.unreadPosts;
              final page = (lastPostNumber ~/ 20) + 1;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThreadScreen(
                    threadId: thread.id,
                    threadTitle: thread.title,
                    page: page,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
