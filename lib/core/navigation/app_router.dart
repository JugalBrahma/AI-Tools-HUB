import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toolshub/features/shell/app_shell.dart';
import 'package:toolshub/features/home/screens/home_screen.dart';
import 'package:toolshub/features/categories/screens/categories_page.dart';
import 'package:toolshub/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:toolshub/features/trending/screens/trending_screen.dart';
import 'package:toolshub/features/ai_assistant/screens/ai_assistant_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

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
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesPage(),
        ),
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
  ],
);
