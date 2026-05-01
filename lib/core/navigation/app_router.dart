import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toolshub/features/shell/app_shell.dart';
import 'package:toolshub/features/home/screens/home_screen.dart';
import 'package:toolshub/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:toolshub/features/trending/screens/trending_screen.dart';
import 'package:toolshub/features/ai_assistant/screens/ai_assistant_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/bookmarks',
          builder: (context, state) => const BookmarksScreen(),
        ),
        GoRoute(
          path: '/trending',
          builder: (context, state) => const TrendingScreen(),
        ),
        GoRoute(
          path: '/assistant',
          builder: (context, state) => const AiAssistantScreen(),
        ),
      ],
    ),
    // Firebase auth callback route
    GoRoute(
      path: '/__/auth/handler',
      builder: (context, state) {
        // Firebase will handle the auth callback automatically
        // Redirect to home after processing
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    ),
  ],
  redirect: (context, state) {
    // Handle Firebase auth redirects
    if (state.uri.path.startsWith('/__/auth/')) {
      return null; // Let Firebase handle auth routes
    }
    return null; // No redirect
  },
);
