import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:measured_size/measured_size.dart';

class CachedSizeWidget extends StatefulWidget {
  final String id;
  final Widget child;

  CachedSizeWidget({this.child, this.id});

  @override
  _CachedSizeWidgetState createState() => _CachedSizeWidgetState();
}

class _CachedSizeWidgetState extends State<CachedSizeWidget> {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage('sizeCache');
    Size loadedWidgetSize = Size.zero;
    final bool hasCachedSize = box.hasData(this.widget.id);

    // Check if we have cached the image size
    if (hasCachedSize) {
      Map cachedSize = box.read(this.widget.id);
      loadedWidgetSize = Size(
        cachedSize['width'],
        cachedSize['height'],
      );
    }

    return Container(
      height: loadedWidgetSize != Size.zero ? loadedWidgetSize.height : null,
      width: loadedWidgetSize != Size.zero ? loadedWidgetSize.width : null,
      child: MeasuredSize(
        onChange: (size) {
          if (!hasCachedSize) {
            var sizeMap = Map();
            sizeMap['height'] = size.height;
            sizeMap['width'] = size.width;
            box.writeIfNull(this.widget.id, sizeMap);
          } else {
            print('size updated');
            print(this.widget.id + ' using cached size');
            if (loadedWidgetSize.height < size.height ||
                loadedWidgetSize.width < size.width) {
              print('Cache is smaller, update it');
              var sizeMap = Map();
              sizeMap['height'] = size.height;
              sizeMap['width'] = size.width;
              box.writeIfNull(this.widget.id, sizeMap);
            } else {
              print('Cache is up to date');
            }
          }
        },
        child: this.widget.child,
      ),
    );
  }
}
