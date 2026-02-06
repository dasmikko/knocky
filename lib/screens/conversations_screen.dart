import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../models/thread_user.dart';
import '../services/knockout_api_service.dart';
import '../widgets/conversation_list_item.dart';
import 'conversation_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Conversation>? _conversations;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversations = await context.read<KnockoutApiService>().getConversations();
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showNewConversationDialog() async {
    final user = await showDialog<ThreadUser>(
      context: context,
      builder: (context) => const _UserSearchDialog(),
    );

    if (user != null && mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(recipient: user),
        ),
      );

      if (result == true) {
        _loadConversations();
      }
    }
  }

  void _showConversationOptions(Conversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.trash, size: 20, color: Colors.red),
              title: const Text(
                'Delete conversation',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteConversation(conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteConversation(Conversation conversation) async {
    final currentUserId = context.read<KnockoutApiService>().syncData?.id ?? 0;
    final otherUsers = conversation.getOtherUsers(currentUserId);
    final displayName = otherUsers.isNotEmpty
        ? otherUsers.map((u) => u.username).join(', ')
        : 'this user';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation'),
        content: Text(
          'Are you sure you want to delete the conversation with $displayName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<KnockoutApiService>().archiveConversation(conversation.id);
      if (mounted) {
        if (success) {
          _loadConversations();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete conversation'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<KnockoutApiService>().syncData?.id ?? 0;

    if (!context.read<KnockoutApiService>().isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Please log in to view messages')),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
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
                onPressed: _loadConversations,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations == null || _conversations!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('No conversations')),
        floatingActionButton: FloatingActionButton(
          onPressed: _showNewConversationDialog,
          child: const FaIcon(FontAwesomeIcons.pen, size: 20),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: 8,
            bottom: 8 + MediaQuery.of(context).viewPadding.bottom,
          ),
          itemCount: _conversations!.length,
          itemBuilder: (context, index) {
            final conversation = _conversations![index];
            return ConversationListItem(
              conversation: conversation,
              currentUserId: currentUserId,
              onLongPress: () => _showConversationOptions(conversation),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewConversationDialog,
        child: const FaIcon(FontAwesomeIcons.pen, size: 20),
      ),
    );
  }
}

class _UserSearchDialog extends StatefulWidget {
  const _UserSearchDialog();

  @override
  State<_UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<_UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ThreadUser>? _searchResults;
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await context.read<KnockoutApiService>().searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Message'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a user...',
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
                        onPressed: _search,
                      ),
              ),
              onSubmitted: (_) => _search(),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_searchResults != null) ...[
              const SizedBox(height: 16),
              if (_searchResults!.isEmpty)
                const Text('No users found')
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults!.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults![index];
                      final avatarUrl = user.avatarUrl;
                      final hasAvatar =
                          avatarUrl.isNotEmpty && avatarUrl != 'none.webp';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: hasAvatar
                              ? CachedNetworkImageProvider(
                                  'https://cdn.knockout.chat/image/$avatarUrl',
                                )
                              : null,
                          child: hasAvatar ? null : const Icon(Icons.person),
                        ),
                        title: Text(user.username),
                        onTap: () => Navigator.pop(context, user),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
