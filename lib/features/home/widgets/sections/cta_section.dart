import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double maxWidth = 1080;
        final double wrapWidth = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;
        final bool isCompact = wrapWidth < 860;

        return Center(
          child: Container(
            width: wrapWidth,
            padding: EdgeInsets.symmetric(
              vertical: isCompact ? 44 : 56,
              horizontal: isCompact ? 20 : 32,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12141A), const Color(0xFF0D0D0F)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF232530)),
            ),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isCompact: true),
                      const SizedBox(height: 26),
                      const _BenefitTile(
                        icon: Icons.tune_rounded,
                        title: 'Compare by actual use case',
                      ),
                      const SizedBox(height: 12),
                      const _BenefitTile(
                        icon: Icons.bookmark_added_rounded,
                        title: 'Create a shortlist before signup',
                      ),
                      const SizedBox(height: 12),
                      const _BenefitTile(
                        icon: Icons.speed_rounded,
                        title: 'Decide faster with less trial-and-error',
                      ),
                      const SizedBox(height: 26),
                      const _CtaButton(),
                      const SizedBox(height: 16),
                      _buildMeta(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildHeader(isCompact: false)),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _BenefitTile(
                              icon: Icons.tune_rounded,
                              title: 'Compare by actual use case',
                            ),
                            const SizedBox(height: 12),
                            const _BenefitTile(
                              icon: Icons.bookmark_added_rounded,
                              title: 'Create a shortlist before signup',
                            ),
                            const SizedBox(height: 12),
                            const _BenefitTile(
                              icon: Icons.speed_rounded,
                              title: 'Decide faster with less trial-and-error',
                            ),
                            const SizedBox(height: 28),
                            const _CtaButton(),
                            const SizedBox(height: 16),
                            _buildMeta(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader({required bool isCompact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF00A8FF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF00A8FF).withOpacity(0.28),
            ),
          ),
          child: Text(
            'NEXT STEP',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00A8FF),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Build Your AI Stack\nWith More Confidence',
          style: GoogleFonts.inter(
            fontSize: isCompact ? 30 : 44,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.2,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Use the catalog to narrow options, then test only the tools that match your workflow and budget.',
          style: GoogleFonts.inter(
            fontSize: isCompact ? 14 : 16,
            height: 1.55,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildMeta() {
    return Center(
      child: Text(
        'REAL DATA  •  PRACTICAL EVALUATION  •  NO HYPE METRICS',
        textAlign: TextAlign.center,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white24,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262A36)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7BB6FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Explore Tools',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
