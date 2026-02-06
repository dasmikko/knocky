import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/thread.dart' as thread_model;
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';
import '../widgets/thread_list_item.dart';

class LatestThreadsScreen extends StatefulWidget {
  const LatestThreadsScreen({super.key});

  @override
  State<LatestThreadsScreen> createState() => _LatestThreadsScreenState();
}

class _LatestThreadsScreenState extends State<LatestThreadsScreen> {
  List<thread_model.Thread>? _threads;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLatestThreads();
  }

  Future<void> _loadLatestThreads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final threads = await context.read<KnockoutApiService>().getLatestThreads(
        showNsfw: context.read<SettingsService>().showNsfw,
      );
      setState(() {
        _threads = threads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Latest Threads')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Latest Threads')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLatestThreads,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_threads == null || _threads!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Latest Threads')),
        body: const Center(child: Text('No latest threads found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Latest Threads')),
      body: RefreshIndicator(
        onRefresh: _loadLatestThreads,
        child: ListView.builder(
          itemCount: _threads!.length,
          itemBuilder: (context, index) {
            return ThreadListItem(
              thread: _threads![index],
              showCreatedTime: true,
            );
          },
        ),
      ),
    );
  }
}
