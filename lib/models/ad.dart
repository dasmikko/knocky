class KnockoutAd {
  String? description;
  String? imageUrl;
  String? query;

  KnockoutAd({this.description, this.imageUrl, this.query});

  factory KnockoutAd.fromJson(Map<String, dynamic> json) =>
      KnockoutAd(
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        query: json['query'] as String?,
      );
  Map<String, dynamic> toJson() => {
    'description': description,
    'image_url': imageUrl,
    'query': query,
  };
}
