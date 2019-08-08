import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/widget/Thread/PostElements/Embed.dart';
import 'package:knocky/widget/Thread/PostElements/Image.dart';
import 'package:knocky/widget/Thread/PostElements/UserQuote.dart';
import 'package:knocky/widget/Thread/PostElements/Video.dart';
import 'package:knocky/widget/Thread/PostElements/YouTubeEmbed.dart';
import 'package:knocky/widget/Thread/PostHeader.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/widget/Thread/RatePostContent.dart';
import 'package:knocky/widget/Thread/ViewUsersOfRatingsContent.dart';
import 'package:knocky/widget/Thread/PostBan.dart';
import 'package:intent/intent.dart' as Intent;
import 'package:intent/action.dart' as Action;

class ThreadPostItem extends StatelessWidget {
  final ThreadPost postDetails;
  final GlobalKey scaffoldKey;
  final Function onPostRated;
  final Function onPressReply;
  final Function onLongPressReply;
  final bool isOnReplyList;
  final Function onTapEditPost;

  ThreadPostItem({
    this.postDetails,
    this.scaffoldKey,
    this.onPostRated,
    this.onPressReply,
    this.isOnReplyList = false,
    this.onLongPressReply,
    this.onTapEditPost,
  });

  Widget buildRatings(List<ThreadPostRatings> ratings) {
    List<Widget> items = List();

    if (ratings != null) {
      ratings.sort((a, b) => b.count.compareTo(a.count));
      ratings.forEach((rating) {
        RatingistItem icon =
            ratingsIconList.where((icon) => icon.id == rating.rating).first;

        items.add(
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: Column(children: <Widget>[
              CachedNetworkImage(
                imageUrl: icon.url,
              ),
              Text(rating.count.toString())
            ]),
          ),
        );
      });
    }

