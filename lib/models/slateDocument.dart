part 'slateDocument.g.dart';

class SlateObject {
  String? object;
  SlateDocument? document;

  SlateObject({this.object, this.document});

  factory SlateObject.fromJson(Map<String, dynamic> json) =>
      _$SlateObjectFromJson(json);
  Map<String, dynamic> toJson() => _$SlateObjectToJson(this);

  SlateObject.clone(SlateObject slateObject)
      : this(object: slateObject.object, document: slateObject.document);
}

Map _documentToJson(SlateDocument document) => document.toJson();

class SlateDocument {
  String? object;
  Map? data = Map<String, String>();
  List<SlateNode>? nodes;

  SlateDocument({this.object, this.nodes});

  factory SlateDocument.fromJson(Map<String, dynamic> json) =>
      _$SlateDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$SlateDocumentToJson(this);
}

class SlateDocumentData {
  String? dummy;

  SlateDocumentData({this.dummy});

  factory SlateDocumentData.fromJson(Map<String, dynamic> json) =>
      _$SlateDocumentDataFromJson(json);
  Map<String, dynamic> toJson() => _$SlateDocumentDataToJson(this);
}

List<Map>? _nodesToJson(List<SlateNode>? nodes) =>
    nodes != null ? nodes.map((node) => node.toJson()).toList() : null;

// Slate Block
class SlateNode {
  String? object;
  String? type;
  SlateNodeData? data;
  List<SlateLeaf>? leaves;
  List<SlateNode>? nodes;

  SlateNode({this.nodes, this.object, this.type, this.data, this.leaves});

  factory SlateNode.fromJson(Map<String, dynamic> json) =>
      _$SlateNodeFromJson(json);
  Map<String, dynamic> toJson() => _$SlateNodeToJson(this);
}

List<Map>? _leavesToJson(List<SlateLeaf>? leaves) =>
    leaves != null ? leaves.map((leaf) => leaf.toJson()).toList() : null;
Map? _nodeDataToJson(SlateNodeData? data) => data != null ? data.toJson() : null;

class SlateNodeData {
  String? src;
  NodeDataPostData? postData;
  String? href;
  bool? isThumbnail;
  bool? isSmartLink;

  SlateNodeData(
      {this.src, this.postData, this.href, this.isThumbnail, this.isSmartLink});

  factory SlateNodeData.fromJson(Map<String, dynamic> json) =>
      _$SlateNodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$SlateNodeDataToJson(this);
}

Map? _nodeDataPostDataToJson(NodeDataPostData? postdata) =>
    postdata != null ? postdata.toJson() : null;

class NodeDataPostData {
  dynamic threadPage;
  int? threadId;
  int? postId;
  String? username;

  NodeDataPostData(
      {this.threadId, this.username, this.postId, this.threadPage});

  factory NodeDataPostData.fromJson(Map<String, dynamic> json) =>
      _$NodeDataPostDataFromJson(json);
  Map<String, dynamic> toJson() => _$NodeDataPostDataToJson(this);
}

int? _stringToIntFromJson(dynamic number) {
  if (number is String) {
    return int.parse(number);
  }
  return number;
}

int? _stringToIntToJson(int? number) => number;

class SlateLeaf {
  String? object;
  String? text;
  List<SlateLeafMark>? marks;

  SlateLeaf({this.object, this.text, this.marks});

  factory SlateLeaf.fromJson(Map<String, dynamic> json) =>
      _$SlateLeafFromJson(json);
  Map<String, dynamic> toJson() => _$SlateLeafToJson(this);
}

List<Map> _leafmarksToJson(List<SlateLeafMark>? marks) =>
    marks != null ? marks.map((mark) => mark.toJson()).toList() : [];

class SlateLeafMark {
  String? object;
  String? type;

  SlateLeafMark({this.object, this.type});

  factory SlateLeafMark.fromJson(Map<String, dynamic> json) =>
      _$SlateLeafMarkFromJson(json);
  Map<String, dynamic> toJson() => _$SlateLeafMarkToJson(this);
}
