import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:path/path.dart';
import 'dart:io';

class DownloadHelper {
  void downloadFile(String url, GlobalKey<ScaffoldState> scaffoldKey) async {
    List<StorageInfo> dir = await PathProviderEx.getStorageInfo();
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((hasPermission) async {
      if (hasPermission == PermissionStatus.granted) {
        try {
          var fileName = basename(url);

          // Create directory if not existing!
          new Directory.fromUri(new Uri.file(dir[0].rootDir + '/Knocky/'))
              .createSync(recursive: true);

          Dio()
              .download(url, dir[0].rootDir + "/Knocky/" + fileName)
              .then((response) {
            if (response.statusCode == 200) {
              scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text(fileName + " was downloaded"),
              ));
            } else {
              scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text(fileName + " was not downloaded"),
              ));
            }
          });
        } catch (e) {
          print(e);
        }
      } else {
        var fileName = basename(url);

        // Create directory if not existing!
        new Directory.fromUri(new Uri.file(dir[0].rootDir + '/Knocky/'))
            .createSync(recursive: true);

        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);

        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          Dio()
              .downloadUri(
                  Uri.parse(url), dir[0].rootDir + "/Knocky/" + fileName)
              .then((response) {
            if (response.statusCode == 200) {
              scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text(fileName + " was downloaded"),
              ));
            } else {
              scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text(fileName + " was not downloaded"),
              ));
            }
          });
        }
      }
    });
  }
}
