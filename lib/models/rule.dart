class KnockoutRule {
  int? cardinality;
  String? category;
  DateTime? createdAt;
  String? description;
  int? id;
  int? rulableId;
  String? rulableType;
  String? title;
  DateTime? updatedAt;

  KnockoutRule({
    this.cardinality,
    this.category,
    this.createdAt,
    this.description,
    this.id,
    this.rulableId,
    this.rulableType,
    this.title,
    this.updatedAt,
  });

  factory KnockoutRule.fromJson(Map<String, dynamic> json) => KnockoutRule(
        cardinality: json["cardinality"] == null ? null : json["cardinality"],
        category: json["category"] == null ? null : json["category"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        description: json["description"] == null ? null : json["description"],
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );
  Map<String, dynamic> toJson() => {
        'cardinality': cardinality,
        'category': category,
        'createdAt': createdAt?.toIso8601String(),
        'description': description,
        'id': id,
        'title': title,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
