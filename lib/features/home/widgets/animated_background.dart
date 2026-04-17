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

          // ── Radial gradient fade for the grid ──────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Colors.transparent, Color(0xFF030303)],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),

          // ── Floating Orbs ─────────────────────────────────────────────────
          const FloatingOrb(delay: 0, size: 300, top: 0.2, left: 0.1),
          const FloatingOrb(delay: 2, size: 200, top: 0.1, left: 0.75),
          const FloatingOrb(delay: 4, size: 250, top: 0.6, left: 0.6),
          const FloatingOrb(delay: 1, size: 180, top: 0.7, left: 0.2),

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

class FloatingOrb extends StatefulWidget {
  final int delay;
  final double size;
  final double top;
  final double left;

  const FloatingOrb({
    super.key,
    required this.delay,
    required this.size,
    required this.top,
    required this.left,
  });

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateY;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _translateY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -30.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -30.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.15,
          end: 0.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.3,
          end: 0.15,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Initial state before delay starts
    _controller.value = 0;

    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blurSigma = kIsWeb ? 16.0 : 30.0;
    
    final content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Transform.scale(
            scale: _scale.value,
            child: Opacity(opacity: _opacity.value, child: child),
          ),
        );
      },
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6366F1),
            ),
          ),
        ),
      ),
    );

    if (kIsWeb) {
      return Positioned(
        top: MediaQuery.of(context).size.height * widget.top - (widget.size / 2),
        left: MediaQuery.of(context).size.width * widget.left - (widget.size / 2),
        child: content,
      );
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * widget.top - (widget.size / 2),
      left: MediaQuery.of(context).size.width * widget.left - (widget.size / 2),
      child: VisibilityDetector(
        key: Key('orb-${widget.delay}-${widget.top}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction <= 0.0) {
            if (_controller.isAnimating) _controller.stop();
          } else {
            if (!_controller.isAnimating) _controller.repeat();
          }
        },
        child: content,
      ),
    );
  }
}
