import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

class UserQuoteWidget extends StatefulWidget {
  final String username;
  final List<Widget> children;

  UserQuoteWidget({this.username, this.children});

  @override
  _UserQuoteWidgetState createState() => _UserQuoteWidgetState();
}

class _UserQuoteWidgetState extends State<UserQuoteWidget>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    Animation curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 0.5, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(UserQuoteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  void toggleUserQuote() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors(context);

    if (this._isOpen) {
      expandController.forward();
    } else {
      expandController.reverse();
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: appColors.userQuoteBodyBackground(),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      margin: EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: appColors.userQuoteHeaderBackground(),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                padding: EdgeInsets.all(10.0),
                child: Text(this.widget.username,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: this.widget.children,
                ),
              ),
            ]),
      ),
    );
  }
}
