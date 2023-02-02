import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:path_provider/path_provider.dart';

class DownloadUpdateDialog extends StatefulWidget {
  final String title;
  final String? url;
  final String? fileName;

  const DownloadUpdateDialog(
      {this.title = 'Downloading update...', this.url = '', this.fileName = ''})
      : super();

  @override
  State<DownloadUpdateDialog> createState() => _DownloadUpdateDialogState();
}

class _DownloadUpdateDialogState extends State<DownloadUpdateDialog> {
  double progress = 0;
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    startDownload();
  }

  void startDownload() async {
    var tempDir = await getTemporaryDirectory();

    String fullPath = tempDir.path + "/" + this.widget.fileName!;
    Dio dio = new Dio();
    try {
      await dio.download(
        this.widget.url!,
        fullPath,
        cancelToken: cancelToken,
        onReceiveProgress: (fetchedBytes, totalBytes) {
          setState(() {
            progress = (fetchedBytes / totalBytes);
          });
        },
      );

      print('apk downloaded!');
      Get.back(result: fullPath);
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print('user canceled');
      }
      KnockySnackbar.error('Error while downloading update...');
      Get.back(result: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.widget.title),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: LinearProgressIndicator(
          value: progress,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              cancelToken.cancel('user canceled');
            },
            child: Text('Cancel')),
      ],
    );
  }
}
