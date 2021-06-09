import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ffcache/ffcache.dart';
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

  @override
  Widget build(BuildContext context) {
    final box = GetStorage('sizeCache');
    Size loadedImageSize = Size.zero;

    // Check if we have cached the image size
    if (box.hasData(this.widget.url)) {
      print('Has size cache');
      Map cachedSize = box.read(this.widget.url);
      loadedImageSize = Size(
        cachedSize['width'],
        cachedSize['height'],
      );
    } else {
      print(this.widget.url);
      print('Has NOT size cache');
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
      child: MeasuredSize(
        onChange: (Size size) {
          if (loadedImageSize == Size.zero && size != Size(100, 100)) {
            print('Image loaded, setting image size!: ' + size.toString());
            setState(() {
              var sizeMap = Map();
              sizeMap['height'] = size.height;
              sizeMap['width'] = size.width;

              box.write(this.widget.url, sizeMap);
            });
          }
        },
        child: Container(
          height: loadedImageSize != Size.zero ? loadedImageSize.height : null,
          width: loadedImageSize != Size.zero ? loadedImageSize.width : null,
          child: Hero(
            tag: this.widget.url + this.widget.postId.toString(),
            child: CachedNetworkImage(
              placeholder: (context, url) {
                return Container(
                  height: loadedImageSize != Size.zero
                      ? loadedImageSize.height
                      : 100,
                  width: loadedImageSize != Size.zero
                      ? loadedImageSize.width
                      : 100,
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
