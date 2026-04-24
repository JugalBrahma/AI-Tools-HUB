import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/features/categories/widgets/logo_widget.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';

class PopularToolsGrid extends StatelessWidget {
  const PopularToolsGrid({super.key});

  static const List<String> _preferredPopularNames = [
    'chatgpt',
    'claude',
    'gemini',
    'perplexity',
    'midjourney',
    'cursor',
    'notion ai',
    'copilot',
    'runway',
    'elevenlabs',
    'canva',
    'suno',
  ];

  @override
  Widget build(BuildContext context) {
    final toolProvider = context.watch<ToolProvider>();
    final featuredTools = _selectFeaturedTools(toolProvider.categories);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isMobile = width < 700;
        final bool isTablet = width < 1100 && width >= 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FFD1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00FFD1).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'ESSENTIAL_STACK',
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00FFD1),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Industry Leading Tools',
                          style: GoogleFonts.inter(
                            fontSize: width < 600 ? 28 : 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: width < 600 ? 32 : 64),

                if (featuredTools.isEmpty)
                  _EmptyFeaturedState(isLoading: toolProvider.isLoading)
                else if (isMobile)
                  _buildMobileLayout(featuredTools)
                else if (isTablet)
                  _buildTabletLayout(width, featuredTools)
                else
                  _buildDesktopLayout(width, featuredTools),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ToolInfo> _selectFeaturedTools(List<CategoryData> categories) {
    final allTools = categories.expand((c) => c.tools).toList();
    final byPreferred = <ToolInfo>[];
    final remaining = <ToolInfo>[];
    final seenNames = <String>{};
    final usedPreferredKeys = <String>{};

    for (final tool in allTools) {
      final name = tool.name.toLowerCase().trim();
      if (name.isEmpty || seenNames.contains(name)) continue;
      seenNames.add(name);

      final matchedKey = _preferredPopularNames.cast<String?>().firstWhere(
        (p) => p != null && name.contains(p),
        orElse: () => null,
      );

      if (matchedKey != null) {
        // Prevent duplicate brands like "Gemini 1.5" + "Google Gemini"
        if (usedPreferredKeys.contains(matchedKey)) continue;
        usedPreferredKeys.add(matchedKey);
        byPreferred.add(tool);
      } else {
        remaining.add(tool);
      }
    }

    byPreferred.sort((a, b) {
      final ai = _preferredPopularNames.indexWhere(
        (p) => a.name.toLowerCase().contains(p),
      );
      final bi = _preferredPopularNames.indexWhere(
        (p) => b.name.toLowerCase().contains(p),
      );
      return ai.compareTo(bi);
    });

    remaining.sort((a, b) {
      final aHasLogo = a.logo.trim().isNotEmpty ? 1 : 0;
      final bHasLogo = b.logo.trim().isNotEmpty ? 1 : 0;
      if (aHasLogo != bHasLogo) return bHasLogo.compareTo(aHasLogo);
      return a.name.compareTo(b.name);
    });

    final picked = <ToolInfo>[];
    for (final tool in [...byPreferred, ...remaining]) {
      picked.add(tool);
      if (picked.length == 6) break;
    }
    return picked;
  }

  Widget _buildMobileLayout(List<ToolInfo> tools) {
    return Column(
      children: List.generate(
        tools.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: ScrollReveal(
            delay: index * 0.1,
            child: SizedBox(
              height: 180,
              child: _PopularToolCard(tool: tools[index], index: index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(double totalWidth, List<ToolInfo> tools) {
    final double cardWidth = (totalWidth - 20) / 2;
    final safeTools = List<ToolInfo>.generate(
      6,
      (i) => tools[i % tools.length],
    );
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        ScrollReveal(
          delay: 0.1,
          child: SizedBox(
            width: cardWidth,
            height: 280,
            child: _PopularToolCard(
              tool: safeTools[0],
              index: 0,
              isLarge: true,
            ),
          ),
        ),
        ScrollReveal(
          delay: 0.2,
          child: SizedBox(
            width: cardWidth,
            height: 220,
            child: _PopularToolCard(tool: safeTools[1], index: 1),
          ),
        ),
        ScrollReveal(
          delay: 0.3,
          child: SizedBox(
            width: cardWidth,
            height: 220,
            child: _PopularToolCard(tool: safeTools[2], index: 2),
          ),
        ),
        ScrollReveal(
          delay: 0.4,
          child: SizedBox(
            width: cardWidth,
            height: 280,
            child: _PopularToolCard(tool: safeTools[3], index: 3),
          ),
        ),
        ScrollReveal(
          delay: 0.5,
          child: SizedBox(
            width: cardWidth,
            height: 220,
            child: _PopularToolCard(tool: safeTools[4], index: 4),
          ),
        ),
        ScrollReveal(
          delay: 0.6,
          child: SizedBox(
            width: cardWidth,
            height: 220,
            child: _PopularToolCard(tool: safeTools[5], index: 5),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(double totalWidth, List<ToolInfo> tools) {
    const double spacing = 20.0;
    final safeTools = List<ToolInfo>.generate(
      6,
      (i) => tools[i % tools.length],
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ScrollReveal(
                delay: 0.1,
                child: SizedBox(
                  height: 330,
                  child: _PopularToolCard(
                    tool: safeTools[0],
                    index: 0,
                    isLarge: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              flex: 2,
              child: ScrollReveal(
                delay: 0.2,
                child: SizedBox(
                  height: 330,
                  child: _PopularToolCard(tool: safeTools[1], index: 1),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              flex: 2,
              child: ScrollReveal(
                delay: 0.3,
                child: SizedBox(
                  height: 330,
                  child: _PopularToolCard(tool: safeTools[2], index: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: ScrollReveal(
                delay: 0.4,
                child: SizedBox(
                  height: 220,
                  child: _PopularToolCard(tool: safeTools[3], index: 3),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: ScrollReveal(
                delay: 0.5,
                child: SizedBox(
                  height: 220,
                  child: _PopularToolCard(tool: safeTools[4], index: 4),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: ScrollReveal(
                delay: 0.6,
                child: SizedBox(
                  height: 220,
                  child: _PopularToolCard(tool: safeTools[5], index: 5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PopularToolCard extends StatefulWidget {
  final ToolInfo tool;
  final int index;
  final bool isLarge;
  const _PopularToolCard({
    required this.tool,
    required this.index,
    this.isLarge = false,
  });

  @override
  State<_PopularToolCard> createState() => _PopularToolCardState();
}

class _PopularToolCardState extends State<_PopularToolCard> {
  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final color = tool.accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131722), Color(0xFF0D0F15)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF242B3A), width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 230;
          final cardPadding = isCompact ? 14.0 : 20.0;
          final logoSize = isCompact ? 40.0 : 52.0;

          return Stack(
            children: [
              Positioned(
                right: -50,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.16), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        LogoWidget(
                          tool: tool,
                          size: logoSize,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isCompact ? 10 : (widget.isLarge ? 18 : 16),
                    ),
                    Text(
                      tool.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: isCompact ? 17 : (widget.isLarge ? 30 : 21),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: isCompact ? 6 : 10),
                    Expanded(
                      child: Text(
                        tool.description.trim().isEmpty
                            ? 'No description available yet.'
                            : tool.description,
                        maxLines: isCompact ? 1 : (widget.isLarge ? 3 : 2),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: isCompact ? 12 : 14,
                          color: Colors.white54,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _getDisplayCategory(tool.name, tool.category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getDisplayCategory(String name, String original) {
    final n = name.toLowerCase();
    if (n.contains('chatgpt') || n.contains('claude') || n.contains('gemini')) return 'AI CHAT';
    if (n.contains('perplexity')) return 'AI SEARCH';
    if (n.contains('midjourney') || n.contains('leonardo')) return 'IMAGE GEN';
    if (n.contains('cursor') || n.contains('copilot') || n.contains('replit')) return 'CODING';
    if (n.contains('runway') || n.contains('pika') || n.contains('sora') || n.contains('veo')) return 'VIDEO GEN';
    if (n.contains('notion') || n.contains('jasper') || n.contains('writesonic')) return 'WRITING';
    if (n.contains('canva') || n.contains('framer') || n.contains('gamma')) return 'DESIGN';
    if (n.contains('elevenlabs')) return 'VOICE GEN';
    if (n.contains('suno')) return 'MUSIC GEN';
    if (n.contains('bolt') || n.contains('lovable') || n.contains('v0')) return 'VIBE CODING';
    return original.toUpperCase();
  }
}

class _EmptyFeaturedState extends StatelessWidget {
  const _EmptyFeaturedState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E1E24)),
      ),
      child: Text(
        'No tools available yet. Add tools in Firestore to populate featured cards.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
