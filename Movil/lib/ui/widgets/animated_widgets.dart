import 'package:flutter/material.dart';

class AnimatedXpBadge extends StatefulWidget {
  final int xp;
  final bool animate;

  const AnimatedXpBadge({
    super.key,
    required this.xp,
    this.animate = true,
  });

  @override
  State<AnimatedXpBadge> createState() => _AnimatedXpBadgeState();
}

class _AnimatedXpBadgeState extends State<AnimatedXpBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _displayedXp = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _displayedXp = widget.xp;
  }

  @override
  void didUpdateWidget(AnimatedXpBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.xp != oldWidget.xp && widget.animate) {
      _animateXpChange(oldWidget.xp, widget.xp);
    } else {
      _displayedXp = widget.xp;
    }
  }

  void _animateXpChange(int from, int to) async {
    final diff = to - from;
    final steps = diff.abs().clamp(1, 20);
    final stepValue = diff / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _displayedXp = (from + stepValue * (i + 1)).round();
        });
      }
    }
    _displayedXp = to;

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Color(0xFFF6C85F),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$_displayedXp XP',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFFF6C85F),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLevelUp extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onComplete;

  const AnimatedLevelUp({
    super.key,
    required this.newLevel,
    this.onComplete,
  });

  @override
  State<AnimatedLevelUp> createState() => _AnimatedLevelUpState();
}

class _AnimatedLevelUpState extends State<AnimatedLevelUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(
            alpha: (_controller.value * 0.6).clamp(0.0, 0.6),
          ),
          child: Center(
            child: Transform.scale(
              scale: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
              ).value,
              child: Opacity(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.0, 0.3),
                ).value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Subiste de nivel!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nivel ${widget.newLevel}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF6C85F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final bool active;

  const PulsingWidget({
    super.key,
    required this.child,
    this.active = true,
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

/// Staggered animation for list items
class StaggeredAnimation extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;
  final Duration delay;
  final Duration duration;

  const StaggeredAnimation({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * delay.inMilliseconds / 1000).clamp(0.0, 1.0);
    final end = (start + duration.inMilliseconds / 1000).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animValue = controller.value;
        if (animValue < start) {
          return const SizedBox.shrink();
        }
        final progress = ((animValue - start) / (end - start)).clamp(0.0, 1.0);
        final curved = Curves.easeOutCubic.transform(progress);

        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curved)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
