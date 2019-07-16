import 'package:json_annotation/json_annotation.dart';

part 'slateDocument.g.dart';

@JsonSerializable()
class SlateObject {
  final String object;
  final SlateDocument document;

  SlateObject({this.object, this.document});

  factory SlateObject.fromJson(Map<String, dynamic> json) => _$SlateObjectFromJson(json);
  Map<String, dynamic> toJson() => _$SlateObjectToJson(this);
}

@JsonSerializable()
class SlateDocument {
  final String object;
  // final Object data;
  final List<SlateNode> nodes;

  SlateDocument({this.object, this.nodes});

  factory SlateDocument.fromJson(Map<String, dynamic> json) => _$SlateDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$SlateDocumentToJson(this);
}

// Slate Block
@JsonSerializable()
class SlateNode {
  final String object;
  final String type;
  final SlateNodeData data;
  final List<SlateLeaf> leaves;
  final List<SlateNode> nodes;

  SlateNode({this.nodes, this.object, this.type, this.data, this.leaves});

  factory SlateNode.fromJson(Map<String, dynamic> json) => _$SlateNodeFromJson(json);
  Map<String, dynamic> toJson() => _$SlateNodeToJson(this);
}

@JsonSerializable()
class SlateNodeData {
  final String src;
  final NodeDataPostData postData;
  final String href;

  SlateNodeData({this.src, this.postData, this.href});

  factory SlateNodeData.fromJson(Map<String, dynamic> json) => _$SlateNodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$SlateNodeDataToJson(this);
}

@JsonSerializable()
class NodeDataPostData {
  final dynamic threadPage;
  @JsonKey(fromJson: _stringToIntFromJson, toJson: _stringToIntToJson)
  final int threadId;
  @JsonKey(fromJson: _stringToIntFromJson, toJson: _stringToIntToJson)
  final int postId;
  final String username;


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
  final String object;
  final String text;
  final List<SlateLeafMark> marks;

  SlateLeaf({this.object, this.text, this.marks});

  factory SlateLeaf.fromJson(Map<String, dynamic> json) => _$SlateLeafFromJson(json);
  Map<String, dynamic> toJson() => _$SlateLeafToJson(this);
}

@JsonSerializable()
class SlateLeafMark {
  final String object;
  final String type;

  SlateLeafMark({this.object, this.type});

  factory SlateLeafMark.fromJson(Map<String, dynamic> json) => _$SlateLeafMarkFromJson(json);
  Map<String, dynamic> toJson() => _$SlateLeafMarkToJson(this);
}



