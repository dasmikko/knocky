import 'package:audioplayers/audioplayers.dart';
import "package:flutter/material.dart";
import 'package:chewie/chewie.dart';
import 'package:seekbar/seekbar.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/Download.dart';

class AudioElement extends StatefulWidget {
  final String url;
  final GlobalKey<ScaffoldState> scaffoldKey;

  AudioElement({@required this.url, this.scaffoldKey});

  @override
  _AudioElementState createState() => _AudioElementState();
}

class _AudioElementState extends State<AudioElement> {
  AudioPlayer audioPlayer;
  AudioPlayerState currentState = AudioPlayerState.STOPPED;
  Size size = new Size(16, 9);
  Duration audioDuration;
  double currentPlayPosition = 0.0;

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((Duration p) {
      if (audioDuration == null) {
        setState(() {
         audioDuration = p;
        });
      }
      print('Full duration: ' + p.inSeconds.toString());
    });
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      if (audioDuration != null) {
        print((p.inMilliseconds / audioDuration.inMilliseconds));
        setState(() {
         currentPlayPosition = (p.inMilliseconds / audioDuration.inMilliseconds);
        });
      }
      print('current duration: ' + p.inSeconds.toString());

    });
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      setState(() {
       currentState = state;

       if (state == AudioPlayerState.COMPLETED) currentPlayPosition = 1.0;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
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

  IconData playIcon () {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onLongPress: () => this.onLongPress(context, this.widget.url),
        child: Container(
            child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                playIcon(),
                size: 50,
              ),
              onPressed: () {
                print(currentState.toString());
                switch (currentState) {
                  case AudioPlayerState.STOPPED:
                    audioPlayer.play(this.widget.url);
                    break;
                  case AudioPlayerState.PAUSED:
                    audioPlayer.resume();
                    break;
                  case AudioPlayerState.PLAYING:
                    audioPlayer.pause();
                    break;
                  case AudioPlayerState.COMPLETED:
                    audioPlayer.play(this.widget.url);
                    break;
                }

              },
            ),
            Flexible(
              child: SeekBar(
                value: currentPlayPosition,
              ),
            ),
          ],
        )),
      ),
    );
  }
}
