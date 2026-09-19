import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3000), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColorsDark.background,
                    AppColorsDark.surface,
                    AppColorsDark.tertiary.withValues(alpha: 0.3),
                  ]
                : [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                    AppColors.secondary.withValues(alpha: 0.7),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: child,
                  ),
                );
              },
              child: _buildLeafIcon(),
            ),
            const SizedBox(height: 32),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Eco Retos',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pequeñas acciones, grandes cambios.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: isDark
                      ? AppColorsDark.primary
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLeafIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: _LeafPainter(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color color;

  _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;


    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.cubicTo(
      center.dx + radius * 1.2,
      center.dy - radius * 0.5,
      center.dx + radius * 0.8,
      center.dy + radius * 0.8,
      center.dx,
      center.dy + radius,
    );
    path.cubicTo(
      center.dx - radius * 0.8,
      center.dy + radius * 0.8,
      center.dx - radius * 1.2,
      center.dy - radius * 0.5,
      center.dx,
      center.dy - radius,
    );
    canvas.drawPath(path, paint);


    final veinPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.7),
      Offset(center.dx, center.dy + radius * 0.7),
      veinPaint,
    );


    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.2),
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.5),
      veinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + radius * 0.1),
      Offset(center.dx - radius * 0.4, center.dy - radius * 0.2),
      veinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + radius * 0.3),
      Offset(center.dx + radius * 0.35, center.dy + radius * 0.1),
      veinPaint,
    );


    final arrowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final arrowPath = Path();
    final arrowRadius = radius * 0.4;
    arrowPath.addArc(
      Rect.fromCircle(
        center: Offset(center.dx, center.dy),
        radius: arrowRadius,
      ),
      -math.pi * 0.5,
      math.pi * 1.4,
    );
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
