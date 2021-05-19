import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  final String url;
  final int postId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String bbcode;

  ImageWidget({this.url, this.scaffoldKey, this.bbcode, this.postId});

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CachedNetworkImage(
        // TODO: Placeholder
        // TODO: On tapping image
        height: 300,
        imageUrl: this.widget.url,
      ),
    );
  }
}
