import 'package:flutter/material.dart';
import 'package:toolshub/features/auth/screens/login_screen.dart';
import 'package:toolshub/features/subscription/screens/subscription_screen.dart';
import 'package:toolshub/features/profile/screens/profile_screen.dart';

/// Centralized navigation helper for the app.
///
/// Call these static methods instead of manually building routes.
/// All transitions are standardized here so changes propagate everywhere.
class AppNavigator {
  AppNavigator._(); // Prevent instantiation

  // ── Transitions ──────────────────────────────────────────────────────────

  /// Standard fade transition used across the app.
  static Route<T> _fadeRoute<T>(Widget page, {bool fullscreen = false}) {
    return PageRouteBuilder<T>(
      fullscreenDialog: fullscreen,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// Slide-up transition for modals / full-screen dialogs.
  static Route<T> _slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      fullscreenDialog: true,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
                  .animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // ── Login ────────────────────────────────────────────────────────────────

  /// Opens the login screen with a fade transition.
  /// [closeDrawer] — pass true when navigating from an open drawer.
  static void toLogin(BuildContext context, {bool closeDrawer = false}) {
    if (closeDrawer) Navigator.pop(context);
    Navigator.of(context).push(
      _fadeRoute(
        LoginScreen(onDismiss: () => Navigator.of(context).pop()),
      ),
    );
  }

  // ── Subscription ─────────────────────────────────────────────────────────

  /// Opens the subscription/pricing screen as a full-screen dialog.
  /// [closeDrawer] — pass true when navigating from an open drawer.
  static void toSubscription(BuildContext context,
      {bool closeDrawer = false}) {
    if (closeDrawer) Navigator.pop(context);
    Navigator.of(context).push(
      _slideUpRoute(
        SubscriptionScreen(onDismiss: () => Navigator.of(context).pop()),
      ),
    );
  }

  // ── Profile ──────────────────────────────────────────────────────────────

  /// Opens the profile screen as a full-screen dialog.
  /// [closeDrawer] — pass true when navigating from an open drawer.
  static void toProfile(BuildContext context, {bool closeDrawer = false}) {
    if (closeDrawer) Navigator.pop(context);
    Navigator.of(context).push(
      _slideUpRoute(
        ProfileScreen(onDismiss: () => Navigator.of(context).pop()),
      ),
    );
  }

  // ── Generic Push ─────────────────────────────────────────────────────────

  /// Push any screen with the standard fade transition.
  static void pushFade(BuildContext context, Widget page) {
    Navigator.of(context).push(_fadeRoute(page));
  }

  /// Push any screen with the slide-up modal transition.
  static void pushSlideUp(BuildContext context, Widget page) {
    Navigator.of(context).push(_slideUpRoute(page));
  }
}
