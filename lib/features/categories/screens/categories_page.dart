import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/models/tool_model.dart';

import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/features/categories/widgets/filter_bar.dart';
import 'package:toolshub/features/categories/widgets/shimmer_grid.dart';
import 'package:toolshub/features/categories/widgets/tool_sliver_grid.dart';
import 'package:toolshub/features/categories/widgets/category_sliver_group.dart';
import 'package:toolshub/features/home/widgets/footer.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  int _activeFilter = -1;

  void _scrollToCategory(int index) {
    setState(() => _activeFilter = index);
  }

  @override
  Widget build(BuildContext context) {
    final toolProvider = Provider.of<ToolProvider>(context);
    final categories = toolProvider.categories;
    final isSearching = _searchQuery.isNotEmpty;
    final List<ToolInfo> searchResults = isSearching
        ? toolProvider.searchTools(_searchQuery)
        : const <ToolInfo>[];

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth - 1100).clamp(40.0, screenWidth) / 2;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 52)),

        // ── Sticky Search Bar ──────────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickySearchDelegate(
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              color: const Color(0xFF030303),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0C10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1C1C24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF00D4AA),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Search tools, categories, use cases...',
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFF333340),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFF444455),
                              ),
                              onPressed: () => _searchController.clear(),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14141C),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF222230),
                              ),
                            ),
                            child: Text(
                              '⌘ K',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 11,
                                color: const Color(0xFF444455),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Header Text + Filter Bar ─────────────────────────────────────
        if (!isSearching)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF11141D), Color(0xFF0A0B10)],
                      ),
                      border: Border.all(color: const Color(0xFF1D2230)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00D4AA).withOpacity(0.28),
                            ),
                          ),
                          child: const Icon(
                            Icons.apps_rounded,
                            color: Color(0xFF00D4AA),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Browse AI Categories',
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${categories.length} categories • ${categories.fold<int>(0, (sum, c) => sum + c.tools.length)} tools indexed',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF8C93A8),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilterBar(
                    categories: categories,
                    activeIndex: _activeFilter,
                    onAll: () => _scrollToCategory(-1),
                    onTap: _scrollToCategory,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

        // ── Loading state ──────────────────────────────────────────────
        if (toolProvider.isLoading)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: const SliverToBoxAdapter(child: ShimmerGrid()),
          ),

        // ── Search Results ─────────────────────────────────────────────
        if (isSearching)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      children: [
                        Text(
                          'Search results',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A24),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF253043)),
                          ),
                          child: Text(
                            '${searchResults.length}',
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF89B4FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ToolSliverGrid(
                  tools: searchResults,
                  themeColor: const Color(0xFF00D4AA),
                ),
              ],
            ),
          ),

        // ── Category Groups ───────────────────────────────────────────
        if (!toolProvider.isLoading && !isSearching)
          ...(_activeFilter == -1 ? categories : [categories[_activeFilter]])
              .map(
                (cat) => SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: CategorySliverGroup(category: cat),
                ),
              ),

        // ── Footer ───────────────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: const SliverToBoxAdapter(
            child: Column(
              children: [SizedBox(height: 120), Footer(), SizedBox(height: 40)],
            ),
          ),
        ),
      ],
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickySearchDelegate({required this.child});

  @override
  double get minExtent => 90.0;
  @override
  double get maxExtent => 90.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickySearchDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
