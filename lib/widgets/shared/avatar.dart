import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String avatarUrl;
  final bool isBanned;
  final String imageEndpoint = 'https://cdn.knockout.chat/image/';

  Avatar({@required this.avatarUrl, @required this.isBanned});

  @override
  Widget build(BuildContext context) {
    if (isBanned) {
      return Container(); // todo: return banned placeholder
    } else if (avatarUrl == 'none.webp') {
      return Container(); // todo: ?
    }
    return CachedNetworkImage(imageUrl: "$imageEndpoint/$avatarUrl");
  }
}
