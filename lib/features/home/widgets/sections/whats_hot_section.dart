import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhatsHotSection extends StatelessWidget {
  const WhatsHotSection({super.key});

  @override
  Widget build(BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9900).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF9900).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.whatshot, size: 12, color: Color(0xFFFF9900)),
                      const SizedBox(width: 8),
                      Text(
                        'EVALUATION_CHECKLIST',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF9900),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'How This Helps You Decide',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Use this checklist to pick tools based on fit, not hype.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
                ),
                const SizedBox(height: 64),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _TrendingRow(
                        rank: '01',
                        name: 'Define Outcome',
                        category: 'Planning',
                        growth: 'Start here',
                        users: 'Step 0',
                      ),
                      _TrendingRow(
                        rank: '02',
                        name: 'Match Use Case First',
                        category: 'Productivity',
                        growth: 'Priority',
                        users: 'Step 1',
                      ),
                      _TrendingRow(
                        rank: '03',
                        name: 'Check Pricing Early',
                        category: 'Budget',
                        growth: 'Avoid surprises',
                        users: 'Step 2',
                      ),
                      _TrendingRow(
                        rank: '04',
                        name: 'Review Integrations',
                        category: 'Workflow',
                        growth: 'Reduce friction',
                        users: 'Step 3',
                      ),
                      _TrendingRow(
                        rank: '05',
                        name: 'Bookmark Shortlist',
                        category: 'Decision',
                        growth: 'Team review',
                        users: 'Step 4',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

class _TrendingRow extends StatefulWidget {
  final String rank;
  final String name;
  final String category;
  final String growth;
  final String users;

  const _TrendingRow({
    required this.rank,
    required this.name,
    required this.category,
    required this.growth,
    required this.users,
  });

  @override
  State<_TrendingRow> createState() => _TrendingRowState();
}

class _TrendingRowState extends State<_TrendingRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: _hover ? Colors.white.withOpacity(0.03) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                widget.rank,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _hover ? const Color(0xFFFF9900) : Colors.white24,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.category.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      color: Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 1,
              child: Text(
                widget.users,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFD1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.growth,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00FFD1),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Icon(
              Icons.trending_up_rounded,
              size: 18,
              color: const Color(0xFF00FFD1).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
