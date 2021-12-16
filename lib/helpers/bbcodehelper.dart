import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BBCodeHelper implements bbob.NodeVisitor {
  List<String> urls = [];
  String _elType = 'text'; // Types: text, img, blockquote,
  List<TextSpan> textChildren = [];

  List<String> getUrls(String text) {
    var ast = bbob.parse(text);

    for (final node in ast) {
      node.accept(this);
    }
    return urls;
  }

  void visitText(bbob.Text text) {
    if (_elType == 'img') {
      urls.add(text.textContent);
    }
  }

  bool visitElementBefore(bbob.Element element) {
    if (element.tag == 'img') {
      _elType = 'img';
    }

    // Handle children
    return true;
  }

  void visitElementAfter(bbob.Element element) {
    if (element.tag == 'img') {
      _elType = 'text';
    }
  }

  static void addTagAtSelection(
      TextEditingController controller, String tag, Function onInputChange,
      {String option}) {
    print(option);
    var start = controller.selection.start;
    var end = controller.selection.end;
    RegExp regExp = new RegExp(
      r'(\[([^/].*?)(=(.+?))?\](.*?)\[/\2\]|\[([^/].*?)(=(.+?))?\])',
      caseSensitive: false,
      multiLine: false,
    );

    String selectedText = controller.text.substring(start, end);
    String replaceWith = '';

    if (regExp.hasMatch(selectedText)) {
      replaceWith = selectedText.replaceAll('[$tag]', '');
      replaceWith = replaceWith.replaceAll('[/$tag]', '');
    } else {
      if (option != null) {
        replaceWith = '[$tag $option=""]$selectedText[/$tag]';
      } else {
        replaceWith = '[$tag]$selectedText[/$tag]';
      }
    }
    controller.text = controller.text.replaceRange(start, end, replaceWith);
    if (option == null) {
      controller.selection =
          TextSelection.collapsed(offset: start + (tag.length + 2));
    } else {
      controller.selection = TextSelection.collapsed(
          offset: start + ((tag.length + option.length) + 6));
    }
    onInputChange.call(controller.text);
  }

  static void addTag(
      TextEditingController controller, String tag, String content) {
    // ignore: unnecessary_brace_in_string_interps
    String tagToAdd = '[${tag}]' +
        content +
        '[/${tag}]'; //ignore: unnecessary_brace_in_string_interps
    if (controller.text.isNotEmpty)
      controller.text = controller.text +
          '\n' +
          tagToAdd; // Add new line if content is not empty
    if (controller.text.isEmpty) controller.text = controller.text + tagToAdd;
  }

  static void showUploadProgressDialog(BuildContext context, XFile selectedFile,
      TextEditingController textEditingController) async {
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: Text('Uploading image'),
        /*content: UploadProgressDialogContent(
          selectedFile: selectedFile,
          onFinishedUploading: (String imageLink) {
            Navigator.of(context, rootNavigator: true).pop();
            var controller = textEditingController;
            addTag(controller, 'img', imageLink);
          },
        )
        */
      ),
    );
  }

  static _pickImage(BuildContext context,
      TextEditingController textEditingController, ImageSource source) async {
    XFile image = await ImagePicker().pickImage(source: source);
    Navigator.of(context, rootNavigator: true).pop();
    if (image != null)
      showUploadProgressDialog(context, image, textEditingController);
  }

  static _imageDialogChoice(String text, IconData icon, Function onPressed) {
    return SimpleDialogOption(
        child: Row(
          children: <Widget>[
            Icon(icon),
            Container(margin: EdgeInsets.only(left: 10), child: Text(text)),
          ],
        ),
        onPressed: onPressed);
  }

  static void addImageUrlDialog(
      BuildContext context, TextEditingController textEditingController) async {
    var onImageUrlClicked = () {
      Navigator.of(context, rootNavigator: true).pop();
      addImageUrlDialog(context, textEditingController);
    };
    await showDialog<String>(
      context: context,
      builder: (_) => new SimpleDialog(
        title: Text('Add image'),
        children: <Widget>[
          _imageDialogChoice(
              'Take picture and upload to Imgur',
              Icons.camera_alt,
              _pickImage(context, textEditingController, ImageSource.camera)),
          _imageDialogChoice(
              'Upload existing image to Imgur',
              Icons.file_upload,
              _pickImage(context, textEditingController, ImageSource.gallery)),
          _imageDialogChoice('Image url', Icons.insert_link, onImageUrlClicked)
        ],
      ),
    );
  }
}
