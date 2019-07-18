import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:knocky/models/slateDocument.dart';

class BBCodeHandler implements bbob.NodeVisitor {
  SlateDocument document = SlateDocument(object: 'document', nodes: List());
  StringBuffer _leafContentBuffer = StringBuffer();

  SlateNode _lastElement = null;
  List<SlateLeafMark> _leafMarks = List();

  SlateObject parse(String text) {
    print(text);

    var ast = bbob.parse(text);
    print(ast);

    for (final node in ast) {
      node.accept(this);
    }

    // if string buffer is not empty, add a leaf
    if (_leafContentBuffer.isNotEmpty || (_lastElement != null && _lastElement.nodes.length > 0)) {
      // New leaf is appearing, add old leaf to node
      SlateNode textLeafNode = SlateNode(object: 'text', leaves: [
        SlateLeaf(
            text: _leafContentBuffer.toString(),
            marks: _leafMarks,
            object: 'leaf')
      ]);

      // Add node
      _lastElement.nodes.add(textLeafNode);
      _leafContentBuffer = StringBuffer();
      document.nodes.add(_lastElement);
    }

    return SlateObject(object: 'value', document: document);
  }

  void visitText(bbob.Text text) {
    if (_lastElement == null) {
      _lastElement =
          SlateNode(object: 'block', type: 'paragraph', data: SlateNodeData(), nodes: List());
    }

    if (text.textContent == '\n') {
      // New leaf is appearing, add old leaf to node
      SlateNode textLeafNode = SlateNode(object: 'text', leaves: [
        SlateLeaf(
            text: _leafContentBuffer.toString(),
            marks: _leafMarks,
            object: 'leaf'),
      ]);

      // Reset leaf marks
      _leafMarks = List();

      // Add node
      _lastElement.nodes.add(textLeafNode);
      _leafContentBuffer = StringBuffer();

      document.nodes.add(_lastElement);

      // Paragraph ended, to reset last element
      _lastElement =
          SlateNode(object: 'block', type: 'paragraph', data: SlateNodeData(), nodes: List());
    } else {
      _leafContentBuffer.write(text.textContent);
    }
  }

  bool visitElementBefore(bbob.Element element) {
    if (_leafContentBuffer.isNotEmpty) {
      // New leaf is appearing, add old leaf to node
      SlateNode textNode = SlateNode(object: 'text', leaves: [
        SlateLeaf(
            text: _leafContentBuffer.toString(),
            marks: _leafMarks,
            object: 'leaf')
      ]);

      // Reset leaf marks
      _leafMarks = List();

      _lastElement.nodes.add(textNode);
      _leafContentBuffer = StringBuffer();
    }

    // Text styles
    if (element.tag == 'b') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'bold'));
    }
    if (element.tag == 'i') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'italic'));
    }
    if (element.tag == 'u') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'underlined'));
    }
    if (element.tag == 'code') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'code'));
    }
    if (element.tag == 'spoiler') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'spoiler'));
    }

    if (element.tag == 'url') {
      if (_lastElement == null) {
        _lastElement =
            SlateNode(object: 'block', type: 'paragraph', data: SlateNodeData(), nodes: List());
      }

      _lastElement.nodes.add(SlateNode(
          object: 'inline',
          type: 'link',
          data: SlateNodeData(href: element.children.first.textContent),
          nodes: [
            SlateNode(object: 'text', leaves: [
              SlateLeaf(
                  object: 'leaf',
                  text: element.children.first.textContent,
                  marks: [])
            ])
          ]));
      // Do not handle children
      return false;
    }

    if (element.tag == 'img') {
      if (_lastElement != null) {
        _lastElement =
            SlateNode(object: 'block', type: 'paragraph', data: SlateNodeData(), nodes: List());
      }

      SlateNode imgNode = SlateNode(
        object: 'block',
        type: 'image',
        data: SlateNodeData(src: element.children.first.textContent),
        nodes: List(),
      );

      document.nodes.add(imgNode);
      // Do not handle children
      return false;
    }

    if (element.tag == 'h1') {
      _lastElement = SlateNode(
        object: 'block',
        type: 'heading-one',
        data: null,
        nodes: [
          SlateNode(object: 'text', leaves: []),
        ],
      );
    }

    if (element.tag == 'h2') {
      _lastElement = SlateNode(
        object: 'block',
        type: 'heading-two',
        data: null,
        nodes: [
          SlateNode(object: 'text', leaves: [],)
        ]
      );
    }

    if (element.tag == 'blockquote') {
      _lastElement = SlateNode(
        object: 'block',
        type: 'block-quote',
        data: null,
        nodes: [
          SlateNode(object: 'text', leaves: [],)
        ]
      );
    }

    if (element.tag == 'youtube') {
      _lastElement = SlateNode(
        object: 'block',
        type: 'block-quote',
        data: SlateNodeData(src: element.children.first.textContent),
        nodes: []
      );
      return false;
    }

    if (element.tag == 'video') {
      _lastElement = SlateNode(
        object: 'block',
        type: 'video',
        data: SlateNodeData(src: element.children.first.textContent),
        nodes: []
      );
      return false;
    }

    // Handle children
    return true;
  }

  void visitElementAfter(bbob.Element element) {
    // Tag is done, add leaf
    SlateNode textNode = SlateNode(object: 'text', leaves: [
      SlateLeaf(
          text: _leafContentBuffer.toString(),
          marks: _leafMarks,
          object: 'leaf')
    ]);

    // Reset leaf marks
    _leafMarks = List();

    _lastElement.nodes.add(textNode);
    _leafContentBuffer = StringBuffer();
  }
}
