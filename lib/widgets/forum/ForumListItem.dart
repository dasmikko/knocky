import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/subforum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumListItem extends StatelessWidget {
  final Subforum subforum;
  final Function(Subforum subforum) onTapItem;
  final Function(int threadId, int page) onTapItemFooter;

  ForumListItem(
      {@required this.subforum,
      @required this.onTapItem,
      @required this.onTapItemFooter});

  Color getSubforumBorderColor(int id) {
    switch (id) {
      case 1:
        return Color.fromRGBO(98, 61, 210, 1);
        break;
      case 2:
        return Color.fromRGBO(239, 36, 36, 1);
        break;
      case 3:
        return Color.fromRGBO(245, 170, 32, 1);
        break;
      case 4:
        return Color.fromRGBO(41, 212, 78, 1);
        break;
      case 5:
        return Color.fromRGBO(41, 212, 78, 1);
        break;
      case 6:
        return Color.fromRGBO(98, 61, 210, 1);
        break;
      case 7:
        return Color.fromRGBO(239, 36, 36, 1);
        break;
      case 8:
        return Color.fromRGBO(245, 170, 32, 1);
        break;
      case 9:
        return Color.fromRGBO(97, 217, 250, 1);
        break;
      case 10:
        return Color.fromRGBO(239, 134, 101, 1);
        break;
      case 11:
        return Color.fromRGBO(239, 134, 101, 1);
        break;
      case 12:
        return Color.fromRGBO(98, 61, 210, 1);
        break;
      case 13:
        return Color.fromRGBO(97, 217, 250, 1);
        break;
      default:
        return Colors.white;
    }
  }

  Widget header(BuildContext context) {
    TextStyle statsTheme = TextStyle(
      fontSize: 12,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: getSubforumBorderColor(subforum.id),
            width: 2,
          ),
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        subforum.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.message_rounded,
                            size: statsTheme.fontSize,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          child: Text(
                            subforum.totalThreads.toString(),
                            style: statsTheme,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.reply_all_rounded,
                            size: statsTheme.fontSize,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          child: Text(
                            subforum.totalPosts.toString(),
                            style: statsTheme,
                          ),
                        )
                      ],
                    )
                  ]),
            ),
          ),
          Container(
            child: CachedNetworkImage(
              imageUrl: !subforum.icon.contains('static')
                  ? subforum.icon
                  : 'https://knockout.chat' + subforum.icon,
              width: 40.0,
            ),
          )
        ],
      ),
    );
  }

  Widget footer(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: subforum.lastPost.thread != null
                ? InkWell(
                    onTap: () {
                      this.onTapItemFooter(
                          subforum.lastPost.thread.lastPost.thread,
                          subforum.lastPost.thread.lastPost.page);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(
                              subforum.lastPost.thread.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: Colors.grey),
                                      children: <InlineSpan>[
                                        TextSpan(text: 'Last post by '),
                                        TextSpan(
                                          text:
                                              subforum.lastPost.user.username !=
                                                      null
                                                  ? subforum.lastPost.user
                                                          .username +
                                                      ' '
                                                  : ' ',
                                          style: TextStyle(
                                              color: AppColors(context)
                                                  .userGroupToColor(subforum
                                                      .lastPost
                                                      .user
                                                      .usergroup)),
                                        ),
                                        TextSpan(
                                            text: timeago
                                                .format(
                                                    subforum.lastPost.createdAt)
                                                .toString())
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[Text('No threads yet...')],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTapItem(subforum),
        child: Column(
          children: <Widget>[
            header(context),
            footer(context),
          ],
        ),
      ),
    );
  }
}
