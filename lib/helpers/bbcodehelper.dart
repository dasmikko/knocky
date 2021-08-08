import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';

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
      TextEditingController controller, String tag, Function onInputChange) {
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
      replaceWith = '[$tag]$selectedText[/$tag]';
    }
    controller.text = controller.text.replaceRange(start, end, replaceWith);
    controller.selection =
        TextSelection.collapsed(offset: start + (tag.length + 2));
    onInputChange.call(controller.text);
  }
}
