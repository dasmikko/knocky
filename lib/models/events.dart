
class KnockoutEvent {
  final String content;
  final DateTime createdAt;
  final int executedBy;
  final int id;

  KnockoutEvent({
    this.content,
    this.createdAt,
    this.id,
    this.executedBy,
  });

  factory KnockoutEvent.fromJson(Map<String, dynamic> json) =>
      KnockoutEvent(
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        id: json['id'],
        executedBy: json['executed_by'],
      );
  
  Map<String, dynamic> toJson() => {
    'content': content,
    'created_at': createdAt,
    'id': id,
    'executed_by': executedBy
  };
}
