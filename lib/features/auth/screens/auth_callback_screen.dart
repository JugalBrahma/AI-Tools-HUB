import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      // Wait a moment for Firebase to process the auth callback
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // User is authenticated, redirect to home
        if (mounted) {
          context.go('/');
        }
      } else {
        // User not authenticated, redirect to login
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      debugPrint('Auth callback error: $e');
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Completing sign in...'),
          ],
        ),
      ),
    );
  }
}
