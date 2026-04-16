import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Color(0xFF15151A), height: 1),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOOLSHUB',
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
            ),
            Row(
              children: [
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    color: const Color(0xFF555555),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'Terms of Service',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    color: const Color(0xFF555555),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'Contact Us',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    color: const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
