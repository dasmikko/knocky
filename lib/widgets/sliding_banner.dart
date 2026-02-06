import 'package:flutter/material.dart';

/// A banner that slides in from the top and slides out when dismissed.
///
/// Set [visible] to true/false to animate the banner in/out.
/// The [child] is typically a [MaterialBanner].
class SlidingBanner extends StatefulWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SlidingBanner({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  State<SlidingBanner> createState() => _SlidingBannerState();
}

class _SlidingBannerState extends State<SlidingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(SlidingBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
      axisAlignment: -1.0,
      child: widget.child,
    );
  }
}
