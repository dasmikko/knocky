import 'package:flutter/material.dart';
import 'package:knocky_edge/helpers/bbcode.dart';
import 'package:knocky_edge/models/slateDocument.dart';
import 'package:knocky_edge/widget/LinkDialogContent.dart';

class EditTextBlockModal extends StatefulWidget {
  final SlateNode node;

  EditTextBlockModal({this.node});

  @override
  _EditTextBlockModalState createState() => _EditTextBlockModalState();
}

class _EditTextBlockModalState extends State<EditTextBlockModal> {
  String bbcodeText;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    bbcodeText = BBCodeHandler().slateParagraphToBBCode(this.widget.node);
    textEditingController = TextEditingController(text: bbcodeText);
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

  void addLinkDialog(
      TextEditingController mainController, BuildContext context) async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
    bool isRichLink = false;

    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new TextField(
              autofocus: true,
              keyboardType: TextInputType.url,
              controller: urlController,
              decoration: new InputDecoration(labelText: 'Url'),
            ),
            Flexible(
              flex: 0,
              child: LinkDialogWidget(
                onChanged: (bool value) {
                  isRichLink = value;
                },
              ),
            ),
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

                String richTextAttribute = isRichLink ? ' rich=true' : '';

                mainController.text = mainController.text +
                    '\n[url${richTextAttribute}]${urlController.text}[/url]';
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit text block'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete block',
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              SlateNode newNode = BBCodeHandler()
                  .parse(textEditingController.text, type: widget.node.type);
              print(BBCodeHandler().slateParagraphToBBCode(newNode));
              print(newNode.toJson());
              Navigator.of(context).pop(newNode);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextField(
                decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                expands: false,
              ),
            ),
          ),
          Container(
            color: Colors.grey[600],
            padding: EdgeInsets.all(0),
            child: Wrap(
              children: <Widget>[
                IconButton(
                  tooltip: 'Bold',
                  icon: Icon(Icons.format_bold),
                  onPressed: () {
                    TextSelection theSelection =
                        textEditingController.selection;
                    addTagAtSelection(textEditingController, theSelection.start,
                        theSelection.end, 'b');
                  },
                ),
                IconButton(
                  tooltip: 'Italic',
                  icon: Icon(Icons.format_italic),
                  onPressed: () {
                    TextSelection theSelection =
                        textEditingController.selection;
                    addTagAtSelection(textEditingController, theSelection.start,
                        theSelection.end, 'i');
                  },
                ),
                IconButton(
                  tooltip: 'Underlined',
                  icon: Icon(Icons.format_underlined),
                  onPressed: () {
                    TextSelection theSelection =
                        textEditingController.selection;
                    addTagAtSelection(textEditingController, theSelection.start,
                        theSelection.end, 'u');
                  },
                ),
                IconButton(
                  tooltip: 'Code',
                  icon: Icon(Icons.code),
                  onPressed: () {
                    TextSelection theSelection =
                        textEditingController.selection;
                    addTagAtSelection(textEditingController, theSelection.start,
                        theSelection.end, 'code');
                  },
                ),
                IconButton(
                  tooltip: 'Spoiler',
                  icon: Icon(Icons.visibility_off),
                  onPressed: () {
                    TextSelection theSelection =
                        textEditingController.selection;
                    addTagAtSelection(textEditingController, theSelection.start,
                        theSelection.end, 'spoiler');
                  },
                ),
                IconButton(
                  tooltip: 'Link',
                  icon: Icon(Icons.link),
                  onPressed: () {
                    addLinkDialog(textEditingController, context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
