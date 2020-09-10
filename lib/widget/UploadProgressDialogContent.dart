import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:knocky_edge/helpers/ImgurHelper.dart';

typedef void OnFinishedUploading(String imageUrl);

class UploadProgressDialogContent extends StatefulWidget {
  final File selectedFile;
  final OnFinishedUploading onFinishedUploading;

  UploadProgressDialogContent({this.selectedFile, this.onFinishedUploading});

  @override
  _UploadProgressDialogContentState createState() =>
      _UploadProgressDialogContentState();
}

class _UploadProgressDialogContentState
    extends State<UploadProgressDialogContent> {
  double progress = 0;

  @override
  void initState() {
    super.initState();

    ImgurHelper().uploadImage(this.widget.selectedFile,
        (int currentProgress, int totalProgress) {
      setState(() {
        progress = (currentProgress / totalProgress);
      });
    }).then((Response response) {
      print(response.data);
      this.widget.onFinishedUploading(response.data['data']['link']);
    }).catchError((error) {
      print('Imgur call failed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          CircularProgressIndicator(
            value: this.progress,
          ),
          Container(
              margin: EdgeInsets.only(left: 10), child: Text('Uploading...'))
        ],
      ),
    );
  }
}
