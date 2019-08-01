import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';

class BBCodeHandler implements bbob.NodeVisitor {
  SlateDocument document = SlateDocument(object: 'document', nodes: List());
  StringBuffer _leafContentBuffer = StringBuffer();
  List<ThreadPost> _replyList = List();
  Thread _thread;

  SlateNode _lastElement;
  List<SlateLeafMark> _leafMarks = List();

  SlateObject parse(String text, Thread thread, List<ThreadPost> replyList) {
    _thread = thread;
    _replyList = replyList;
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
      _lastElement.nodes.add(textLeafNode);
      _leafContentBuffer = StringBuffer();
      document.nodes.add(_lastElement);
    }

    return SlateObject(object: 'value', document: document);
  }

  void visitText(bbob.Text text) {
    if (_lastElement == null) {
      _lastElement = SlateNode(
          object: 'block',
          type: 'paragraph',
          data: SlateNodeData(),
          nodes: List());
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
      _lastElement = SlateNode(
          object: 'block',
          type: 'paragraph',
          data: SlateNodeData(),
          nodes: List());
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
        _lastElement = SlateNode(
            object: 'block',
            type: 'paragraph',
            data: SlateNodeData(),
            nodes: List());
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
        _lastElement = SlateNode(
            object: 'block',
            type: 'paragraph',
            data: SlateNodeData(),
            nodes: List());
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
      _lastElement =
          SlateNode(object: 'block', type: 'heading-two', data: null, nodes: [
        SlateNode(
          object: 'text',
          leaves: [],
        )
      ]);
    }

    if (element.tag == 'blockquote') {
      _lastElement =
          SlateNode(object: 'block', type: 'block-quote', data: null, nodes: [
        SlateNode(
          object: 'text',
          leaves: [],
        )
      ]);
    }

    if (element.tag == 'youtube') {
      document.nodes.add(SlateNode(
          object: 'block',
          type: 'youtube',
          data: SlateNodeData(src: element.children.first.textContent),
          nodes: []));
      return false;
    }

    if (element.tag == 'video') {
      document.nodes.add(SlateNode(
          object: 'block',
          type: 'video',
          data: SlateNodeData(src: element.children.first.textContent),
          nodes: []));
      return false;
    }

    if (element.tag == 'userquote') {
      int replyIndex = int.parse(element.children.first.textContent) - 1;

      if (_replyList[replyIndex] != null) {
        ThreadPost reply = _replyList[replyIndex];

        document.nodes.add(
          SlateNode(
              object: 'block',
              type: 'userquote',
              data: SlateNodeData(
                postData: NodeDataPostData(
                  postId: reply.id,
                  threadId: _thread.id,
                  threadPage: _thread.currentPage,
                  username: reply.user.username,
                ),
              ),
              nodes: reply.content.document.nodes),
        );
      }
      return false;
    }

    if (element.tag == 'ul') {
      _lastElement = SlateNode(
          object: 'block',
          type: 'bulleted-list',
          data: SlateNodeData(),
          nodes: []);
    }

    if (element.tag == 'ol') {
      _lastElement = SlateNode(
          object: 'block',
          type: 'numbered-list',
          data: SlateNodeData(),
          nodes: []);
    }

    if (element.tag == 'li') {
      _lastElement.nodes.add(
        SlateNode(
            object: 'block',
            type: 'list-item',
            data: SlateNodeData(),
            nodes: []),
      );
    }

    // Handle children
    return true;
  }

  void visitElementAfter(bbob.Element element) {
    switch (element.tag) {
      case 'li':
        SlateNode textNode = SlateNode(object: 'text', leaves: [
          SlateLeaf(
              text: _leafContentBuffer.toString(),
              marks: _leafMarks,
              object: 'leaf')
        ]);

        // Reset leaf marks
        _leafMarks = List();

        _lastElement.nodes.last.nodes.add(textNode);
        _leafContentBuffer = StringBuffer();
        break;
      case 'ul':
        document.nodes.add(_lastElement);
        _lastElement = null;
        break;
      default:
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

  Map<String, dynamic> slateDocumentToBBCode(SlateDocument document) {
    String bbcode = _handleNodes(document.nodes).trim();
    return {'bbcode': bbcode, 'userquotes': {}};
  }

  String _inlineHandler(SlateNode object, SlateNode node) {
    StringBuffer content = new StringBuffer();

    if (node.type == 'link') {
      content.write('[url]');
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

    nodes.forEach((node) {
      if (asList) {
        print(node.type);
      }

      // Handle blocks
      switch (node.type) {
        case 'paragraph':
          node.nodes.asMap().forEach((i, line) {
            if (line.leaves != null) {
              content.write(_leafHandler(line.leaves));
            }

            // Handle inline element
            if (line.object == 'inline') {
              // Handle links
              if (line.type == 'link') {
                line.nodes.forEach((inlineNode) {
                  inlineNode.leaves.forEach((leaf) {
                    content.write('[url]' + leaf.text + '[/url]');
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
          });
          content.write('\n');
          break;
        case 'heading-one':
          node.nodes.forEach((line) {
            content.write('[h1]');
            if (line.leaves != null) {
              // Handle node leaves
              content.write(_leafHandler(line.leaves));
            }

            // Handle inline element
            if (line.object == 'inline') {
              // Handle links
              content.write(_inlineHandler(node, line));
            }
          });
          content.write('[/h1]\n');
          //widgets.add(headingToWidget(node));
          break;
        case 'heading-two':
          node.nodes.forEach((line) {
            content.write('[h2]');
            if (line.leaves != null) {
              // Handle node leaves
              content.write(_leafHandler(line.leaves));
            }

            // Handle inline element
            if (line.object == 'inline') {
              // Handle links
              content.write(_inlineHandler(node, line));
            }
          });
          content.write('[/h2]\n');
          break;
        case 'userquote':
          //widgets.add(userquoteToWidget(node, isChild: isChild));
          break;
        case 'bulleted-list':
          content.write('[ul]');
          List<String> listItemsContent = List();
          listItemsContent.addAll(_handleNodes(node.nodes, asList: true));
          listItemsContent.forEach((item) {
            content.write('[li]' + item + '[/li]');
          });
          content.write('[/ul]\n');
          break;
        case 'numbered-list':
          //widgets.add(numberedListToWidget(node));
          break;
        case 'list-item':
          node.nodes.asMap().forEach((i, line) {
            if (line.leaves != null) {
              content.write(_leafHandler(line.leaves));
            }

            // Handle inline element
            if (line.object == 'inline') {
              // Handle links
              if (line.type == 'link') {
                line.nodes.forEach((inlineNode) {
                  inlineNode.leaves.forEach((leaf) {
                    content.write('[url]' + leaf.text + '[/url]');
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
          });
          break;
        case 'image':
          content.write('[img]' + node.data.src + '[/img]\n');
          break;
        case 'youtube':
          //(widgets.add(youTubeToWidget(node));
          break;
        case 'block-quote':
          //widgets.add(handleQuotes(node));
          break;
        case 'twitter':
          //widgets.add(EmbedWidget(url: node.data.src));
          break;
        case 'video':
          //widgets.add(handleVideo(node));
          break;
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
