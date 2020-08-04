//import 'package:audioplayers/audioplayers.dart';
import "package:flutter/material.dart";
//import 'package:seekbar/seekbar.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
//import 'package:knocky_edge/helpers/Download.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:video_player/video_player.dart';

class AudioElement extends StatefulWidget {
  final String url;
  final GlobalKey<ScaffoldState> scaffoldKey;

  AudioElement({@required this.url, this.scaffoldKey});

  @override
  _AudioElementState createState() => _AudioElementState();
}

class _AudioElementState extends State<AudioElement> {
  //AudioPlayer audioPlayer;
  //AudioPlayerState currentState = AudioPlayerState.STOPPED;
  Size size = new Size(16, 9);
  Duration audioDuration;
  double currentPlayPosition = 0.0;

  VideoPlayerController videoPlayerController;
  ChewieAudioController chewieAudioController;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.network(this.widget.url);
    chewieAudioController = ChewieAudioController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieAudioController.dispose();
    super.dispose();
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
                child: const Text('Copy audio link'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: const Text('Download audio file'),
              ),
            ],
          );
        })) {
      case 1:
        Clipboard.setData(new ClipboardData(text: url));
        /*this.widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: Text('Link copied to clipboard'),
            ));*/
        break;
      case 2:
        //DownloadHelper().downloadFile(url, this.widget.scaffoldKey);
        break;
    }
  }

  IconData playIcon() {
    return Icons.play_arrow;
    /*
    switch (currentState) {
      case AudioPlayerState.PAUSED:
      case AudioPlayerState.STOPPED:
      case AudioPlayerState.COMPLETED:
        return Icons.play_arrow;
        break;
      case AudioPlayerState.PLAYING:
        return Icons.pause;
        break;
      default:
        return Icons.play_arrow;
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChewieAudio(
        controller: chewieAudioController,
      ),
    );
  }
}
