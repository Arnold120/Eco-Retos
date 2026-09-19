import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'garden_effects.dart';

/// Celebración de desbloqueo de la planta carnívora (racha de 30 días).
/// Se muestra sobre el jardín; al cerrarla, el visor 3D ya tiene seleccionada
/// la nueva planta.
class UnlockCelebration extends StatefulWidget {
  final VoidCallback onVerPlanta;
  final VoidCallback onCerrar;

  const UnlockCelebration({
    super.key,
    required this.onVerPlanta,
    required this.onCerrar,
  });

  @override
  State<UnlockCelebration> createState() => _UnlockCelebrationState();
}

class _UnlockCelebrationState extends State<UnlockCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _brillo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _brillo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.72),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const GardenEffectOverlay(
              key: ValueKey('unlock_brillo'),
              tipo: GardenEffectType.brillo,
              duracion: Duration(milliseconds: 2200),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.7, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, escala, child) => Transform.scale(
                  scale: escala,
                  child: Opacity(opacity: escala.clamp(0.0, 1.0), child: child),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.xpGold.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.xpGold.withValues(alpha: 0.35),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _brillo,
                        builder: (context, _) => Icon(
                          Icons.local_fire_department,
                          size: 52,
                          color: Color.lerp(
                            AppColors.streakFire,
                            AppColors.xpGold,
                            _brillo.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '¡RACHA DE 30 DÍAS!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: AppColors.xpGold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '🎉 ¡Nueva planta desbloqueada!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Planta carnívora',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gardenGrass,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Por mantener tu racha diaria durante 30 días, tu '
                        'jardín recibe una especie exclusiva con animación '
                        'propia. ¡Ya está plantada!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onVerPlanta,
                          icon: const Icon(Icons.visibility),
                          label: const Text('¡Ver mi planta!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gardenGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onCerrar,
                        child: const Text(
                          'Después',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
