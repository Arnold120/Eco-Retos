import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/trivia/diario_models.dart';
import '../cubit/diario_state.dart' show mensajePorDesempeno;

/// Colores de superficie "menta" según el tema.
/// Verde principal de las tarjetas de trivia: vivo en claro, apagado en
/// oscuro para no resultar chillante.
Color colorTriviaPrincipal(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.ecoGreen
        : AppColors.ecoGreen;

/// Verde secundario de las tarjetas de trivia (mismo criterio).
Color colorTriviaSecundario(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.ecoGreen2
        : AppColors.ecoGreenLight;

Color colorMintFondo(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColorsDark.mintSoft
    : AppColors.mintSoft;

Color colorMintFuerte(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColorsDark.mintStrong
    : AppColors.mintStrong;

Color colorTextoMenta(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColorsDark.textPrimary
    : AppColors.primaryDark;

/// Color representativo según el porcentaje de aciertos.
Color colorResultadoTrivia(int porcentaje) {
  if (porcentaje >= 80) return AppColors.success;
  if (porcentaje >= 50) return AppColors.mintStrong;
  return AppColors.error;
}

/// Mensaje motivador según el porcentaje (re-export del estado diario).
String mensajePorcentajeTrivia(double porcentaje) =>
    mensajePorDesempeno(porcentaje);

/// Estados visuales de una opción de respuesta.
enum TriviaOpcionEstado { normal, seleccionada, correcta, incorrecta, eliminada }

/// Botón de opción A-D reutilizado por Modo Libre y Modo Diario.
class TriviaOpcionButton extends StatelessWidget {
  final String letra;
  final String texto;
  final TriviaOpcionEstado estado;
  final VoidCallback? onTap;

  const TriviaOpcionButton({
    super.key,
    required this.letra,
    required this.texto,
    this.estado = TriviaOpcionEstado.normal,
    this.onTap,
  });

  bool get _tocable =>
      estado == TriviaOpcionEstado.normal && onTap != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enFeedback =
        estado == TriviaOpcionEstado.correcta ||
        estado == TriviaOpcionEstado.incorrecta;

    final Color fondo;
    final Color borde;
    Color? textoColor;
    double opacity = 1;
    Widget badge;
    IconData? iconoDerecha;

    switch (estado) {
      case TriviaOpcionEstado.correcta:
        fondo = AppColors.success;
        borde = AppColors.success;
        textoColor = Colors.white;
        badge = _CirculoBadge(
          color: Colors.white,
          child: const Icon(Icons.check, color: AppColors.success, size: 18),
        );
        iconoDerecha = Icons.check_circle;
        break;
      case TriviaOpcionEstado.incorrecta:
        fondo = AppColors.error;
        borde = AppColors.error;
        textoColor = Colors.white;
        badge = _CirculoBadge(
          color: Colors.white,
          child: const Icon(Icons.close, color: AppColors.error, size: 18),
        );
        iconoDerecha = Icons.cancel;
        break;
      case TriviaOpcionEstado.seleccionada:
        fondo = AppColors.primary;
        borde = AppColors.primary;
        textoColor = Colors.white;
        badge = _CirculoBadge(
          color: AppColors.secondary,
          child: Text(
            letra,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        );
        break;
      case TriviaOpcionEstado.eliminada:
        fondo = isDark ? AppColorsDark.surfaceCard : AppColors.surface;
        borde = AppColors.border;
        opacity = 0.35;
        badge = _CirculoBadge(
          color: AppColors.surfaceDim,
          child: Text(
            letra,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
        break;
      case TriviaOpcionEstado.normal:
        fondo = isDark ? AppColorsDark.surfaceCard : AppColors.surface;
        borde = AppColors.border;
        badge = _CirculoBadge(
          color: AppColors.surfaceDim,
          child: Text(
            letra,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
        break;
    }

    final colorTexto =
        textoColor ??
        (isDark ? AppColorsDark.textPrimary : Colors.white);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: _tocable,
        label: 'Opción $letra: $texto',
        child: GestureDetector(
          onTap: _tocable ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: enFeedback ? borde : AppColors.border,
                width: enFeedback ? 2 : 1,
              ),
            ),
            child: Opacity(
              opacity: opacity,
              child: Row(
                children: [
                  badge,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      texto,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: estado == TriviaOpcionEstado.normal
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: colorTexto,
                      ),
                    ),
                  ),
                  if (iconoDerecha != null)
                    Icon(iconoDerecha, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CirculoBadge extends StatelessWidget {
  final Color color;
  final Widget child;

  const _CirculoBadge({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

/// Chip compacto con icono y texto (categoría, dificultad, recompensas).
class ChipTrivia extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;

  const ChipTrivia({
    super.key,
    required this.icono,
    required this.texto,
    this.color = AppColors.mintStrong,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora con el tiempo restante de la pregunta.
class TemporizadorTrivia extends StatelessWidget {
  final Duration restante;

  const TemporizadorTrivia({super.key, required this.restante});

  @override
  Widget build(BuildContext context) {
    final segundos = restante.inSeconds.clamp(0, 999);
    final urgente = segundos <= 5;
    final color = urgente ? AppColors.error : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${segundos}s',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de ayudas (pista, 50/50 y opcionalmente saltar).
class AyudasTriviaBar extends StatelessWidget {
  final int monedasDisponibles;
  final bool permitirSaltar;
  final Set<AyudaTrivia> usadas;
  final bool habilitadas;
  final ValueChanged<AyudaTrivia> onSeleccionada;

  const AyudasTriviaBar({
    super.key,
    required this.monedasDisponibles,
    this.permitirSaltar = false,
    this.usadas = const {},
    this.habilitadas = true,
    required this.onSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    final ayudas = [
      if (permitirSaltar) AyudaTrivia.saltar,
      AyudaTrivia.pista,
      AyudaTrivia.cincuentaCincuenta,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final ayuda in ayudas) _botonAyuda(context, ayuda),
        ],
      ),
    );
  }

  Widget _botonAyuda(BuildContext context, AyudaTrivia ayuda) {
    final usada = usadas.contains(ayuda);
    final sinMonedas = monedasDisponibles < ayuda.costo;
    final deshabilitada = usada || !habilitadas || sinMonedas;

    final colorIcono = switch (ayuda) {
      AyudaTrivia.pista => AppColors.info,
      AyudaTrivia.cincuentaCincuenta => AppColors.levelPurple,
      AyudaTrivia.saltar => AppColors.warning,
    };

    IconData icono = switch (ayuda) {
      AyudaTrivia.pista => Icons.lightbulb_outline,
      AyudaTrivia.cincuentaCincuenta => Icons.filter_tilt_shift,
      AyudaTrivia.saltar => Icons.skip_next_outlined,
    };

    return Tooltip(
      message: usada
          ? '${ayuda.nombre} ya usada'
          : (sinMonedas
                ? 'Necesitas ${ayuda.costo} monedas'
                : '${ayuda.nombre} · ${ayuda.costo} monedas'),
      child: Opacity(
        opacity: deshabilitada ? 0.4 : 1,
        child: GestureDetector(
          onTap: deshabilitada
              ? null
              : () => _confirmar(context, ayuda),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorIcono.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 18, color: colorIcono),
                const SizedBox(width: 4),
                Text(
                  '${ayuda.costo}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorIcono,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.monetization_on,
                    size: 14, color: AppColors.coinGold),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmar(BuildContext context, AyudaTrivia ayuda) async {
    if (ayuda == AyudaTrivia.pista) {
      onSeleccionada(ayuda);
      return;
    }
    final aceptar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Usar ${ayuda.nombre}?'),
        content: Text(
          'Costará ${ayuda.costo} monedas. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
    if (aceptar == true) onSeleccionada(ayuda);
  }
}

/// Panel de retroalimentación inferior (correcto/incorrecto/tiempo agotado).
class PanelFeedbackTrivia extends StatelessWidget {
  final bool esCorrecta;
  final bool tiempoAgotado;
  final String? titulo;
  final IconData? icono;
  final String? respuestaCorrectaTexto;
  final String etiquetaPuntos;
  final List<Widget>? chips;
  final VoidCallback onContinuar;
  final String? textoContinuar;

  const PanelFeedbackTrivia({
    super.key,
    required this.esCorrecta,
    required this.tiempoAgotado,
    this.titulo,
    this.icono,
    this.respuestaCorrectaTexto,
    required this.etiquetaPuntos,
    this.chips,
    required this.onContinuar,
    this.textoContinuar,
  });

  @override
  Widget build(BuildContext context) {
    final color = esCorrecta ? AppColors.success : AppColors.error;
    final tituloFinal = titulo ??
        (esCorrecta
            ? '¡Correcto!'
            : (tiempoAgotado ? 'Tiempo agotado' : 'Incorrecta'));
    final iconoFinal = icono ??
        (esCorrecta ? Icons.check_circle : Icons.cancel);

    return Container(
      key: const ValueKey('panel_feedback'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.4))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(iconoFinal, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  tituloFinal,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  etiquetaPuntos,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!esCorrecta) ...[
              const SizedBox(height: 10),
              Text(
                'Respuesta correcta:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorTextoMenta(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                respuestaCorrectaTexto ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (chips != null && chips!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: chips!),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinuar,
                icon: const Icon(Icons.arrow_forward),
                label: Text(textoContinuar ?? 'Continuar'),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Avanzando automáticamente…',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de recompensas (XP / Monedas) usada en las pantallas de resultados.
class RecompensasTrivia extends StatelessWidget {
  final int xp;
  final int monedas;
  final List<Widget>? extra;

  const RecompensasTrivia({
    super.key,
    required this.xp,
    required this.monedas,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorMintFondo(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _celda(
            context,
            icono: const Icon(Icons.eco, color: AppColors.mintStrong, size: 26),
            valor: '$xp',
            etiqueta: 'XP',
          ),
          _divisor(context),
          _celda(
            context,
            icono: const Icon(
              Icons.monetization_on,
              size: 24,
              color: AppColors.coinGold,
            ),
            valor: '$monedas',
            etiqueta: 'Monedas',
          ),
          if (extra != null) ...extra!,
        ],
      ),
    );
  }

  Widget _celda(
    BuildContext context, {
    required Widget icono,
    required String valor,
    required String etiqueta,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icono,
        const SizedBox(height: 6),
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorMintFuerte(context),
          ),
        ),
        Text(
          etiqueta,
          style: TextStyle(fontSize: 12, color: colorTextoMenta(context)),
        ),
      ],
    );
  }

  Widget _divisor(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: colorMintFuerte(context).withValues(alpha: 0.35),
    );
  }
}