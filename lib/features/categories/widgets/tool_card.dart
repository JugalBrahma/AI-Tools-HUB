import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/providers/bookmark_provider.dart';
import 'package:toolshub/core/providers/history_provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'logo_widget.dart';

class ToolCard extends StatefulWidget {
  const ToolCard({super.key, required this.tool, required this.themeColor});
  final ToolInfo tool;
  final Color themeColor;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  void _showCompactMessage(
    String text, {
    Color accent = const Color(0xFF00D4AA),
  }) {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final sideInset = screenWidth > 680 ? (screenWidth - 460) / 2 : 16.0;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withOpacity(0.35)),
                ),
                child: Icon(Icons.check_rounded, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1700),
          margin: EdgeInsets.only(
            left: sideInset,
            right: sideInset,
            bottom: 18,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: const Color(0xFF0F1624),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accent.withOpacity(0.6)),
          ),
          elevation: 8,
        ),
      );
  }

  Future<void> _launchUrl() async {
    final raw = widget.tool.url.trim();
    final normalized = raw.contains('://') ? raw : 'https://$raw';
    final Uri? url = Uri.tryParse(normalized);
    if (url == null) {
      _showCompactMessage('Invalid tool URL');
      return;
    }

    if (!await launchUrl(url)) {
      _showCompactMessage('Could not open this tool');
      return;
    }

    // Record "Try it now" usage for Recently Used.
    await context.read<HistoryProvider>().recordUsage(widget.tool.docId);
    _showCompactMessage('Opened ${widget.tool.name}');
  }

  Future<void> _toggleBookmark({
    required BookmarkProvider bookmarkProvider,
    required app_auth.AuthProvider authProvider,
  }) async {
    if (!authProvider.isLoggedIn) {
      _showCompactMessage('Sign in to save tools');
      return;
    }

    final wasBookmarked = bookmarkProvider.isBookmarked(widget.tool.docId);

    if (wasBookmarked) {
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF11141C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF262C3C)),
            ),
            title: Text(
              'Remove from saved?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            content: Text(
              '${widget.tool.name} will be removed from your saved tools.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Remove',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (shouldRemove != true) return;
    }

    await bookmarkProvider.toggleBookmark(widget.tool.docId);
    _showCompactMessage(
      wasBookmarked ? 'Removed from saved tools' : 'Saved to bookmarks',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final tc = widget.themeColor;
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final authProvider = context.watch<app_auth.AuthProvider>();
    final isBookmarked = bookmarkProvider.isBookmarked(tool.docId);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF161620), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [tc, tc.withOpacity(0.0)]),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LogoWidget(tool: tool),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _toggleBookmark(
                              bookmarkProvider: bookmarkProvider,
                              authProvider: authProvider,
                            ),
                            borderRadius: BorderRadius.circular(9),
                            child: Ink(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isBookmarked
                                    ? const Color(0xFF00A8FF).withOpacity(0.18)
                                    : const Color(0xFF13131A),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: isBookmarked
                                      ? const Color(
                                          0xFF00A8FF,
                                        ).withOpacity(0.42)
                                      : const Color(0xFF252533),
                                ),
                              ),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 16,
                                color: isBookmarked
                                    ? const Color(0xFF00A8FF)
                                    : const Color(0xFF7C7C90),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tool.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.description,
                      maxLines: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF888899),
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (tool.pricing.isEmpty ||
                                        tool.pricing.toLowerCase() == 'free'
                                    ? const Color(0xFF00D4AA)
                                    : tc)
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              (tool.pricing.isEmpty ||
                                          tool.pricing.toLowerCase() == 'free'
                                      ? const Color(0xFF00D4AA)
                                      : tc)
                                  .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 9,
                              color:
                                  (tool.pricing.isEmpty ||
                                      tool.pricing.toLowerCase() == 'free'
                                  ? const Color(0xFF00D4AA)
                                  : tc),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              tool.pricing.isEmpty
                                  ? 'FREEMIUM'
                                  : tool.pricing.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color:
                                    (tool.pricing.isEmpty ||
                                        tool.pricing.toLowerCase() == 'free'
                                    ? const Color(0xFF00D4AA)
                                    : tc),
                                letterSpacing: 0.2,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Material(
                          color: tc,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: _launchUrl,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              height: 34,
                              child: Center(
                                child: Text(
                                  'Try it now',
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
