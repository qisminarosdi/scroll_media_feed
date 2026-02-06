// lib/views/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/feed_controller.dart';
import '../widgets/feed_item.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/loading_view.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  static const double _itemHeight = 480.0;
  static const double _preloadThreshold = 5.0;
  static const Color _primaryColor = Color(0xFF705196);
  static const Color _backgroundColor = Color(0xFFFAF8FF);

  @override
  void initState() {
    super.initState();
    _initializeFeed();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeFeed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedController>().loadInitialFeed();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final controller = context.read<FeedController>();
      final threshold = _itemHeight * _preloadThreshold;

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
            textColor: _primaryColor,
            onPressed: controller.retryPagination,
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[900],
        ),
      );
      controller.clearPaginationError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<FeedController>(
        builder: (context, controller, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPaginationErrorSnackbar(controller);
          });

          if (controller.isInitialLoad) {
            return const LoadingView();
          }

          if (controller.initialError != null && controller.isEmpty) {
            return ErrorView(onRetry: controller.retryInitialLoad);
          }

          if (controller.isEmpty) {
            return const EmptyView();
          }

          return _buildFeedList(controller);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Feed',
        style: TextStyle(
          color: _primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: _primaryColor,
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primaryColor.withOpacity(0.1),
                Colors.grey[200]!,
              ],
            ),
          ),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildFeedList(FeedController controller) {
    return RefreshIndicator(
      onRefresh: controller.loadInitialFeed,
      color: _primaryColor,
      strokeWidth: 2.5,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
        itemCount: controller.moments.length + 1,
        itemBuilder: (context, index) {
          if (index < controller.moments.length) {
            return FeedItem(moment: controller.moments[index]);
          }

          if (controller.isLoading && controller.hasMore) {
            return _buildLoadingIndicator();
          }

          if (!controller.hasMore) {
            return _buildEndOfFeed();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: _primaryColor.withOpacity(0.7),
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}