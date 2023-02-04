import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';

class Avatar extends StatelessWidget {
  final String? avatarUrl;
  final bool? isBanned;

  Avatar({required this.avatarUrl, required this.isBanned});

  @override
  Widget build(BuildContext context) {
    if (isBanned!) {
      return Container(width: 40); // TODO: return banned placeholder
    } else if (avatarUrl == 'none.webp' || avatarUrl!.isEmpty) {
      return Container(width: 40);
    }
    return ExtendedImage.network(
      "${KnockoutAPI.CDN_URL}/$avatarUrl",
      clearMemoryCacheWhenDispose: true,
      cache: true,
      cacheWidth: 40,
    );
  }
}
