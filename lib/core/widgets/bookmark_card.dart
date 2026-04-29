import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/widgets/logo_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarkCard extends StatefulWidget {
  final ToolInfo tool;
  final Color themeColor;
  final VoidCallback? onDelete;

  const BookmarkCard({
    super.key,
    required this.tool,
    required this.themeColor,
    this.onDelete,
  });

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    final url = Uri.parse(widget.tool.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final color = widget.themeColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF16161E) : const Color(0xFF0F0F15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered ? color.withOpacity(0.45) : const Color(0xFF222228),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, spreadRadius: 0)]
              : [],
        ),
        child: Stack(
          children: [
            // ── Delete button (Top Right) ─────────────────────
            Positioned(
              top: 4,
              right: 4,
              child: _DeleteButton(onTap: widget.onDelete),
            ),

            // ── Main Content Centered ──────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Logo ──────────────────────────────────────────
                    LogoWidget(tool: tool, size: 34),
                    const SizedBox(height: 10),

                    // ── Tool name ────────────────────────────────────────
                    Text(
                      tool.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Description ─────────────────────────────────────
                    Text(
                      tool.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white38,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Pricing badge ─────────────────────────────────────
                    _PricingBadge(label: tool.pricing, color: color),

                    const SizedBox(height: 12),

                    // ── Visit button ─────────────────────────────────────
                    _VisitButton(color: color, onTap: _launchUrl),
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

// ─── Pricing badge ────────────────────────────────────────────────────────────
class _PricingBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PricingBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: Colors.white60,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Visit button ─────────────────────────────────────────────────────────────
class _VisitButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  const _VisitButton({required this.color, required this.onTap});

  @override
  State<_VisitButton> createState() => _VisitButtonState();
}

class _VisitButtonState extends State<_VisitButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? widget.color : widget.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hover
                ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Visit Site',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // High contrast
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.open_in_new_rounded,
                size: 11,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Delete button ────────────────────────────────────────────────────────────
class _DeleteButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _DeleteButton({this.onTap});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _hover ? Colors.redAccent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 14,
            color: _hover ? Colors.redAccent : Colors.white24,
          ),
        ),
      ),
    );
  }
}
