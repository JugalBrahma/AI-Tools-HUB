import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/features/auth/screens/login_screen.dart';
import 'package:toolshub/features/home/screens/home_screen.dart';
import 'package:toolshub/features/categories/screens/categories_page.dart';
import 'package:toolshub/features/home/widgets/top_nav_bar.dart';
import 'package:toolshub/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:toolshub/features/profile/screens/profile_screen.dart';
import 'package:toolshub/features/trending/screens/trending_screen.dart';
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            child: IndexedStack(
              index: _currentIndex,
              children: [
                TickerMode(enabled: _currentIndex == 0, child: const HomeScreen()),
                TickerMode(
                  enabled: _currentIndex == 1,
                  child: const CategoriesPage(),
                ),
                TickerMode(
                  enabled: _currentIndex == 2,
                  child: const ProfileScreen(),
                ),
                TickerMode(
                  enabled: _currentIndex == 3,
                  child: const BookmarksScreen(),
                ),
                TickerMode(
                  enabled: _currentIndex == 4,
                  child: const TrendingScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

                const SizedBox(height: 24),
                const Divider(color: Color(0xFF15151A)),
                const SizedBox(height: 8),

                // ── Nav Links ────────────────────────────────────────
                _buildDrawerLink('Dashboard', Icons.dashboard_outlined, 0),
                _buildDrawerLink('Categories', Icons.category_outlined, 1),
                if (auth.isLoggedIn)
                  _buildDrawerLink('Profile', Icons.person_outline_rounded, 2),
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
                _buildDrawerLink(
                  'Trending',
                  Icons.local_fire_department_rounded,
                  4,
                ),
                _buildDrawerLink(
                  'Submit Tool',
                  Icons.add_box_outlined,
                  -1,
                  isComingSoon: true,
                ),

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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
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

  // ── Not Logged In Header ────────────────────────────────────────────────────
  Widget _buildLoginPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // close drawer
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                LoginScreen(onDismiss: () => Navigator.of(context).pop()),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
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
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  LoginScreen(onDismiss: () => Navigator.of(context).pop()),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 250),
            ),
          );
        },
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
}
