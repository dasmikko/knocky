import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
      child: Container(
        height: loadedImageSize != Size.zero ? loadedImageSize.height : null,
        width: loadedImageSize != Size.zero ? loadedImageSize.width : null,
        child: Hero(
          tag: this.widget.url + this.widget.postId.toString(),
          child: CachedNetworkImage(
            imageBuilder: (context, imageProvider) {
              return MeasuredSize(
                onChange: (size) {
                  if (!hasCachedSize) {
                    var sizeMap = Map();
                    sizeMap['height'] = size.height;
                    sizeMap['width'] = size.width;
                    box.writeIfNull(this.widget.url, sizeMap);
                  }
                },
                child: Image(
                  image: imageProvider,
                ),
              );
            },
            placeholder: (context, url) => Container(
              height: hasCachedSize ? loadedImageSize.height : 100,
              width: hasCachedSize ? loadedImageSize.width : 100,
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
            imageUrl: this.widget.url,
          ),
        ),
      ),
    );
  }
}
