// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slateDocument.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlateObject _$SlateObjectFromJson(Map<String, dynamic> json) {
  return SlateObject(
    object: json['object'] as String,
    document: json['document'] == null
        ? null
        : SlateDocument.fromJson(json['document'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SlateObjectToJson(SlateObject instance) =>
    <String, dynamic>{
      'object': instance.object,
      'document': _documentToJson(instance.document),
    };

SlateDocument _$SlateDocumentFromJson(Map<String, dynamic> json) {
  return SlateDocument(
    object: json['object'] as String,
    nodes: (json['nodes'] as List)
        ?.map((e) =>
            e == null ? null : SlateNode.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )..data = json['data'] as Map<String, dynamic>;
}

Map<String, dynamic> _$SlateDocumentToJson(SlateDocument instance) =>
    <String, dynamic>{
      'object': instance.object,
      'data': instance.data,
      'nodes': _nodesToJson(instance.nodes),
    };

SlateDocumentData _$SlateDocumentDataFromJson(Map<String, dynamic> json) {
  return SlateDocumentData(
    dummy: json['dummy'] as String,
  );
}

Map<String, dynamic> _$SlateDocumentDataToJson(SlateDocumentData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('dummy', instance.dummy);
  return val;
}

SlateNode _$SlateNodeFromJson(Map<String, dynamic> json) {
  return SlateNode(
    nodes: (json['nodes'] as List)
        ?.map((e) =>
            e == null ? null : SlateNode.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    object: json['object'] as String,
    type: json['type'] as String,
    data: json['data'] == null
        ? null
        : SlateNodeData.fromJson(json['data'] as Map<String, dynamic>),
    leaves: (json['leaves'] as List)
        ?.map((e) =>
            e == null ? null : SlateLeaf.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SlateNodeToJson(SlateNode instance) {
  final val = <String, dynamic>{
    'object': instance.object,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('data', _nodeDataToJson(instance.data));
  writeNotNull('leaves', _leavesToJson(instance.leaves));
  writeNotNull('nodes', _nodesToJson(instance.nodes));
  return val;
}

SlateNodeData _$SlateNodeDataFromJson(Map<String, dynamic> json) {
  return SlateNodeData(
    src: json['src'] as String,
    postData: json['postData'] == null
        ? null
        : NodeDataPostData.fromJson(json['postData'] as Map<String, dynamic>),
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$SlateNodeDataToJson(SlateNodeData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', instance.src);
  writeNotNull('postData', _nodeDataPostDataToJson(instance.postData));
  writeNotNull('href', instance.href);
  return val;
}

NodeDataPostData _$NodeDataPostDataFromJson(Map<String, dynamic> json) {
  return NodeDataPostData(
    threadId: _stringToIntFromJson(json['threadId']),
    username: json['username'] as String,
    postId: _stringToIntFromJson(json['postId']),
    threadPage: json['threadPage'],
  );
}

Map<String, dynamic> _$NodeDataPostDataToJson(NodeDataPostData instance) =>
    <String, dynamic>{
      'threadPage': instance.threadPage,
      'threadId': _stringToIntToJson(instance.threadId),
      'postId': _stringToIntToJson(instance.postId),
      'username': instance.username,
    };

SlateLeaf _$SlateLeafFromJson(Map<String, dynamic> json) {
  return SlateLeaf(
    object: json['object'] as String,
    text: json['text'] as String,
    marks: (json['marks'] as List)
        ?.map((e) => e == null
            ? null
            : SlateLeafMark.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SlateLeafToJson(SlateLeaf instance) => <String, dynamic>{
      'object': instance.object,
      'text': instance.text,
      'marks': _leafmarksToJson(instance.marks),
    };

SlateLeafMark _$SlateLeafMarkFromJson(Map<String, dynamic> json) {
  return SlateLeafMark(
    object: json['object'] as String,
    type: json['type'] as String,
  );
}

Map<String, dynamic> _$SlateLeafMarkToJson(SlateLeafMark instance) =>
    <String, dynamic>{
      'object': instance.object,
      'type': instance.type,
    };
