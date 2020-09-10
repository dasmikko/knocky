import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
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
  TransformationController transformationController;
  Animation<Matrix4> _animationZoom;
  AnimationController _animationController;

  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    transformationController = new TransformationController();
    _currentPage = this.widget.urls.indexOf(widget.url);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onZoomAnimation() {
    transformationController.value = _animationZoom.value;
    if (!_animationController.isAnimating) {
      _animationZoom?.removeListener(_onZoomAnimation);
      _animationZoom = null;
      _animationController.reset();
    }
  }

  void _handleTapDown(TapDownDetails details) async {
    print('tap tap tap');
    final RenderBox referenceBox = context.findRenderObject();

    print(details);

    Timer onSingleTapTimer = Timer(Duration(milliseconds: 200), () {
      print('is single tap');
      setState(() {
        _tapCount = 0;
      });
    });

    if (_tapCount < 2) {
      print(_tapCount);
      setState(() {
        _tapCount++;
      });
    }

    if (_tapCount >= 2) {
      print('is Double tap');

      onSingleTapTimer.cancel();

      if (_animationController.isAnimating) {
        _animationController.reverse();
      }

      setState(() {
        _tapCount = 0;
      });

      double currentScale = transformationController.value.getMaxScaleOnAxis();
      Matrix4 endTransform;

      if (currentScale == 1.0) {
        setState(() {
          _isZooming = true;
        });
        endTransform = Matrix4Transform.from(transformationController.value)
            .scale(3, origin: details.globalPosition)
            .matrix4;
      } else {
        setState(() {
          _isZooming = false;
        });
        endTransform = Matrix4.identity();
      }

      _animationZoom = Matrix4Tween(
        begin: transformationController.value,
        end: endTransform,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease,
      ));
      _animationZoom.addListener(_onZoomAnimation);
      _animationController.forward();
    }
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
              child: InteractiveViewer(
                transformationController: transformationController,
                minScale: 1.0,
                panEnabled: true,
                maxScale: 3.0,
                onInteractionUpdate: (ScaleUpdateDetails update) {
                  if (update.scale > 1.0 && !_isZooming) {
                    setState(() {
                      _isZooming = true;
                    });
                  } else if (update.scale < 1.0 && _isZooming) {
                    setState(() {
                      _isZooming = false;
                    });
                  }
                },
                child: GestureDetector(
                  child: CachedNetworkImage(imageUrl: this.widget.urls[index]),
                  onTapDown: _handleTapDown,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
