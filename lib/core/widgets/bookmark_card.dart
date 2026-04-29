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
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? color.withOpacity(0.15) : Colors.black.withOpacity(0.2),
                blurRadius: _isHovered ? 30 : 10,
                offset: const Offset(0, 10),
                spreadRadius: _isHovered ? 2 : -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Decorative Gradient Glow ──────────────────
                Positioned(
                  top: -50,
                  right: -50,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(_isHovered ? 0.15 : 0.05),
                          color.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Delete button (Top Right) ─────────────────────
                Positioned(
                  top: 12,
                  right: 12,
                  child: _DeleteButton(onTap: widget.onDelete),
                ),

                // ── Main Content Centered ──────────────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Logo with glow ──────────────────────────
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: LogoWidget(tool: tool, size: 42),
                        ),
                        const SizedBox(height: 16),

                        // ── Tool name ────────────────────────────────────────
                        Text(
                          tool.name,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Description ─────────────────────────────────────
                        Text(
                          tool.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4),
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Pricing badge ─────────────────────────────────────
                        _PricingBadge(label: tool.pricing, color: color),

                        const SizedBox(height: 20),

                        // ── Visit button ─────────────────────────────────────
                        _VisitButton(color: color, onTap: _launchUrl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
