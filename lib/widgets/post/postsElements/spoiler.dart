import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bbob_dart/bbob_dart.dart';

class SpoilerWidget extends StatefulWidget {
  final Node node;
  final Function handleNodes;
  final BuildContext parentContext;
  final TextStyle textStyle;

  const SpoilerWidget(
      this.node, this.handleNodes, this.parentContext, this.textStyle,
      {Key? key})
      : super(key: key);

  @override
  State<SpoilerWidget> createState() => _SpoilerWidgetState();
}

class _SpoilerWidgetState extends State<SpoilerWidget> {
  bool showSpoiler = false;
  late TextStyle hiddenStyle;
  late TextStyle visibleStyle;

  @override
  void initState() {
    super.initState();

    hiddenStyle = widget.textStyle.copyWith();
    visibleStyle =
        widget.textStyle.copyWith(backgroundColor: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      text: widget.node.textContent,
      style: showSpoiler ? visibleStyle : hiddenStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          print('on spoiler tap');
          setState(() {
            showSpoiler = !showSpoiler;
          });
        },
    ));
  }
}
