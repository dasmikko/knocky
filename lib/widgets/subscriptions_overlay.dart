import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/sync_subscription.dart';
import '../services/knockout_api_service.dart';
import '../screens/subscriptions_screen.dart';
import '../screens/thread_screen.dart';

class SubscriptionsOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Offset anchorPosition;
  final Size anchorSize;

  const SubscriptionsOverlay({
    super.key,
    required this.onClose,
    required this.anchorPosition,
    required this.anchorSize,
  });

  @override
  State<SubscriptionsOverlay> createState() => _SubscriptionsOverlayState();
}

class _SubscriptionsOverlayState extends State<SubscriptionsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCirc,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInCirc,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animationController.reverse();
    widget.onClose();
  }

  List<SyncSubscription> get _unreadSubscriptions {
    final apiService = context.read<KnockoutApiService>();
    final subscriptions = apiService.syncData?.subscriptions ?? [];
    return subscriptions.where((s) => s.unreadPosts > 0).toList();
  }

  void _onSubscriptionTap(SyncSubscription subscription) {
    final lastPostNumber =
        subscription.threadPostCount - subscription.unreadPosts;
    final page = (lastPostNumber ~/ 20) + 1;
    widget.onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          threadId: subscription.threadId,
          threadTitle: subscription.threadTitle,
          page: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlayTop = widget.anchorPosition.dy + widget.anchorSize.height + 8;
    final overlayRight =
        MediaQuery.of(context).size.width -
        widget.anchorPosition.dx -
        widget.anchorSize.width;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: _close,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black26),
            ),
          ),
          // Overlay positioned under the subscriptions icon
          Positioned(
            top: overlayTop,
            right: overlayRight,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const Divider(height: 1),
                        Flexible(child: _buildContent()),
                        const Divider(height: 1),
                        _buildViewSubscriptionsButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.newspaper, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Subscriptions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _close,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final unread = _unreadSubscriptions;

    if (unread.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('No new posts', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: unread.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final subscription = unread[index];
        return _SubscriptionTile(
          subscription: subscription,
          onTap: () => _onSubscriptionTap(subscription),
        );
      },
    );
  }

  Widget _buildViewSubscriptionsButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () {
            widget.onClose();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionsScreen(),
              ),
            );
          },
          icon: const Icon(Icons.list, size: 18),
          label: const Text('View subscriptions'),
        ),
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final SyncSubscription subscription;
  final VoidCallback onTap;

  const _SubscriptionTile({required this.subscription, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final updatedAt = DateTime.tryParse(subscription.threadUpdatedAt);
    final timeAgoStr = updatedAt != null ? timeago.format(updatedAt) : '';

    return ListTile(
      onTap: onTap,
      tileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      title: Row(
        children: [
          Expanded(
            child: Text(
              subscription.threadTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              subscription.unreadPosts.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        timeAgoStr,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }
}
