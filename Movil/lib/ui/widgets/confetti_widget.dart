import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ConfettiWidget extends StatefulWidget {
  final bool show;
  final Duration duration;
  final int particleCount;
  final Color color;

  const ConfettiWidget({
    super.key,
    this.show = false,
    this.duration = const Duration(milliseconds: 2000),
    this.particleCount = 50,
    this.color = const Color(0xFFF6C85F),
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _particles = _generateParticles();

    if (widget.show) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _particles = _generateParticles();
      _controller.forward(from: 0);
    }
  }

  List<_Particle> _generateParticles() {
    final random = Random();
    return List.generate(widget.particleCount, (_) {
      final colors = [
        widget.color,
        AppColors.primary,
        AppColors.secondary,
        AppColors.xpGold,
        AppColors.coralSoft,
        AppColors.lavender,
      ];
      return _Particle(
        color: colors[random.nextInt(colors.length)],
        speed: random.nextDouble() * 3 + 2,
        angle: random.nextDouble() * 2 * pi - pi,
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        );
      },
    );
  }
}

class _Particle {
  final Color color;
  final double speed;
  final double angle;
  final double size;
  final double rotation;
  final double rotationSpeed;

  _Particle({
    required this.color,
    required this.speed,
    required this.angle,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()..color = particle.color;

      final x = size.width / 2 +
          cos(particle.angle) * particle.speed * progress * 200;
      final y = -50 +
          progress * (size.height + 100) * (particle.speed / 5);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * progress);

      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = particle.color.withValues(alpha: opacity);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
