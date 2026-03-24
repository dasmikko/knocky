import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticker_event.dart';
import '../services/knockout_api_service.dart';
import '../widgets/animated_content_switcher.dart';
import '../widgets/ticker/ticker_event_item.dart';

class TickerScreen extends StatefulWidget {
  const TickerScreen({super.key});

  @override
  State<TickerScreen> createState() => _TickerScreenState();
}

class _TickerScreenState extends State<TickerScreen> {
  List<TickerEvent>? _events;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = context.read<KnockoutApiService>();
      final events = await api.getTickerEvents();
      setState(() {
        _events = events;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticker'),
      ),
      body: AnimatedContentSwitcher<List<TickerEvent>>(
        isLoading: _isLoading,
        data: _events,
        isEmpty: (data) => data.isEmpty,
        emptyWidget: const Center(child: Text('No events yet')),
        errorMessage: _errorMessage,
        onRetry: _loadEvents,
        contentBuilder: (events) => RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return TickerEventItem(event: events[index]);
            },
          ),
        ),
      ),
    );
  }
}
