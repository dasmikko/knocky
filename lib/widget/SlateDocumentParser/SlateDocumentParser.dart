import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/widget/PostElements/Video.dart';
import 'package:knocky/widget/YouTubeEmbed.dart';
import 'package:knocky/widget/PostElements/Image.dart';
import 'package:intent/intent.dart';
import 'package:intent/action.dart';
import 'package:knocky/widget/PostElements/Embed.dart';

class SlateDocumentParser extends StatelessWidget {
  final SlateObject slateObject;
  final Function onPressSpoiler;
  final GlobalKey scaffoldkey;
  final BuildContext context;

  SlateDocumentParser({this.slateObject, this.onPressSpoiler, this.scaffoldkey, this.context});

  Widget paragraphToWidget(SlateNode node) {
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
                      Intent()
                        ..setAction(Action.ACTION_VIEW)
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
  }

  List<TextSpan> leafHandler(List<SlateLeaf> leaves, {double fontSize = 14.0}) {
    List<TextSpan> lines = List();
    leaves.forEach((leaf) {
      bool isBold = leaf.marks.where((mark) => mark.type == 'bold').length > 0;

      bool isItalic =
          leaf.marks.where((mark) => mark.type == 'italic').length > 0;

      bool isUnderlined =
          leaf.marks.where((mark) => mark.type == 'underlined').length > 0;

      bool isCode = leaf.marks.where((mark) => mark.type == 'code').length > 0;

      bool isSpoiler =
          leaf.marks.where((mark) => mark.type == 'spoiler').length > 0;

      TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(
        fontSize: fontSize,
        fontFamily: isCode ? 'RobotoMono' : 'Roboto',
        decoration:
          isUnderlined ? TextDecoration.underline : TextDecoration.none,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );

      TextStyle spoilerStyle = textStyle.copyWith(
        background: Paint()..color = Theme.of(context).textTheme.body1.color,
        color: Theme.of(context).textTheme.body1.color
      );

      if (isSpoiler) {
        lines.add(
          TextSpan(
            text: leaf.text,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print('Clicked spoiler');
                this.onPressSpoiler(leaf.text);
              },
            style: spoilerStyle,
          ),
        );
      } else {
        lines.add(
          TextSpan(
            text: leaf.text,
            style: textStyle,
          ),
        );
      }
    });

    return lines;
  }

  List<TextSpan> inlineHandler(SlateNode object, SlateNode node) {
    List<TextSpan> lines = List();

    if (node.type == 'link') {
      node.nodes.forEach((inlineNode) {
        inlineNode.leaves.forEach((leaf) {
          lines.add(
            TextSpan(
              text: leaf.text,
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('Clicked link: ' + object.data.href);
                },
            ),
          );
        });
      });
    } else {
      node.nodes.forEach((inlineNode) {
        inlineNode.leaves.forEach((leaf) {
          lines.add(TextSpan(text: leaf.text));
        });
      });
    }

    return lines;
  }

  Widget bulletListToWidget(SlateNode node) {
    List<Widget> listItemsContent = List();
    List<Widget> listItems = List();

    listItemsContent.addAll(handleNodes(node.nodes));

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
  }

  Widget numberedListToWidget(SlateNode node) {
    List<Widget> listItemsContent = List();
    List<Widget> listItems = List();

    listItemsContent.addAll(handleNodes(node.nodes));

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
  }

  Widget headingToWidget(SlateNode node) {
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
  }

  Widget userquoteToWidget(SlateNode node) {
    List<Widget> widgets = List();

    widgets.add(
      Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: Text(node.data.postData.username,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    // Handle block nodes
    widgets.addAll(handleNodes(node.nodes));

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets),
    );
  }

  Widget youTubeToWidget(SlateNode node) {
    return YoutubeVideoEmbed(url: node.data.src);
  }

  Widget handleQuotes(SlateNode node) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blue, width: 3.0),
        ),
        color: Colors.grey,
      ),
      child: paragraphToWidget(node),
    );
  }

  Widget handleImage(SlateNode node) {
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: LimitedBox(
        maxHeight: 300,
        child: ImageWidget(url: node.data.src),
      ),
    );
  }

  Widget handleVideo(SlateNode node) {
    return VideoElement(node.data.src, scaffoldkey);
  }

  List<Widget> handleNodes(List<SlateNode> nodes) {
    List<Widget> widgets = new List();

    nodes.forEach((node) {
      // Handle blocks
      switch (node.type) {
        case 'paragraph':
          widgets.add(Container(
              child: paragraphToWidget(node)));
          break;
        case 'heading-one':
          widgets.add(headingToWidget(node));
          break;
        case 'heading-two':
          widgets.add(headingToWidget(node));
          break;
        case 'userquote':
          widgets.add(userquoteToWidget(node));
          break;
        case 'bulleted-list':
          widgets.add(bulletListToWidget(node));
          break;
        case 'numbered-list':
          widgets.add(numberedListToWidget(node));
          break;
        case 'list-item':
          widgets.add(paragraphToWidget(node));
          break;
        case 'image':
          widgets.add(handleImage(node));
          break;
        case 'youtube':
          widgets.add(youTubeToWidget(node));
          break;
        case 'block-quote':
          widgets.add(handleQuotes(node));
          break;
        case 'twitter':
          widgets.add(
            EmbedWidget(url: node.data.src)
          );
          break;
        case 'video':
          widgets.add(handleVideo(node));
          break;
        default:
          if (node.object == 'text') {
            widgets.add(
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: leafHandler(node.leaves),
                ),
              ),
            );
          }
      }
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: handleNodes(slateObject.document.nodes)));
  }
}
