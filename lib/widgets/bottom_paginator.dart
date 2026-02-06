import 'package:flutter/material.dart';

class BottomPaginatorController {
  _BottomPaginatorState? _state;
  bool _isVisible = true;
  ValueChanged<bool>? onVisibilityChanged;

  /// Whether the paginator is currently visible
  bool get isVisible => _isVisible;

  void _attach(_BottomPaginatorState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void _notifyVisibilityChanged(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      onVisibilityChanged?.call(visible);
    }
  }

  /// Call this when scroll position changes
  void onScroll(ScrollController scrollController) {
    _state?._onScroll(scrollController);
  }

  /// Call this when the page changes to reset visibility
  void onPageChanged() {
    _state?._onPageChanged();
  }
}

class BottomPaginator extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final BottomPaginatorController? controller;

  static const double paginatorHeight = 60.0;

  const BottomPaginator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.controller,
  });

  /// Returns the height needed for bottom padding in the list
  static double getBottomPadding(BuildContext context, {bool hasPagination = true}) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    if (!hasPagination) return bottomSafeArea;
    return paginatorHeight + bottomSafeArea + 16;
  }

  @override
  State<BottomPaginator> createState() => _BottomPaginatorState();
}

class _BottomPaginatorState extends State<BottomPaginator> {
  bool _isVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(BottomPaginator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  void _onScroll(ScrollController controller) {
    final currentOffset = controller.offset;
    final maxScroll = controller.position.maxScrollExtent;
    final isAtBottom = currentOffset >= maxScroll - 50;

    if (isAtBottom) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
        widget.controller?._notifyVisibilityChanged(true);
      }
    } else if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      if (_isVisible) {
        setState(() => _isVisible = false);
        widget.controller?._notifyVisibilityChanged(false);
      }
    } else if (currentOffset < _lastScrollOffset) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
        widget.controller?._notifyVisibilityChanged(true);
      }
    }

    _lastScrollOffset = currentOffset;
  }

  void _onPageChanged() {
    setState(() {
      _isVisible = true;
      _lastScrollOffset = 0;
    });
    widget.controller?._notifyVisibilityChanged(true);
  }

  Future<void> _showJumpToPageDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 - ${widget.totalPages}',
            labelText: 'Page number',
          ),
          onSubmitted: (value) {
            final page = int.tryParse(value);
            if (page != null && page >= 1 && page <= widget.totalPages) {
              Navigator.of(context).pop(page);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= widget.totalPages) {
                Navigator.of(context).pop(page);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );

    if (result != null) {
      widget.onPageChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalPages <= 1) return const SizedBox.shrink();

    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        offset: _isVisible ? Offset.zero : const Offset(0, 1),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomSafeArea),
            child: Container(
              height: BottomPaginator.paginatorHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: widget.currentPage > 1
                        ? () => widget.onPageChanged(widget.currentPage - 1)
                        : null,
                  ),
                  Text(
                    '${widget.currentPage} / ${widget.totalPages}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: widget.currentPage < widget.totalPages
                        ? () => widget.onPageChanged(widget.currentPage + 1)
                        : null,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showJumpToPageDialog,
                    icon: const Icon(Icons.shortcut, size: 18),
                    label: const Text('Jump'),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
