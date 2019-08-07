import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PostEditor extends StatefulWidget {
  final SlateObject document;
  final Function onTapTextBlock;
  final Function onTapImageBlock;
  final Function onTapVideoBlock;
  final Function onTapYouTubeBlock;
  final Function onTapQuoteBlock;
  final Function onTapListBlock;
  final Function onTapUserQuoteBlock;
  final Function onTapTwitterBlock;

  // Toolbar callbacks
  final Function onTapAddTextBlock;
  final Function onTapAddHeadingOne;
  final Function onTapAddHeadingTwo;
  final Function onTapAddImage;
  final Function onTapAddQuote;
  final Function onTapAddYouTubeVideo;
  final Function onTapAddVideo;
  final Function onReorderHandler;

  PostEditor(
      {this.document,
      this.onTapTextBlock,
      this.onTapImageBlock,
      this.onTapListBlock,
      this.onTapQuoteBlock,
      this.onTapTwitterBlock,
      this.onTapUserQuoteBlock,
      this.onTapVideoBlock,
      this.onTapYouTubeBlock,
      this.onTapAddHeadingOne,
      this.onTapAddHeadingTwo,
      this.onTapAddImage,
      this.onTapAddQuote,
      this.onTapAddTextBlock,
      this.onTapAddVideo,
      this.onTapAddYouTubeVideo,
      this.onReorderHandler});

  @override
  _PostEditorState createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  List<Widget> editorContent() {
    return SlateDocumentParser(
      slateObject: this.widget.document,
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
                  ));
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

        return ListTile(
          leading: Icon(Icons.text_format),
          onTap: () {
            print(node);
            this.widget.onTapTextBlock(context, node);
          },
          title: Container(
            margin: EdgeInsets.only(bottom: 5),
            child: RichText(
                text: lines.length > 0
                    ? TextSpan(children: lines)
                    : TextSpan(text: '- empty text block -')),
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

        return ListTile(
          leading: Icon(node.type.contains('-one') ? MdiIcons.formatHeader1 : MdiIcons.formatHeader2),
          onTap: () {
            this.widget.onTapTextBlock(context, node);
          },
          title: Container(
            margin: EdgeInsets.only(bottom: 10),
            child: RichText(
              text: lines.length > 0
                  ? TextSpan(children: lines)
                  : TextSpan(text: '- empty heading block -'),
            ),
          ),
        );
      },
      imageWidgetHandler: (String imageUrl, slateObject, SlateNode node) {
        return ListTile(
          leading: Icon(Icons.image),
          onTap: () {
            this.widget.onTapImageBlock(slateObject, node);
          },
          title: Container(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[Text('Image block'), Text(imageUrl)],
                ),
          ),
        );
      },
    )
        .asWidgetList()
        .map((widget) => Container(
              key: ValueKey(widget),
              child: widget,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ReorderableListView(
            onReorder: this.widget.onReorderHandler,
            children: editorContent(),
          ),
        ),
        Container(
          color: Colors.grey[600],
          padding: EdgeInsets.all(0),
          child: Wrap(
            children: <Widget>[
              IconButton(
                icon: Icon(MdiIcons.textbox),
                onPressed: this.widget.onTapAddTextBlock,
              ),
              IconButton(
                icon: Icon(MdiIcons.formatHeader1),
                onPressed: this.widget.onTapAddHeadingOne,
              ),
              IconButton(
                icon: Icon(MdiIcons.formatHeader2),
                onPressed: this.widget.onTapAddHeadingTwo,
              ),
              IconButton(
                icon: Icon(Icons.format_quote),
                onPressed: this.widget.onTapAddQuote,
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: this.widget.onTapAddImage,
              ),
              IconButton(
                icon: Icon(Icons.ondemand_video),
                onPressed: this.widget.onTapAddYouTubeVideo,
              ),
              IconButton(
                icon: Icon(Icons.videocam),
                onPressed: this.widget.onTapAddVideo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
