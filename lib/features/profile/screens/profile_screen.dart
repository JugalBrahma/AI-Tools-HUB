import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/features/auth/screens/login_screen.dart';
import 'package:toolshub/features/home/widgets/footer.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/history_provider.dart';
import 'package:toolshub/core/models/tool_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isHistoryExpanded = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    if (!auth.isLoggedIn) {
      return const _NotLoggedInView();
    }

    final user = auth.currentUser;
    final String name =
        (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'User';
    final String email = user?.email ?? '';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildLoggedInContent(context, name, email, auth),
        ],
      ),
    );
  }

  Widget _buildLoggedInContent(
    BuildContext context,
    String name,
    String email,
    app_auth.AuthProvider auth,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1060),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, name, email),
              const SizedBox(height: 28),
              _buildStatsRow(context),
              const SizedBox(height: 40),
              _buildSectionTitle(
                'Recently Used',
                Icons.history_rounded,
                isExpanded: _isHistoryExpanded,
                onToggle: () =>
                    setState(() => _isHistoryExpanded = !_isHistoryExpanded),
              ),
              const SizedBox(height: 16),
              _buildRecentToolsList(context),
              const SizedBox(height: 36),
              _buildBottomSignOut(auth),
              const SizedBox(height: 120),
              const Footer(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email) {
    String initials = 'U';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else if (parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131A2A), Color(0xFF0C0F17)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF232C40)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A8FF).withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A8FF), Color(0xFF00D4AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 510,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4AA).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF00D4AA).withOpacity(0.28),
                    ),
                  ),
                  child: Text(
                    'PROFILE',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      color: const Color(0xFF00D4AA),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? 'No email linked' : email,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFAAB2C8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSignOut(app_auth.AuthProvider auth) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => auth.signOut(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final historyProvider = context.watch<HistoryProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 970;
        final cardWidth = compact
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              width: cardWidth,
              label: 'Saved',
              value: '${bookmarkProvider.count}',
              icon: Icons.bookmark_rounded,
              color: const Color(0xFF00A8FF),
            ),
            _buildStatCard(
              width: cardWidth,
              label: 'Used',
              value: '${historyProvider.usageCount}',
              icon: Icons.bolt_rounded,
              color: const Color(0xFF00D4AA),
            ),
            _buildStatCard(
              width: cardWidth,
              label: 'Recent',
              value: '${historyProvider.recentToolIds.length}',
              icon: Icons.history_rounded,
              color: const Color(0xFF7C8BFF),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF10141D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2938)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withOpacity(0.5), size: 16),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white30,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon, {
    bool isExpanded = false,
    VoidCallback? onToggle,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF00A8FF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF00A8FF).withOpacity(0.24),
            ),
          ),
          child: Icon(icon, color: const Color(0xFF00A8FF), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (onToggle != null)
          GestureDetector(
            onTap: onToggle,
            child: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white38,
                size: 22,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentToolsList(BuildContext context) {
    final toolProvider = context.watch<ToolProvider>();
    final historyProvider = context.watch<HistoryProvider>();

    if (historyProvider.recentToolIds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1218),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF202636)),
        ),
        alignment: Alignment.center,
        child: Text(
          'No recent activity yet',
          style: GoogleFonts.inter(color: Colors.white38),
        ),
      );
    }

    final allTools = toolProvider.categories.expand((c) => c.tools).toList();
    final recentTools = <ToolInfo>[];

    for (var id in historyProvider.recentToolIds) {
      try {
        final tool = allTools.firstWhere((t) => t.docId == id);
        recentTools.add(tool);
      } catch (_) {}
    }

    final displayedTools = _isHistoryExpanded
        ? recentTools
        : recentTools.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF10141C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E2634)),
          ),
          child: Column(
            children: List.generate(displayedTools.length, (index) {
              final tool = displayedTools[index];
              return Column(
                children: [
                  _buildRecentItem(tool),
                  if (index != displayedTools.length - 1)
                    const Divider(height: 1, color: Color(0xFF202838)),
                ],
              );
            }),
          ),
        ),
        if (recentTools.length > 3)
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => _isHistoryExpanded = !_isHistoryExpanded),
              icon: AnimatedRotation(
                turns: _isHistoryExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.white38,
                ),
              ),
              label: Text(
                _isHistoryExpanded
                    ? 'Show less'
                    : 'Show all ${recentTools.length}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentItem(ToolInfo tool) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tool.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bolt_rounded, color: tool.accentColor, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Opened via Try it',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          if (tool.pricing.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                tool.pricing.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.white38,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF10141C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1F2636)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4AA).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlowIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 10),
            _buildSubtitle(),
            const SizedBox(height: 28),
            _buildSignInCTA(context),
            const SizedBox(height: 14),
            _buildFooterText(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF4A89FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Your Profile',
      style: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Sign in to save your favourite tools,\ntrack history, and more.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: const Color(0xFF9AA3BB),
        height: 1.6,
      ),
    );
  }

  Widget _buildSignInCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                const LoginScreen(onDismiss: null), // Update this if needed
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4AA), Color(0xFF4A89FF)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4AA).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Sign In / Create Account',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Text(
      'The dashboard is available for everyone — no sign in required.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF646D84)),
    );
  }
}
