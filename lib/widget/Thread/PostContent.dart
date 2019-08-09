import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/widget/Thread/PostElements/Embed.dart';
import 'package:knocky/widget/Thread/PostElements/Image.dart';
import 'package:knocky/widget/Thread/PostElements/UserQuote.dart';
import 'package:knocky/widget/Thread/PostElements/Video.dart';
import 'package:knocky/widget/Thread/PostElements/YouTubeEmbed.dart';
import 'package:intent/intent.dart' as Intent;
import 'package:intent/action.dart' as Action;

class PostContent extends StatelessWidget {
  final SlateObject content;
  final Function onTapSpoiler;
  final GlobalKey scaffoldKey;

  PostContent({
    this.onTapSpoiler,
    this.content,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return SlateDocumentParser(
      slateObject: this.content,
      onPressSpoiler: (text) {
        this.onTapSpoiler(text);
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
                            ..startActivity().catchError((e) => print(e));
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
      headingHandler:
          (SlateNode node, Function inlineHandler, Function leafHandler) {
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
            lines.addAll(leafHandler(line.leaves, fontSize: headingSize));
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
      imageWidgetHandler: (String imageUrl, slateObject, SlateNode node) {
        return Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: LimitedBox(
            maxHeight: 300,
            child: ImageWidget(url: imageUrl, slateObject: slateObject),
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
      twitterEmbedHandler: (String embedUrl, SlateNode node) {
        return EmbedWidget(
          url: embedUrl,
        );
      },
      strawpollHandler: (SlateNode node) {
        return EmbedWidget(
          url: node.data.src,
        );
      },
      userQuoteHandler: (String username, List<Widget> widgets, bool isChild, SlateNode node) {
        return UserQuoteWidget(
          username: username,
          children: widgets,
          isChild: isChild,
        );
      },
      bulletedListHandler: (List<Widget> listItemsContent, node) {
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
      numberedListHandler: (List<Widget> listItemsContent, SlateNode node) {
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
      quotesHandler:
          (SlateNode node, Function inlineHandler, Function leafHandler) {
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
            lines.addAll(leafHandler(line.leaves, fontSize: headingSize));
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
    );
  }
}
