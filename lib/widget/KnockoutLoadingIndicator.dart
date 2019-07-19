import 'dart:ui';

import 'package:flutter/material.dart';

class KnockoutLoadingIndicator extends StatefulWidget {
  final Widget child;
  bool show = false;

  KnockoutLoadingIndicator({this.child, this.show});

  @override
  _KnockoutLoadingIndicatorState createState() =>
      _KnockoutLoadingIndicatorState();
}

class _KnockoutLoadingIndicatorState extends State<KnockoutLoadingIndicator>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    /*animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      controller.forward();
    }
  });*/
//this will start the animation
  
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
        Positioned(
          child: FadeTransition(
            opacity: animation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Node graph out of date. Rebuilding...',
                          style:
                              TextStyle(fontSize: 14, fontFamily: 'RobotoMono'),
                        ),
                      ),
                      CircularProgressIndicator()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
