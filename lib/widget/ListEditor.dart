import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knocky_edge/helpers/bbcode.dart';
import 'package:knocky_edge/models/slateDocument.dart';
import 'package:knocky_edge/widget/SlateDocumentParser/SlateDocumentParser.dart';

class ListEditor extends StatefulWidget {
  final List oldListItems;
  final Function onTapListItem;
  final Function onListUpdated;

  ListEditor({
    this.oldListItems,
    this.onTapListItem,
    this.onListUpdated,
  });

  @override
  _ListEditorState createState() => _ListEditorState();
}

class _ListEditorState extends State<ListEditor> {
  List<SlateNode> currentItemList = List();

  @override
  void initState() {
    super.initState();
    currentItemList = this.widget.oldListItems;
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

  Widget listItemTextHandler(SlateNode node) {
    List<TextSpan> lines = List();

    // Handle block nodes
    node.nodes.forEach((line) {
      if (line.leaves != null) {
        lines.addAll(this.leafHandler(line.leaves));
      }

      // Handle inline element
      if (line.object == 'inline') {
        // Handle links
        if (line.type == 'link') {
          line.nodes.forEach((inlineNode) {
            inlineNode.leaves.forEach((leaf) {
              lines.add(
                TextSpan(
                  text: leaf.text,
                  style: TextStyle(color: Colors.blue),
                ),
              );
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

  void showTextEditDialog(BuildContext context, SlateNode node) {
    String bbcodeText = BBCodeHandler().slateParagraphToBBCode(node);
    TextEditingController textEditingController =
        TextEditingController(text: bbcodeText);

    showDialog(
        context: context,
        builder: (BuildContext bcontext) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text('Remove'),
                onPressed: () {
                  setState(() {
                    int index = this.currentItemList.indexOf(node);
                    this.currentItemList.removeAt(index);
                    this.widget.onListUpdated(this.currentItemList);
                  });
                  Navigator.pop(bcontext);
                },
              ),
              FlatButton(
                child: Text('Save'),
                onPressed: () {
                  SlateNode newNode = BBCodeHandler()
                      .parse(textEditingController.text, type: node.type);
                  Navigator.pop(bcontext, newNode);
                },
              )
            ],
            title: Text('Edit text'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    controller: textEditingController,
                  ),
                ),
                Container(
                  color: Colors.grey[600],
                  padding: EdgeInsets.all(0),
                  child: Wrap(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.format_bold),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'b');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.format_italic),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'i');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.format_underlined),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'u');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.code),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'code');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.link),
                        onPressed: () {
                          addLinkDialog(textEditingController);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).then(
      (newNode) {
        SlateNode newNodeAsListItem = newNode;
        newNodeAsListItem.type = 'list-item';
        setState(() {
          int index = this.currentItemList.indexOf(node);
          this.currentItemList[index] = newNodeAsListItem;
          this.widget.onListUpdated(this.currentItemList);
        });
      },
    );
  }

  void addLinkDialog(TextEditingController mainController) async {
    ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController =
        TextEditingController(text: clipBoardText.text);
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                controller: urlController,
                decoration: new InputDecoration(labelText: 'Url'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();

                if (mainController.text.endsWith('\n') ||
                    mainController.text.isEmpty) {
                  mainController.text =
                      mainController.text + '[url]${urlController.text}[/url]';
                } else {
                  mainController.text = mainController.text +
                      '\n[url]${urlController.text}[/url]';
                }
              })
        ],
      ),
    );
  }

  void addTagAtSelection(
      TextEditingController controller, int start, int end, String tag) {
    RegExp regExp = new RegExp(
      r'(\[([^/].*?)(=(.+?))?\](.*?)\[/\2\]|\[([^/].*?)(=(.+?))?\])',
      caseSensitive: false,
      multiLine: false,
    );

    String newline = tag == 'h1' || tag == 'h2' ? "\n" : '';
    String selectedText = controller.text.substring(start, end);
    String replaceWith = '';

    if (regExp.hasMatch(selectedText)) {
      replaceWith = selectedText.replaceAll(
          '[${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
      replaceWith = replaceWith.replaceAll(
          '[/${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
    } else {
      replaceWith = newline +
          '[${tag}]' +
          selectedText +
          '[/${tag}]'; //ignore: unnecessary_brace_in_string_interps
    }
    controller.text = controller.text.replaceRange(start, end, replaceWith);
  }

  List<Widget> buildItemList() {
    return currentItemList
        .map((SlateNode item) => ListTile(
            onTap: () => this.showTextEditDialog(context, item),
            title: item.nodes.first.leaves.length > 0
                ? listItemTextHandler(item)
                : Text('- empty list item -')))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LimitedBox(
          maxHeight: 400,
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: buildItemList()),
          ),
        ),
        FlatButton(
          child: Text('Add list item'),
          onPressed: () {
            setState(() {
              currentItemList.add(
                SlateNode(
                  type: 'list-item',
                  nodes: [SlateNode(object: 'block', leaves: [])],
                ),
              );
            });
          },
        ),
      ],
    );
  }
}
