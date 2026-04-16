import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhoIsThisForSection extends StatelessWidget {
  const WhoIsThisForSection({super.key});

  static const List<Map<String, dynamic>> audiences = [
    {
      'title': 'Developers',
      'icon': Icons.code_rounded,
      'color': Color(0xFF00A8FF),
      'desc':
          'Compare Copilot vs Cursor. Find deep-learning libraries and dev-ops automation tools.',
    },
    {
      'title': 'Business Leaders',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF00FFD1),
      'desc':
          'Identify tools that cut costs and scale teams with AI-driven augmentation.',
    },
    {
      'title': 'Students',
      'icon': Icons.school_rounded,
      'color': Color(0xFFFF9900),
      'desc':
          'Find AI tutors and research assistants. Discover free student-tier tools.',
    },
    {
      'title': 'Creators',
      'icon': Icons.videocam_rounded,
      'color': Color(0xFFFF3366),
      'desc':
          'AI video generators, script writing assistants, and high-fidelity asset creators.',
    },
    {
      'title': 'Designers',
      'icon': Icons.palette_rounded,
      'color': Color(0xFF9933FF),
      'desc':
          'Generative UI tools, mockup assistants, and branding automation suites.',
    },
    {
      'title': 'Marketers',
      'icon': Icons.analytics_rounded,
      'color': Color(0xFF00D4AA),
      'desc':
          'SEO optimization, automated copywriting, and data-driven campaign analytics.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF9933FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF9933FF).withOpacity(0.2)),
          ),
          child: Text(
            'TARGETED_SOLUTIONS',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9933FF),
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Who Is This For?',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 64),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossCount = 3;
            if (constraints.maxWidth < 1100) crossCount = 2;
            if (constraints.maxWidth < 700) crossCount = 1;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.5,
                ),
                itemCount: audiences.length,
                itemBuilder: (context, index) {
                  final a = audiences[index];
                  return _AudienceCard(
                    title: a['title'],
                    icon: a['icon'],
                    color: a['color'],
                    desc: a['desc'],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AudienceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String desc;

  const _AudienceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.desc,
  });

  @override
  State<_AudienceCard> createState() => _AudienceCardState();
}

class _AudienceCardState extends State<_AudienceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final int seed = widget.title.hashCode.abs();
    final int durationMs = 2600 + (seed % 1000);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _hover ? 1 : 0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        builder: (context, hoverT, _) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: durationMs),
            curve: Curves.easeInOut,
            onEnd: () {
              if (mounted) {
                setState(() {});
              }
            },
            builder: (context, loopT, __) {
              final pulse = (loopT < 0.5 ? loopT : (1 - loopT)) * 2;
              final iconYOffset = -3.0 * pulse;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0F),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color.lerp(
                      const Color(0xFF1E1E24),
                      widget.color.withOpacity(0.5),
                      hoverT * 0.9 + pulse * 0.1,
                    )!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.04 + (pulse * 0.03)),
                      blurRadius: 20 + (pulse * 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -22,
                      bottom: -26,
                      child: Icon(
                        widget.icon,
                        size: 96,
                        color: widget.color.withOpacity(0.04 + (pulse * 0.03)),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: Offset(0, iconYOffset),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(
                                0.10 + (hoverT * 0.05) + (pulse * 0.03),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          height: 3,
                          width: 26 + (hoverT * 30) + (pulse * 10),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
