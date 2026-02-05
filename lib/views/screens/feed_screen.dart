// lib/views/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/feed_controller.dart';
import '../widgets/feed_item.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/loading_view.dart';

/// Main feed screen - handles UI only, delegates logic to controller
class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _itemHeight = 300.0;

  @override
  void initState() {
    super.initState();
    _initializeFeed();
    _setupScrollListener();
  }

  void _initializeFeed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedController>().loadInitialFeed();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final controller = context.read<FeedController>();
      final threshold = _itemHeight * 5; // 5th item threshold

      if (_scrollController.position.pixels >= threshold) {
        controller.loadMoreMoments();
      }
    });
  }

  void _showPaginationErrorSnackbar(FeedController controller) {
    if (controller.paginationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load more posts'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: controller.retryPagination,
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      controller.clearPaginationError();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Feed'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FeedController>(
        builder: (context, controller, child) {
          // Show pagination error snackbar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPaginationErrorSnackbar(controller);
          });

          // Initial loading
          if (controller.isInitialLoad) {
            return const LoadingView();
          }

          // Initial error
          if (controller.initialError != null && controller.isEmpty) {
            return ErrorView(
              onRetry: controller.retryInitialLoad,
            );
          }

          // Empty state
          if (controller.isEmpty) {
            return const EmptyView();
          }

          // Feed list
          return RefreshIndicator(
            onRefresh: controller.loadInitialFeed,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.moments.length + 1,
              itemBuilder: (context, index) {
                // Feed items
                if (index < controller.moments.length) {
                  return FeedItem(moment: controller.moments[index]);
                }

                // Bottom loader
                if (controller.isLoading && controller.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // End of feed
                if (!controller.hasMore) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'You\'re all caught up!',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}