import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';


enum GardenEffectType { gotas, abono, insecticida, brillo }



class GardenEffectOverlay extends StatefulWidget {
  final GardenEffectType tipo;
  final Duration duracion;

  const GardenEffectOverlay({
    super.key,
    required this.tipo,
    this.duracion = const Duration(milliseconds: 1700),
  });

  @override
  State<GardenEffectOverlay> createState() => _GardenEffectOverlayState();
}

class _GardenEffectOverlayState extends State<GardenEffectOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: widget.duracion,
  )..forward();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controlador,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _EffectPainter(tipo: widget.tipo, t: _controlador.value),
        ),
      ),
    );
  }
}

class _EffectPainter extends CustomPainter {
  final GardenEffectType tipo;
  final double t;

  const _EffectPainter({required this.tipo, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    switch (tipo) {
      case GardenEffectType.gotas:
        _pintarGotas(canvas, size);
      case GardenEffectType.abono:
        _pintarAbono(canvas, size);
      case GardenEffectType.insecticida:
        _pintarInsecticida(canvas, size);
      case GardenEffectType.brillo:
        _pintarBrillo(canvas, size);
    }
  }

  void _pintarGotas(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bluePastel;
    for (var i = 0; i < 16; i++) {
      final semilla = ((i * 37) % 23) / 23;
      final x = (i * 61 % 100) / 100 * size.width;
      final fase = (t * 1.6 + i * 0.06) % 1.0;
      final y = -0.05 * size.height + fase * size.height * 1.05;
      final alpha = (1 - fase) * 0.85;
      final alto = size.height * 0.035 * (0.6 + semilla * 0.8);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + math.sin((t + i) * 6) * 2, y),
          width: alto * 0.45,
          height: alto,
        ),
        paint..color = AppColors.bluePastel.withValues(alpha: alpha),
      );
    }

    final humedad = t < 0.5 ? t / 0.5 : (1 - t) / 0.5;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.93),
        width: size.width * 0.7,
        height: size.height * 0.16,
      ),
      Paint()
        ..color = const Color(
          0xFF3E2723,
        ).withValues(alpha: 0.35 * humedad.clamp(0.0, 1.0)),
    );
  }

  void _pintarAbono(Canvas canvas, Size size) {
    for (var i = 0; i < 18; i++) {
      final semilla = ((i * 29) % 17) / 17;
      final fase = (t * 1.35 + i * 0.05) % 1.0;
      final x =
          size.width / 2 +
          math.sin(i * 2.1 + fase * 5) * size.width * 0.22 * semilla;
      final y = size.height * 0.95 - fase * size.height * 0.85;
      final alpha = (1 - fase).clamp(0.0, 1.0);
      final color = i.isEven ? AppColors.gardenGrass : AppColors.success;
      canvas.drawCircle(
        Offset(x, y),
        size.height * 0.012 * (0.6 + semilla),
        Paint()..color = color.withValues(alpha: alpha * 0.9),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.93),
        width: size.width * 0.6 * (0.6 + t * 0.5),
        height: size.height * 0.1 * (0.6 + t * 0.5),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.gardenGrass.withValues(alpha: 0.7 * (1 - t)),
    );
  }

  void _pintarInsecticida(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.45);

    for (var i = 0; i < 14; i++) {
      final semilla = ((i * 41) % 19) / 19;
      final angulo = i * 2 * math.pi / 14 + t * 2.4;
      final distancia = t * size.height * (0.18 + semilla * 0.22);
      final posicion =
          centro +
          Offset(math.cos(angulo) * distancia, math.sin(angulo) * distancia);
      canvas.drawCircle(
        posicion,
        size.height * 0.02 * (0.5 + semilla),
        Paint()..color = AppColors.mintLight.withValues(alpha: (1 - t) * 0.45),
      );
    }

    final alphaBicho = (1 - t * 1.2).clamp(0.0, 1.0);
    if (alphaBicho > 0) {
      final cuerpo = Paint()
        ..color = AppColors.error.withValues(alpha: alphaBicho);
      final pos = centro + Offset(0, t * size.height * 0.12);
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: size.width * 0.05,
          height: size.width * 0.065,
        ),
        cuerpo,
      );
      canvas.drawCircle(
        Offset(pos.dx, pos.dy - size.width * 0.04),
        size.width * 0.018,
        cuerpo,
      );
      final patas = Paint()
        ..color = AppColors.error.withValues(alpha: alphaBicho)
        ..strokeWidth = 1.4;
      for (var i = -1; i <= 1; i++) {
        canvas.drawLine(
          Offset(pos.dx - size.width * 0.03, pos.dy + i * 4.0),
          Offset(pos.dx - size.width * 0.055, pos.dy + i * 4.0 - 4),
          patas,
        );
        canvas.drawLine(
          Offset(pos.dx + size.width * 0.03, pos.dy + i * 4.0),
          Offset(pos.dx + size.width * 0.055, pos.dy + i * 4.0 - 4),
          patas,
        );
      }
    }
  }

  void _pintarBrillo(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.52);

    for (var anillo = 0; anillo < 3; anillo++) {
      final fase = (t * 1.25 - anillo * 0.18).clamp(0.0, 1.0);
      if (fase <= 0) continue;
      canvas.drawCircle(
        centro,
        size.shortestSide * 0.05 + fase * size.shortestSide * 0.3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = AppColors.xpGold.withValues(alpha: (1 - fase) * 0.8),
      );
    }

    final paint = Paint()..color = AppColors.xpGold;
    for (var i = 0; i < 16; i++) {
      final semilla = ((i * 53) % 21) / 21;
      final angulo = i * 2 * math.pi / 16;
      final distancia =
          size.shortestSide * 0.08 +
          t * size.shortestSide * (0.16 + semilla * 0.22);
      final pos =
          centro +
          Offset(math.cos(angulo) * distancia, math.sin(angulo) * distancia);
      final radio = size.shortestSide * 0.011 * (1 - t * 0.5);
      canvas.drawCircle(
        pos,
        radio,
        paint
          ..color = (i.isEven ? AppColors.xpGold : AppColors.gardenGrass)
              .withValues(alpha: (1 - t) * 0.95),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EffectPainter oldDelegate) =>
      oldDelegate.t != t;
}


class SueloHumedoOverlay extends StatelessWidget {
  final double intensidad;

  const SueloHumedoOverlay({super.key, this.intensidad = 0.28});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 0.72,
          heightFactor: 0.22,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3E2723).withValues(alpha: intensidad),
                  const Color(0xFF3E2723).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
