import 'package:flutter/material.dart';
import 'package:toolshub/core/utils/html_stub.dart'
    if (dart.library.html) 'dart:html'
    as html;
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/features/auth/screens/login_screen.dart';
import 'package:toolshub/features/home/screens/home_screen.dart';
import 'package:toolshub/features/categories/screens/categories_page.dart';
import 'package:toolshub/features/home/widgets/top_nav_bar.dart';
import 'package:toolshub/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:toolshub/features/profile/screens/profile_screen.dart';
import 'package:toolshub/features/trending/screens/trending_screen.dart';
import 'package:toolshub/features/ai_assistant/screens/ai_assistant_screen.dart';
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/core/navigation/app_navigator.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkUrlForSuccess();
      });
    }
  }

  void _checkUrlForSuccess() {
    final status = Uri.base.queryParameters['razorpay_payment_link_status'];
    final paymentId = Uri.base.queryParameters['razorpay_payment_id'];

    if (status == 'paid') {
      print("---------------------------------------");
      print("💰 STATUS: PAYMENT COMPLETED!");
      print("📄 RECEIPT ID: $paymentId");
      print("---------------------------------------");

      _showSuccessDialog(paymentId ?? 'N/A');
    }
  }

  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111118),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: const Color(0xFF00D4AA).withOpacity(0.2)),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00D4AA),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thank you for upgrading to Pro. Your membership is now active.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receipt ID',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white38,
                    ),
                  ),
                  Text(
                    paymentId,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 12,
                      color: const Color(0xFF00D4AA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear URL parameters to prevent dialog from reappearing
                html.window.history.replaceState(null, '', '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A89FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Got it',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF030303),
      endDrawer: _buildRightDrawer(),
      body: Column(
        children: [
          TopNavBar(
            activeIndex: _currentIndex,
            onNavChanged: _navigate,
            onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _buildCurrentPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CategoriesPage();
      case 2:
        return ProfileScreen(onDismiss: () {});
      case 3:
        return const BookmarksScreen();
      case 4:
        return const TrendingScreen();
      case 5:
        return const AiAssistantScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildRightDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF08080A),
      width: 320,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFF15151A), width: 1)),
        ),
        child: Consumer<app_auth.AuthProvider>(
          builder: (context, auth, child) {
            return Column(
              children: [
                const SizedBox(height: 56),

                // ── Auth Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: auth.isLoggedIn
                      ? _buildLoggedInHeader(auth)
                      : _buildLoginPrompt(context),
                ),

                if (!auth.isPro) ...[
                  const SizedBox(height: 24),
                  _buildUpgradeBanner(context),
                ],
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF15151A)),
                const SizedBox(height: 8),

                // ── Nav Links ────────────────────────────────────────
                _buildDrawerLink('Dashboard', Icons.dashboard_outlined, 0),
                // _buildDrawerLink('Categories', Icons.category_outlined, 1),
                _buildDrawerLink('AI Assistant', Icons.smart_toy_outlined, 5),
                if (auth.isLoggedIn)
                  _buildDrawerLink('Profile', Icons.person_outline_rounded, 2),
                /*
                Consumer<BookmarkProvider>(
                  builder: (context, provider, child) {
                    final count = provider.count;
                    return _buildDrawerLink(
                      'Saved Tools',
                      count > 0
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      3,
                      color: count > 0 ? const Color(0xFF00D4AA) : null,
                      badge: count > 0 ? _buildCountBadge(count) : null,
                    );
                  },
                ),
                */
                _buildDrawerLink(
                  'Trending',
                  Icons.local_fire_department_rounded,
                  4,
                ),
                _buildDrawerLink(
                  'Membership',
                  Icons.stars_rounded,
                  -2,
                  color: const Color(0xFFFFD700),
                  badge: (auth.isPro || auth.status == 'trial')
                      ? _buildStatusBadge(auth)
                      : null,
                ),
                /*
                _buildDrawerLink(
                  'Submit Tool',
                  Icons.add_box_outlined,
                  -1,
                  isComingSoon: true,
                ),
                */

                const Spacer(),

                const Divider(color: Color(0xFF15151A)),
                const SizedBox(height: 8),

                _buildDrawerLink(
                  'Settings',
                  Icons.settings_outlined,
                  -1,
                  isComingSoon: true,
                ),
                const SizedBox(height: 4),

                // ── Auth Action at bottom ────────────────────────────
                if (auth.isLoggedIn)
                  _buildSignOutTile(context, auth)
                else
                  _buildSignInTile(context),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Logged In Header ────────────────────────────────────────────────────────
  Widget _buildLoggedInHeader(app_auth.AuthProvider auth) {
    final user = auth.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? '';
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF4A89FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (auth.isPro)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 10, color: Colors.black),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (auth.isPro || auth.status == 'trial') ...[
                    const SizedBox(width: 6),
                    _buildStatusBadge(auth),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  color: Colors.white38,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(app_auth.AuthProvider auth) {
    final isTrial = auth.status == 'trial';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isTrial ? const Color(0xFF00D4AA) : const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isTrial ? 'TRIAL' : 'PRO',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Not Logged In Header ────────────────────────────────────────────────────
  Widget _buildLoginPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.toLogin(context, closeDrawer: true),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00D4AA).withOpacity(0.08),
              const Color(0xFF4A89FF).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF111118),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E2C)),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF888888),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in to your account',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save tools, track history & more',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF00D4AA),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sign In tile at drawer bottom ───────────────────────────────────────────
  Widget _buildSignInTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => AppNavigator.toLogin(context, closeDrawer: true),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4AA), Color(0xFF4A89FF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Sign In / Create Account',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign Out tile at drawer bottom ──────────────────────────────────────────
  Widget _buildSignOutTile(BuildContext context, app_auth.AuthProvider auth) {
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        await auth.signOut();
      },
      leading: const Icon(
        Icons.logout_rounded,
        color: Colors.redAccent,
        size: 18,
      ),
      title: Text(
        'Sign Out',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  // ── Drawer Nav Link ─────────────────────────────────────────────────────────
  Widget _buildDrawerLink(
    String title,
    IconData icon,
    int index, {
    Color? color,
    bool isComingSoon = false,
    Widget? badge,
  }) {
    final bool isActive = index != -1 && _currentIndex == index;
    return ListTile(
      onTap: () {
        if (index != -1) {
          if (index == -2) {
            AppNavigator.toSubscription(context, closeDrawer: true);
            return;
          }
          _navigate(index);
          Navigator.pop(context);
        } else if (isComingSoon) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$title feature is coming soon!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF1D5A9E),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      leading: Icon(
        icon,
        color: color ?? (isActive ? const Color(0xFF4A89FF) : Colors.white54),
        size: 18,
      ),
      title: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  color ??
                  (isActive ? const Color(0xFF4A89FF) : Colors.white70),
            ),
          ),
          if (badge != null) ...[const SizedBox(width: 8), badge],
          if (isComingSoon) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'SOON',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00A8FF),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4AA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => AppNavigator.toSubscription(context, closeDrawer: true),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A89FF), Color(0xFF00D4AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A89FF).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      'Unlock all AI features',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
