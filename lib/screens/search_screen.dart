import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subforum.dart';
import '../models/thread.dart' as thread_model;
import '../models/thread_search_response.dart';
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';
import '../widgets/subforum_thread_list_item.dart';
import 'thread_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _titleController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  ThreadSearchResponse? _searchResponse;
  int _currentPage = 1;

  // Filter state
  List<Subforum>? _subforums;
  int? _selectedSubforumId;
  String _sortBy = 'relevance';
  String _sortOrder = 'desc';
  bool _showLocked = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _titleController.text = widget.initialQuery!;
      _search();
    }
    _loadSubforums();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSubforums() async {
    try {
      final api = context.read<KnockoutApiService>();
      final settings = context.read<SettingsService>();
      final subforums = await api.getSubforums(showNsfw: settings.showNsfw);
      if (mounted) {
        setState(() => _subforums = subforums);
      }
    } catch (_) {}
  }

  Future<void> _search({int page = 1}) async {
    final query = _titleController.text.trim();
    if (query.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search query must be at least 5 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = page;
    });

    try {
      final api = context.read<KnockoutApiService>();
      final response = await api.searchThreads(
        title: query,
        page: page,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        locked: _showLocked,
        subforumId: _selectedSubforumId,
      );
      if (mounted) {
        setState(() {
          _searchResponse = response;
          _hasSearched = true;
          _isLoading = false;
        });
        _scrollController.jumpTo(0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _hasSearched = true;
          _isLoading = false;
        });
      }
    }
  }

  void _showThreadOptions(thread_model.Thread thread) {
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
    final response = _searchResponse;
    final showPagination = _hasSearched && !_isLoading && _error == null &&
        response != null && response.threads.isNotEmpty && response.totalPages > 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSearchFormSliver(),
                _buildResultsSliver(),
              ],
            ),
          ),
          if (showPagination)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => _search(page: _currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$_currentPage / ${response.totalPages}'),
                  IconButton(
                    onPressed: _currentPage < response.totalPages
                        ? () => _search(page: _currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchFormSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Thread title',
                hintText: 'Enter at least 5 characters',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _selectedSubforumId,
                    decoration: const InputDecoration(
                      labelText: 'Subforum',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any subforum')),
                      if (_subforums != null)
                        ..._subforums!.map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name, overflow: TextOverflow.ellipsis),
                            )),
                    ],
                    onChanged: (value) => setState(() => _selectedSubforumId = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'relevance', child: Text('Relevance')),
                      DropdownMenuItem(value: 'updated_at', child: Text('Updated')),
                      DropdownMenuItem(value: 'created_at', child: Text('Created')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _sortBy = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortOrder,
                    decoration: const InputDecoration(
                      labelText: 'Order',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'desc', child: Text('Descending')),
                      DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                    ],
                    onChanged: _sortBy == 'relevance'
                        ? null
                        : (value) {
                            if (value != null) setState(() => _sortOrder = value);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Show locked threads'),
                    value: _showLocked,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) => setState(() => _showLocked = value),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isLoading ? null : () => _search(),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Searching...' : 'Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSliver() {
    if (!_hasSearched) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Could not search. Try again in a few moments.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _search(page: _currentPage),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final response = _searchResponse;
    if (response == null || response.threads.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No threads found')),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${response.totalThreads} result${response.totalThreads == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (response.totalPages > 1)
                  Text(
                    'Page $_currentPage of ${response.totalPages}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: response.threads.length,
          itemBuilder: (context, index) {
            final thread = response.threads[index];
            return SubforumThreadListItem(
              thread: thread,
              onLongPress: () => _showThreadOptions(thread),
            );
          },
        ),
      ],
    );
  }
}
