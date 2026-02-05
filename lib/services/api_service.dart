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
    debugPrint('═' * 60);
    debugPrint('🌐 API SERVICE - FETCH MOMENTS');
    debugPrint('═' * 60);
    
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'refresh': '1',
        'type': '0',
        'auth': '0',
        'per_page': '8',
      });

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add Tag header for pagination if available
      if (tag != null && tag.isNotEmpty) {
        headers['Tag'] = tag;
        debugPrint('📌 Pagination Tag: $tag');
      } else {
        debugPrint('📌 Initial Request (No Tag)');
      }

      // LOG REQUEST DETAILS
      debugPrint('─' * 60);
      debugPrint('📤 REQUEST DETAILS:');
      debugPrint('   URL: $uri');
      debugPrint('   Method: GET');
      debugPrint('   Headers: $headers');
      debugPrint('─' * 60);

      final stopwatch = Stopwatch()..start();
      final response = await http.get(uri, headers: headers);
      stopwatch.stop();

      // LOG RESPONSE DETAILS
      debugPrint('📥 RESPONSE DETAILS:');
      debugPrint('   Status Code: ${response.statusCode}');
      debugPrint('   Response Time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('   Body Length: ${response.body.length} characters');
      debugPrint('   Response Headers:');
      response.headers.forEach((key, value) {
        debugPrint('      $key: $value');
      });
      debugPrint('─' * 60);

      if (response.statusCode == 200) {
        debugPrint('✅ HTTP 200 OK - Parsing JSON...');
        
        final List<dynamic> jsonData = json.decode(response.body);
        debugPrint('📦 JSON Array Length: ${jsonData.length} items');
        
        // LOG FIRST ITEM SAMPLE
        if (jsonData.isNotEmpty) {
          debugPrint('─' * 60);
          debugPrint('📄 SAMPLE DATA (First Item):');
          debugPrint('   Raw JSON: ${jsonData.first}');
          debugPrint('─' * 60);
        }
        
        final moments = jsonData
            .map((json) => Moment.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Successfully parsed ${moments.length} moments');

        // Extract Tag from response headers for next pagination
        final nextTag = response.headers['tag'];
        
        if (nextTag != null && nextTag.isNotEmpty) {
          debugPrint('🏷️  Next Pagination Tag: $nextTag');
        } else {
          debugPrint('🏷️  No Next Tag (End of pagination or not provided)');
        }

        // LOG PARSED MOMENTS DETAILS
        debugPrint('─' * 60);
        debugPrint('📋 PARSED MOMENTS SUMMARY:');
        for (int i = 0; i < moments.length && i < 3; i++) {
          debugPrint('   [$i] Title: ${moments[i].title}');
          debugPrint('       Description: ${moments[i].description.substring(0, moments[i].description.length > 50 ? 50 : moments[i].description.length)}...');
          debugPrint('       Images: ${moments[i].mediaUrls.length}');
          if (moments[i].mediaUrls.isNotEmpty) {
            debugPrint('       First Image: ${moments[i].mediaUrls.first}');
          }
        }
        if (moments.length > 3) {
          debugPrint('   ... and ${moments.length - 3} more items');
        }
        debugPrint('─' * 60);
        debugPrint('✅ SUCCESS: API call completed successfully');
        debugPrint('═' * 60);

        return FeedResponse(
          items: moments,
          nextTag: nextTag,
        );
      } else {
        // ERROR: Non-200 status code
        debugPrint('❌ HTTP ERROR: ${response.statusCode}');
        debugPrint('   Response Body: ${response.body}');
        debugPrint('═' * 60);
        throw Exception('Failed to load moments: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // CATCH ALL ERRORS
      debugPrint('❌ EXCEPTION CAUGHT:');
      debugPrint('   Error Type: ${e.runtimeType}');
      debugPrint('   Error Message: $e');
      debugPrint('   Stack Trace:');
      debugPrint('$stackTrace');
      debugPrint('═' * 60);
      throw Exception('Network error: $e');
    }
  }
}