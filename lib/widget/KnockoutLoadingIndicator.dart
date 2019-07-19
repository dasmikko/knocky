import 'dart:ui';

import 'package:flutter/material.dart';

class KnockoutLoadingIndicator extends StatefulWidget {
  final Widget child;
  final bool show;
  final bool blurBackground;

  KnockoutLoadingIndicator(
      {@required this.child, this.show = false, this.blurBackground = true});

  @override
  _KnockoutLoadingIndicatorState createState() =>
      _KnockoutLoadingIndicatorState();
}

class _KnockoutLoadingIndicatorState extends State<KnockoutLoadingIndicator>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  bool isHidden = false;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isHidden = false;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          isHidden = true;
        });
      }
    });
  }

  Widget blurredContent() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(color: Color.fromRGBO(0, 0, 0, 0.5), child: content()),
    );
  }

  Widget fadedContent() {
    return Container(color: Color.fromRGBO(0, 0, 0, 0.5), child: content());
  }

  Widget content() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Node graph out of date. Rebuilding...',
              style: TextStyle(fontSize: 14, fontFamily: 'RobotoMono'),
            ),
          ),
          CircularProgressIndicator()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.show) {
      controller.forward();
    } else {
      controller.reverse();
    }

    return Stack(
      children: <Widget>[
        this.widget.child,
        IgnorePointer(
          ignoring: !this.widget.show,
          child: FadeTransition(
              opacity: animation,
              child: this.widget.blurBackground
                  ? blurredContent()
                  : fadedContent()),
        ),
      ],
    );
  }
}
