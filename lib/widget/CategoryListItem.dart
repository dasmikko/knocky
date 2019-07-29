import 'package:flutter/material.dart';
import 'package:knocky/models/subforum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:knocky/screens/thread.dart';

class CategoryListItem extends StatelessWidget {
  final Subforum subforum;
  final Function onTapItem;

  CategoryListItem({@required this.subforum, @required this.onTapItem});

  Color getSubforumBorderColor(int id) {
    switch (id) {
      case 1:
        return Color.fromRGBO(98, 61, 210, 1);
        break;
      case 2:
        return Color.fromRGBO(41, 212, 78, 1);
        break;
      case 3:
        return Color.fromRGBO(245, 170, 32, 1);
        break;
      case 4:
        return Color.fromRGBO(239, 36, 36, 1);
        break;
      case 5:
        return Color.fromRGBO(97, 217, 250, 1);
        break;
      case 6:
        return Color.fromRGBO(239, 134, 101, 1);
        break;
      case 7:
        return Color.fromRGBO(98, 61, 210, 1);
        break;
      case 8:
        return Color.fromRGBO(41, 212, 78, 1);
        break;
      case 9:
        return Color.fromRGBO(245, 170, 32, 1);
        break;
      case 10:
        return Color.fromRGBO(239, 36, 36, 1);
        break;
      case 11:
        return Color.fromRGBO(97, 217, 250, 1);
        break;
      case 12:
        return Color.fromRGBO(239, 134, 101, 1);
        break;
      default:
        return Colors.white;
    }
  }

  Widget header() {
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
                    Text(
                      subforum.name,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subforum.description,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ]),
            ),
          ),
          Container(
            child: CachedNetworkImage(
              imageUrl: subforum.icon,
              width: 40.0,
            ),
          )
        ],
      ),
    );
  }

  Widget footer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: subforum.lastPost != null
                ? InkWell(
                    onTap: () {
                      print('Clicked on last post');

                      int page =
                          (subforum.lastPost.thread.postCount / 20).ceil();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThreadScreen(
                            title: subforum.lastPost.thread.title,
                            postCount: subforum.lastPost.thread.postCount,
                            page: page,
                            threadId: subforum.lastPost.thread.id,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          child: Text(
                            subforum.lastPost.thread.title,
                            overflow: TextOverflow.ellipsis,
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
                                        text: subforum.lastPost.user.username +
                                            ' ',
                                        style: TextStyle(color: Colors.blue),
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
                  )
                : Row(
                    children: <Widget>[Text('No posts here...')],
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            margin: EdgeInsets.only(left: 10),
            padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      subforum.totalThreads.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getSubforumBorderColor(subforum.id),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        'threads',
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      subforum.totalPosts.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getSubforumBorderColor(subforum.id),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text('posts'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
      child: InkWell(
        onTap: () => onTapItem(subforum),
        child: Column(
          children: <Widget>[
            header(),
            footer(context),
          ],
        ),
      ),
    );
  }
}
