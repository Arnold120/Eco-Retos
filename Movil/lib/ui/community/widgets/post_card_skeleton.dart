import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import 'post_helpers.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return PostCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonWidgets.shimmerCircle(40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidgets.shimmerRect(width: 140, height: 14),
                  const SizedBox(height: 6),
                  SkeletonWidgets.shimmerRect(width: 90, height: 11),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SkeletonWidgets.shimmerRect(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          SkeletonWidgets.shimmerRect(width: 220, height: 12),
          const SizedBox(height: 14),
          SkeletonWidgets.shimmerRect(
            width: double.infinity,
            height: 160,
            radius: 12,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidgets.shimmerRect(width: 70, height: 12),
              SkeletonWidgets.shimmerRect(width: 70, height: 12),
              SkeletonWidgets.shimmerRect(width: 70, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class CommentsSkeleton extends StatelessWidget {
  const CommentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonWidgets.shimmerCircle(32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidgets.shimmerRect(width: 120, height: 12),
                  const SizedBox(height: 8),
                  SkeletonWidgets.shimmerRect(
                    width: double.infinity,
                    height: 12,
                  ),
                  const SizedBox(height: 6),
                  SkeletonWidgets.shimmerRect(width: 180, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SocialErrorState extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;

  const SocialErrorState({
    super.key,
    required this.mensaje,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 52, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textColor(context),
              ),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class SocialEmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final String? accionLabel;
  final VoidCallback? onAccion;

  const SocialEmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    this.accionLabel,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryOf(context).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: textColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondaryColor(context),
                height: 1.4,
              ),
            ),
            if (accionLabel != null && onAccion != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAccion,
                icon: const Icon(Icons.add, size: 18),
                label: Text(accionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
