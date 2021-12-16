import 'dart:math';
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

  List<String> messages = [
    'Reticulating Splines...',
    'Node Graph out of date. Rebuilding...',
    'Sending client info...',
    'hl2.exe is not responding...',
    'i see you.',
  ];
  int messageIndex = 0;

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
        Random random = new Random();
        int randomNumber = random.nextInt(messages.length);
        setState(() {
          isHidden = true;
          messageIndex = randomNumber;
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
            messages.elementAt(messageIndex),
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
