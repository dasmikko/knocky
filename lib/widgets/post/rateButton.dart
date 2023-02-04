import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

/// Info
///
/// The reason the rate button is it's own stateless widget, is to make the popover package to position itself correctly!

class RateButton extends StatelessWidget {
  final Widget? popOverContent;

  const RateButton({this.popOverContent});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showPopover(
          backgroundColor: Colors.grey[800]!,
          context: context,
          transitionDuration: const Duration(milliseconds: 150),
          bodyBuilder: (context) => popOverContent!,
          onPop: () => print('Popover was popped!'),
          direction: PopoverDirection.bottom,
          width: 300,
          //height: 400,
          arrowHeight: 15,
          arrowWidth: 30,
        );
      },
      child: Text(
        'Rate',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
