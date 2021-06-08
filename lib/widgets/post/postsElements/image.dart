import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/helpers/bbcodehelper.dart';
import 'package:knocky/screens/imageViewer.dart';
import 'package:measured_size/measured_size.dart';

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
  List<String> findAllImages() {
    List<String> urls = BBCodeHelper().getUrls(this.widget.bbcode);
    if (urls.length > 0) return urls;
    return [this.widget.url];
  }

  Size loadedImageSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ImageViewerScreen(
            url: this.widget.url,
            urls: findAllImages(),
            postId: widget.postId,
          ),
          opaque: false,
          transition: Transition.fadeIn,
        );
      },
      child: Hero(
        tag: this.widget.url + this.widget.postId.toString(),
        child: MeasuredSize(
          onChange: (Size size) {
            if (loadedImageSize == Size.zero && size != Size(100, 100)) {
              print('Image loaded, setting image size!');
              setState(() {
                loadedImageSize = size;
              });
            } else {
              print(loadedImageSize);
            }
          },
          child: Container(
            height:
                loadedImageSize != Size.zero ? loadedImageSize.height : null,
            width: loadedImageSize != Size.zero ? loadedImageSize.width : null,
            child: CachedNetworkImage(
              placeholder: (context, url) {
                return Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              },
              imageUrl: this.widget.url,
            ),
          ),
        ),
      ),
    );
  }
}
