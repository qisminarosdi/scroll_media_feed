import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../views/screens/feed_screen.dart';

class MediaFeedApp extends StatelessWidget {
  const MediaFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Feed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const FeedScreen(),
    );
  }
}