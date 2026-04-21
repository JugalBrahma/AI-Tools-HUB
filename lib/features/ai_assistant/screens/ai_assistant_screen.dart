import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/features/ai_assistant/models/assistant_models.dart';
import 'package:toolshub/features/ai_assistant/models/assistant_api_models.dart';
import 'package:toolshub/features/ai_assistant/services/assistant_api_service.dart';
import 'package:toolshub/features/home/widgets/animated_background.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/features/subscription/screens/subscription_screen.dart';
import 'package:toolshub/core/navigation/app_navigator.dart';
import 'package:toolshub/features/auth/screens/login_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AssistantState _state = AssistantState();
  final AssistantApiService _apiService = AssistantApiService();
  final TextEditingController _promptController = TextEditingController();

  bool _isLoading = false;

  Future<void> _generateStack() async {
    final goal = _promptController.text.trim();
    if (goal.isEmpty && _state.selections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide some context or select filters.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<app_auth.AuthProvider>();

      // ── Check Usage Limit for Free Users ────────────────────────────
      if (!auth.isPro) {
        final user = auth.currentUser;
        if (user == null) {
          _showError('Please sign in to use the AI Assistant.');
          return;
        }

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final lastUsage = doc.data()?['last_ai_usage'] as Timestamp?;

        if (lastUsage != null) {
          final lastDate = lastUsage.toDate();
          final now = DateTime.now();
          if (lastDate.year == now.year && lastDate.month == now.month) {
            _showLimitReachedError();
            return;
          }
        }
      }

      // ── Map UI to API Request ─────────────────────────────────────
      final request = AssistantRequest(
        category: _state.selections['Category']?.toString() ?? 'Other',
        goal: goal,
        budget: _state.selections['Budget']?.toString() ?? 'Not sure',
        teamSize: _state.selections['Team Size']?.toString() ?? 'Solo',
        mustHaveFeatures: List<String>.from(
          _state.selections['Must-haves'] ?? [],
        ),
        priority:
            _state.selections['Priority']?.toString() ?? 'Balanced / Other',
        avoid: List<String>.from(_state.selections['Avoid'] ?? []),
        referenceTool: _state.selections['Reference Tool']?.toString(),
      );

      final response = await _apiService.getRecommendations(request);

      // ── Update usage timestamp for free users ──────────────────────
      if (!auth.isPro && auth.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser!.uid)
            .update({'last_ai_usage': FieldValue.serverTimestamp()});
      }

      if (mounted) {
        _showResults(response);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResults(AssistantResponse response) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF030303),
      isScrollControlled: true,
      constraints: const BoxConstraints(
        maxWidth: 940,
      ), // Even wider width for response stack comparisons
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      builder: (context) => _ResultsSheet(response: response),
    );
  }

  void _showLimitReachedError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: Color(0xFFFFD700), size: 18),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Free plan limit: 1 use per month reached. Upgrade for unlimited AI!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'UPGRADE',
          textColor: const Color(0xFFFFD700),
          onPressed: () => AppNavigator.toSubscription(context),
        ),
        backgroundColor: const Color(0xFF14141C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFD700), width: 0.5),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSignInToast() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) {
        final curve =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(opacity: curve, child: child),
        );
      },
      pageBuilder: (dialogContext, _, __) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0C14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4A89FF).withOpacity(0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A89FF).withOpacity(0.08),
                      blurRadius: 40,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A89FF).withOpacity(0.15),
                            const Color(0xFF00D4AA).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4A89FF).withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Color(0xFF4A89FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign in to generate',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Create an account to use the AI Assistant',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        AppNavigator.toLogin(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A89FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged(FilterConfig filter, dynamic value) {
    setState(() {
      _state.selections[filter.label] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        children: [
          // ── Main Content ──────────────────────────────────────────────
          AnimatedGridBackground(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 60,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      // ── Header ──────────────────────────────────────────
                      ScrollReveal(
                        child: Column(
                          children: [
                            Text(
                              'AI Stack Assistant',
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Describe what you need. We\'ll build the right stack.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.white54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Interaction Card ──────────────────────────────
                      ScrollReveal(
                        delay: 0.1,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C0C10),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color(0xFF1C1C22),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPromptInput(),
                              const SizedBox(height: 32),
                              const Divider(
                                color: Color(0xFF1C1C22),
                                height: 1,
                              ),
                              const SizedBox(height: 24),

                              _buildFilterHeader('CORE REQUIREMENTS'),
                              const SizedBox(height: 12),
                              _buildFilterScroll(
                                _state.filters.take(4).toList(),
                              ),
                              const SizedBox(height: 24),

                              _buildFilterHeader('SPECIFICATIONS'),
                              const SizedBox(height: 12),
                              _buildFilterScroll(
                                _state.filters.skip(4).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Submit Button ─────────────────────────────────
                      ScrollReveal(
                        delay: 0.2,
                        child: _PremiumCTA(
                          onPressed: _isLoading ? null : _generateStack,
                          isLoading: _isLoading,
                          isLocked: !auth.isLoggedIn,
                          onLockedTap: _showSignInToast,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A89FF)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromptInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF141418),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF24242A)),
          ),
          child: TextField(
            controller: _promptController,
            maxLines: 3,
            minLines: 1,
            enabled: !_isLoading,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'What do you need AI tools for?',
              hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 15),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'High-fidelity prompt build. Use chips below to refine.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 9,
        color: Colors.white24,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildFilterScroll(List<FilterConfig> filters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: filters
            .map(
              (f) => _FilterPill(
                config: f,
                enabled: !_isLoading,
                currentValue: _state.selections[f.label],
                onChanged: (val) => _onSelectionChanged(f, val),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLockedOverlay(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: ScrollReveal(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF030303).withOpacity(0.85),
              borderRadius: BorderRadius.circular(40),
              border:
                  Border.all(color: const Color(0xFF4A89FF).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A89FF).withOpacity(0.1),
                  blurRadius: 100,
                  spreadRadius: -20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SIGN IN TO ACCESS',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A89FF),
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unlock the AI Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Describe your goals and we’ll build the perfect tool stack for you. Sign in to get 1 free use per month!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                _PremiumCTA(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionScreen(
                          onDismiss: () => Navigator.pop(context),
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  isLoading: false,
                  isLocked: false,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pro members get unlimited generations',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Results Widget ────────────────────────────────────────────────────────────

class _ResultsSheet extends StatelessWidget {
  final AssistantResponse response;
  const _ResultsSheet({required this.response});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF030303),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(top: BorderSide(color: Color(0xFF1C1C22), width: 1.5)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generated AI Stack',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatusBadge(
                            response.confidenceLevel.toUpperCase(),
                            response.confidenceLevel.toLowerCase() == 'high'
                                ? const Color(0xFF00D4AA)
                                : const Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CONFIDENCE',
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 10,
                              color: Colors.white24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF24242A)),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF4A89FF),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (response.missingInformation.isNotEmpty) ...[
              _buildMissingInfoBanner(response.missingInformation),
              const SizedBox(height: 32),
            ],

            if (response.topPick != null) ...[
              _RecommendationCard(rec: response.topPick!, isTop: true),
              const SizedBox(height: 32),
            ],

            if (response.alternatives.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  'ALTERNATIVE TOOLS',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    color: Colors.white24,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...response.alternatives.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _RecommendationCard(rec: a),
                ),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14141C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF1C1C22)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Refine Request',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMissingInfoBanner(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A89FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4A89FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF4A89FF),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'REFINEMENT SUGGESTION',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  color: const Color(0xFF4A89FF),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (info) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: CircleAvatar(
                      radius: 2,
                      backgroundColor: Color(0xFF4A89FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      info,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  final bool isTop;
  const _RecommendationCard({required this.rec, this.isTop = false});

  Future<void> _launchToolUrl() async {
    if (rec.url.isEmpty) return;
    final url = Uri.parse(rec.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = isTop
        ? const Color(0xFF00D4AA)
        : const Color(0xFF4A89FF);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isTop
              ? primaryColor.withOpacity(0.3)
              : const Color(0xFF1C1C22),
          width: 1.5,
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Section ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF1C1C22).withOpacity(0.5),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rec.toolName,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (isTop) _buildTopPickBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _launchToolUrl,
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 14, color: Colors.white24),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rec.url
                                .replaceFirst('https://', '')
                                .replaceFirst('www.', ''),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: primaryColor.withOpacity(0.8),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body Section ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceSection(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('WHY IT FITS'),
                  const SizedBox(height: 8),
                  Text(
                    rec.whyItFits,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      rec.fitScoreReason,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('FOR THE BEST EXPERIENCE'),
                  const SizedBox(height: 8),
                  Text(
                    rec.bestFor,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF1C1C22)),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildWarningSection(
                          'TRADEOFFS',
                          rec.tradeoffs,
                          Icons.compare_arrows,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildWarningSection(
                          'CAUTION',
                          rec.caution,
                          Icons.warning_amber_rounded,
                          isUrgent: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Footer Section ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFF14141C),
              child: Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 14,
                    color: _getFreshnessColor(rec.freshnessStatus),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STATUS: ${rec.freshnessStatus.toUpperCase()}',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _getFreshnessColor(rec.freshnessStatus),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: rec.evidenceSummary,
                    triggerMode: TooltipTriggerMode.tap,
                    child: const Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPickBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF00BFA5)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'TOP PICK',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 10,
        color: Colors.white24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.payments_outlined,
            size: 16,
            color: Colors.white54,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRICING',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 9,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                rec.price,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningSection(
    String title,
    String content,
    IconData icon, {
    bool isUrgent = false,
  }) {
    final color = isUrgent ? const Color(0xFFFF4B4B) : Colors.white24;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white54,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Color _getFreshnessColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return const Color(0xFF00D4AA);
      case 'partly_verified':
        return const Color(0xFFFFB800);
      default:
        return Colors.white24;
    }
  }
}

// ── Reusable Filter Pill (Updated with enabled state) ──────────────────────────

class _FilterPill extends StatelessWidget {
  final FilterConfig config;
  final dynamic currentValue;
  final Function(dynamic) onChanged;
  final bool enabled;

  const _FilterPill({
    required this.config,
    required this.currentValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    bool active =
        currentValue != null &&
        (currentValue is! List || (currentValue as List).isNotEmpty);
    String label = currentValue == null
        ? config.label
        : (currentValue is List
              ? '${config.label} (${currentValue.length})'
              : currentValue.toString());

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: enabled ? () => _showSheet(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF4A89FF).withOpacity(0.1)
                : const Color(0xFF141418),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? const Color(0xFF4A89FF).withOpacity(0.4)
                  : const Color(0xFF24242A),
            ),
          ),
          child: Opacity(
            opacity: enabled ? 1.0 : 0.4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  config.icon,
                  size: 14,
                  color: active ? const Color(0xFF4A89FF) : Colors.white24,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : Colors.white38,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: active ? const Color(0xFF4A89FF) : Colors.white10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _FilterSheet(
        config: config,
        initialValue: currentValue,
        onSave: onChanged,
      ),
    );
  }
}

// ── (Keeping _FilterSheet and _PremiumCTA from previous turns) ────────────────

class _FilterSheet extends StatefulWidget {
  final FilterConfig config;
  final dynamic initialValue;
  final Function(dynamic) onSave;

  const _FilterSheet({
    required this.config,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late dynamic _tempValue;

  @override
  void initState() {
    super.initState();
    if (widget.config.type == SelectionType.multi) {
      _tempValue = List<String>.from(widget.initialValue ?? []);
    } else {
      _tempValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.config.label,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (widget.config.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.config.description!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.config.type == SelectionType.multi)
                  TextButton(
                    onPressed: () =>
                        setState(() => (_tempValue as List).clear()),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(color: const Color(0xFF4A89FF)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.config.options.map((opt) {
                    final isSelected = widget.config.type == SelectionType.multi
                        ? (_tempValue as List).contains(opt)
                        : _tempValue == opt;

                    return ChoiceChip(
                      label: Text(opt),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (widget.config.type == SelectionType.multi) {
                            if (selected) {
                              (_tempValue as List).add(opt);
                            } else {
                              (_tempValue as List).remove(opt);
                            }
                          } else {
                            _tempValue = selected ? opt : null;
                          }
                        });
                        if (widget.config.type != SelectionType.multi) {
                          widget.onSave(_tempValue);
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: const Color(0xFF14141C),
                      selectedColor: const Color(0xFF4A89FF).withOpacity(0.2),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF4A89FF)
                            : Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4A89FF)
                              : const Color(0xFF222230),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
              ),
            ),
            if (widget.config.type == SelectionType.multi) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(_tempValue);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A89FF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Apply Selection',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PremiumCTA extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLockedTap;
  final bool isLoading;
  final bool isLocked;
  const _PremiumCTA({
    required this.onPressed,
    required this.isLoading,
    this.isLocked = false,
    this.onLockedTap,
  });

  @override
  State<_PremiumCTA> createState() => _PremiumCTAState();
}

class _PremiumCTAState extends State<_PremiumCTA> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool locked = widget.isLocked;
    final bool enabled = !locked && widget.onPressed != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: locked ? widget.onLockedTap : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: locked
                ? null
                : (enabled
                    ? const LinearGradient(
                        colors: [Color(0xFF4A89FF), Color(0xFF00D4AA)],
                      )
                    : null),
            color: locked
                ? const Color(0xFF14141C)
                : (enabled ? null : Colors.white12),
            borderRadius: BorderRadius.circular(20),
            border: locked
                ? Border.all(color: const Color(0xFF252533))
                : null,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A89FF).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (locked) ...[
                        const Icon(Icons.lock_rounded,
                            size: 16, color: Color(0xFF4A89FF)),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        locked
                            ? 'Sign in to Generate'
                            : 'Generate Custom Stack',
                        style: GoogleFonts.inter(
                          color: locked
                              ? const Color(0xFF4A89FF)
                              : (enabled ? Colors.white : Colors.white24),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
