import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
//import 'package:knocky_edge/helpers/Download.dart';

class CustomZoomWidget extends StatefulWidget {
  final Widget? child;
  final Function? onZoomStateChange;

  CustomZoomWidget({this.child, this.onZoomStateChange});

  @override
  _CustomZoomWidgetState createState() => _CustomZoomWidgetState();
}

class _CustomZoomWidgetState extends State<CustomZoomWidget>
    with TickerProviderStateMixin {
  bool _isZooming = false;
  TransformationController? transformationController;
  Animation<Matrix4>? _animationZoom;
  late AnimationController _animationController;

  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    transformationController = new TransformationController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onZoomAnimation() {
    transformationController!.value = _animationZoom!.value;
    if (!_animationController.isAnimating) {
      _animationZoom!.removeListener(_onZoomAnimation);
      _animationZoom = null;
      _animationController.reset();
    }
  }

  void _handleTapDown(TapDownDetails details) async {
    print('tap tap tap');
    //final RenderBox referenceBox = context.findRenderObject();

    print(details);

    Timer onSingleTapTimer = Timer(Duration(milliseconds: 200), () {
      print('is single tap');
      setState(() {
        _tapCount = 0;
      });
    });

    if (_tapCount < 2) {
      print(_tapCount);
      setState(() {
        _tapCount++;
      });
    }

    if (_tapCount >= 2) {
      print('is Double tap');

      onSingleTapTimer.cancel();

      if (_animationController.isAnimating) {
        _animationController.reverse();
      }

      setState(() {
        _tapCount = 0;
      });

      double currentScale = transformationController!.value.getMaxScaleOnAxis();
      Matrix4 endTransform;

      if (currentScale == 1.0) {
        setState(() {
          _isZooming = true;
          this.widget.onZoomStateChange!(true);
        });
        endTransform = Matrix4Transform.from(transformationController!.value)
            .scale(3, origin: details.globalPosition)
            .matrix4;
      } else {
        setState(() {
          _isZooming = false;
          this.widget.onZoomStateChange!(false);
        });
        endTransform = Matrix4.identity();
      }

      _animationZoom = Matrix4Tween(
        begin: transformationController!.value,
        end: endTransform,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease,
      ));
      _animationZoom!.addListener(_onZoomAnimation);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InteractiveViewer(
        transformationController: transformationController,
        minScale: 1.0,
        panEnabled: true,
        maxScale: 3.0,
        onInteractionUpdate: (ScaleUpdateDetails update) {
          double currentScale =
              transformationController!.value.getMaxScaleOnAxis();
          if (currentScale > 1.0 && !_isZooming) {
            setState(() {
              _isZooming = true;
              this.widget.onZoomStateChange!(true);
            });
          } else if (currentScale <= 1.0 && _isZooming) {
            setState(() {
              _isZooming = false;
              this.widget.onZoomStateChange!(false);
            });
          }
        },
        child: GestureDetector(
          child: this.widget.child,
          onTapDown: _handleTapDown,
        ),
      ),
    );
  }
}
