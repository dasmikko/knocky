import 'dart:ui';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';


class BBCodeHelper implements bbob.NodeVisitor { 
  List<String> urls = List();
  String _elType = 'text'; // Types: text, img, blockquote,
  List<TextSpan> textChildren = List();

  List<String> getUrls(String text) {
    var ast = bbob.parse(text);

    for (final node in ast) {
      node.accept(this);
    }

    print('done with nodes');

    print(textChildren.length);


    return urls;
  }

  void visitText(bbob.Text text) {
    print('visit text');
    
    if (_elType == 'img') {
      urls.add(text.textContent);
    }
  }

  bool visitElementBefore(bbob.Element element) {
    print('visit before');
    print(element);

    if (element.tag == 'img') {
      print('is image');
      _elType = 'img';
    }

    // Handle children
    return true;
  }

  void visitElementAfter(bbob.Element element) {
    print('visit after');
    print(element);
    if (element.tag == 'img') {
      _elType = 'text';
    }
  }
}
