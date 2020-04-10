class KnockoutDocument {
  List<KnockoutDocumentNode> nodes;

  KnockoutDocument({
    this.nodes,
  });
}

class KnockoutDocumentNode {
  String type;
  String url;
  int mentionUser;
  int postId;
  int threadPage;
  int threadId;
  List<KnockoutDocumentLeaf> children;
  List<KnockoutDocumentNode> nodes;

  /**
   * Current types: text, img, blockquote, youtube, video, twitter, strawpoll, ol, ul
   */

  KnockoutDocumentNode({
    this.type,
    this.url,
    this.mentionUser,
    this.postId,
    this.threadId,
    this.threadPage,
    this.children,
    this.nodes,
  });
}


class KnockoutDocumentLeaf {
  String text;
  String url;
  bool bold;
  bool italic;
  bool underlined;
  bool spoiler;
  bool code;
  bool smartLink;
  bool h1;
  bool h2;


  KnockoutDocumentLeaf({
    this.url,
    this.bold,
    this.code,
    this.italic,
    this.spoiler,
    this.text,
    this.underlined,
    this.smartLink,
    this.h1,
    this.h2
  });

  String toString () {
    return 'text: ${this.text}, Bold: ${this.bold}, Italic: ${this.italic}, Underlined: ${this.underlined}, Code: ${this.code}, Url: ${this.url}, Spoiler: ${spoiler}, SmartLink: ${this.smartLink}, h1: ${this.h1}, h2 ${this.h2}';
  }
}
