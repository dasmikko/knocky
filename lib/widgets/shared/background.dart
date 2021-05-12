import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';

class Background extends StatelessWidget {
  final String backgroundUrl;

  Background({@required this.backgroundUrl});

  @override
  Widget build(BuildContext context) {
    if (backgroundUrl == 'none.webp' || backgroundUrl.isEmpty) {
      return Container();
    }
    // TODO: apply brightness/contrast filter
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: "${KnockoutAPI.CDN_URL}/$backgroundUrl",
    );
  }
}
