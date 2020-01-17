import 'dart:ui';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:knocky/screens/Modals/knockoutDocument.dart';

class BBCodeParser implements bbob.NodeVisitor {
  KnockoutDocument document = new KnockoutDocument(
    nodes: List(),
  );
  StringBuffer _stringBuffer = new StringBuffer();

  KnockoutDocumentNode _lastNode;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  int _tagLevel = 0; 

  KnockoutDocument parse(String text) {
    var ast = bbob.parse(text);

    for (final node in ast) {
      node.accept(this);
    }

    //print('done with nodes');

    // is we still have a node, add it
    if (_lastNode != null) {
      if (_lastNode.type == 'text') removeLastChildIfEmpty();

      document.nodes.add(_lastNode);
      _lastNode = null;
    }

    return document;
  }

  void visitText(bbob.Text text) {
    //print('visit text');

    if (_lastNode == null) {
      _lastNode = KnockoutDocumentNode(
        type: 'text',
        children: [
          new KnockoutDocumentLeaf(
            text: '',
            bold: _isBold,
            italic: _isItalic
          )
        ]
      );
    }

    switch (_lastNode.type) {
      case 'text':
        _lastNode.children.last.text = _lastNode.children.last.text + text.textContent;
        break;
      default:
    }
  }

  bool visitElementBefore(bbob.Element element) {
    //print('visit before');
    //print(element);

    // Text styles
    switch (element.tag) {
      // Text styles
      case 'b':
        _tagLevel++;
        _isBold = true;

        removeLastChildIfEmpty();

        _lastNode.children.add(
          new KnockoutDocumentLeaf(
            text: '',
            bold: _isBold,
            italic: _isItalic,
            underlined: _isUnderlined
          )
        );
        break;
      case 'i':
        _tagLevel++;
        _isItalic = true;

        removeLastChildIfEmpty();

        _lastNode.children.add(
          new KnockoutDocumentLeaf(
            text: '',
            bold: _isBold,
            italic: _isItalic,
            underlined: _isUnderlined
          )
        );
        break;
      case 'u':
        _tagLevel++;
        _isUnderlined = true;

        removeLastChildIfEmpty();

        _lastNode.children.add(
          new KnockoutDocumentLeaf(
            text: '',
            bold: _isBold,
            italic: _isItalic,
            underlined: _isUnderlined
          )
        );
        break;
      case 'img':
        // TODO: Add logic
        break;      
    } 

   
    /*'if (element.tag == 'img') {
      // If we were writing text to string buffer before, add it to document before starting on the next element
      if (_stringBuffer.isNotEmpty) {
        if (_lastNode == null) {
          _lastNode = new KnockoutDocumentNode(
            type: 'text',
            children: List()
          );

          document.nodes.add(_lastNode);
          _lastNode = null;
          _stringBuffer.clear();
        }
      }

      _lastNode = new KnockoutDocumentNode(
        type: 'img',
        url: element.children.first.textContent,
        children: List()
      );

      document.nodes.add(_lastNode);
      _lastNode = null;
      //print('is image');
    }*/

    // Handle children
    return true;
  }

  void visitElementAfter(bbob.Element element) {
    //print('visit after');
    //print(element);

    switch (element.tag) {
      // Text styles
      case 'b':
        _tagLevel--;
        _isBold = false;

        if (_tagLevel == 0) {
          _lastNode.children.add(
            new KnockoutDocumentLeaf(
              text: '',
              bold: _isBold,
              italic: _isItalic,
              underlined: _isUnderlined
            )
          );
        }
        break;
      case 'i':
        _tagLevel--;
        _isItalic = false;
        if (_tagLevel == 0) {
          _lastNode.children.add(
            new KnockoutDocumentLeaf(
              text: '',
              bold: _isBold,
              italic: _isItalic,
              underlined: _isUnderlined
            )
          );
        }
        break;
      case 'u':
        _tagLevel--;
        _isUnderlined = false;
        if (_tagLevel == 0) {
          _lastNode.children.add(
            new KnockoutDocumentLeaf(
              text: '',
              bold: _isBold,
              italic: _isItalic,
              underlined: _isUnderlined
            )
          );
        }
        break;
      // Block elements
      case 'img':
        _stringBuffer.clear();
        break;      
    } 
  }

  void removeLastChildIfEmpty () {
    if(_lastNode.children.last.text == '') _lastNode.children.removeLast();
  }
}