import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:knocky_edge/models/slateDocument.dart';

class BBCodeHandler implements bbob.NodeVisitor {
  SlateNode paragraph = SlateNode(object: 'block', nodes: List());
  StringBuffer _leafContentBuffer = StringBuffer();

  SlateNode _lastElement;
  List<SlateLeafMark> _leafMarks = List();

  SlateNode parse(String text, {type: 'paragraph'}) {
    paragraph.type = type;

    var ast = bbob.parse(text);

    for (final node in ast) {
      node.accept(this);
    }

    // if string buffer is not empty, add a leaf
    if (_leafContentBuffer.isNotEmpty ||
        (_lastElement != null && _lastElement.nodes.length > 0)) {
      // New leaf is appearing, add old leaf to node
      SlateNode textLeafNode = SlateNode(object: 'text', leaves: [
        SlateLeaf(
            text: _leafContentBuffer.toString(),
            marks: _leafMarks,
            object: 'leaf')
      ]);

      // Add node
      paragraph.nodes.add(textLeafNode);
      _leafContentBuffer = StringBuffer();
    }

    return paragraph;
  }

  void visitText(bbob.Text text) {
    _leafContentBuffer.write(text.textContent);
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

      paragraph.nodes.add(textNode);
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
      paragraph.nodes.add(SlateNode(
          object: 'inline',
          type: 'link',
          data: SlateNodeData(
              href: element.children.first.textContent,
              isSmartLink: element.attributes['rich'] != null ? true : false),
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

    paragraph.nodes.add(textNode);
    _leafContentBuffer = StringBuffer();
  }

  String slateParagraphToBBCode(SlateNode node) {
    String bbcode = _handleNodes(node.nodes).trim();
    return bbcode;
  }

  String _inlineHandler(SlateNode object, SlateNode node) {
    StringBuffer content = new StringBuffer();

    if (node.type == 'link') {
      content.write(node.data.isSmartLink ? '[url rich=true]' : '[url]');
      node.nodes.forEach((inlineNode) {
        inlineNode.leaves.forEach((leaf) {
          content.write(leaf.text);
        });
      });
      content.write('[/url]');
    } else {
      node.nodes.forEach((inlineNode) {
        inlineNode.leaves.forEach((leaf) {
          content.write(leaf.text);
        });
      });
    }
    return content.toString();
  }

  dynamic _handleNodes(List<SlateNode> nodes,
      {bool isChild = false, bool asList = false}) {
    StringBuffer content = new StringBuffer();
    List<String> contentItems = List();

    nodes.forEach((line) {
      if (line.leaves != null) {
        content.write(_leafHandler(line.leaves));
      }

      // Handle inline element
      if (line.object == 'inline') {
        // Handle links
        if (line.type == 'link') {
          line.nodes.forEach((inlineNode) {
            inlineNode.leaves.forEach((leaf) {
              String linktext = '';
              if (line.data.isSmartLink != null && line.data.isSmartLink) {
                linktext = '[url rich=true]' + leaf.text + '[/url]';
              } else {
                linktext = '[url]' + leaf.text + '[/url]';
              }
              content.write(linktext);
            });
          });
        } else {
          line.nodes.forEach((inlineNode) {
            inlineNode.leaves.forEach((leaf) {
              content.write(leaf.text);
            });
          });
        }
      }

      if (asList) {
        contentItems.add(content.toString());
        content.clear();
      }
    });

    if (asList) {
      return contentItems;
    }
    print(content.toString());
    return content.toString();
  }

  String _leafHandler(List<SlateLeaf> leaves) {
    StringBuffer content = new StringBuffer();
    leaves.forEach((leaf) {
      bool isBold = leaf.marks.where((mark) => mark.type == 'bold').length > 0;

      bool isItalic =
          leaf.marks.where((mark) => mark.type == 'italic').length > 0;

      bool isUnderlined =
          leaf.marks.where((mark) => mark.type == 'underlined').length > 0;

      bool isCode = leaf.marks.where((mark) => mark.type == 'code').length > 0;

      bool isSpoiler =
          leaf.marks.where((mark) => mark.type == 'spoiler').length > 0;

      if (isBold) content.write('[b]' + leaf.text + '[/b]');
      if (isItalic) content.write('[i]' + leaf.text + '[/i]');
      if (isUnderlined) content.write('[u]' + leaf.text + '[/u]');
      if (isCode) content.write('[code]' + leaf.text + '[/code]');
      if (isSpoiler) content.write('[spoiler]' + leaf.text + '[/spoiler]');
      if (!isBold && !isItalic && !isUnderlined && !isCode && !isCode)
        content.write(leaf.text);
    });
    return content.toString();
  }
}
