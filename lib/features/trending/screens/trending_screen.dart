import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/providers/trending_provider.dart';
import 'package:toolshub/core/models/trending_model.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/widgets/logo_widget.dart';
import 'package:toolshub/features/home/widgets/animated_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kCard = Color(0xFF0D0E14);
const _kBorder = Color(0xFF1A1B26);
const _kAccentGreen = Color(0xFF00FFD1);
const _kAccentOrange = Color(0xFFFF6B35);
const _kAccentBlue = Color(0xFF4A89FF);
const _kAccentPurple = Color(0xFF9B5EFF);

const _bentoCategories = [
  _BentoCat(
    'Overall Trending',
    Icons.local_fire_department_rounded,
    _kAccentOrange,
    'Most dominant AI tools across all categories',
    'overall',
    'assets/trending/overall.png',
  ),
  _BentoCat(
    'Coding & Vibe Coding',
    Icons.code_rounded,
    _kAccentBlue,
    'The future of software engineering',
    'vibe',
    'assets/trending/coding.png',
  ),
  _BentoCat(
    'Image Gen',
    Icons.image_rounded,
    Color(0xFFFF6B96),
    'AI-powered visual creation',
    'image',
    'assets/trending/image.png',
  ),
  _BentoCat(
    'Video Gen',
    Icons.play_circle_rounded,
    Color(0xFFFFBE0B),
    'Next-gen AI video production',
    'video',
    'assets/trending/video.png',
  ),
  _BentoCat(
    'Writing',
    Icons.edit_note_rounded,
    _kAccentPurple,
    'AI writing, editing & content creation',
    'writing',
    'assets/trending/writing.png',
  ),
];

class _BentoCat {
  final String name;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String firestorePrefix;
  final String imagePath;
  const _BentoCat(
    this.name,
    this.icon,
    this.color,
    this.subtitle,
    this.firestorePrefix,
    this.imagePath,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _openUrl(String raw) async {
  if (raw.trim().isEmpty) return;
  final u = raw.contains('://') ? raw : 'https://$raw';
  final uri = Uri.tryParse(u);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.platformDefault);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TrendingProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: const Color(0xFF08080A),
        width: 300,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Color(0xFF15151A), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
            child: _CategorySidebar(onClose: () => Navigator.pop(context)),
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedGridBackground(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar (Hidden on mobile)
                  if (!isMobile) ...[
                    const SizedBox(
                      width: 280,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        child: _CategorySidebar(),
                      ),
                    ),
                    // Subtle Vertical Divider
                    Container(width: 1, color: Colors.white.withOpacity(0.05)),
                  ],

                  // Content Area
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1100),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 48,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isMobile) const SizedBox(height: 40),
                                    ScrollReveal(child: const _TrendingHeader()),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1100),
                                child: tp.isLoading
                                    ? const _LoadingState()
                                    : _BentoGrid(tp: tp),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Left Side Drawer Toggle (Mobile Only) ───────────────────────
          if (isMobile)
            Positioned(
              left: 24,
              top: 24,
              child: Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141418),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF24242A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.dashboard_customize_rounded,
                      color: Color(0xFF00FFD1),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: 'Trending Categories',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendingHeader extends StatelessWidget {
  const _TrendingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _kAccentGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _kAccentGreen.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _kAccentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INTELLIGENCE BRIEFING',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _kAccentGreen,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFBBBBCC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Elite AI Market\nDominance',
            style: GoogleFonts.inter(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.5,
              height: 1.0,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'The definitive leaderboard of the most disruptive artificial intelligence tools\nacross primary engineering and creative sectors. Updated in real-time.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white38,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bento Grid System
// ─────────────────────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.tp});
  final TrendingProvider tp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return c.maxWidth < 900
            ? _MobileGrid(tp: tp)
            : _DesktopGrid(tp: tp, width: c.maxWidth);
      },
    );
  }
}

class _DesktopGrid extends StatelessWidget {
  const _DesktopGrid({required this.tp, required this.width});
  final TrendingProvider tp;
  final double width;

  @override
  Widget build(BuildContext context) {
    const gap = 24.0;
    final longW = (width - gap) * 2 / 3; // ~66%
    final shortW = (width - gap) * 1 / 3; // ~33%
    final cats = _bentoCategories;
    // cats[0]=Overall, cats[1]=Coding, cats[2]=ImageGen, cats[3]=VideoGen, cats[4]=Writing

    return Column(
      children: [
        // Row 1: Overall (LONG) ── Coding (SHORT)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _TrendingBentoCard(
                cat: cats[0],
                entries: tp.entriesFor(cats[0].firestorePrefix),
                style: _BentoStyle.featuredWide,
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              flex: 1,
              child: _TrendingBentoCard(
                cat: cats[1],
                entries: tp.entriesFor(cats[1].firestorePrefix),
                style: _BentoStyle.compactTall,
              ),
            ),
          ],
        ),
        const SizedBox(height: gap),

