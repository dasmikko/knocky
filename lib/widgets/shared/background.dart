import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final String backgroundUrl;
  // todo: how can we have this as a const somewhere
  final String imageEndpoint = 'https://cdn.knockout.chat/image/';

  Background({@required this.backgroundUrl});

  @override
  Widget build(BuildContext context) {
    if (backgroundUrl == 'none.webp') {
      return Container();
    }
    // todo: apply brightness/contrast filter
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: "$imageEndpoint/$backgroundUrl",
    );
  }
}
