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
}
