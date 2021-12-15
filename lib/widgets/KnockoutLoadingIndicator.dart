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
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  bool isHidden = false;

  initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget blurredContent() {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
      ),
      child: Container(color: Color.fromRGBO(0, 0, 0, 0.5), child: content()),
    );
  }

  Widget fadedContent() {
    return Container(color: Color.fromRGBO(0, 0, 0, 0.5), child: content());
  }

  Widget content() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Image(width: 100, image: AssetImage('assets/logo.png')),
          ),
          Text(
            'Sending client info...',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
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
