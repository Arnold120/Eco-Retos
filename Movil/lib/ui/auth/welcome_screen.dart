import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  final String nombre;
  final VoidCallback onStart;

  const WelcomeScreen({
    super.key,
    required this.nombre,
    required this.onStart,
  });

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
                  ]
                : [
                    AppColors.primary,
                    AppColors.secondary.withValues(alpha: 0.8),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '¡Cuenta creada!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '¡Bienvenido a Eco Retos, ',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                    children: [
                      TextSpan(
                        text: nombre,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '!'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '"Tu camino hacia un estilo de vida más sostenible comienza hoy."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColorsDark.textSecondary.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('🌱', 'Nivel 1', isDark),
                      _buildStat('⭐', '0 XP', isDark),
                      _buildStat('🪙', '0 Monedas', isDark),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String emoji, String label, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColorsDark.textPrimary
                : Colors.white,
          ),
        ),
      ],
    );
  }
}
