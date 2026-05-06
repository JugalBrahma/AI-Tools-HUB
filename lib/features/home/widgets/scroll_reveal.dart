import 'package:flutter/material.dart';

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

    // Check visibility after first layout (catches items already on screen).
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Attach to the nearest Scrollable's position so we re-check on every scroll event.
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_checkVisibility);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_checkVisibility);
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_triggered || !mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    // Use global (screen) coordinates — works regardless of scroll nesting.
    final globalPosition = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Widget is visible if any part of it overlaps the screen viewport.
    final isVisible = globalPosition.dy < screenHeight &&
        globalPosition.dy + box.size.height > 0;

    if (isVisible) {
      _triggered = true;
      // Detach scroll listener — no longer needed after trigger.
      _scrollPosition?.removeListener(_checkVisibility);

      final delayMs = (widget.delay * 1000).toInt();
      if (delayMs == 0) {
        _controller.forward();
      } else {
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translateY.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