        // Row 2: Image Gen (SHORT) ── Video Gen (LONG)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _TrendingBentoCard(
                cat: cats[2],
                entries: tp.entriesFor(cats[2].firestorePrefix),
                style: _BentoStyle.compactTall,
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              flex: 2,
              child: _TrendingBentoCard(
                cat: cats[3],
                entries: tp.entriesFor(cats[3].firestorePrefix),
                style: _BentoStyle.featuredWide,
              ),
            ),
          ],
        ),
        const SizedBox(height: gap),

        // Row 3: Writing (LONG) — final full-width card
        _TrendingBentoCard(
          cat: cats[4],
          entries: tp.entriesFor(cats[4].firestorePrefix),
          style: _BentoStyle.featuredWide,
        ),
      ],
    );
  }
}

class _MobileGrid extends StatelessWidget {
  const _MobileGrid({required this.tp});
  final TrendingProvider tp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _bentoCategories.asMap().entries.map((e) {
        final style = e.key == 0
            ? _BentoStyle.featuredWide
            : e.key % 2 == 0
            ? _BentoStyle.compactTall
            : _BentoStyle.imageTall;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _TrendingBentoCard(
            cat: e.value,
            entries: tp.entriesFor(e.value.firestorePrefix),
            style: style,
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unified Trending Bento Card
// ─────────────────────────────────────────────────────────────────────────────

enum _BentoStyle { featuredWide, imageTall, compactTall, videoWide }

class _TrendingBentoCard extends StatefulWidget {
  const _TrendingBentoCard({
    required this.cat,
    required this.entries,
    required this.style,
  });
  final _BentoCat cat;
  final List<TrendingEntry> entries;
  final _BentoStyle style;

  @override
  State<_TrendingBentoCard> createState() => _TrendingBentoCardState();
}

class _TrendingBentoCardState extends State<_TrendingBentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? widget.cat.color.withOpacity(0.4) : _kBorder,
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: widget.cat.color.withOpacity(0.05),
                blurRadius: 30,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle Grid Background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(painter: _GridPainter(widget.cat.color)),
                ),
              ),
              _buildStyleContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleContent(BuildContext context) {
    switch (widget.style) {
      case _BentoStyle.featuredWide:
        return _StyleFeaturedWide(cat: widget.cat, entries: widget.entries);
      case _BentoStyle.imageTall:
        return _StyleImageTall(cat: widget.cat, entries: widget.entries);
      case _BentoStyle.compactTall:
        return _StyleCompactTall(cat: widget.cat, entries: widget.entries);
      case _BentoStyle.videoWide:
        return _StyleVideoWide(cat: widget.cat, entries: widget.entries);
    }
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StyleFeaturedWide extends StatelessWidget {
  const _StyleFeaturedWide({required this.cat, required this.entries});
  final _BentoCat cat;
  final List<TrendingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final hero = entries.first;
    final others = entries.skip(1).take(4).toList();
    return Column(
      children: [
        _BentoHeader(cat: cat),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              _HeroFeatureCard(entry: hero, color: cat.color),
              const SizedBox(height: 16),
              ...others.asMap().entries.map(
                (e) => _DetailedRankRow(
                  entry: e.value,
                  color: cat.color,
                  rank: e.key + 2,
                  isLast: e.key == others.length - 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyleImageTall extends StatelessWidget {
  const _StyleImageTall({required this.cat, required this.entries});
  final _BentoCat cat;
  final List<TrendingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final hero = entries.first;
    final others = entries.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BentoHeader(cat: cat),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _HeroFeatureCard(entry: hero, color: cat.color, compact: true),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: others
                .asMap()
                .entries
                .map(
                  (e) => _DetailedRankRow(
                    entry: e.value,
                    color: cat.color,
                    rank: e.key + 2,
                    isLast: e.key == others.length - 1,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _StyleCompactTall extends StatelessWidget {
  const _StyleCompactTall({required this.cat, required this.entries});
  final _BentoCat cat;
  final List<TrendingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final hero = entries.first;
    final others = entries.skip(1).take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BentoHeader(cat: cat),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _HeroFeatureCard(entry: hero, color: cat.color, compact: true),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: others
                .asMap()
                .entries
                .map(
                  (e) => _DetailedRankRow(
                    entry: e.value,
                    color: cat.color,
                    rank: e.key + 2,
                    isLast: e.key == others.length - 1,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _StyleVideoWide extends StatelessWidget {
  const _StyleVideoWide({required this.cat, required this.entries});
  final _BentoCat cat;
  final List<TrendingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final hero = entries.first;
    final others = entries.skip(1).take(4).toList();
    return Column(
      children: [
        _BentoHeader(cat: cat),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VideoFeatureBox(entry: hero, color: cat.color),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: others
                    .asMap()
                    .entries
                    .map(
                      (e) => SizedBox(
                        width: 240,
                        child: _DetailedRankRow(
                          entry: e.value,
                          color: cat.color,
                          rank: e.key + 2,
                          isLast: true,
                          compact: true,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: Text(
                      'BENCHMARK_TELEMETRY',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                    label: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: cat.color,
                    ),
                  ),
                  _Badge(
                    label: 'LIVE_DATA_SYNC',
                    color: cat.color.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BentoHeader extends StatelessWidget {
  const _BentoHeader({required this.cat, this.actionLabel});
  final _BentoCat cat;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cat.icon, color: cat.color, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cat.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (actionLabel != null)
            _Badge(label: actionLabel!, color: cat.color),
        ],
      ),
    );
  }
}

class _HeroFeatureCard extends StatelessWidget {
  const _HeroFeatureCard({
    required this.entry,
    required this.color,
    this.compact = false,
  });
  final TrendingEntry entry;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(entry.url),
      child: Container(
        padding: EdgeInsets.all(compact ? 16 : 24),
        decoration: BoxDecoration(
          color: const Color(0xFF13141C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LogoWidget(tool: entry.toToolInfo(), size: compact ? 44 : 52),
                _Badge(
                  label: compact ? 'LEADER' : 'SYSTEM_LEADER_V1',
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'RANK #1_PRIMARY',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.name,
              style: GoogleFonts.inter(
                fontSize: compact ? 22 : 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              entry.desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LAUNCH_RESOURCE_LINK',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_outward_rounded, size: 14, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TechMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 8,
            color: Colors.white24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailedRankRow extends StatelessWidget {
  final TrendingEntry entry;
  final Color color;
  final int rank;
  final bool isLast;
  final bool compact;

  const _DetailedRankRow({
    required this.entry,
    required this.color,
    required this.rank,
    this.isLast = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(entry.url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
                ),
        ),
        child: Row(
          children: [
            // Rank Number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              alignment: Alignment.center,
              child: Text(
                rank.toString().padLeft(2, '0'),
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 16),
            LogoWidget(tool: entry.toToolInfo(), size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoFeatureBox extends StatelessWidget {
  const _VideoFeatureBox({required this.entry, required this.color});
  final TrendingEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _HeroFeatureCard(entry: entry, color: color);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _BentoBigButton extends StatelessWidget {
  final String label;
  final Color color;
  const _BentoBigButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _kBorder),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: _kAccentGreen,
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'POLLING_DATABASE...',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  final VoidCallback? onClose;
  const _CategorySidebar({this.onClose});

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('AI Trendings', Icons.auto_awesome_rounded, true, false),
      ('Students', Icons.school_rounded, false, true),
      ('Business', Icons.business_center_rounded, false, true),
      ('Content', Icons.draw_rounded, false, true),
      ('Growth', Icons.trending_up_rounded, false, true),
      ('Lifestyle', Icons.spa_rounded, false, true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: Colors.white38),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFF15151A)),
        const SizedBox(height: 16),

        ...categories.map(
          (cat) => _SidebarItem(
            title: cat.$1,
            icon: cat.$2,
            isActive: cat.$3,
            isComingSoon: cat.$4,
          ),
        ),
        const SizedBox(height: 32),
        // Premium Support Card or similar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF00FFD1).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFD1).withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE_TELEMETRY',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00FFD1),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Real-time indexing of new deployment nodes.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white38,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final bool isComingSoon;

  const _SidebarItem({
    required this.title,
    required this.icon,
    this.isActive = false,
    this.isComingSoon = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isActive
              ? const Color(0xFF00FFD1).withOpacity(0.08)
              : _isHovered
              ? Colors.white.withOpacity(0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isActive
                ? const Color(0xFF00FFD1).withOpacity(0.2)
                : _isHovered
                ? Colors.white.withOpacity(0.05)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: widget.isActive ? const Color(0xFF00FFD1) : Colors.white38,
            ),
            const SizedBox(width: 16),
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                color: widget.isActive ? Colors.white : Colors.white60,
              ),
            ),
            if (widget.isComingSoon) ...[
              const SizedBox(width: 8),
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
            if (widget.isActive) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00FFD1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
