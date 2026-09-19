import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalogos/retos/reto_model.dart';

/// Componentes base del Design System de Eco Retos.
///
/// Toda pantalla del producto debe reutilizarlos (evita estilos duplicados
/// y garantiza consistencia en light/dark).

/// Título de sección con opción de acción "Ver todo".
class EcoSectionTitle extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onVerTodo;

  const EcoSectionTitle({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onVerTodo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTitulo =
        isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final colorSubtitulo =
        isDark ? AppColorsDark.textSecondary : AppColors.textHint;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorTitulo,
                  ),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorSubtitulo,
                    ),
                  ),
              ],
            ),
          ),
          if (onVerTodo != null)
            TextButton(
              onPressed: onVerTodo,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ver todo'),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Selector compacto (chips horizontales). Reutilizable en filtros.
class EcoChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final IconData? icono;
  final Color? color;
  final VoidCallback? onTap;

  const EcoChip({
    super.key,
    required this.label,
    this.seleccionado = false,
    this.icono,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = color ?? AppColors.primary;
    final usarBlanco = base.computeLuminance() < 0.5;
    final fg = seleccionado
        ? (usarBlanco ? Colors.white : AppColors.textPrimary)
        : (isDark ? AppColorsDark.textPrimary : AppColors.textSecondary);
    return Material(
      color: seleccionado
          ? base
          : (isDark ? AppColorsDark.surfaceElevated : AppColors.surface),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: seleccionado
                  ? base
                  : (isDark ? AppColorsDark.border : AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(icono, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de dificultad con color semántico.
class EcoDificultadTag extends StatelessWidget {
  final RetoDificultad dificultad;

  const EcoDificultadTag({super.key, required this.dificultad});

  Color get _color => switch (dificultad) {
    RetoDificultad.facil => AppColors.difficultyEasy,
    RetoDificultad.intermedio => AppColors.difficultyMedium,
    RetoDificultad.dificil => AppColors.error,
    RetoDificultad.experto => AppColors.levelPurple,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    // Fondo sólido con letra de alto contraste: oscura sobre el verde y el
    // naranja claros, blanca sobre rojo y morado.
    final colorTexto = color.computeLuminance() > 0.30
        ? AppColors.textPrimary
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        dificultad.label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: colorTexto,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Barra de progreso reutilizable (retos, nivel, trivias, etc.).
class EcoProgressBar extends StatelessWidget {
  final double progreso;
  final Color? color;
  final double altura;

  const EcoProgressBar({
    super.key,
    required this.progreso,
    this.color,
    this.altura = 8,
  });

  @override
  Widget build(BuildContext context) {
    final porciento = progreso.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(altura),
      child: LinearProgressIndicator(
        value: porciento,
        minHeight: altura,
        backgroundColor: AppColors.border.withValues(alpha: 0.5),
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
      ),
    );
  }
}

/// Tarjeta con dato destacado (XP, monedas, completados, nivel...).
class EcoStatCard extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color? color;

  const EcoStatCard({
    super.key,
    required this.icono,
    required this.valor,
    required this.etiqueta,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            color: base == AppColors.primary || base == AppColors.success
                ? Colors.white
                : base,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: base == AppColors.primary || base == AppColors.success
                  ? Colors.white
                  : base,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío centralizado (misma gráfica que el Muro).
class EcoEmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;
  final String? accionLabel;
  final VoidCallback? onAccion;

  const EcoEmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accionLabel,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
            if (accionLabel != null && onAccion != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onAccion,
                icon: const Icon(Icons.refresh),
                label: Text(accionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error con reintento centralizado.
class EcoErrorState extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const EcoErrorState({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenedor principal de sección (fondo + padding homogéneo).
class EcoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const EcoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
