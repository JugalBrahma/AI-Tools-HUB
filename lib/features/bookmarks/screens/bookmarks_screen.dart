import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/features/categories/widgets/tool_card.dart';
import 'package:toolshub/features/home/widgets/footer.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth - 1100).clamp(40.0, screenWidth) / 2;

    if (!auth.isLoggedIn) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1118),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1D2230)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF7B86A7),
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                'Sign in to view your saved tools',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A8FF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00A8FF).withOpacity(0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.bookmark_rounded,
                        color: Color(0xFF00A8FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Saved Tools',
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your personal shortlist of tools to revisit and compare.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF7F879B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Search Bar
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search your saved tools...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF555566),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF555566),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F0F12),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E1E28)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                _buildSavedToolsGrid(context),
                const SizedBox(height: 120),
                const Footer(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedToolsGrid(BuildContext context) {
    final toolProvider = context.watch<ToolProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();

    final Map<String, CategoryData> groupedSaves = {};
    for (var cat in toolProvider.categories) {
      final savedInCat = cat.tools.where((t) {
        final isSaved = bookmarkProvider.isBookmarked(t.docId);
        final matchesSearch =
            t.name.toLowerCase().contains(_searchQuery) ||
            t.description.toLowerCase().contains(_searchQuery);
        return isSaved && matchesSearch;
      }).toList();
      if (savedInCat.isNotEmpty) {
        groupedSaves[cat.name] = CategoryData(
          icon: cat.icon,
          name: cat.name,
          themeColor: cat.themeColor,
          tools: savedInCat,
        );
      }
    }

    if (groupedSaves.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E24)),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No saved tools yet'
                  : 'No matches found in saved tools',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            if (_searchQuery.isEmpty)
              Text(
                'Explore categories and save your favourites.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
              ),
          ],
        ),
      );
    }

    return Column(
      children: groupedSaves.values.map((CategoryData category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: category.themeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.themeColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(color: category.themeColor.withOpacity(0.1)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 500
                      ? 2
                      : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: category.tools.length,
                    itemBuilder: (context, index) {
                      return ToolCard(
                        tool: category.tools[index],
                        themeColor: category.themeColor,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
