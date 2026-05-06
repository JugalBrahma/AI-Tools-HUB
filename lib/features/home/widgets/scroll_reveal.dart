import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final double delay; // seconds

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  ScrollPosition? _scrollPosition;
  bool _triggered = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _translateY = Tween<double>(begin: 36.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    // Initial check after layout settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });

    // Web-specific safety: Flutter Web's scroll listeners are often unreliable 
    // when the browser natively handles scrolling. To prevent the content from 
    // being stuck invisible, we immediately trigger the animation on Web.
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_triggered) {
          _trigger();
        }
      });
    }
  }

  void _trigger() {
    if (_triggered || !mounted) return;
    _triggered = true;
    
    // Clean up listener immediately
    try {
      _scrollPosition?.removeListener(_checkVisibility);
    } catch (_) {}

    final delayMs = (widget.delay * 1000).toInt();
    if (delayMs <= 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachToScrollable();
    
    // Re-check visibility when dependencies change (e.g. scroll position became available).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  void _attachToScrollable() {
    ScrollPosition? newPosition;
    try {
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        // Accessing .position will work if exactly one position is attached.
        // If zero or multiple are attached, it may throw, which we catch below.
        newPosition = scrollable.position;
      }
    } catch (_) {
      // Fallback if .position throws due to multiple or no positions attached yet.
    }

    if (newPosition != _scrollPosition) {
      try {
        _scrollPosition?.removeListener(_checkVisibility);
      } catch (_) {}
      _scrollPosition = newPosition;
      try {
        _scrollPosition?.addListener(_checkVisibility);
      } catch (_) {}
    }
  }

  @override
  void didUpdateWidget(ScrollReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    try {
      _scrollPosition?.removeListener(_checkVisibility);
    } catch (_) {}
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_triggered || !mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      // If layout isn't ready, try again a few times in subsequent frames.
      if (_retryCount < 10) {
        _retryCount++;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _checkVisibility();
        });
      }
      return;
    }

    try {
      final viewportSize = MediaQuery.sizeOf(context);
      // Safety check: if viewport is not yet determined, retry.
      if (viewportSize.height <= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _checkVisibility();
        });
        return;
      }

      final globalPosition = box.localToGlobal(Offset.zero);
      final widgetHeight = box.size.height;

      // Widget is visible if any part of it overlaps the screen viewport.
      final bool isVisible = globalPosition.dy < viewportSize.height &&
          (globalPosition.dy + widgetHeight) > 0;

      if (isVisible) {
        _trigger();
      } else if (_scrollPosition == null) {
        // If we missed the scrollable before, try re-attaching.
        _attachToScrollable();
      }
    } catch (e) {
      // Fail-safe for coordinate transformation errors: trigger so content is visible.
      _trigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _translateY.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
