import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isPhone = constraints.maxWidth < 600;

        return Column(
          children: [
            const Divider(color: Color(0xFF15151A), height: 1),
            const SizedBox(height: 32),
            if (isPhone)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandInfo(),
                  const SizedBox(height: 24),
                  _buildLinks(isPhone: true),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBrandInfo(),
                  _buildLinks(isPhone: false),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildBrandInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI TOOLS HUB',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Built to help teams pick tools faster with less guesswork.',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 9,
            color: const Color(0xFF555555),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLinks({required bool isPhone}) {
    final List<Widget> links = [
      Text(
        'Privacy Policy',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          color: const Color(0xFF555555),
        ),
      ),
      SizedBox(width: isPhone ? 16 : 24),
      Text(
        'Terms of Service',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          color: const Color(0xFF555555),
        ),
      ),
      SizedBox(width: isPhone ? 16 : 24),
      Text(
        'Contact Us',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          color: const Color(0xFF555555),
        ),
      ),
    ];

    if (isPhone) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: links,
      );
    }

    return Row(children: links);
  }
}
