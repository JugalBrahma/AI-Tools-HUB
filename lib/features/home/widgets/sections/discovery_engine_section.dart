import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoveryEngineSection extends StatelessWidget {
  const DiscoveryEngineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00A8FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00A8FF).withOpacity(0.2)),
          ),
          child: Text(
            'WHY USE THIS',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00A8FF),
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFAAAAAA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'A Practical AI Tool Workspace',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 500,
          child: Text(
            'Pick tools with confidence using category-based discovery, clearer comparison, and simple shortlisting before paid signup.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: Colors.white38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 80),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            const double maxContainerWidth = 1100;
            final double wrapWidth = constraints.maxWidth > maxContainerWidth
                ? maxContainerWidth
                : constraints.maxWidth;

            return SizedBox(
              width: wrapWidth,
              child: Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  _DiscoveryCard(
                    width: isMobile ? double.infinity : (wrapWidth - 32) / 2,
                    icon: Icons.auto_awesome_outlined,
                    title: 'Save Hours of Research',
                    desc:
                        'Find relevant tools in one place instead of opening many tabs and random review pages.',
                    stat: 'Less context switching',
                    statLabel: 'BENEFIT',
                    color: const Color(0xFF00A8FF),
                  ),
                  _DiscoveryCard(
                    width: isMobile ? double.infinity : (wrapWidth - 32) / 2,
                    icon: Icons.trending_up_rounded,
                    title: 'Stay Ahead of the Curve',
                    desc:
                        'Track what is available in your own catalog without chasing hype on social media.',
                    stat: 'Cleaner discovery flow',
                    statLabel: 'BENEFIT',
                    color: const Color(0xFF00FFD1),
                  ),
                  _DiscoveryCard(
                    width: isMobile ? double.infinity : (wrapWidth - 32) / 2,
                    icon: Icons.bolt_rounded,
                    title: 'Choose by Actual Use Case',
                    desc:
                        'Match tools to coding, marketing, writing, or design needs using clear categories.',
                    stat: 'Better fit decisions',
                    statLabel: 'BENEFIT',
                    color: const Color(0xFFFF3366),
                  ),
                  _DiscoveryCard(
                    width: isMobile ? double.infinity : (wrapWidth - 32) / 2,
                    icon: Icons.verified_user_outlined,
                    title: 'Trusted & Verified',
                    desc:
                        'Open tool pages quickly, verify value yourself, and bookmark finalists for your team.',
                    stat: 'Shortlist with clarity',
                    statLabel: 'BENEFIT',
                    color: const Color(0xFF9933FF),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DiscoveryCard extends StatefulWidget {
  final double width;
  final IconData icon;
  final String title;
  final String desc;
  final String stat;
  final String statLabel;
  final Color color;

  const _DiscoveryCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.desc,
    required this.stat,
    required this.statLabel,
    required this.color,
  });

  @override
  State<_DiscoveryCard> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<_DiscoveryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0F).withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hover
                ? widget.color.withOpacity(0.4)
                : const Color(0xFF1E1E24),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                right: _hover ? -20 : -40,
                bottom: _hover ? -20 : -40,
                child: Icon(
                  widget.icon,
                  size: 180,
                  color: widget.color.withOpacity(0.04),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.title,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.desc,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.6,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            widget.stat,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.statLabel,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: widget.color,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
