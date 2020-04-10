import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/LinkDialogContent.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/widget/UploadProgressDialogContent.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PostEditorBBCode extends StatefulWidget {
  final String postBBCode;
  final Function onInputChange;
  final Thread thread;

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
      { this.thread,
        this.postBBCode,
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
  final TextEditingController _textEditingController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = this.widget.postBBCode;
    print(this.widget.replyList);
  }

  void addTagAtSelection(
      TextEditingController controller, int start, int end, String tag) {
    RegExp regExp = new RegExp(
      r'(\[([^/].*?)(=(.+?))?\](.*?)\[/\2\]|\[([^/].*?)(=(.+?))?\])',
      caseSensitive: false,
      multiLine: false,
    );

    String selectedText = controller.text.substring(start, end);
    String replaceWith = '';

    if (regExp.hasMatch(selectedText)) {
      replaceWith = selectedText.replaceAll(
          '[${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
      replaceWith = replaceWith.replaceAll(
          '[/${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
    } else {
      replaceWith = '[${tag}]' +
          selectedText +
          '[/${tag}]'; //ignore: unnecessary_brace_in_string_interps
    }
    controller.text = controller.text.replaceRange(start, end, replaceWith);
    controller.selection =
        TextSelection.collapsed(offset: start + (tag.length + 2));
    this.widget.onInputChange(controller.text);
  }

  ///
  /// Add a tag with content at cursor position
  ///
  void addTag(TextEditingController controller, String tag, String content) {
    String tagToAdd = '[${tag}]' + content + '[/${tag}]'; //ignore: unnecessary_brace_in_string_interps
    if (controller.text.isNotEmpty) controller.text = controller.text + '\n' + tagToAdd; // Add new line if content is not empty
    if (controller.text.isEmpty) controller.text = controller.text + tagToAdd; 

    this.widget.onInputChange(controller.text);
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

                this.widget.onInputChange(mainController.text);
              })
        ],
      ),
    );
  }

  void addImageUrlDialog() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController imgurlController = TextEditingController(text: '');
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
                controller: imgurlController,
                decoration: new InputDecoration(labelText: 'Image url'),
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
                var controller = _textEditingController;
                addTag(controller, 'youtube', imgurlController.text);
              })
        ],
      ),
    );
  }

  void showUploadProgressDialog(File selectedFile) async {
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: Text('Uploading image'),
        content: UploadProgressDialogContent(
          selectedFile: selectedFile,
          onFinishedUploading: (String imageLink) {
            Navigator.of(context, rootNavigator: true).pop();
            var controller = _textEditingController;
            addTag(controller, 'img', imageLink); 
          },
        ),
      ),
    );
  }

  void addImageDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new SimpleDialog(
        title: Text('Add image'),
        children: <Widget>[
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.camera_alt),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Take picture and upload to Imgur')),
              ],
            ),
            onPressed: () async {
              File image =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              Navigator.of(context, rootNavigator: true).pop();
              if (image != null) showUploadProgressDialog(image);
            },
          ),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.file_upload),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Upload existing image to Imgur')),
              ],
            ),
            onPressed: () async {
              File image =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              Navigator.of(context, rootNavigator: true).pop();
              if (image != null) showUploadProgressDialog(image);
            },
          ),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.insert_link),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Image url')),
              ],
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              this.addImageUrlDialog();
            },
          )
        ],
      ),
    );
  }

  void addYoutubeVideoDialog() async {
    TextEditingController urlController = TextEditingController(text: '');
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
                decoration: new InputDecoration(labelText: 'YouTube URL'),
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
                var controller = _textEditingController;
                addTag(controller, 'youtube', urlController.text);
                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void addVideoDialog() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                controller: urlController,
                decoration:
                    new InputDecoration(labelText: 'Video URL (Webm/mp4)'),
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
                var controller = _textEditingController;
                addTag(controller, 'video', urlController.text);
                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void addTwitterEmbed() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
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
                decoration: new InputDecoration(labelText: 'Twitter URL'),
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
                var controller = _textEditingController;
                addTag(controller, 'twitter', urlController.text);
                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void addStrawpollEmbed() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
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
                decoration: new InputDecoration(labelText: 'Strawpoll URL'),
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
                var controller = _textEditingController;
                addTag(controller, 'strawpoll', urlController.text);

                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void addUserquoteDialog() async {
    await showDialog<int>(
      context: context,
      child: new AlertDialog(
        title: Text('Select post'),
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          height: 400,
          width: 200,
          child: ListView.builder(
            itemCount: this.widget.replyList.length,
            itemBuilder: (BuildContext context, int index) {
              ThreadPost item = this.widget.replyList[index];
              return ListTile(
                title: Text(item.user.username),
                subtitle: Text(item.content.toString().substring(0, 50)),
                contentPadding: EdgeInsets.all(10),
                onTap: () {
                  var controller = _textEditingController;
                  controller.text += '[quote mentionUser="${item.user.id}" postId="${item.id}" threadPage="${this.widget.thread.currentPage}" threadPage="${this.widget.thread.id}" username="${item.user.username}" ]${item.content}[/quote]';
                  this.widget.onInputChange(controller.text);
                  Navigator.of(context, rootNavigator: true).pop();
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
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
          autofocus: true,
          controller: _textEditingController,
          textInputAction: TextInputAction.newline,
          maxLines: null,
          expands: true,
          onChanged: this.widget.onInputChange,
          decoration: InputDecoration(contentPadding: EdgeInsets.all(12.0)),
        )),
        Container(
          color: Colors.grey[600],
          padding: EdgeInsets.all(0),
          child: Wrap(
            children: <Widget>[
              IconButton(
                tooltip: 'Bold',
                icon: Icon(Icons.format_bold),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'b');
                },
              ),
              IconButton(
                tooltip: 'Italic',
                icon: Icon(Icons.format_italic),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'i');
                },
              ),
              IconButton(
                tooltip: 'Underlined',
                icon: Icon(Icons.format_underlined),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'u');
                },
              ),
              IconButton(
                tooltip: 'Code',
                icon: Icon(Icons.code),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'code');
                },
              ),
              IconButton(
                tooltip: 'Spoiler',
                icon: Icon(Icons.visibility_off),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
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
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'h1');
                },
              ),
              IconButton(
                tooltip: 'Large text',
                icon: Icon(MdiIcons.formatHeader2),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'h2');
                },
              ),
              IconButton(
                tooltip: 'Quote',
                icon: Icon(Icons.format_quote),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'blockquote');
                },
              ),
              IconButton(
                tooltip: 'Bulleted list',
                icon: Icon(Icons.format_list_bulleted),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'ul');
                },
              ),
              IconButton(
                tooltip: 'Numbered list',
                icon: Icon(Icons.format_list_numbered),
                onPressed: () {
                  TextSelection theSelection = _textEditingController.selection;
                  addTagAtSelection(_textEditingController, theSelection.start,
                      theSelection.end, 'ol');
                },
              ),
              IconButton(
                tooltip: 'Image',
                icon: Icon(Icons.image),
                onPressed: addImageDialog,
              ),
              IconButton(
                tooltip: 'YouTube video',
                icon: Icon(Icons.ondemand_video),
                onPressed: this.addYoutubeVideoDialog,
              ),
              IconButton(
                tooltip: 'Video',
                icon: Icon(Icons.videocam),
                onPressed: this.addVideoDialog,
              ),
              IconButton(
                tooltip: 'Twitter embed',
                icon: Icon(MdiIcons.twitter),
                onPressed: this.addTwitterEmbed,
              ),
              IconButton(
                tooltip: 'Strawpoll',
                icon: Icon(MdiIcons.poll),
                onPressed: this.addStrawpollEmbed,
              ),
              if (this.widget.replyList.length > 0)
                Builder(
                  builder: (BuildContext bcontext) {
                    return IconButton(
                      tooltip: 'Insert userquote',
                      icon: Icon(Icons.message),
                      onPressed: this.addUserquoteDialog,
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
