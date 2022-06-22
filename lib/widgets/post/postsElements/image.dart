import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/bbcodehelper.dart';
import 'package:knocky/screens/imageViewer.dart';
import 'package:measure_size/measure_size.dart';

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
  Size imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('image dispose');
    clearMemoryImageCache(this.widget.url);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage('sizeCache');
    Size loadedWidgetSize = Size.zero;
    final bool hasCachedSize = box.hasData(this.widget.url);

    // Check if we have cached the image size
    if (hasCachedSize) {
      Map cachedSize = box.read(this.widget.url);
      //print('Found cached size: ' + cachedSize.toString());
      loadedWidgetSize = Size(
        cachedSize['width'],
        cachedSize['height'],
      );
    } else {
      //print('Found no cached size');
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
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 400),
          child: ExtendedImage.network(
            this.widget.url,
            key: ValueKey(this.widget.url),
            cache: true,
            shape: BoxShape.rectangle,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
            compressionRatio: 0.2,
            clearMemoryCacheWhenDispose: true,
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return Container(
                    height: loadedWidgetSize != Size.zero
                        ? loadedWidgetSize.height
                        : null,
                    width: 300,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  break;
                case LoadState.completed:
                  return MeasureSize(
                    onChange: (size) {
                      if (!hasCachedSize) {
                        var sizeMap = Map();
                        sizeMap['height'] = size.height;
                        sizeMap['width'] = size.width;
                        box.writeIfNull(this.widget.url, sizeMap);
                      } else {
                        print('mesured size updated ' + size.toString());
                        print(this.widget.url + ' using cached size');
                        if (loadedWidgetSize.height < size.height ||
                            loadedWidgetSize.width < size.width) {
                          print('Cache is smaller, update it');
                          var sizeMap = Map();
                          sizeMap['height'] = size.height;
                          sizeMap['width'] = size.width;
                          box.writeIfNull(this.widget.url, sizeMap);
                        } else {
                          print('Cache is up to date');
                        }
                      }
                    },
                    child: ExtendedRawImage(
                      image: state.extendedImageInfo?.image,
                    ),
                  );
                  break;
                default:
                  return null;
              }
            },
          ),
        ),
      ),
    );
  }
}
