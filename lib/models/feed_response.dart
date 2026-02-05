// lib/models/feed_response.dart
import 'moment.dart';

class FeedResponse {
  final List<Moment> items;
  final String? nextTag;

  FeedResponse({
    required this.items,
    this.nextTag,
  });
}