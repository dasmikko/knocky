import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/containers.dart';

class Background extends StatelessWidget {
  final String backgroundUrl;

  Background({@required this.backgroundUrl});

  @override
  Widget build(BuildContext context) {
    if (backgroundUrl == 'none.webp' || backgroundUrl.isEmpty) {
      return Container();
    }
    return Container(
        decoration: Containers.getBackgroundDecoration(
            context, "${KnockoutAPI.CDN_URL}/$backgroundUrl"));
  }
}
