import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/models/trending_model.dart';
import 'package:toolshub/core/providers/trending_provider.dart';
import 'package:toolshub/features/home/widgets/animated_background.dart';
import 'package:toolshub/features/categories/widgets/logo_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TrendingProvider>();
    return AnimatedGridBackground(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    _TrendingHeader(),
                    const SizedBox(height: 40),
                    if (tp.isLoading)
                      const _LoadingState()
                    else
                      _BentoGrid(tp: tp),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: longW,
                child: _TrendingBentoCard(
                  cat: cats[0],
                  entries: tp.entriesFor(cats[0].firestorePrefix),
                  style: _BentoStyle.featuredWide,
                ),
              ),
              const SizedBox(width: gap),
              SizedBox(
                width: shortW,
                child: _TrendingBentoCard(
                  cat: cats[1],
                  entries: tp.entriesFor(cats[1].firestorePrefix),
                  style: _BentoStyle.compactTall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: gap),

        // Row 2: Image Gen (SHORT) ── Video Gen (LONG)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: shortW,
                child: _TrendingBentoCard(
                  cat: cats[2],
                  entries: tp.entriesFor(cats[2].firestorePrefix),
                  style: _BentoStyle.compactTall,
                ),
              ),
              const SizedBox(width: gap),
              SizedBox(
                width: longW,
                child: _TrendingBentoCard(
                  cat: cats[3],
                  entries: tp.entriesFor(cats[3].firestorePrefix),
                  style: _BentoStyle.featuredWide,
                ),
              ),
            ],
          ),
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
        final style = e.key % 2 == 0
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

class _TrendingBentoCard extends StatelessWidget {
  const _TrendingBentoCard({
    required this.cat,
    required this.entries,
    required this.style,
  });
  final _BentoCat cat;
  final List<TrendingEntry> entries;
  final _BentoStyle style;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: _buildStyleContent(context),
      ),
    );
  }

  Widget _buildStyleContent(BuildContext context) {
    switch (style) {
      case _BentoStyle.featuredWide:
        return _StyleFeaturedWide(cat: cat, entries: entries);
      case _BentoStyle.imageTall:
        return _StyleImageTall(cat: cat, entries: entries);
      case _BentoStyle.compactTall:
        return _StyleCompactTall(cat: cat, entries: entries);
      case _BentoStyle.videoWide:
        return _StyleVideoWide(cat: cat, entries: entries);
    }
  }
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
        _BentoHeader(cat: cat, actionLabel: 'Explore Category'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _HeroFeatureCard(entry: hero, color: cat.color),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 5,
                child: Column(
                  children: others
                      .asMap()
                      .entries
                      .map(
                        (e) => _RankedItemRow(
                          entry: e.value,
                          color: cat.color,
                          isLast: e.key == others.length - 1,
                        ),
                      )
                      .toList(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BentoHeader(cat: cat),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cat.color.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: cat.color, size: 16),
                const SizedBox(width: 8),
                Text(
                  'FEATURED LEADER: ${entries.first.name}',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cat.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: entries
                .asMap()
                .entries
                .map(
                  (e) => _RankedItemRow(
                    entry: e.value,
                    color: cat.color,
                    isLast: e.key == entries.length - 1,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        _BentoBigButton(label: 'View All Engines', color: cat.color),
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
          child: _MiniFeatureBox(entry: hero, color: cat.color),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: others
                .asMap()
                .entries
                .map(
                  (e) => _RankedItemRow(
                    entry: e.value,
                    color: cat.color,
                    isLast: e.key == others.length - 1,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        _BentoBigButton(label: 'Analyze Category', color: cat.color),
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
                    .map(
                      (e) => SizedBox(
                        width: 200,
                        child: _RankedItemRow(
                          entry: e,
                          color: cat.color,
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
                      'Full Benchmarks',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    label: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: cat.color,
                    ),
                  ),
                  _Badge(
                    label: 'DATA VERIFIED',
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
              Icon(cat.icon, color: cat.color, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1B23),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cat.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroFeatureCard extends StatelessWidget {
  const _HeroFeatureCard({required this.entry, required this.color});
  final TrendingEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(entry.url),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF13141C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.05), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LogoWidget(tool: entry.toToolInfo(), size: 40),
                _Badge(label: 'CURRENT LEADER', color: color),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'RANK #1',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              entry.name,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              entry.desc,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.trending_up, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  '+14.3% Adoption',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Visit site',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_outward_rounded, size: 12, color: color),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniFeatureBox extends StatelessWidget {
  const _MiniFeatureBox({required this.entry, required this.color});
  final TrendingEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(entry.url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF13141C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.06), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LogoWidget(tool: entry.toToolInfo(), size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Badge(label: '#1 BREAKOUT', color: color),
                      const SizedBox(height: 4),
                      Text(
                        entry.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_outward_rounded, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white38,
                height: 1.4,
              ),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF13141C),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      children: [
        LogoWidget(tool: entry.toToolInfo(), size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Badge(label: 'ALPHA', color: color),
                ],
              ),
              Text(
                'Top-ranked in category',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),
        Icon(Icons.trending_up_rounded, color: color, size: 20),
      ],
    ),
  );
}

class _RankedItemRow extends StatelessWidget {
  const _RankedItemRow({
    required this.entry,
    required this.color,
    required this.isLast,
    this.compact = false,
  });
  final TrendingEntry entry;
  final Color color;
  final bool isLast;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => _openUrl(entry.url),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 10 : 14),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${entry.rank}',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                LogoWidget(tool: entry.toToolInfo(), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 14,
                  color: color.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 1, color: _kBorder),
      ],
    );
  }
}

class _BentoBigButton extends StatelessWidget {
  const _BentoBigButton({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
          ),
        ),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.9),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 8,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2, color: _kAccentGreen),
          const SizedBox(height: 16),
          Text(
            'Loading Trending Data…',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
          ),
        ],
      ),
    ),
  );
}
