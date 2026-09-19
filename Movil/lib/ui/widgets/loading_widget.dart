import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ??
        (isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}


class SkeletonWidgets {
  static Widget profileHeader({bool isDark = false}) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          shimmerCircle(88),
          const SizedBox(height: 14),
          shimmerRect(width: 180, height: 24),
          const SizedBox(height: 8),
          shimmerRect(width: 220, height: 16),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: shimmerRect(width: 80, height: 28, radius: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget nivelCard({bool isDark = false}) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerCircle(42),
              const SizedBox(width: 12),
              _shimmerRect(width: 120, height: 22),
              const Spacer(),
              _shimmerRect(width: 60, height: 22, radius: 20),
            ],
          ),
          const SizedBox(height: 14),
          _shimmerRect(width: double.infinity, height: 10, radius: 6),
          const SizedBox(height: 10),
          Row(
            children: [
              _shimmerRect(width: 160, height: 16),
              const Spacer(),
              _shimmerRect(width: 80, height: 16),
            ],
          ),
        ],
      ),
    );
  }

  static Widget quickStatCard({bool isDark = false}) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _shimmerCircle(38),
          const SizedBox(height: 8),
          _shimmerRect(width: 60, height: 24),
          const SizedBox(height: 2),
          _shimmerRect(width: 80, height: 14),
        ],
      ),
    );
  }

  static Widget actionTile({bool isDark = false}) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Row(
        children: [
          _shimmerCircle(42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _shimmerRect(width: 140, height: 18),
                const SizedBox(height: 2),
                _shimmerRect(width: 100, height: 14),
              ],
            ),
          ),
          _shimmerCircle(20),
        ],
      ),
    );
  }

  static Widget achievementCard({bool isDark = false}) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Row(
        children: [
          _shimmerCircle(56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shimmerRect(width: 160, height: 18),
                const SizedBox(height: 4),
                _shimmerRect(width: 200, height: 14),
                const SizedBox(height: 6),
                _shimmerRect(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget statGridItem({bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _shimmerCircle(24),
          const SizedBox(height: 8),
          _shimmerRect(width: 60, height: 26),
          const SizedBox(height: 2),
          _shimmerRect(width: 100, height: 14),
        ],
      ),
    );
  }

  static Widget gardenHeader({bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Column(
        children: [
          _shimmerCircle(56),
          const SizedBox(height: 6),
          _shimmerRect(width: 80, height: 16),
          const SizedBox(height: 4),
          _shimmerRect(width: 60, height: 36),
          const SizedBox(height: 10),
          _shimmerRect(width: double.infinity, height: 10, radius: 6),
          const SizedBox(height: 8),
          _shimmerRect(width: 180, height: 16),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (i) => _shimmerRect(width: 80, height: 32, radius: 12),
            ),
          ),
        ],
      ),
    );
  }

  static Widget gardenVisualization({bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerRect(width: 140, height: 22),
              _shimmerRect(width: 100, height: 22, radius: 20),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(
              9,
              (i) => _shimmerRect(width: 62, height: 62, radius: 12),
            ),
          ),
        ],
      ),
    );
  }

  static Widget plantShopItem({bool isDark = false}) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      ),
      child: Row(
        children: [
          _shimmerCircle(28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shimmerRect(width: 120, height: 18),
                const SizedBox(height: 4),
                _shimmerRect(width: 80, height: 14),
              ],
            ),
          ),
          _shimmerRect(width: 80, height: 36, radius: 14),
        ],
      ),
    );
  }

  static Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
    );
  }

  static Widget _shimmerRect({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.grey[300],
      ),
    );
  }


  static Widget shimmerCircle(double size) => _shimmerCircle(size);
  static Widget shimmerRect({
    required double width,
    required double height,
    double radius = 8,
  }) => _shimmerRect(width: width, height: height, radius: radius);
}
