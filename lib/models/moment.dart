// lib/models/moment.dart
class Moment {
  final String title;
  final String description;
  final List<String> mediaUrls;

  Moment({
    required this.title,
    required this.description,
    required this.mediaUrls,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    final medias = json['medias'] as List<dynamic>? ?? [];
    final mediaUrls = medias
        .map((media) => media['media_filename'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    return Moment(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mediaUrls: mediaUrls,
    );
  }

  String? get firstImage => mediaUrls.isNotEmpty ? mediaUrls.first : null;
}