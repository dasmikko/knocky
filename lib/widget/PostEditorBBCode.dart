import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/LinkDialogContent.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PostEditorBBCode extends StatefulWidget {
  final String postBBCode;
  final Function onInputChange;

  // Toolbar callbacks
  final Function onTapAddTextBlock;
  final Function onTapAddHeadingOne;
  final Function onTapAddHeadingTwo;
  final Function onTapAddImage;
  final Function onTapAddQuote;
  final Function onTapAddYouTubeVideo;
  final Function onTapAddVideo;
  final Function onReorderHandler;
  final Function onTapAddBulletedList;
  final Function onTapAddNumberedList;
  final Function onTapAddUserQuote;
  final Function onTapAddTwitterEmbed;
  final Function onTapAddStrawPollEmbed;

  final List<ThreadPost> replyList;


  PostEditorBBCode(
      {this.postBBCode,
      this.onTapAddHeadingOne,
      this.onTapAddHeadingTwo,
      this.onTapAddImage,
      this.onTapAddQuote,
      this.onTapAddTextBlock,
      this.onTapAddVideo,
      this.onTapAddYouTubeVideo,
      this.onReorderHandler,
      this.onTapAddBulletedList,
      this.onTapAddNumberedList,
      this.onTapAddUserQuote,
      this.onTapAddTwitterEmbed,
      this.onTapAddStrawPollEmbed,
      this.onInputChange,
      this.replyList});

  @override
  _PostEditorBBCodeState createState() => _PostEditorBBCodeState();
}

class _PostEditorBBCodeState extends State<PostEditorBBCode> {
  final TextEditingController _textEditingController = new TextEditingController(
  );

  @override
  void initState() {
    super.initState();
    _textEditingController.text = this.widget.postBBCode;
    print(this.widget.replyList);
  }

  void addTagAtSelection(TextEditingController controller, int start, int end, String tag) {
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
    controller.selection = TextSelection.collapsed(offset: start + (tag.length + 2));
    this.widget.onInputChange(controller.text);
  }

  void addLinkDialog(TextEditingController mainController, BuildContext context) async {
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

                this.widget.onInputChange(mainController.text);
              })
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _textEditingController,
            textInputAction: TextInputAction.newline,
            maxLines: null,
            expands: true,
            onChanged: this.widget.onInputChange,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12.0)
            ),
          )
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
                      _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'b');
                },
              ),
              IconButton(
                tooltip: 'Italic',
                icon: Icon(Icons.format_italic),
                onPressed: () {
                  TextSelection theSelection =
                      _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'i');
                },
              ),
              IconButton(
                tooltip: 'Underlined',
                icon: Icon(Icons.format_underlined),
                onPressed: () {
                  TextSelection theSelection =
                      _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'u');
                },
              ),
              IconButton(
                tooltip: 'Code',
                icon: Icon(Icons.code),
                onPressed: () {
                  TextSelection theSelection =
                      _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'code');
                },
              ),
              IconButton(
                tooltip: 'Spoiler',
                icon: Icon(Icons.visibility_off),
                onPressed: () {
                  TextSelection theSelection =
                      _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'spoiler');
                },
              ),
              IconButton(
                tooltip: 'Link',
                icon: Icon(Icons.link),
                onPressed: () {
                  addLinkDialog(_textEditingController, context);
                },
              ),
              IconButton(
                tooltip: 'Very large text',
                icon: Icon(MdiIcons.formatHeader1),
                onPressed: this.widget.onTapAddHeadingOne,
              ),
              IconButton(
                tooltip: 'Large text',
                icon: Icon(MdiIcons.formatHeader2),
                onPressed: this.widget.onTapAddHeadingTwo,
              ),
              IconButton(
                tooltip: 'Quote',
                icon: Icon(Icons.format_quote),
                onPressed: this.widget.onTapAddQuote,
              ),
              IconButton(
                tooltip: 'Bulleted list',
                icon: Icon(Icons.format_list_bulleted),
                onPressed: this.widget.onTapAddBulletedList,
              ),
              IconButton(
                tooltip: 'Numbered list',
                icon: Icon(Icons.format_list_numbered),
                onPressed: this.widget.onTapAddNumberedList,
              ),
              IconButton(
                tooltip: 'Image',
                icon: Icon(Icons.image),
                onPressed: this.widget.onTapAddImage,
              ),
              IconButton(
                tooltip: 'YouTube video',
                icon: Icon(Icons.ondemand_video),
                onPressed: this.widget.onTapAddYouTubeVideo,
              ),
              IconButton(
                tooltip: 'Video',
                icon: Icon(Icons.videocam),
                onPressed: this.widget.onTapAddVideo,
              ),
              IconButton(
                tooltip: 'Twitter embed',
                icon: Icon(MdiIcons.twitter),
                onPressed: this.widget.onTapAddTwitterEmbed,
              ),
              IconButton(
                tooltip: 'Strawpoll',
                icon: Icon(MdiIcons.poll),
                onPressed: this.widget.onTapAddStrawPollEmbed,
              ),
              if (this.widget.replyList.length > 0)
                Builder(
                  builder: (BuildContext bcontext) {
                    return IconButton(
                      tooltip: 'Insert userquote',
                      icon: Icon(Icons.message),
                      onPressed: this.widget.onTapAddUserQuote,
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