    return Row(children: items);
  }

  void onPressSpoiler(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onPressRatePost(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (BuildContext bContext) {
          return RatePostContent(
            buildContext: context,
            postId: postDetails.id,
            onPostRated: onPostRated,
          );
        });
  }

  void onPressViewRatings(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (BuildContext bContext) {
          return ViewUsersOfRatingsContent(
            buildContext: context,
            ratings: postDetails.ratings,
          );
        });
  }

  List<Widget> otherUserButton(BuildContext context) {
    return [
      FlatButton(
        child: Text('Rate'),
        onPressed: () => onPressRatePost(context),
      ),
      GestureDetector(
        onLongPress: () => onLongPressReply(postDetails),
        child: FlatButton(
          child: Text(!this.isOnReplyList ? 'Reply' : 'Unreply'),
          onPressed: () => onPressReply(postDetails),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        ),
      ),
    ];
  }

  List<Widget> ownPostButtons(BuildContext context) {
    return [];
    return [
      FlatButton(
        child: Text('Edit'),
        onPressed: () => onTapEditPost(postDetails),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .isLoggedIn;
    final int ownUserId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .userId;

    // Handler post footer stuff
    List<Widget> footer = List();

    footer.add(
      Flexible(
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: postDetails.ratings != null
              ? () => onPressViewRatings(context)
              : null,
          child: buildRatings(postDetails.ratings),
        ),
      ),
    );

    if (isLoggedIn && postDetails.user.id != ownUserId)
      footer.addAll(otherUserButton(context));

    if (isLoggedIn && postDetails.user.id == ownUserId)
      footer.addAll(ownPostButtons(context));

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PostHeader(
                      username: postDetails.user.username,
                      avatarUrl: postDetails.user.avatarUrl,
                      backgroundUrl: postDetails.user.backgroundUrl,
                      threadPost: postDetails,
                      context: context,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: SlateDocumentParser(
                slateObject: postDetails.content,
                onPressSpoiler: (text) {
                  onPressSpoiler(context, text);
                },
                context: context,
                paragraphHandler: (SlateNode node, Function leafHandler) {
                  List<TextSpan> lines = List();

                  // Handle block nodes
                  node.nodes.forEach((line) {
                    if (line.leaves != null) {
                      lines.addAll(leafHandler(line.leaves));
                    }

                    // Handle inline element
                    if (line.object == 'inline') {
                      // Handle links
                      if (line.type == 'link') {
                        line.nodes.forEach((inlineNode) {
                          inlineNode.leaves.forEach((leaf) {
                            lines.add(TextSpan(
                                text: leaf.text,
                                style: TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Intent.Intent()
                                      ..setAction(Action.Action.ACTION_VIEW)
                                      ..setData(Uri.parse(line.data.href))
                                      ..startActivity()
                                          .catchError((e) => print(e));
                                    print('Clicked link: ' + line.data.href);
                                  }));
                          });
                        });
                      } else {
                        line.nodes.forEach((inlineNode) {
                          inlineNode.leaves.forEach((leaf) {
                            lines.add(TextSpan(text: leaf.text));
                          });
                        });
                      }
                    }
                  });

                  return Container(
                    child: RichText(
                      text: TextSpan(children: lines),
                    ),
                  );
                },
                headingHandler: (SlateNode node, Function inlineHandler,
                    Function leafHandler) {
                  List<TextSpan> lines = List();

                  // Handle block nodes
                  node.nodes.forEach((line) {
                    if (line.leaves != null) {
                      double headingSize = 14.0;

                      if (node.type.contains('-one')) {
                        headingSize = 30.0;
                      }

                      if (node.type.contains('-two')) {
                        headingSize = 20.0;
                      }

                      // Handle node leaves
                      lines.addAll(
                          leafHandler(line.leaves, fontSize: headingSize));
                    }

                    // Handle inline element
                    if (line.object == 'inline') {
                      // Handle links
                      inlineHandler(node, line);
                    }
                  });

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: RichText(
                      text: TextSpan(children: lines),
                    ),
                  );
                },
                imageWidgetHandler:
                    (String imageUrl, slateObject, SlateNode node) {
                  return Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: LimitedBox(
                      maxHeight: 300,
                      child:
                          ImageWidget(url: imageUrl, slateObject: slateObject),
                    ),
                  );
                },
                videoWidgetHandler: (SlateNode node) {
                  return VideoElement(
                    url: node.data.src,
                    scaffoldKey: this.scaffoldKey,
                  );
                },
                youTubeWidgetHandler: (String youTubeUrl, SlateNode node) {
                  return YoutubeVideoEmbed(
                    url: youTubeUrl,
                  );
                },
                twitterEmbedHandler: (String embedUrl) {
                  return EmbedWidget(
                    url: embedUrl,
                  );
                },
                userQuoteHandler:
                    (String username, List<Widget> widgets, bool isChild) {
                  return UserQuoteWidget(
                    username: username,
                    children: widgets,
                    isChild: isChild,
                  );
                },
                bulletedListHandler: (List<Widget> listItemsContent) {
                  List<Widget> listItems = List();
                  // Handle block nodes
                  listItemsContent.forEach((item) {
                    listItems.add(
                      Container(
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10.0),
                              height: 5.0,
                              width: 5.0,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).textTheme.body1.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(child: item)
                          ],
                        ),
                      ),
                    );
                  });

                  return Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(children: listItems),
                  );
                },
                numberedListHandler: (List<Widget> listItemsContent) {
                  List<Widget> listItems = List();
                  // Handle block nodes
                  listItemsContent.forEach((item) {
                    listItems.add(
                      Container(
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10.0),
                              child: Text(
                                (listItems.length + 1).toString(),
                              ),
                            ),
                            Expanded(
                              child: item,
                            )
                          ],
                        ),
                      ),
                    );
                  });

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(children: listItems),
                  );
                },
                quotesHandler: (SlateNode node, Function inlineHandler,
                    Function leafHandler) {
                  List<TextSpan> lines = List();
                  // Handle block nodes
                  node.nodes.forEach((line) {
                    if (line.leaves != null) {
                      double headingSize = 14.0;

                      if (node.type.contains('-one')) {
                        headingSize = 30.0;
                      }

                      if (node.type.contains('-two')) {
                        headingSize = 20.0;
                      }

                      // Handle node leaves
                      lines.addAll(
                          leafHandler(line.leaves, fontSize: headingSize));
                    }

                    // Handle inline element
                    if (line.object == 'inline') {
                      // Handle links
                      inlineHandler(node, line);
                    }
                  });

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.blue, width: 3.0),
                      ),
                      color: Colors.grey,
                    ),
                    child: RichText(
                      text: TextSpan(children: lines),
                    ),
                  );
                },
              ),
            ),
            Container(
                padding:
                    EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (postDetails.bans != null)
                      Column(
                        children: postDetails.bans
                            .map(
                              (ban) => PostBan(
                                ban: ban,
                              ),
                            )
                            .toList(),
                      ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: footer),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
