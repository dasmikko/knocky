import 'package:audioplayers/audioplayers.dart';
import "package:flutter/material.dart";
import 'package:seekbar/seekbar.dart';
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
        if (this.mounted) {
          setState(() {
            audioDuration = p;
          });
        }
      }
    });
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      if (audioDuration != null) {
        if (this.mounted) {
          setState(() {
            currentPlayPosition =
                (p.inMilliseconds / audioDuration.inMilliseconds);
          });
        }
      }
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
        this.widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: Text('Link copied to clipboard'),
            ));
        break;
      case 2:
        DownloadHelper().downloadFile(url, this.widget.scaffoldKey);
        break;
    }
  }

  IconData playIcon() {
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
      margin: EdgeInsets.only(bottom: 15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          color: Colors.grey[800],
          padding: EdgeInsets.all(8),
          child: Container(
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    playIcon(),
                    size: 30,
                  ),
                  onPressed: () {
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
                        audioPlayer.seek(Duration(milliseconds: 0));
                        audioPlayer.resume();
                        break;
                    }
                  },
                ),
                Flexible(
                  child: SeekBar(
                    value: currentPlayPosition,
                    onProgressChanged: (double position) {
                      if (audioDuration != null) {
                        int positionInPercent = (position * 100).ceil();
                        double onePercent =
                            (audioDuration.inMilliseconds / 100);
                        int newMiliseconds =
                            (onePercent * positionInPercent).floor();
                        audioPlayer
                            .seek(Duration(milliseconds: newMiliseconds));
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 30,
                  ),
                  onPressed: () => onLongPress(context, this.widget.url),
                  highlightColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
