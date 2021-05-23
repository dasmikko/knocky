import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Containers {
  /// Given a URL returns a darkened filtered background image
  static BoxDecoration getBackgroundDecoration(
      BuildContext context, String imageUrl) {
    return BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25), BlendMode.dstATop),
          image: CachedNetworkImageProvider(imageUrl),
        ));
  }
}
