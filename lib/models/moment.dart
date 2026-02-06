class Moment {
  final String title;
  final String description;
  final List<String> mediaUrls;
  final String username;
  final String? userAvatar;
  final String timestamp;

  Moment({
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.username,
    this.userAvatar,
    required this.timestamp,
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
      username: json['username'] as String? ?? 'Anonymous',
      userAvatar: json['user_avatar'] as String?,
      timestamp: json['created_at'] as String? ?? '',
    );
  }

  String? get firstImage => mediaUrls.isNotEmpty ? mediaUrls.first : null;
  
  String get timeAgo {
    if (timestamp.isEmpty) return 'Just now';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }
}