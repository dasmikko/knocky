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
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: CachedNetworkImage(
        placeholder: (context, url) {
          return Container(
            height: 100,
            width: 100,
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        },
        // TODO: On tapping image
        imageUrl: this.widget.url,
      ),
    );
  }
}
