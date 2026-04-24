import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FourStepsSection extends StatelessWidget {
  const FourStepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00FFD1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFD1).withOpacity(0.2)),
          ),
          child: Text(
            'ONBOARDING_PROCESS',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00FFD1),
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Four Steps to AI Mastery',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 80),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          const double maxWidth = 1100;
          final double wrapWidth = constraints.maxWidth > maxWidth ? maxWidth : constraints.maxWidth;

          return SizedBox(
            width: wrapWidth,
            child: Wrap(
              spacing: isMobile ? 40 : 0,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: [
                _StepItem(
                    index: 1,
                    width: isMobile ? double.infinity : wrapWidth / 4,
                    icon: Icons.search_rounded,
                    title: 'Discover Tools',
                    desc: 'Explore our directory to find the perfect AI tools for your next big project or daily workflow.'),
                _StepItem(
                    index: 2,
                    width: isMobile ? double.infinity : wrapWidth / 4,
                    icon: Icons.local_fire_department_rounded,
                    title: 'Track Trending',
                    desc: 'Stay ahead of the curve by monitoring the most dominant and disruptive AI tools in real-time.'),
                _StepItem(
                    index: 3,
                    width: isMobile ? double.infinity : wrapWidth / 4,
                    icon: Icons.auto_awesome_rounded,
                    title: 'Ask AI Assistant',
                    desc: 'Not sure what to use? Chat with our intelligent assistant to get personalized tool recommendations.'),
                _StepItem(
                    index: 4,
                    width: isMobile ? double.infinity : wrapWidth / 4,
                    icon: Icons.bolt_rounded,
                    title: 'Stay Updated',
                    desc: 'Get live telemetry and alerts on new industry shifts. Never miss a breakthrough again.'),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final double width;
  final IconData icon;
  final String title;
  final String desc;

  const _StepItem({
    required this.index,
    required this.width,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Connecting line for desktop
          if (width > 200 && index < 4)
            Positioned(
              top: 30,
              left: width * 0.5 + 40,
              right: -width * 0.5 + 40,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FFD1).withOpacity(0.5),
                      const Color(0xFF00FFD1).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E1E24), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFD1).withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: -5,
                    )
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF00FFD1), size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                '0$index',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00FFD1),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

