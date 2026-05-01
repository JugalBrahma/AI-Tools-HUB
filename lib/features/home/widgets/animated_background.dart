import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedGridBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGridBackground({super.key, required this.child});

  @override
  State<AnimatedGridBackground> createState() => _AnimatedGridBackgroundState();
}

class _AnimatedGridBackgroundState extends State<AnimatedGridBackground> {
  final ValueNotifier<Offset> _mousePosition = ValueNotifier(Offset.zero);
  static const Duration _hoverThrottle = Duration(milliseconds: 33);
  DateTime _lastHoverUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  Offset _lastHoverPosition = Offset.zero;

  void _onHover(PointerHoverEvent event) {
    final now = DateTime.now();
    if (now.difference(_lastHoverUpdate) < _hoverThrottle &&
        (event.position - _lastHoverPosition).distance < 12) {
      return;
    }
    _lastHoverUpdate = now;
    _lastHoverPosition = event.position;
    _mousePosition.value = event.position;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      child: Stack(
        children: [
          // ── Background color ──────────────────────────────────────────────
          Positioned.fill(child: Container(color: const Color(0xFF030303))),

          // ── Grid pattern ──────────────────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // ── Feature-Specific Background Elements ───────────────────────────
          // Discovery Section (Hexagons - Structure)
          const _FloatingShape(type: _ShapeType.hexagon, delay: 0, size: 280, top: 0.1, left: 0.1),
          const _FloatingShape(type: _ShapeType.hexagon, delay: 2, size: 180, top: 0.15, left: 0.8),
          
          // Four Steps / Onboarding (Crosses - Navigation)
          const _FloatingShape(type: _ShapeType.cross, delay: 1, size: 120, top: 0.3, left: 0.2),
          const _FloatingShape(type: _ShapeType.cross, delay: 3, size: 100, top: 0.35, left: 0.7),

          // Trending / Market Dominance (Rising Waves - Growth)
          const _FloatingShape(type: _ShapeType.wave, delay: 4, size: 200, top: 0.55, left: 0.15),
          const _FloatingShape(type: _ShapeType.wave, delay: 2, size: 220, top: 0.6, left: 0.85),

          // AI Assistant / Expert Advice (Sparkles - Intelligence)
          const _FloatingShape(type: _ShapeType.sparkle, delay: 0, size: 150, top: 0.8, left: 0.25),
          const _FloatingShape(type: _ShapeType.sparkle, delay: 2, size: 180, top: 0.85, left: 0.75),

          // CTA Section (Circles - Completeness)
          const _FloatingShape(type: _ShapeType.circle, delay: 1, size: 250, top: 0.95, left: 0.5),

          // ── Mouse Glow (Optimized with ValueListenableBuilder) ────────────
          ValueListenableBuilder<Offset>(
              valueListenable: _mousePosition,
              builder: (context, pos, child) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCirc,
                  left: pos.dx - 250,
                  top: pos.dy - 250,
                  child: child!,
                );
              },
              child: IgnorePointer(
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4A89FF).withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),

          // ── Main Content ──────────────────────────────────────────────────
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const double step = 80.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _ShapeType { hexagon, cross, wave, sparkle, circle }

class _FloatingShape extends StatefulWidget {
  final _ShapeType type;
  final int delay;
  final double size;
  final double top;
  final double left;

  const _FloatingShape({
    super.key,
    required this.type,
    required this.delay,
    required this.size,
    required this.top,
    required this.left,
  });

  @override
  State<_FloatingShape> createState() => _FloatingShapeState();
}

class _FloatingShapeState extends State<_FloatingShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateY;
  late Animation<double> _opacity;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8 + widget.delay),
    );

    _translateY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -30.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -30.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.04, end: 0.12).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.12, end: 0.04).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotate = Tween<double>(begin: 0, end: 2 * 3.14159).animate(_controller);

    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * widget.top - (widget.size / 2),
      left: MediaQuery.of(context).size.width * widget.left - (widget.size / 2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Transform.rotate(
              angle: widget.type == _ShapeType.wave ? 0 : _rotate.value * (widget.type == _ShapeType.cross ? 0.5 : 1.0),
              child: Opacity(
                opacity: _opacity.value,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SectionPainter(widget.type),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionPainter extends CustomPainter {
  final _ShapeType type;
  _SectionPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final double r = size.width / 2;
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    switch (type) {
      case _ShapeType.hexagon:
        final double hr = r * 0.7;
        path.moveTo(cx + hr, cy);
        for (int i = 1; i <= 6; i++) {
          final double angle = i * 60 * 3.14159 / 180;
          path.lineTo(cx + hr * (i == 0 || i == 3 ? 1 : 0.866) * (i == 0 || i == 3 ? 1 : 1), cy); // Simplified
        }
        // Correct Hex
        path.reset();
        path.moveTo(cx + hr, cy);
        path.lineTo(cx + hr * 0.5, cy + hr * 0.866);
        path.lineTo(cx - hr * 0.5, cy + hr * 0.866);
        path.lineTo(cx - hr, cy);
        path.lineTo(cx - hr * 0.5, cy - hr * 0.866);
        path.lineTo(cx + hr * 0.5, cy - hr * 0.866);
        path.close();
        break;

      case _ShapeType.cross:
        final double cr = r * 0.5;
        path.moveTo(cx - cr, cy);
        path.lineTo(cx + cr, cy);
        path.moveTo(cx, cy - cr);
        path.lineTo(cx, cy + cr);
        break;

      case _ShapeType.wave:
        final double wr = r * 0.8;
        path.moveTo(cx - wr, cy);
        path.quadraticBezierTo(cx - wr / 2, cy - wr / 2, cx, cy);
        path.quadraticBezierTo(cx + wr / 2, cy + wr / 2, cx + wr, cy);
        break;

      case _ShapeType.sparkle:
        final double sr = r * 0.6;
        for (int i = 0; i < 4; i++) {
          final double angle = i * 90 * 3.14159 / 180;
          path.moveTo(cx, cy);
          path.lineTo(cx + sr * (i % 2 == 0 ? 1 : 0), cy + sr * (i % 2 == 0 ? 0 : 1));
          // Wait, simple star
        }
        path.reset();
        path.moveTo(cx, cy - sr);
        path.quadraticBezierTo(cx + sr * 0.2, cy - sr * 0.2, cx + sr, cy);
        path.quadraticBezierTo(cx + sr * 0.2, cy + sr * 0.2, cx, cy + sr);
        path.quadraticBezierTo(cx - sr * 0.2, cy + sr * 0.2, cx - sr, cy);
        path.quadraticBezierTo(cx - sr * 0.2, cy - sr * 0.2, cx, cy - sr);
        break;

      case _ShapeType.circle:
        canvas.drawCircle(Offset(cx, cy), r * 0.6, paint);
        return;
    }

    canvas.drawPath(path, paint);
    
    // Subtle glow
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    paint.strokeWidth = 2.0;
    canvas.drawPath(path, paint);
  }

  Color _getColor() {
    switch (type) {
      case _ShapeType.hexagon: return const Color(0xFF6366F1);
      case _ShapeType.cross: return const Color(0xFF00FFD1);
      case _ShapeType.wave: return const Color(0xFFFF9900);
      case _ShapeType.sparkle: return const Color(0xFF9933FF);
      case _ShapeType.circle: return const Color(0xFF00A8FF);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



