import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/confetti_widget.dart';






class RecompensaCelebracionSheet extends StatelessWidget {
  final int xp;
  final int monedas;
  final int puntos;
  final int? rachaNueva;
  final int? xpSemana;
  final int? monedasSemana;
  final bool esDiario;
  final String titulo;
  final VoidCallback onContinuar;

  const RecompensaCelebracionSheet({
    super.key,
    required this.xp,
    required this.monedas,
    this.puntos = 0,
    this.rachaNueva,
    this.xpSemana,
    this.monedasSemana,
    this.esDiario = true,
    this.titulo = '¡Recompensas obtenidas!',
    required this.onContinuar,
  });



  static Future<void> mostrar(
    BuildContext context, {
    required int xp,
    required int monedas,
    int puntos = 0,
    int? rachaNueva,
    int? xpSemana,
    int? monedasSemana,
    bool esDiario = true,
    String titulo = '¡Recompensas obtenidas!',
    VoidCallback? onContinuar,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecompensaCelebracionSheet(
        xp: xp,
        monedas: monedas,
        puntos: puntos,
        rachaNueva: rachaNueva,
        xpSemana: xpSemana,
        monedasSemana: monedasSemana,
        esDiario: esDiario,
        titulo: titulo,
        onContinuar: () {
          Navigator.of(context).pop();
          onContinuar?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneSemana = (xpSemana ?? 0) > 0 || (monedasSemana ?? 0) > 0;

    return Stack(
      children: [
        Positioned.fill(child: ConfettiWidget(show: true)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutBack,
              builder: (context, t, child) {
                return Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * t,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.ecoBgLight, AppColors.ecoBg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.ecoGold.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ecoGold.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ecoGold,
                        ),
                        child: const Icon(Icons.emoji_events,
                            color: AppColors.ecoBg, size: 26),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ecoGold,
                        ),
                      ),
                      if (esDiario && rachaNueva != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: AppColors.ecoGreenLight,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Racha diaria de $rachaNueva día(s)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ecoGreenLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _BadgeRecompensa(
                              icono: Icons.eco,
                              color: AppColors.ecoGreen,
                              etiqueta: 'XP ganados',
                              valor: xp,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BadgeRecompensa(
                              icono: Icons.monetization_on,
                              color: AppColors.ecoGold,
                              etiqueta: 'Monedas',
                              valor: monedas,
                            ),
                          ),
                        ],
                      ),
                      if (puntos > 0 && !esDiario) ...[
                        const SizedBox(height: 10),
                        _BadgeRecompensa(
                          icono: Icons.star,
                          color: AppColors.ecoBlue,
                          etiqueta: 'Puntuación',
                          valor: puntos,
                        ),
                      ],
                      if (tieneSemana) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.celebration,
                              color: AppColors.ecoGold,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '¡Semana completa!',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ecoGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if ((xpSemana ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.ecoGreenLight.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.ecoGreenLight.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.eco, size: 16, color: AppColors.ecoGreenLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+$xpSemana XP',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if ((monedasSemana ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.ecoGold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.ecoGold.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.monetization_on, size: 16, color: AppColors.ecoGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+$monedasSemana',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.ecoGold,
                            foregroundColor: AppColors.ecoBg,
                          ),
                          onPressed: onContinuar,
                          child: const Text(
                            'CONTINUAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class _BadgeRecompensa extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String etiqueta;
  final int valor;

  const _BadgeRecompensa({
    required this.icono,
    required this.color,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icono, size: 26, color: color),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: valor),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, valorAnimado, _) {
              return Text(
                '+$valorAnimado',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}