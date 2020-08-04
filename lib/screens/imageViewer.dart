import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:knocky_edge/helpers/Download.dart';

class ImageViewerScreen extends StatefulWidget {
  final String url;
  final List<String> urls;
  final int postId;

  ImageViewerScreen({@required this.url, this.urls, this.postId = 0});

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
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
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: "Download image",
            onPressed: () async {
              //DownloadHelper().downloadFile(widget.url, _scaffoldKey);
            },
          ),
          IconButton(
            icon: Icon(Icons.content_copy),
            tooltip: "Copy image link",
            onPressed: () async {
              Clipboard.setData(
                  new ClipboardData(text: this.widget.urls[_currentPage]));
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text('Image link copied to clipboard'),
              ));
            },
          ),
        ],
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
            child: Hero(
              tag: this.widget.urls[index] + this.widget.postId.toString(),
              child: ZoomableWidget(
                minScale: 1.0,
                maxScale: 2.0,
                zoomSteps: 3,
                enableFling: true,
                autoCenter: true,
                multiFingersPan: false,
                bounceBackBoundary: true,
                onZoomChanged: (double zoom) {
                  if (zoom > 1.0 && !_isZooming) {
                    setState(() {
                      _isZooming = true;
                    });
                  }

                  if (zoom == 1.0 && _isZooming) {
                    setState(() {
                      _isZooming = false;
                    });
                  }
                },
                // default factor is 1.0, use 0.0 to disable boundary
                panLimit: 1.0,
                child: CachedNetworkImage(imageUrl: this.widget.urls[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
