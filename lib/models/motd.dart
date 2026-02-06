/// Message of the Day from the Knockout.chat API.
class Motd {
  final int id;
  final String message;
  final String? buttonLink;
  final String? buttonName;

  Motd({
    required this.id,
    required this.message,
    this.buttonLink,
    this.buttonName,
  });

  factory Motd.fromJson(Map<String, dynamic> json) {
    return Motd(
      id: json['id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      buttonLink: json['buttonLink'] as String?,
      buttonName: json['buttonName'] as String?,
    );
  }

  bool get hasButton =>
      buttonName != null &&
      buttonName!.isNotEmpty &&
      buttonLink != null &&
      buttonLink!.isNotEmpty;
}
