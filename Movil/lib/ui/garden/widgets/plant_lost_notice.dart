import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/garden_repository.dart';

/// Aviso de plantas que se perdieron por descuido (sed o plaga sin tratar).
/// Se muestra como diálogo para que el usuario entienda qué pasó y cómo
/// evitarlo la próxima vez.
class PlantLostNotice extends StatelessWidget {
  final List<PlantaPerdida> perdidas;
  final VoidCallback onCerrar;

  const PlantLostNotice({
    super.key,
    required this.perdidas,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
      contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.heart_broken_outlined,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tu jardín perdió una planta',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                perdidas.length == 1
                    ? 'Una planta no recibió los cuidados a tiempo:'
                    : '${perdidas.length} plantas no recibieron cuidados a tiempo:',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              for (final perdida in perdidas) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        perdida.planta.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              perdida.planta.nombre,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              perdida.motivo,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.25,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              const Text(
                'Recuerda: riega antes de que la tierra se seque, abona para '
                'que siga creciendo y cura las plagas el mismo día.',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onCerrar();
            },
            icon: const Icon(Icons.check),
            label: const Text('Entendido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
