import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNavChanged;
  final VoidCallback onMenuTap;

  const TopNavBar({
    super.key,
    this.activeIndex = 0,
    required this.onNavChanged,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isPhone = width < 600;

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF030303),
        border: Border(bottom: BorderSide(color: Color(0xFF15151A), width: 1)),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isPhone ? 20 : 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Brand Logo ───────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOOLSHUB',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'REAL AI TOOL CATALOG',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 7,
                      color: const Color(0xFF888888),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              // ── Hamburger Menu ───────────────────────────────────
              _MenuButton(onTap: onMenuTap),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu Button with Hover ─────────────────────────────────────────────────────

class _MenuButton extends StatefulWidget {
  final VoidCallback onTap;
  const _MenuButton({required this.onTap});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hovering
                ? Colors.white.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovering
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.menu_rounded,
              color: _hovering ? Colors.white : const Color(0xFF888888),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Link (kept for reuse) ─────────────────────────────────────────────────

class NavLink extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;
  const NavLink(this.title, {super.key, this.isActive = false, this.onTap});

  @override
  State<NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: widget.isActive
                ? const Color(0xFF4A89FF)
                : _hovering
                ? Colors.white
                : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}
