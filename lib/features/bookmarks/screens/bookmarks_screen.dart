import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/features/categories/widgets/tool_card.dart';

class BookmarksScreen extends StatelessWidget {
  final VoidCallback? onDismiss;
  const BookmarksScreen({super.key, this.onDismiss});

  String _getFaviconUrl(String siteUrl) {
    if (siteUrl.isEmpty) return '';
    return 'https://t3.gstatic.com/faviconV2'
        '?client=SOCIAL'
        '&type=FAVICON'
        '&fallback_opts=TYPE,SIZE,URL'
        '&url=${Uri.encodeComponent(siteUrl)}'
        '&size=128';
  }

  Future<void> _confirmDelete(BuildContext context, ToolInfo tool, BookmarkProvider bookmarkProvider, String uid) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0C0C12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),

        title: Text(
          'Remove Bookmark?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove "${tool.name}" from your bookmarks?',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      if (tool.category == 'AI Recommendation') {
        await FirebaseFirestore.instance
            .collection('ai_history')
            .doc(uid)
            .collection('bookmarks')
            .doc(tool.docId)
            .delete();
      } else {
        await bookmarkProvider.toggleBookmark(tool.docId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 5;
    } else if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF030303),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: onDismiss ?? () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Text(
                'Bookmarks',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4AA).withOpacity(0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: !auth.isLoggedIn 
                ? SliverToBoxAdapter(child: _buildLoginPrompt())
                : _buildUnifiedBookmarksGrid(context, auth, crossAxisCount),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 48),
          const SizedBox(height: 20),
          Text(
            'Sign in to access your bookmarks',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedBookmarksGrid(BuildContext context, app_auth.AuthProvider auth, int crossAxisCount) {
    final toolProvider = context.watch<ToolProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();

    final List<(ToolInfo, Color)> allItems = [];
    for (var cat in toolProvider.categories) {
      for (var tool in cat.tools) {
        if (bookmarkProvider.isBookmarked(tool.docId)) {
          allItems.add((tool, cat.themeColor));
        }
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ai_history')
          .doc(auth.currentUser!.uid)
          .collection('bookmarks')
          .orderBy('pinnedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final aiDocs = snapshot.data?.docs ?? [];
        final List<(ToolInfo, Color)> aiItems = aiDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final url = data['url'] ?? '';
          final name = data['toolName'] ?? 'Unknown';
          final desc = data['why_it_fits'] ?? data['best_for'] ?? '';
          
          final tool = ToolInfo(
            docId: doc.id,
            name: name,
            url: url,
            description: desc,
            logo: _getFaviconUrl(url),
            category: 'AI Recommendation',
            pricing: data['price'] ?? 'FREE / TRIAL',
            accentColor: const Color(0xFF00D4AA),
            logoGradient: [const Color(0xFF00D4AA), const Color(0xFF00A8FF)],
            searchName: name.toLowerCase(),
            searchDescription: desc.toLowerCase(),
          );
          return (tool, const Color(0xFF00D4AA));
        }).toList();

        final combinedItems = [...aiItems, ...allItems];

        if (combinedItems.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = combinedItems[index];
              return ToolCard(
                tool: entry.$1,
                themeColor: entry.$2,
                showBookmark: false,
                showDelete: true,
                onDelete: () => _confirmDelete(context, entry.$1, bookmarkProvider, auth.currentUser!.uid),
              );
            },
            childCount: combinedItems.length,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          const Icon(Icons.bookmarks_outlined, color: Colors.white10, size: 48),
          const SizedBox(height: 20),
          Text(
            'Your bookmark list is empty',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
