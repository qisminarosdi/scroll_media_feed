// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/moment.dart';
import '../models/feed_response.dart';

class ApiService {
  static const String _baseUrl = 'https://pbapi.forwen.com/v5/moments';
  static const String _apiKey = '1363948447663453409ecac';

  /// Fetch moments from API
  /// [tag] - Pagination tag from previous response
  Future<FeedResponse> fetchMoments({String? tag}) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'refresh': '1',
        'type': '0',
        'auth': '0',
        'per_page': '8',
      });

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (tag != null && tag.isNotEmpty) 'Tag': tag,
      };

      debugPrint('Fetching moments${tag != null ? " (page $tag)" : " (initial)"}...');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final moments = jsonData
            .map((json) => Moment.fromJson(json as Map<String, dynamic>))
            .toList();

        final nextTag = response.headers['tag'];
        
        debugPrint('Loaded ${moments.length} moments${nextTag != null ? " (next: $nextTag)" : " (end of feed)"}');

        return FeedResponse(
          items: moments,
          nextTag: nextTag,
        );
      } else if (response.statusCode == 204) {
        debugPrint('End of feed reached');
        return FeedResponse(
          items: [],
          nextTag: null,
        );
      } else {
        debugPrint('API error: ${response.statusCode}');
        throw Exception('Failed to load moments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}