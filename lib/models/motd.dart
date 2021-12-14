class KnockoutMotd {
  String message;
  String buttonLink;
  String buttonName;
  int id;

  KnockoutMotd({this.message, this.buttonLink, this.buttonName, this.id});

  factory KnockoutMotd.fromJson(Map<String, dynamic> json) => KnockoutMotd(
        message: json['message'] as String,
        buttonName: json['buttonName'] as String,
        buttonLink: json['buttonLink'] as String,
        id: json['id'] as int,
      );
  Map<String, dynamic> toJson() => {
        'message': message,
        'buttonName': buttonName,
        'buttonLink': buttonLink,
        'id': id
      };
}
