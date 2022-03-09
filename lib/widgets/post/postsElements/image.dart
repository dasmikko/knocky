import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/bbcodehelper.dart';
import 'package:knocky/screens/imageViewer.dart';

class ImageWidget extends StatefulWidget {
  final String url;
  final int postId;
  final String bbcode;

  ImageWidget({this.url, this.bbcode, this.postId});

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  List<String> findAllImages() {
    List<String> urls = BBCodeHelper().getUrls(this.widget.bbcode);
    if (urls.length > 0) return urls;
    return [this.widget.url];
  }

  //final _imageWidgetKey = GlobalKey();
  bool imageIsLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('image dispose');
    //CachedNetworkImage.evictFromCache(this.widget.url);
    clearMemoryImageCache(this.widget.url);

    super.dispose();
  }

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
        child: Container(
          width: 300,
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ExtendedImage.network(
              this.widget.url,
              key: ValueKey(this.widget.url),
              fit: BoxFit.cover,
              clearMemoryCacheWhenDispose: true,
            ),
          ),
        ),
      ),
    );
  }
}
