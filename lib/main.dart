import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/history_provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/core/providers/trending_provider.dart';
import 'package:toolshub/config/firebase_options.dart';
import 'package:toolshub/features/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ToolProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => BookmarkProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => HistoryProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => TrendingProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tool Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF050506),
          // ignore: deprecated_member_use
          background: const Color(0xFF050506),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050506),
      ),
      home: const AppShell(),
    );
  }
}
