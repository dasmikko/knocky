import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/screens/thread.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/icons.dart';

class SubforumDetailListItem extends StatelessWidget {
  final SubforumThread threadDetails;

  SubforumDetailListItem({this.threadDetails});

  @override
  Widget build(BuildContext context) {
    String _iconUrl = iconList.firstWhere(
        (IconListItem item) => item.id == threadDetails.iconId).url;

    return Card(
      color: threadDetails.pinned == 1 ? Colors.green : Colors.white,
      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
      child: InkWell(
        onTap: () {
          print('Clicked item ' + threadDetails.id.toString());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                    threadModel: threadDetails,
                  ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: CachedNetworkImage(
                  imageUrl: _iconUrl,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(threadDetails.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
