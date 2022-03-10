import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:measured_size/measured_size.dart';

class CachedSizeWidget extends StatefulWidget {
  final String cacheId;
  final Function(BuildContext context, Size cachedSize) builder;
  final GetStorage box;

  CachedSizeWidget({this.builder, this.cacheId, this.box});

  @override
  _CachedSizeWidgetState createState() => _CachedSizeWidgetState();
}

class _CachedSizeWidgetState extends State<CachedSizeWidget> {
  @override
  Widget build(BuildContext context) {
    Size loadedWidgetSize = Size.zero;
    final bool hasCachedSize = this.widget.box.hasData(this.widget.cacheId);

    // Check if we have cached the image size
    if (hasCachedSize) {
      Map cachedSize = this.widget.box.read(this.widget.cacheId);
      //print('Found cached size: ' + cachedSize.toString());
      loadedWidgetSize = Size(
        cachedSize['width'],
        cachedSize['height'],
      );
    } else {
      //print('Found no cached size');
    }

    return MeasuredSize(
      onChange: (size) {
        if (!hasCachedSize) {
          var sizeMap = Map();
          sizeMap['height'] = size.height;
          sizeMap['width'] = size.width;
          this.widget.box.write(this.widget.cacheId, sizeMap);
        } else {
          if (loadedWidgetSize.height < size.height ||
              loadedWidgetSize.width < size.width) {
            var sizeMap = Map();
            sizeMap['height'] = size.height;
            sizeMap['width'] = size.width;
            this.widget.box.write(this.widget.cacheId, sizeMap);
          } else {
            //print('Cache is up to date');
          }
        }
      },
      child: this.widget.builder(context, loadedWidgetSize),
    );
  }
}
