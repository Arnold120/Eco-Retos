import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/garden/plant_growth.dart';
import '../../../data/repositories/garden_repository.dart';
import 'plant_art.dart';

/// Cantero visual del jardín: una escena viva (cielo, colinas, luz y
/// partículas) con los espacios ocupados por plantas animadas y los libres
/// para sembrar. Usa un único controlador de animación para toda la escena,
/// así el costo en GPU se mantiene bajo.
class GardenBed extends StatefulWidget {
  final List<PlantGrowth> plantas;
  final int maxSlots;
  final String? seleccionadaId;
  final MejoraEtapa? mejora;
  final ValueChanged<PlantGrowth> onVerPlanta;
  final VoidCallback onPlantarNueva;

  const GardenBed({
    super.key,
    required this.plantas,
    required this.maxSlots,
    required this.onVerPlanta,
    required this.onPlantarNueva,
    this.seleccionadaId,
    this.mejora,
  });

  @override
  State<GardenBed> createState() => _GardenBedState();
}

class _GardenBedState extends State<GardenBed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final porSlot = <int, PlantGrowth>{
      for (final p in widget.plantas) p.slot: p,
    };
    final libres = widget.plantas.length >= widget.maxSlots
        ? 0
        : widget.maxSlots - widget.plantas.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _EscenaPainter(animacion: _sway, isDark: isDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chipLibres(libres),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  childAspectRatio: 0.78,
                  children: List.generate(widget.maxSlots, (slot) {
                    final planta = porSlot[slot];
                    if (planta == null) {
                      return _EspacioLibre(onTap: widget.onPlantarNueva);
                    }
                    return _PlotTile(
                      key: ValueKey(planta.id),
                      planta: planta,
                      animacion: _sway,
                      fase: (planta.slot % 5) / 5,
                      seleccionada: planta.id == widget.seleccionadaId,
                      mejora: widget.mejora?.planta.id == planta.id
                          ? widget.mejora
                          : null,
                      onTap: () => widget.onVerPlanta(planta),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipLibres(int libres) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.grass,
            size: 13,
            color: AppColors.gardenGrass.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 6),
          Text(
            '$libres ${libres == 1 ? 'espacio libre' : 'espacios libres'}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Escena de fondo (cielo, colinas, luz y partículas)
// -----------------------------------------------------------------------------

class _EscenaPainter extends CustomPainter {
  final Animation<double> animacion;
  final bool isDark;

  _EscenaPainter({required this.animacion, required this.isDark})
      : super(repaint: animacion);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = animacion.value;
    final rect = Offset.zero & size;

    final cielo = isDark ? const Color(0xFF122334) : const Color(0xFFBFE7F2);
    final aire = isDark ? const Color(0xFF1A3D31) : const Color(0xFF8CC98A);
    final suelo = isDark ? const Color(0xFF0F231B) : const Color(0xFF5C9A62);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cielo, aire, suelo],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(rect),
    );

    // Sol/luna con resplandor tenue.
    final astro = Offset(w * 0.88, h * 0.07);
    final ambito = h * 0.14;
    canvas.drawCircle(
      astro,
      ambito,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (isDark ? const Color(0xFFF6E7A8) : const Color(0xFFFFF3B0))
                .withValues(alpha: isDark ? 0.14 : 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: astro, radius: ambito)),
    );
    canvas.drawCircle(
      astro,
      h * 0.008,
      Paint()
        ..color = (isDark ? const Color(0xFFF6E7A8) : const Color(0xFFFFF8CE))
            .withValues(alpha: 0.75),
    );

    // Nubes suaves que cruzan el cielo.
    final nubeBase = isDark ? const Color(0xFF3C4E5A) : Colors.white;
    for (var i = 0; i < 3; i++) {
      final velocidad = 0.018 + i * 0.006;
      final recorrido = (t * velocidad + i * 0.41) % 1.35 - 0.18;
      _nube(
        canvas,
        Offset(w * recorrido, h * (0.10 + i * 0.065)),
        w * (0.11 + i * 0.035),
        nubeBase.withValues(alpha: isDark ? 0.16 : 0.5),
      );
    }

    // Colinas traseras.
    final colinaLejos = Path()
      ..moveTo(0, h * 0.52)
      ..quadraticBezierTo(w * 0.22, h * 0.42, w * 0.45, h * 0.5)
      ..quadraticBezierTo(w * 0.7, h * 0.58, w, h * 0.46)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      colinaLejos,
      Paint()
        ..color = (isDark ? const Color(0xFF16382C) : const Color(0xFF74B878))
            .withValues(alpha: 0.75),
    );

    final colinaCerca = Path()
      ..moveTo(0, h * 0.66)
      ..quadraticBezierTo(w * 0.3, h * 0.56, w * 0.6, h * 0.64)
      ..quadraticBezierTo(w * 0.85, h * 0.7, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      colinaCerca,
      Paint()
        ..color = (isDark ? const Color(0xFF102A21) : const Color(0xFF5FA265))
            .withValues(alpha: 0.9),
    );

    // Partículas ambientales: polen de día, luciérnagas de noche.
    final mota = isDark ? const Color(0xFFD8F28A) : const Color(0xFFFFFDF0);
    for (var i = 0; i < 16; i++) {
      final semilla = ((i * 61) % 97) / 97;
      final fase = (t * (0.12 + semilla * 0.2) + semilla) % 1.0;
      final x = w * ((semilla * 0.9 + math.sin((t + semilla) * 2 * math.pi) * 0.05) % 1.0);
      final y = h * (1.05 - fase * 1.1);
      final alfa = math.sin(fase * math.pi).clamp(0.0, 1.0) *
          (isDark ? 0.85 : 0.5);
      canvas.drawCircle(
        Offset(x, y),
        (isDark ? 1.4 : 1.1) + semilla * 0.9,
        Paint()..color = mota.withValues(alpha: alfa),
      );
    }

    // Mariposa que pasea durante el día.
    if (!isDark) {
      final ciclo = (t * 0.6) % 1.0;
      final bx = w * (-0.06 + 1.12 * ciclo);
      final by = h * (0.40 + math.sin(ciclo * math.pi * 5) * 0.07);
      _mariposa(canvas, Offset(bx, by), h * 0.02, t);
    }

    // Viñeta para dar profundidad.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.15,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.32)],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  void _nube(Canvas canvas, Offset centro, double radio, Color color) {
    final paint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: centro, width: radio * 2.2, height: radio),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx - radio * 0.7, centro.dy + radio * 0.18),
        width: radio * 1.4,
        height: radio * 0.8,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx + radio * 0.75, centro.dy + radio * 0.22),
        width: radio * 1.5,
        height: radio * 0.85,
      ),
      paint,
    );
  }

  void _mariposa(Canvas canvas, Offset centro, double tam, double t) {
    final aleteo = math.sin(t * 2 * math.pi * 6).abs();
    final alaColor = Color.lerp(
      const Color(0xFFF6C445),
      const Color(0xFFE88AB8),
      (math.sin(t * 2 * math.pi) + 1) / 2,
    )!;
    final pintura = Paint()..color = alaColor.withValues(alpha: 0.9);
    final anchoAla = tam * (0.35 + 0.65 * aleteo);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx - anchoAla, centro.dy),
        width: anchoAla * 2,
        height: tam * 1.5,
      ),
      pintura,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx + anchoAla, centro.dy),
        width: anchoAla * 2,
        height: tam * 1.5,
      ),
      pintura,
    );
    canvas.drawLine(
      Offset(centro.dx, centro.dy - tam * 0.8),
      Offset(centro.dx, centro.dy + tam * 0.8),
      Paint()
        ..color = const Color(0xFF3A2E2E)
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(covariant _EscenaPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// -----------------------------------------------------------------------------
// Piezas del cantero
// -----------------------------------------------------------------------------

class _PlotTile extends StatefulWidget {
  final PlantGrowth planta;
  final Animation<double> animacion;
  final double fase;
  final bool seleccionada;
  final MejoraEtapa? mejora;
  final VoidCallback onTap;

  const _PlotTile({
    super.key,
    required this.planta,
    required this.animacion,
    required this.fase,
    required this.onTap,
    this.seleccionada = false,
    this.mejora,
  });

  @override
  State<_PlotTile> createState() => _PlotTileState();
}

class _PlotTileState extends State<_PlotTile> {
  int _toques = 0;

  void _alTocar() {
    setState(() => _toques++);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final planta = widget.planta;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final etapa = planta.etapa();
    final progreso = planta.progreso();
    final rareza = planta.rarezaColor;
    final recienRegada = planta.horasSinRiego < 6;
    final necesitaAgua = planta.necesitaAgua && !planta.marchita;
    final necesitaAbono = planta.faltaAbono;
    final marchita = planta.marchita;

    return GestureDetector(
      onTap: _alTocar,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('toque_${planta.id}_$_toques'),
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 550),
        curve: _toques == 0 ? Curves.easeOutBack : Curves.elasticOut,
        builder: (context, escala, child) =>
            Transform.scale(scale: escala, child: child),
        child: TweenAnimationBuilder<double>(
          key: ValueKey('crece_${planta.id}_${etapa.index}'),
          tween: Tween(begin: 1.18, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          builder: (context, escala, child) => Transform.scale(
            scale: escala,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
          child: AnimatedBuilder(
            animation: widget.animacion,
            builder: (context, child) {
              final pulso = widget.seleccionada
                  ? 0.5 + 0.5 * math.sin(widget.animacion.value * 2 * math.pi)
                  : 0.0;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark
                              ? const Color(0xFF22331F)
                              : const Color(0xFF3E5230))
                          .withValues(alpha: 0.42),
                      (isDark
                              ? const Color(0xFF14231A)
                              : const Color(0xFF24341F))
                          .withValues(alpha: 0.62),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.seleccionada
                        ? rareza.withValues(alpha: 0.55 + 0.35 * pulso)
                        : Colors.white.withValues(alpha: 0.1),
                    width: widget.seleccionada ? 1.6 : 1,
                  ),
                  boxShadow: widget.seleccionada
                      ? [
                          BoxShadow(
                            color: rareza.withValues(alpha: 0.25 + 0.2 * pulso),
                            blurRadius: 12 + 6 * pulso,
                          ),
                        ]
                      : null,
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                      child: PlantSprite(
                        planta: planta,
                        animacion: widget.animacion,
                        fase: widget.fase,
                        marchita: marchita,
                        marchitez: planta.marchitez,
                        recienRegada: recienRegada,
                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(7, 4, 7, 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    etapa.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${progreso.round()}%',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: progreso / 100),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (context, valor, _) => Container(
                                  height: 3.5,
                                  color: Colors.white.withValues(alpha: 0.16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: valor.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              rareza.withValues(alpha: 0.95),
                                              Color.lerp(
                                                rareza,
                                                Colors.white,
                                                0.45,
                                              )!,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    children: [
                      if (necesitaAgua)
                        _insignia(Icons.water_drop_outlined, AppColors.warning),
                      if (necesitaAbono) ...[
                        if (necesitaAgua) const SizedBox(width: 3),
                        _insignia(Icons.eco_outlined, AppColors.warning),
                      ],
                      if (planta.tienePlaga) ...[
                        if (necesitaAgua || necesitaAbono)
                          const SizedBox(width: 3),
                        _insignia(Icons.bug_report, AppColors.error),
                      ],
                    ],
                  ),
                ),
                if (widget.mejora != null)
                  Positioned.fill(
                    child: GrowthBurst(
                      key: ValueKey(
                        'burst_${planta.id}_${widget.mejora!.momento.microsecondsSinceEpoch}',
                      ),
                      color: rareza,
                    ),
                  ),
                Positioned.fill(
                  child: GrowthRing(
                    key: ValueKey('ring_${planta.id}_${etapa.index}'),
                    color: rareza,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _insignia(IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: Icon(icono, size: 11, color: color),
    );
  }
}

class _EspacioLibre extends StatelessWidget {
  final VoidCallback onTap;

  const _EspacioLibre({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: Colors.white.withValues(alpha: 0.28),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Sembrar',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(16)),
      );
    final discontinuo = Path();
    for (final metrica in path.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < metrica.length) {
        final fin = (distancia + 5).clamp(0.0, metrica.length);
        discontinuo.addPath(metrica.extractPath(distancia, fin), Offset.zero);
        distancia += 10;
      }
    }
    canvas.drawPath(
      discontinuo,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}