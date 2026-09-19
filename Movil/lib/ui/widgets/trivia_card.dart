import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class TriviaCard extends StatelessWidget {
  final String titulo;
  final String categoria;
  final String dificultad;
  final int puntosMaximos;
  final VoidCallback? onTap;

  const TriviaCard({
    super.key,
    required this.titulo,
    required this.categoria,
    required this.dificultad,
    required this.puntosMaximos,
    this.onTap,
  });

  Color get _dificultadColor {
    switch (dificultad.toUpperCase()) {
      case 'FACIL':
        return Colors.white;
      case 'MEDIO':
        return AppColors.warning;
      case 'DIFICIL':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          categoria,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dificultad,
                          style: TextStyle(
                            fontSize: 12,
                            color: _dificultadColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 20),
                  Text(
                    '$puntosMaximos',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
