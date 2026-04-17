import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final double delay;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    // On web, fire visibility updates immediately (no debounce throttle)
    if (kIsWeb) {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    // Web fallback: if VisibilityDetector never fires (widget already in viewport),
    // auto-reveal after a short delay so images don't stay invisible
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(
          Duration(milliseconds: 300 + (widget.delay * 1000).toInt()),
          () {
            if (mounted && !_isVisible) {
              setState(() => _isVisible = true);
              _controller.forward();
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Lower threshold to 5% so partially visible items trigger faster on web
    if (info.visibleFraction > 0.05 && !_isVisible) {
      if (mounted) {
        setState(() => _isVisible = true);
        Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('scroll_reveal_${identityHashCode(widget)}_${widget.child.runtimeType}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: _slide.value * 100.0,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
