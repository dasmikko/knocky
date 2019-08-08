import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentController.dart';

class SlateDocumentParser extends StatelessWidget {
  final SlateObject slateObject;
  final Function onPressSpoiler;
  final GlobalKey scaffoldkey;
  final BuildContext context;
  final Function imageWidgetHandler;
  final Function videoWidgetHandler;
  final Function youTubeWidgetHandler;
  final Function twitterEmbedHandler;
  final Function userQuoteHandler;
  final Function bulletedListHandler;
  final Function numberedListHandler;
  final Function quotesHandler;
  final Function paragraphHandler;
  final Function headingHandler;
  final SlateDocumentController slateDocumentController;
  final bool asListView;

  SlateDocumentParser({
    this.slateObject,
    this.onPressSpoiler,
    this.scaffoldkey,
    this.context,
    this.slateDocumentController,
    @required this.imageWidgetHandler,
    @required this.videoWidgetHandler,
    @required this.youTubeWidgetHandler,
    @required this.twitterEmbedHandler,
    @required this.userQuoteHandler,
    @required this.bulletedListHandler,
    @required this.numberedListHandler,
    @required this.quotesHandler,
    @required this.paragraphHandler,
    @required this.headingHandler,
    this.asListView,
  });

  Widget paragraphToWidget(SlateNode node) {
    return this.paragraphHandler(node, leafHandler);
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
          color: Theme.of(context).textTheme.body1.color);

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
    listItemsContent.addAll(handleNodes(node.nodes));

    return this.bulletedListHandler(listItemsContent, node);
  }

  Widget numberedListToWidget(SlateNode node) {
    List<Widget> listItemsContent = List();
    listItemsContent.addAll(handleNodes(node.nodes));

    return this.numberedListHandler(listItemsContent, node);
  }

  Widget headingToWidget(SlateNode node) {
    return this.headingHandler(node, inlineHandler, leafHandler);
  }

  Widget userquoteToWidget(SlateNode node, {bool isChild = false}) {
    List<Widget> widgets = List();

    // Handle block nodes
    widgets.addAll(handleNodes(node.nodes, isChild: !isChild));

    return this.userQuoteHandler(node.data.postData.username, widgets, isChild);
  }

  Widget youTubeToWidget(SlateNode node) {
    return this.youTubeWidgetHandler(node.data.src, node);
  }

  Widget handleQuotes(SlateNode node) {
    return this.quotesHandler(node, inlineHandler, leafHandler);
  }

  Widget handleImage(SlateNode node) {
    return this.imageWidgetHandler(node.data.src, slateObject, node);
  }

  Widget handleVideo(SlateNode node) {
    return this.videoWidgetHandler(node);
  }

  List<Widget> handleNodes(List<SlateNode> nodes, {bool isChild = false}) {
    List<Widget> widgets = new List();

    nodes.forEach((node) {
      // Handle blocks
      switch (node.type) {
        case 'paragraph':
          widgets.add(Container(child: paragraphToWidget(node)));
          break;
        case 'heading-one':
          widgets.add(headingToWidget(node));
          break;
        case 'heading-two':
          widgets.add(headingToWidget(node));
          break;
        case 'userquote':
          widgets.add(userquoteToWidget(node, isChild: isChild));
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
          widgets.add(this.twitterEmbedHandler(node.data.src));
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

  List<Widget> asWidgetList() {
    return handleNodes(slateObject.document.nodes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: handleNodes(slateObject.document.nodes),
      ),
    );
  }
}
