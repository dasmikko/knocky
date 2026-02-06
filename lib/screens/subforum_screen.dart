import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../models/subforum_response.dart';
import '../models/thread.dart' as thread_model;
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';
import '../widgets/animated_content_switcher.dart';
import '../widgets/bottom_paginator.dart';
import '../widgets/subforum_thread_list_item.dart';
import 'thread_screen.dart';

class SubforumScreen extends StatefulWidget {
  final int subforumId;
  final String subforumName;

  const SubforumScreen({
    super.key,
    required this.subforumId,
    required this.subforumName,
  });

  @override
  State<SubforumScreen> createState() => _SubforumScreenState();
}

class _SubforumScreenState extends State<SubforumScreen> {
  SubforumResponse? _subforumResponse;
  bool _isLoading = true;
  String? _error;
  late int _currentPage;
  late PageController _pageController;
  final Map<int, SubforumResponse> _pageCache = {};
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
    _loadSubforumData();
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

  Future<void> _loadSubforumData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await context.read<KnockoutApiService>().getSubforumWithThreads(
        widget.subforumId,
        _currentPage,
        showNsfw: context.read<SettingsService>().showNsfw,
      );
      _pageController.dispose();
      _pageController = PageController(initialPage: _currentPage - 1);
      setState(() {
        _subforumResponse = response;
        _pageCache[_currentPage] = response;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      log('Something failed', error: e, stackTrace: stackTrace);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<SubforumResponse?> _loadPage(int page) async {
    if (_pageCache.containsKey(page)) {
      return _pageCache[page];
    }

    _pageCancelToken?.cancel();
    _pageCancelToken = CancelToken();

    try {
      final response = await context.read<KnockoutApiService>().getSubforumWithThreads(
        widget.subforumId,
        page,
        showNsfw: context.read<SettingsService>().showNsfw,
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
    if (page >= 1 && page <= (_subforumResponse?.totalPages ?? 1)) {
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

  void _showThreadOptions(thread_model.Thread thread, int page) {
    final hasReadThread = thread.readThread != null;
    final totalPages = (thread.postCount / 20).ceil().clamp(1, 9999);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.last_page),
              title: const Text('Jump to page'),
              onTap: () {
                Navigator.pop(context);
                _showJumpToPageDialog(thread, totalPages);
              },
            ),
            if (hasReadThread)
              ListTile(
                leading: const Icon(Icons.mark_email_unread),
                title: const Text('Mark unread'),
                onTap: () async {
                  Navigator.pop(context);
                  final messenger = ScaffoldMessenger.of(this.context);
                  final success = await context.read<KnockoutApiService>().markThreadUnread(thread.id);
                  if (success && mounted) {
                    _pageCache.remove(page);
                    await _loadPage(page);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Thread marked as unread'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showJumpToPageDialog(thread_model.Thread thread, int totalPages) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '1 - $totalPages',
                labelText: 'Page number',
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value);
                if (page != null && page >= 1 && page <= totalPages) {
                  Navigator.pop(context);
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (context) => ThreadScreen(
                        threadId: thread.id,
                        threadTitle: thread.title,
                        page: page,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (context) => ThreadScreen(
                        threadId: thread.id,
                        threadTitle: thread.title,
                        page: totalPages,
                      ),
                    ),
                  );
                },
                child: Text('Go to last page ($totalPages)'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= totalPages) {
                Navigator.pop(context);
                Navigator.push(
                  this.context,
                  MaterialPageRoute(
                    builder: (context) => ThreadScreen(
                      threadId: thread.id,
                      threadTitle: thread.title,
                      page: page,
                    ),
                  ),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _subforumResponse?.totalPages ?? 1;
    final hasPagination = totalPages > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_subforumResponse?.subforum.name ?? widget.subforumName),
      ),
      body: AnimatedContentSwitcher<SubforumResponse>(
        isLoading: _isLoading,
        data: _subforumResponse,
        errorMessage: _error,
        onRetry: _loadSubforumData,
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
          : pageData.threads.isEmpty
              ? const Center(
                  key: ValueKey('empty'),
                  child: Text('No threads in this subforum'),
                )
              : _buildThreadList(page, pageData, hasPagination),
    );
  }

  Widget _buildThreadList(int page, SubforumResponse pageData, bool hasPagination) {
    final scrollController = _getScrollController(page);
    final bottomPadding = BottomPaginator.getBottomPadding(
      context,
      hasPagination: hasPagination,
    );

    return RefreshIndicator(
      key: ValueKey('list-$page'),
      onRefresh: () async {
        _pageCache.remove(page);
        await _loadPage(page);
      },
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: bottomPadding),
        itemCount: pageData.threads.length,
        itemBuilder: (context, index) {
          final thread = pageData.threads[index];
          return SubforumThreadListItem(
            thread: thread,
            onLongPress: () => _showThreadOptions(thread, page),
          );
        },
      ),
    );
  }
}
