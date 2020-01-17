class KnockoutDocument {
  List<KnockoutDocumentNode> nodes;

  KnockoutDocument({
    this.nodes,
  });
}

class KnockoutDocumentNode {
  String type;
  String url;
  List<KnockoutDocumentLeaf> children;

  KnockoutDocumentNode({
    this.type,
    this.url,
    this.children,
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

  KnockoutDocumentLeaf({
    this.url,
    this.bold,
    this.code,
    this.italic,
    this.spoiler,
    this.text,
    this.underlined,
  });

  String toString () {
    return 'text: ${this.text}, Bold: ${this.bold}, Italic: ${this.italic}, Underlined: ${this.underlined}, Code: ${this.code}, Url: ${this.url}, Spoiler: ${spoiler}';
  }
}
