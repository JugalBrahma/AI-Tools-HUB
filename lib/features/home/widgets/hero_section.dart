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
                'Explore our live directory of cutting-edge AI tools. Discover trending solutions and chat with our AI Assistant to find exactly what you need.',
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
                  child: const _PulseDot(),
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
                    icon: Icons.sensors_rounded,
                    value: 'Live',
                    label: 'REAL-TIME DATA',
                  ),
                ),
                _StatTile(
                  item: _StatItem(
                    icon: Icons.local_fire_department_rounded,
                    value: '24/7',
                    label: 'LIVE TRENDING',
                  ),
                ),
                _StatTile(
                  item: _StatItem(
                    icon: Icons.auto_awesome_rounded,
                    value: 'Active',
                    label: 'AI ASSISTANT',
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

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF38D56A).withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38D56A).withOpacity(0.5 * _animation.value),
                blurRadius: 8,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
