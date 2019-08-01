import 'package:json_annotation/json_annotation.dart';

part 'slateDocument.g.dart';

@JsonSerializable()
class SlateObject {
  String object;
  @JsonKey(toJson: _documentToJson)
  SlateDocument document;

  SlateObject({this.object, this.document});

  factory SlateObject.fromJson(Map<String, dynamic> json) => _$SlateObjectFromJson(json);
  Map<String, dynamic> toJson() => _$SlateObjectToJson(this);
}

Map _documentToJson(SlateDocument document) => document.toJson();

@JsonSerializable()
class SlateDocument {
  String object;
  Map data = Map<String, String>();
  @JsonKey(toJson: _nodesToJson)
  List<SlateNode> nodes;

  SlateDocument({this.object, this.nodes});

  factory SlateDocument.fromJson(Map<String, dynamic> json) => _$SlateDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$SlateDocumentToJson(this);
}

@JsonSerializable()
class SlateDocumentData {
  @JsonKey(includeIfNull: false)
  String dummy;

  SlateDocumentData({this.dummy});

  factory SlateDocumentData.fromJson(Map<String, dynamic> json) => _$SlateDocumentDataFromJson(json);
  Map<String, dynamic> toJson() => _$SlateDocumentDataToJson(this);
}

List<Map> _nodesToJson(List<SlateNode> nodes) => nodes != null ? nodes.map((node) => node.toJson()).toList() : null;

// Slate Block
@JsonSerializable()
class SlateNode {
  String object;
  @JsonKey(includeIfNull: false)
  String type;
  @JsonKey(toJson: _nodeDataToJson, includeIfNull: false)
  SlateNodeData data;
  @JsonKey(toJson: _leavesToJson, includeIfNull: false)
  List<SlateLeaf> leaves;
  @JsonKey(toJson: _nodesToJson, includeIfNull: false)
  List<SlateNode> nodes;

  SlateNode({this.nodes, this.object, this.type, this.data, this.leaves});

  factory SlateNode.fromJson(Map<String, dynamic> json) => _$SlateNodeFromJson(json);
  Map<String, dynamic> toJson() => _$SlateNodeToJson(this);
}

List<Map> _leavesToJson(List<SlateLeaf> leaves) => leaves != null ? leaves.map((leaf) => leaf.toJson()).toList() : null;
Map _nodeDataToJson(SlateNodeData data) => data != null ? data.toJson() : null;

@JsonSerializable()
class SlateNodeData {
  @JsonKey(includeIfNull: false)
  String src;
  @JsonKey(includeIfNull: false)
  NodeDataPostData postData;
  @JsonKey(includeIfNull: false)
  String href;

  SlateNodeData({this.src, this.postData, this.href});

  factory SlateNodeData.fromJson(Map<String, dynamic> json) => _$SlateNodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$SlateNodeDataToJson(this);
}

//Map _nodeDataPostDataToJson(NodeDataPostData postdata) => postdata != null ? postdata.toJson() : null;

@JsonSerializable()
class NodeDataPostData {
  dynamic threadPage;
  @JsonKey(fromJson: _stringToIntFromJson, toJson: _stringToIntToJson)
  int threadId;
  @JsonKey(fromJson: _stringToIntFromJson, toJson: _stringToIntToJson)
  int postId;
  String username;


  NodeDataPostData({this.threadId, this.username, this.postId, this.threadPage});

  factory NodeDataPostData.fromJson(Map<String, dynamic> json) => _$NodeDataPostDataFromJson(json);
  Map<String, dynamic> toJson() => _$NodeDataPostDataToJson(this);
}

int _stringToIntFromJson(dynamic number) {
  if (number is String) {
    return int.parse(number);
  }
  return number;
}

int _stringToIntToJson(int number) => number;

@JsonSerializable()
class SlateLeaf {
  String object;
  String text;
  @JsonKey(toJson: _leafmarksToJson)
  List<SlateLeafMark> marks;

  SlateLeaf({this.object, this.text, this.marks});

  factory SlateLeaf.fromJson(Map<String, dynamic> json) => _$SlateLeafFromJson(json);
  Map<String, dynamic> toJson() => _$SlateLeafToJson(this);
}

List<Map> _leafmarksToJson(List<SlateLeafMark> marks) => marks != null ? marks.map((mark) => mark.toJson()).toList() : List();

@JsonSerializable()
class SlateLeafMark {
  String object;
  String type;

  SlateLeafMark({this.object, this.type});

  factory SlateLeafMark.fromJson(Map<String, dynamic> json) => _$SlateLeafMarkFromJson(json);
  Map<String, dynamic> toJson() => _$SlateLeafMarkToJson(this);
}



