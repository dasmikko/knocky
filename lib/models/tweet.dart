class Tweet {
  int id;
  String text;
  TweetEntities entities;

  Tweet({
    this.id,
    this.text,
    this.entities,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) => Tweet(
        id: json['id'] as int,
        text: json['text'] as String,
        entities:
            TweetEntities.fromJson(json['entities'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}

class TweetEntities {
  List<TweetEntitiesMedia> media;

  TweetEntities({this.media});

  factory TweetEntities.fromJson(Map<String, dynamic> json) => TweetEntities(
        media: (json as List)
            ?.map((e) => e == null
                ? null
                : TweetEntitiesMedia.fromJson(e as Map<String, dynamic>))
            ?.toList(),
      );
}

class TweetEntitiesMedia {
  int id;
  String mediaUrl;
  String mediaUrlHttps;
  String url;
  String displayUrl;
  String type;

  TweetEntitiesMedia(
      {this.id,
      this.mediaUrl,
      this.displayUrl,
      this.mediaUrlHttps,
      this.type,
      this.url});

  factory TweetEntitiesMedia.fromJson(Map<String, dynamic> json) =>
      TweetEntitiesMedia(
        id: json['id'] as int,
        mediaUrl: json['media_url'] as String,
        displayUrl: json['display_url'] as String,
        mediaUrlHttps: json['media_url_https'] as String,
        type: json['type'] as String,
        url: json['url'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'media_url': mediaUrl,
        'display_url': displayUrl,
        'url': url,
        'media_url_https': mediaUrlHttps,
        'type': type,
      };
}
