import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart' as Ddio;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class ImageViewerBottomSheet extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String url;
  final String embedType;
  final GlobalKey<ScaffoldState> scaffoldKey;

  ImageViewerBottomSheet(
      {this.totalPages,
      this.currentPage,
      this.url,
      this.scaffoldKey,
      this.embedType});

  void copyUrl(context) {
    Clipboard.setData(new ClipboardData(text: url));
    Get.snackbar('URL', 'URL copied to clipboard');
    Get.back();
  }

  void openURL(context) async {
    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        await launch(url, forceSafariVC: false);
      } else {
        await launch(url, forceWebView: false);
      }
    } else {
      throw 'Could not launch $url';
    }
    Navigator.pop(context);
  }

  void shareURL(context) async {
    Uri uri = Uri.parse(url);

    bool isDirectSharable = embedType == 'img' || embedType == 'video';

    // Make temp url for the image
    Directory tempDir = await getTemporaryDirectory();
    String fileUrl = tempDir.path + '/' + uri.pathSegments.last;

    if (isDirectSharable) {
      // Download the element
      Ddio.Dio dio = new Ddio.Dio();
      //Ddio.Response response =
      await dio.download(url, fileUrl, deleteOnError: true);

      print(lookupMimeType(fileUrl));
      // Share the temp file
      await Share.shareFiles([fileUrl], mimeTypes: [lookupMimeType(fileUrl)]);

      // Delete the temp file
      final file = File(fileUrl);
      file.delete();
    } else {
      Share.share(url);
    }
    Navigator.pop(context);
  }

  void downloadEmbed(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    // You can request multiple permissions at once.

    print(statuses[Permission.storage]);

    if (statuses[Permission.storage].isDenied) return;

    // Download the element
    GallerySaver.saveImage(url.split('?').first, albumName: 'Knocky').then(
      (bool success) async {
        if (success) {
          Get.back();
          Get.snackbar(
            'Success',
            'Image was saved to gallery',
            colorText: Colors.white,
            backgroundColor: Colors.green,
          );
        } else {
          Get.back();
          Get.snackbar(
            'Success',
            'Image was saved to gallery',
            colorText: Colors.white,
            backgroundColor: Colors.red,
          );
        }
      },
    );
  }

  void showBottomSheet(BuildContext scaffoldcontext) {
    showModalBottomSheet(
      backgroundColor: Colors.grey[900].withOpacity(0.5),
      context: scaffoldcontext,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(url),
                  ),
                ],
              ),
              Container(
                color: Colors.grey[900],
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () => copyUrl(scaffoldcontext),
                    ),
                    IconButton(
                        icon: Icon(Icons.open_in_browser),
                        onPressed: () => openURL(scaffoldcontext)),
                    IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () => shareURL(scaffoldcontext)),
                    IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () => downloadEmbed(scaffoldcontext)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[900],
      child: GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dy < -10) {
            print('Swipe up!');
            showBottomSheet(context);
          }
        },
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 56,
          child: Row(
            children: <Widget>[
              Expanded(
                child: currentPage == null
                    ? Text('')
                    : (Text(
                        (currentPage + 1).toString() +
                            ' of ' +
                            totalPages.toString(),
                      )),
              ),
              IconButton(
                onPressed: () => showBottomSheet(context),
                icon: Icon(Icons.more_vert),
                tooltip: 'See additional actions and info',
              )
            ],
          ),
        ),
      ),
    );
  }
}
