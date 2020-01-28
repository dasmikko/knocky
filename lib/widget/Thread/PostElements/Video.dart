import 'dart:typed_data';

import 'package:chewie_custom/chewie.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/Download.dart';
import 'package:video_player/video_player.dart';
import 'package:knocky/events.dart';

class VideoElement extends StatefulWidget {
  final String url;
  final GlobalKey<ScaffoldState> scaffoldKey;

  VideoElement({@required this.url, this.scaffoldKey});

  @override
  _VideoElementState createState() => _VideoElementState();
}

class _VideoElementState extends State<VideoElement> {
  VideoPlayerController vidController;
  ChewieController chewieController;
  Size size = new Size(16, 9);

  @override
  void initState() {
    super.initState();

    vidController = VideoPlayerController.network(widget.url);

    vidController
      ..initialize().then((onValue) {
        if (this.mounted) {
          setState(() {
            size = vidController.value.size;
            chewieController = ChewieController(
                videoPlayerController: vidController,
                aspectRatio: size.width / size.height,
                autoInitialize: false,
                deviceOrientationsDuringFullScreen: [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.portraitUp
                ],
                looping: true,
                autoPlay: false);

            chewieController.removeListener(chewieListener);
            chewieController.addListener(chewieListener);
          });
        }
      });

    chewieController = ChewieController(
        videoPlayerController: vidController,
        aspectRatio: size.width / size.height,
        autoInitialize: false,
        deviceOrientationsDuringFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp
        ],
        looping: true,
        autoPlay: false);
    chewieController.addListener(chewieListener);
  }

  void chewieListener() {
    print('Fullscreenstate is: ' + chewieController.isFullScreen.toString());
    // Listen for drawer open events
    eventBus.fire(HideBottomNavbarEvent(chewieController.isFullScreen));
  }

  @override
  void dispose() {
    super.dispose();
    chewieController.removeListener(chewieListener);
    chewieController.dispose();
    vidController.dispose();
  }

  void onLongPress(BuildContext context, String url) async {
    String fileName = basename(url);

    switch (await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(fileName),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: const Text('Copy video link'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: const Text('Download video'),
              ),
            ],
          );
        })) {
      case 1:
        Clipboard.setData(new ClipboardData(text: url));
        this.widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: Text('Image link copied to clipboard'),
            ));
        break;
      case 2:
        DownloadHelper().downloadFile(url, this.widget.scaffoldKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 2
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onLongPress: () => this.onLongPress(context, this.widget.url),
          child: Chewie(
            controller: chewieController,
          ),
        ),
      ),
    );
  }
}
