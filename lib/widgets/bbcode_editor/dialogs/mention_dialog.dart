import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/role_colors.dart';
import '../../../models/thread_user.dart';
import '../../../services/knockout_api_service.dart';

/// Dialog result for mention selection
class MentionDialogResult {
  final int userId;
  final String username;
  final String? roleCode;

  MentionDialogResult({
    required this.userId,
    required this.username,
    this.roleCode,
  });
}

/// Shows a dialog to search and select a user for @mention
Future<MentionDialogResult?> showMentionDialog(BuildContext context) {
  return showDialog<MentionDialogResult>(
    context: context,
    builder: (context) => const _MentionDialog(),
  );
}

class _MentionDialog extends StatefulWidget {
  const _MentionDialog();

  @override
  State<_MentionDialog> createState() => _MentionDialogState();
}

class _MentionDialogState extends State<_MentionDialog> {
  final _searchController = TextEditingController();
  List<ThreadUser>? _results;
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(query.trim());
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results =
          await context.read<KnockoutApiService>().searchUsers(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Search failed';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mention User'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search username',
                hintText: 'Start typing...',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              autofocus: true,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _buildResults(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_error!, style: TextStyle(color: Colors.red.shade400)),
      );
    }

    if (_results == null) {
      return const SizedBox.shrink();
    }

    if (_results!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No users found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _results!.length,
      itemBuilder: (context, index) {
        final user = _results![index];
        final hasAvatar =
            user.avatarUrl.isNotEmpty && user.avatarUrl != 'none.webp';

        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundImage: hasAvatar
                ? ExtendedNetworkImageProvider(
                    'https://cdn.knockout.chat/image/${user.avatarUrl}',
                  )
                : null,
            child: hasAvatar ? null : const Icon(Icons.person, size: 16),
          ),
          title: RoleColoredUsername(
            username: user.username,
            roleCode: user.role.code,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          onTap: () => Navigator.of(context).pop(
            MentionDialogResult(
              userId: user.id,
              username: user.username,
              roleCode: user.role.code,
            ),
          ),
        );
      },
    );
  }
}
