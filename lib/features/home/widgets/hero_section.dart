import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.toolCount,
    required this.categoryCount,
    required this.logoCount,
  });

  final int toolCount;
  final int categoryCount;
  final int logoCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;
        final bool isNarrowing = constraints.maxWidth < 1200;

        return Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            // ── System label ──────────────────────────────────────────
            Text(
              'LIVE CATALOG SNAPSHOT',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // ── Hero title ────────────────────────────────────────────
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00D4AA), Color(0xFF00A8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Find The Right\nAI Tool Faster',
                textAlign: isMobile ? TextAlign.left : TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 36 : 84,
                  height: 0.95,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: isMobile ? -0.5 : -3.0,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Description + green dot ───────────────────────────────
            SizedBox(
              width: isMobile
                  ? double.infinity
                  : isNarrowing
                  ? 320
                  : 460,
              child: Text(
                'Use real listings from your database to compare tools by category, save options, and reduce trial-and-error.',
                textAlign: isMobile ? TextAlign.left : TextAlign.center,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  height: 1.6,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Green online indicator ────────────────────────────────
            Row(
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38D56A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Numbers shown below come from your live catalog',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      color: const Color(0xFF38D56A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Stats row ─────────────────────────────────────────────
            Wrap(
              alignment: isMobile ? WrapAlignment.start : WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatTile(
                  item: _StatItem(
                    icon: Icons.grid_view_rounded,
                    value: '$toolCount',
                    label: 'TOOLS INDEXED',
                  ),
                ),
                _StatTile(
                  item: _StatItem(
                    icon: Icons.category_rounded,
                    value: '$categoryCount',
                    label: 'ACTIVE CATEGORIES',
                  ),
                ),
                _StatTile(
                  item: _StatItem(
                    icon: Icons.verified_rounded,
                    value: '$logoCount',
                    label: 'TOOLS WITH LOGO',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ── Data model ───────────────────────────────────────────────────────────────
class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}

// ── Stat tile ────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  const _StatTile({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161820),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF252840), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon box
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, color: const Color(0xFF6C72FF), size: 15),
          ),
          const SizedBox(width: 10),
          // Value + label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.value,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF555870),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
