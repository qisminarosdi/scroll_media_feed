// lib/controllers/feed_controller.dart
import 'package:flutter/foundation.dart';
import '../models/moment.dart';
import '../services/api_service.dart';

/// Controller handles all business logic for the feed
/// Follows MVC pattern - separates business logic from UI
class FeedController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State
  List<Moment> _moments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _currentTag;
  String? _initialError;
  String? _paginationError;
  bool _isInitialLoad = true;

  // Getters (Public Interface)
  List<Moment> get moments => List.unmodifiable(_moments);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get initialError => _initialError;
  String? get paginationError => _paginationError;
  bool get isInitialLoad => _isInitialLoad;
  bool get isEmpty => _moments.isEmpty;

  /// Load initial feed (called on app start or pull-to-refresh)
  Future<void> loadInitialFeed() async {
    _resetState();
    await _fetchMoments(isInitial: true);
    _isInitialLoad = false;
  }

  /// Load more moments (infinite scroll pagination)
  Future<void> loadMoreMoments() async {
    if (_isLoading || !_hasMore) return;
    await _fetchMoments(isInitial: false);
  }

  /// Retry initial load after error
  void retryInitialLoad() {
    _initialError = null;
    loadInitialFeed();
  }

  /// Retry pagination after error
  void retryPagination() {
    _paginationError = null;
    loadMoreMoments();
  }

  /// Clear pagination error (for snackbar dismissal)
  void clearPaginationError() {
    _paginationError = null;
    notifyListeners();
  }

  /// Check if should preload based on scroll position
  bool shouldPreload(int currentIndex, int totalItems) {
    const preloadThreshold = 5;
    return currentIndex >= preloadThreshold - 1 && !_isLoading && _hasMore;
  }

  // Private Methods

  void _resetState() {
    _isLoading = true;
    _isInitialLoad = true;
    _moments.clear();
    _currentTag = null;
    _hasMore = true;
    _initialError = null;
    _paginationError = null;
    notifyListeners();
  }

  Future<void> _fetchMoments({required bool isInitial}) async {
    _isLoading = true;

    if (isInitial) {
      _initialError = null;
    } else {
      _paginationError = null;
    }

    notifyListeners();

    try {
      final response = await _apiService.fetchMoments(tag: _currentTag);

      _handleSuccessResponse(response);
    } catch (e) {
      _handleError(e, isInitial);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleSuccessResponse(response) {
    if (response.items.isEmpty) {
      _hasMore = false;
    } else {
      _moments.addAll(response.items);
      _currentTag = response.nextTag;

      // If no nextTag, assume no more data
      if (response.nextTag == null || response.nextTag!.isEmpty) {
        _hasMore = false;
      }
    }
  }

  void _handleError(Object error, bool isInitial) {
    final errorMessage = error.toString();
    
    if (isInitial) {
      _initialError = errorMessage;
    } else {
      _paginationError = errorMessage;
    }
    
    debugPrint('Error fetching moments: $errorMessage');
  }
}