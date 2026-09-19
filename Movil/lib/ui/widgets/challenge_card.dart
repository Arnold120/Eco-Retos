import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ChallengeCard extends StatelessWidget {
  final String titulo;
  final String categoria;
  final String dificultad;
  final int puntos;
  final String estado;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;

  const ChallengeCard({
    super.key,
    required this.titulo,
    required this.categoria,
    required this.dificultad,
    required this.puntos,
    required this.estado,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });

  Color get _dificultadColor {
    switch (dificultad.toUpperCase()) {
      case 'FACIL':
        return AppColors.success;
      case 'MEDIO':
        return AppColors.warning;
      case 'DIFICIL':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  Color get _estadoColor {
    switch (estado.toUpperCase()) {
      case 'COMPLETADO':
        return AppColors.success;
      case 'EN_PROGRESO':
        return AppColors.info;
      case 'INICIADO':
        return AppColors.secondary;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorCategoria =
        isDark ? AppColorsDark.mintStrong : AppColors.primary;
    final colorPuntos = isDark
        ? AppColors.accent
        : Color.lerp(AppColors.accent, Colors.black, 0.35)!;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildTag(estado.replaceAll('_', ' '), _estadoColor, isDark),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTag(categoria, colorCategoria, isDark),
                  const SizedBox(width: 8),
                  _buildTag(dificultad, _dificultadColor, isDark),
                  const Spacer(),
                  Icon(Icons.star, color: colorPuntos, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$puntos pts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorPuntos,
                    ),
                  ),
                ],
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, bool isDark) {
    final colorTexto =
        isDark ? color : Color.lerp(color, Colors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorTexto,
        ),
      ),
    );
  }
}
