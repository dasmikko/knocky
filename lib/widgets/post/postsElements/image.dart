import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/bbcodehelper.dart';
import 'package:knocky/screens/imageViewer.dart';
import 'package:measured_size/measured_size.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

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

  //final _imageWidgetKey = GlobalKey();
  bool imageIsLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage('sizeCache');
    Size loadedImageSize = Size.zero;
    final bool hasCachedSize = box.hasData(this.widget.url);

    // Check if we have cached the image size
    if (hasCachedSize) {
      Map cachedSize = box.read(this.widget.url);
      loadedImageSize = Size(
        cachedSize['width'],
        cachedSize['height'],
      );
    }

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
            child: CachedNetworkImage(
              key: ValueKey(this.widget.url),
              imageBuilder: (context, imageProvider) {
                return Container(
                  color: Colors.grey[900],
                  child: Image(
                    key: ValueKey(this.widget.url),
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
                );
              },
              placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                  height: 50,
                  width: 50),
              imageUrl: this.widget.url,
            ),
          ),
        ),
      ),
    );
  }
}
