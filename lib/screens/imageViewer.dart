import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/widgets/CustomZoomWidget.dart';
import 'package:knocky/widgets/imageViewerBottomsheet.dart';
//import 'package:knocky_edge/helpers/Download.dart';

class ImageViewerScreen extends StatefulWidget {
  final String url;
  final List<String> urls;
  final int postId;

  ImageViewerScreen({@required this.url, this.urls, this.postId = 0});

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentPage = 0;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _currentPage = this.widget.urls.indexOf(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 0, 0),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(this.widget.urls[_currentPage]),
      ),
      body: PageView.builder(
        physics: !_isZooming
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        controller: PageController(
          initialPage: this.widget.urls.indexOf(widget.url),
        ),
        onPageChanged: (int newIndex) {
          setState(() {
            _currentPage = newIndex;
          });
        },
        itemCount: this.widget.urls.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: CustomZoomWidget(
              onZoomStateChange: (bool zoomState) {
                setState(() {
                  _isZooming = zoomState;
                });
              },
              child: Hero(
                tag: this.widget.urls[index] + this.widget.postId.toString(),
                child: ExtendedImage.network(this.widget.urls[index]),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: ImageViewerBottomSheet(
        currentPage: _currentPage,
        totalPages: this.widget.urls.length,
        url: this.widget.urls[_currentPage],
        embedType: 'img',
        scaffoldKey: _scaffoldKey,
      ),
    );
  }
}
