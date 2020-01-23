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
  bool _isCode = false;
  bool _isSpoiler = false;
  bool _isQuote = false;
  bool _isH1 = false;
  bool _isH2 = false;
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
        children: List()
      );
      addEmptyLeafToChildren();
    }

    if (_lastNode.children.length == 0) addEmptyLeafToChildren();

    switch (_lastNode.type) {
      case 'text':
        _lastNode.children.last.text = _lastNode.children.last.text + text.textContent;
        break;
      case 'blockquote':
        _lastNode.children.last.text = _lastNode.children.last.text + text.textContent;
        break;
      case 'li':
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
        addEmptyLeafToChildren();
        break;
      case 'i':
        _tagLevel++;
        _isItalic = true;

        removeLastChildIfEmpty();
        addEmptyLeafToChildren();
        break;
      case 'u':
        _tagLevel++;
        _isUnderlined = true;

        removeLastChildIfEmpty();
        addEmptyLeafToChildren(); 
        break;
      case 'code':
        _tagLevel++;
        _isCode = true;

        removeLastChildIfEmpty();
        addEmptyLeafToChildren();
        break;
      case 'spoiler':
        _tagLevel++;
        _isCode = true;

        removeLastChildIfEmpty();
        addEmptyLeafToChildren();
        break;
      case 'h1':
        _tagLevel++;
        _isH1 = true;

        removeLastChildIfEmpty();
        addEmptyLeafToChildren();
        break;
      case 'h2':
        _tagLevel++;
        _isH2 = true;

        removeLastChildIfEmpty();
        addEmptyLeafToChildren();
        break;
      case 'url':
        _tagLevel++;
        removeLastChildIfEmpty();

        _lastNode.children.add(
          new KnockoutDocumentLeaf(
            text: '',
            url: element.attributes['href'] != null ? element.attributes['href'] : element.textContent,
            smartLink: element.attributes['smart'] != null ? true : false,
            bold: _isBold,
            italic: _isItalic,
            underlined: _isUnderlined,
            code: _isCode,
            spoiler: _isSpoiler
          )
        );
        break;
      case 'img':
        if (_lastNode != null) {
          document.nodes.add(_lastNode);
        }

        document.nodes.add(
          new KnockoutDocumentNode(
            type: 'img',
            url: element.children.first.textContent
          )
        );
        _lastNode = null;
        return false; // Ignore child elements
        break; 
      case 'blockquote':
        if (_lastNode != null) {
          document.nodes.add(_lastNode);
        }

        _lastNode = new KnockoutDocumentNode(
          type: 'blockquote',
          children: List()
        );
        break;
      case 'ol':
      case 'ul':
        if (_lastNode != null) {
          document.nodes.add(_lastNode);
        }

        document.nodes.add(
          new KnockoutDocumentNode(
            type: 'ul',
            nodes: List()
          )
        );
        break;
      case 'li':
        _lastNode = new KnockoutDocumentNode(
          type: 'li',
          children: List()
        );
        break;
    } 

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
          addEmptyLeafToChildren();
        }
        break;
      case 'i':
        _tagLevel--;
        _isItalic = false;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      case 'u':
        _tagLevel--;
        _isUnderlined = false;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      case 'code':
        _tagLevel--;
        _isCode = false;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      case 'spoiler':
        _tagLevel--;
        _isSpoiler = false;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      case 'h1':
        _tagLevel--;
        _isH1 = false;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      case 'h2':
        _tagLevel--;
        _isH2 = false;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      case 'url':
        _tagLevel--;
        if (_tagLevel == 0) {
          addEmptyLeafToChildren();
        }
        break;
      // Block elements
      case 'img':
        break;  
      case 'blockquote':
        document.nodes.add(_lastNode);
        _lastNode = null;
        break;
      case 'ol':
      case 'ul':
        //document.nodes.add(_lastNode);
        //_lastNode = null;
        break;
      case 'li':
        // Add the list item to the last ul/ol in the nodes list
        // Note that the code expects, that the last node is an list element
        document.nodes.last.nodes.add(_lastNode);
        _lastNode = null;
        break;
    } 
  }

  void removeLastChildIfEmpty () {
    if(
      _lastNode != null && 
      _lastNode.children.length > 0 && 
      _lastNode.children.last.text == ''
      ) _lastNode.children.removeLast();
  }

  void addEmptyLeafToChildren () {
    if (_lastNode == null) {
      _lastNode = KnockoutDocumentNode(
        type: 'text',
        children: List()
      );
    }

    _lastNode.children.add(
      new KnockoutDocumentLeaf(
        text: '',
        bold: _isBold,
        italic: _isItalic,
        underlined: _isUnderlined,
        code: _isCode,
        spoiler: _isSpoiler,
        h1: _isH1,
        h2: _isH2
      )
    );
  }
}