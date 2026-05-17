import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                  _buildLinks(),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandInfo(),
                  _buildLinks(),
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

  Widget _buildLinks() {
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: [
        _FooterLink(href: '/', label: 'AI Tools Directory'),
        _FooterLink(href: '/trending', label: 'Trending AI Tools'),
        _FooterLink(href: '/assistant', label: 'AI Stack Assistant'),
        _FooterLink(href: '/bookmarks', label: 'Saved Tools'),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.href, required this.label});

  final String href;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(href),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          color: const Color(0xFF888888),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF444444),
        ),
      ),
    );
  }
}
