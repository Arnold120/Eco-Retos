import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/garden/plant_growth.dart';
import 'plant_visual.dart';

/// Dibuja la planta del jardín según su etapa, especie (perfil visual) y
/// estado. Es intencionalmente liviano: un `CustomPainter` por espacio
/// repintado por un controlador compartido (sin reconstruir widgets).
///
/// Cada etapa dibuja únicamente la estructura que le corresponde: la planta
/// adulta (flores y frutos incluidos) solo aparece en la última etapa.
class PlantSprite extends StatelessWidget {
  final PlantGrowth planta;
  final Animation<double> animacion;
  final double fase;

  /// Si la planta lleva más de [GardenGrowthConfig.ventanaHumedad] sin regar,
  /// se dibuja marchita: colores apagados, hojas caídas y menos movimiento.
  final bool marchita;

  /// Progreso de la marchitez (0 = recién seca, 1 = a punto de perderse).
  final double marchitez;

  /// Si fue regada hace poco, muestra rocío brillante y verdes más vivos.
  final bool recienRegada;

  const PlantSprite({
    super.key,
    required this.planta,
    required this.animacion,
    this.fase = 0,
    this.marchita = false,
    this.marchitez = 0,
    this.recienRegada = false,
  });

  @override
  Widget build(BuildContext context) {
    final especie = planta.catalogo;
    final perfil = especie == null
        ? PlantArtProfile.basico
        : PlantArtProfile.perfil(especie);
    return SizedBox.expand(
      child: CustomPaint(
        painter: _PlantSpritePainter(
          etapa: planta.etapa(),
          progreso: planta.progreso(),
          horas: planta.horasTotales(),
          perfil: perfil,
          animacion: animacion,
          fase: fase,
          tienePlaga: planta.tienePlaga,
          marchita: marchita,
          marchitez: marchitez,
          recienRegada: recienRegada,
          tieneFloracion: planta.tieneFloracion,
          aura: planta.rarezaColor,
        ),
      ),
    );
  }
}

/// Colores y shaders para dar volumen (luz por arriba-izquierda, sombra abajo).
extension on Color {
  Color claro(double f) => Color.lerp(this, Colors.white, f)!;
  Color oscuro(double f) => Color.lerp(this, Colors.black, f)!;
}

class _PlantSpritePainter extends CustomPainter {
  final EtapaCrecimiento etapa;
  final double progreso;
  final double horas;
  final PlantProfile perfil;
  final Animation<double> animacion;
  final double fase;
  final bool tienePlaga;
  final bool marchita;
  final double marchitez;
  final bool recienRegada;
  final bool tieneFloracion;
  final Color? aura;

  _PlantSpritePainter({
    required this.etapa,
    required this.progreso,
    required this.horas,
    required this.perfil,
    required this.animacion,
    required this.fase,
    required this.tienePlaga,
    required this.marchita,
    required this.marchitez,
    required this.recienRegada,
    required this.tieneFloracion,
    this.aura,
  }) : super(repaint: animacion);

  bool get _esAdulta =>
      etapa == EtapaCrecimiento.plantaAdulta ||
      etapa == EtapaCrecimiento.floracion;

  /// Mientras más tiempo seco, más apagado y caído se dibuja.
  double get _sed =>
      marchita ? (0.18 + 0.72 * marchitez.clamp(0.0, 1.0)) : 0.0;

  double get _t => (animacion.value + fase) % 1.0;

  /// Altura relativa continua (0..~0.82) derivada de las horas reales, con
  /// interpolación suave entre etapas para que el crecimiento no dé saltos.
  /// La planta adulta solo alcanza su silueta completa al terminar de crecer.
  double get _alturaGlobal {
    const umbrales = [0.0, 5.0, 10.0, 15.0, 19.0, 25.0, 31.0];
    const alturas = [0.0, 0.16, 0.30, 0.44, 0.60, 0.80, 0.82];
    final topeHoras = tieneFloracion ? 31.0 : 25.0;
    final topeAltura = tieneFloracion ? 0.82 : 0.80;
    final hClamp = horas.clamp(0.0, topeHoras);
    if (hClamp <= umbrales.first) return alturas.first;
    for (var i = 0; i < umbrales.length - 1; i++) {
      if (hClamp <= umbrales[i + 1]) {
        final tt = ((hClamp - umbrales[i]) / (umbrales[i + 1] - umbrales[i]))
            .clamp(0.0, 1.0);
        final suave = tt * tt * (3 - 2 * tt);
        return alturas[i] + (alturas[i + 1] - alturas[i]) * suave;
      }
    }
    return topeAltura;
  }

  double get _progresoEnEtapa {
    final horas = progreso / 100 * GardenGrowthConfig.horasHastaAdulta;
    const inicios = [0.0, 5, 10, 15, 19, 25, 25];
    final inicio = inicios[etapa.index];
    final fin = inicios[etapa.index < inicios.length - 1
        ? etapa.index + 1
        : etapa.index];
    if (fin - inicio <= 0) return 1.0;
    return ((horas - inicio) / (fin - inicio)).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // paint principal
  // ---------------------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h * 0.92;
    final topePlanta = baseY - h * _alturaGlobal;

    _fondoAura(canvas, cx, baseY, topePlanta, h);
    _pintarSuelo(canvas, w, h, cx, baseY);
    _sombraDeContacto(canvas, w, h, cx, baseY);

    final respirando = !marchita && _esAdulta;
    if (respirando) {
      _iniciarRespiro(canvas, cx, baseY);
    }

    switch (etapa) {
      case EtapaCrecimiento.semilla:
        _pintarSemilla(canvas, w, h, cx, baseY);
        return;
      case EtapaCrecimiento.germinacion:
        _pintarGerminacion(canvas, w, h, cx, baseY);
        return;
      case EtapaCrecimiento.brote:
      case EtapaCrecimiento.plantaPequena:
      case EtapaCrecimiento.plantaMediana:
      case EtapaCrecimiento.plantaAdulta:
      case EtapaCrecimiento.floracion:
        break;
    }

    final viento = math.sin(_t * 2 * math.pi) * 0.7 +
        math.sin(_t * 4 * math.pi + 1.3) * 0.3;
    final hora = viento * (_marchitado ? 0.4 : 1.0);
    final sway = hora * (0.35 + 0.65 * (_alturaGlobal / 0.82));

    switch (perfil.porte) {
      case Porte.roseta:
        _pintarRoseta(canvas, w, h, cx, baseY, sway);
      case Porte.arbol:
        _pintarArbol(canvas, w, h, cx, baseY, sway);
      case Porte.trepador:
        _pintarTrepador(canvas, w, h, cx, baseY, sway);
      case Porte.carnivoro:
        _pintarCarnivora(canvas, w, h, cx, baseY, sway);
      case Porte.flotante:
        _pintarFlotante(canvas, w, h, cx, baseY, sway);
      case Porte.erecto:
      case Porte.frondoso:
      case Porte.ramificado:
        _pintarHerbacea(canvas, w, h, cx, baseY, sway);
    }

    if (respirando) {
      canvas.restore();
    }

    if (!_esAdulta && !marchita) {
      _motasDeCrecimiento(canvas, w, h, cx, topePlanta);
    }
    if (recienRegada && !marchita) {
      _rocio(canvas, w, h, cx, topePlanta);
    }
    if (!marchita && _esAdulta && perfil.floresAdultas) {
      _pintarPolen(canvas, w, h);
    }
  }

  bool get _marchitado => _sed > 0;

  // ---------------------------------------------------------------------------
  // Fondos, suelo y sombras
  // ---------------------------------------------------------------------------

  void _fondoAura(
    Canvas canvas,
    double cx,
    double baseY,
    double topePlanta,
    double h,
  ) {
    final radio = h * (0.42 + 0.3 * _alturaGlobal);
    final centro = Offset(cx, (baseY + topePlanta) / 2);
    if (!_esAdulta && !marchita) {
      final pulsar = 0.5 + 0.5 * math.sin(_t * 2 * math.pi * 0.8);
      final color = perfil.hojaClara;
      _halo(
        canvas,
        centro,
        radio * (0.85 + 0.12 * pulsar),
        color.withValues(alpha: 0.10 + 0.05 * pulsar),
      );
    } else if (_esAdulta) {
      final auraColor = aura ?? perfil.flor;
      _halo(
        canvas,
        centro,
        radio,
        auraColor.withValues(alpha: 0.06 + 0.03 * math.sin(_t * 2 * math.pi)),
      );
    }
  }

  void _halo(Canvas canvas, Offset centro, double radio, Color color) {
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: centro, radius: radio)),
    );
  }

  void _sombraDeContacto(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
  ) {
    final talla = 0.18 + 0.26 * _alturaGlobal;
    for (var i = 0; i < 3; i++) {
      final alpha = 0.10 + i * 0.06;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, baseY + h * 0.02),
          width: w * talla * (1 + i * 0.3),
          height: h * 0.05 * (1 + i * 0.3),
        ),
        Paint()..color = Colors.black.withValues(alpha: alpha),
      );
    }
  }

  void _pintarSuelo(Canvas canvas, double w, double h, double cx, double baseY) {
    final sueloAncho = w * 0.78;
    final sueloAlto = h * 0.15;
    final centro = Offset(cx, baseY + h * 0.03);
    final rect = Rect.fromCenter(
      center: centro,
      width: sueloAncho,
      height: sueloAlto,
    );

    final base = Color.lerp(
      const Color(0xFF6D4C41),
      const Color(0xFF9A8A72),
      _sed * 0.4,
    )!;
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.5),
          focal: const Alignment(0, -0.45),
          colors: [_claro(base, 0.22), _oscuro(base, 0.12), _oscuro(base, 0.4)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Cerco superior iluminado (borde del terreno).
    final cresta = Paint()
      ..color = base.claro(0.42).withValues(alpha: 0.55)
      ..strokeWidth = h * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, baseY + h * 0.035),
        width: sueloAncho * 0.9,
        height: sueloAlto * 0.85,
      ),
      math.pi,
      math.pi,
      false,
      cresta,
    );

    // Piedritas y granos de tierra.
    final polvo = Paint()..color = base.oscuro(0.5).withValues(alpha: 0.4);
    for (var i = 0; i < 6; i++) {
      final semilla = ((i * 47) % 17) / 17;
      final angulo = -math.pi * 0.92 - semilla * math.pi * 0.16;
      final radio = sueloAncho * 0.34 * (0.3 + semilla * 0.5);
      final p = Offset(
        cx + math.cos(angulo) * radio,
        baseY + h * 0.03 + math.sin(angulo) * sueloAlto * 0.4,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p,
          width: w * (0.008 + semilla * 0.012),
          height: h * (0.005 + semilla * 0.008),
        ),
        polvo,
      );
    }

    // Parque de césped al fondo: briznas que se mecen con el viento.
    for (var i = 0; i < 7; i++) {
      final semilla = ((i * 31) % 13) / 13;
      final x = cx + (semilla - 0.5) * sueloAncho * 0.9;
      final lado = i.isEven ? 1.0 : -1.0;
      final swayBrizna = math.sin(_t * 2 * math.pi + semilla * 5) * w * 0.02;
      _brizna(
        canvas,
        Offset(x, baseY - h * 0.02),
        h * (0.03 + semilla * 0.05),
        lado * (0.25 + swayBrizna * 6),
        Color.lerp(perfil.hojaOscura, const Color(0xFF4E7038), 0.4)!,
      );
    }
  }

  void _brizna(Canvas canvas, Offset base, double largo, double inclinacion, Color color) {
    final pico = Offset(
      base.dx + math.sin(inclinacion) * largo,
      base.dy - math.cos(inclinacion) * largo,
    );
    final ctl = Offset(base.dx + inclinacion * largo * 0.4, base.dy - largo * 0.55);
    final path = Path()
      ..moveTo(base.dx - largo * 0.12, base.dy)
      ..quadraticBezierTo(ctl.dx - largo * 0.1, ctl.dy, pico.dx, pico.dy)
      ..quadraticBezierTo(ctl.dx + largo * 0.1, ctl.dy, base.dx + largo * 0.12, base.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.oscuro(0.25), color],
        ).createShader(path.getBounds()),
    );
  }

  // ---------------------------------------------------------------------------
  // Etapas iniciales
  // ---------------------------------------------------------------------------

  void _pintarSemilla(Canvas canvas, double w, double h, double cx, double baseY) {
    final ancho = w * 0.135 * perfil.anchura;
    final alto = h * 0.075;
    canvas.save();
    canvas.translate(cx, baseY - h * 0.016);
    canvas.rotate(-0.28);
    final semillaRect = Rect.fromCenter(
      center: Offset.zero,
      width: ancho * 2,
      height: alto * 2,
    );
    canvas.drawOval(
      semillaRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.55),
          colors: [
            perfil.marchitar(perfil.semillaDetalle.claro(0.3), _sed),
            perfil.marchitar(perfil.semilla, _sed),
            perfil.marchitar(perfil.semilla.oscuro(0.35), _sed),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(semillaRect),
    );
    canvas.drawOval(
      semillaRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = perfil.marchitar(perfil.semilla.oscuro(0.5), _sed)
            .withValues(alpha: 0.6),
    );
    // Grietilla de germinación.
    canvas.drawLine(
      Offset(-ancho * 0.5, -alto * 0.15),
      Offset(ancho * 0.5, alto * 0.25),
      Paint()
        ..color = perfil.marchitar(perfil.semilla.oscuro(0.6), _sed)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
    // Moteado de la cáscara.
    for (var i = 0; i < 3; i++) {
      final s = ((i * 41) % 11) / 11;
      canvas.drawCircle(
        Offset((s - 0.5) * ancho * 1.1, (s - 0.4) * alto * 0.9),
        math.max(0.7, ancho * 0.06),
        Paint()
          ..color = perfil.marchitar(perfil.semillaDetalle, _sed)
              .withValues(alpha: 0.5),
      );
    }
    canvas.restore();
    _sombraDeContacto(canvas, w * 0.3, h * 0.3, cx, baseY + h * 0.02);
  }

  void _pintarGerminacion(Canvas canvas, double w, double h, double cx, double baseY) {
    final ancho = w * 0.08 * perfil.anchura;
    final alto = h * 0.045;
    final tE = _progresoEnEtapa;

    canvas.save();
    canvas.translate(cx, baseY - h * 0.006);
    canvas.rotate(-0.18);
    final semillaRect = Rect.fromCenter(
      center: Offset.zero,
      width: ancho * 2,
      height: alto * 2,
    );
    canvas.drawOval(
      semillaRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [
            perfil.marchitar(perfil.semillaDetalle, _sed),
            perfil.marchitar(perfil.semilla, _sed),
            perfil.marchitar(perfil.semilla.oscuro(0.3), _sed),
          ],
        ).createShader(semillaRect),
    );
    canvas.drawLine(
      Offset(-ancho * 0.55, alto * 0.1),
      Offset(ancho * 0.55, -alto * 0.05),
      Paint()
        ..color = perfil.marchitar(perfil.semilla.oscuro(0.5), _sed)
        ..strokeWidth = 1.2,
    );
    canvas.restore();

    // Raíz que se hunde.
    final raiz = Path()
      ..moveTo(cx, baseY - h * 0.015)
      ..quadraticBezierTo(
        cx - w * 0.06,
        baseY + h * 0.05,
        cx + w * 0.02,
        baseY + h * 0.09,
      );
    canvas.drawPath(
      raiz,
      Paint()
        ..color = perfil.marchitar(perfil.raiz, _sed)
        ..strokeWidth = h * 0.02 * (1 - 0.3 * tE)
        ..strokeCap = StrokeCap.round,
    );

    // Tallo asomando con dos cotiledones abriéndose (animación de desarrollo).
    final apertura = 0.35 + 0.65 * tE;
    final punta = _puntoCuadratico(
      Offset(cx, baseY - h * 0.01),
      Offset(cx + w * 0.012, baseY - h * 0.055),
      Offset(cx + w * 0.014, baseY - h * 0.10),
      1,
    );
    final tallo = Path()
      ..moveTo(cx, baseY - h * 0.01)
      ..quadraticBezierTo(
        cx + w * 0.012,
        baseY - h * 0.055,
        cx + w * 0.014,
        baseY - h * 0.10,
      );
    canvas.drawPath(
      tallo,
      Paint()
        ..color = perfil.marchitar(perfil.tallo, _sed)
        ..strokeWidth = h * 0.026 * (0.6 + 0.4 * tE)
        ..strokeCap = StrokeCap.round,
    );
    final tamano = h * 0.06 * (0.7 + 0.4 * tE);
    _hoja(
      canvas,
      Offset(punta.dx - w * 0.014, punta.dy + h * 0.012),
      _anguloHoja(-1, 1.05 - 0.4 * apertura),
      tamano,
      perfil.marchitar(perfil.hojaClara, _sed),
    );
    _hoja(
      canvas,
      Offset(punta.dx + w * 0.006, punta.dy + h * 0.008),
      _anguloHoja(1, 1.05 - 0.4 * apertura),
      tamano,
      perfil.marchitar(perfil.hojaClara, _sed),
    );
  }

  // ---------------------------------------------------------------------------
  // Portes
  // ---------------------------------------------------------------------------

  int get _nRamas {
    return switch (etapa) {
      EtapaCrecimiento.plantaMediana => switch (perfil.porte) {
        Porte.ramificado => 2,
        Porte.frondoso => 1,
        _ => 0,
      },
      EtapaCrecimiento.plantaAdulta ||
      EtapaCrecimiento.floracion => switch (perfil.porte) {
        Porte.ramificado => 3,
        Porte.frondoso => 2,
        _ => 0,
      },
      _ => 0,
    };
  }

  void _pintarHerbacea(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final tE = _progresoEnEtapa;
    final altura = h * _alturaGlobal * perfil.anchura;
    final topX = cx + sway * w * 0.16;
    final topY = baseY - altura;
    final controlX = cx + sway * w * 0.07;
    final controlY = baseY - altura * 0.55;
    final p0 = Offset(cx, baseY);
    final p1 = Offset(controlX, controlY);
    final p2 = Offset(topX, topY);

    final grosor = (h *
            (etapa.index >= EtapaCrecimiento.plantaMediana.index ? 0.055 : 0.04) *
            perfil.densidad)
        .clamp(2.6, 8.0);

    // Roseta basal: hojas grandes que abren la planta desde la tierra.
    final nBase = _esAdulta
        ? 5
        : etapa.index >= EtapaCrecimiento.plantaPequena.index
        ? 4
        : 3;
    for (var i = 0; i < nBase; i++) {
      final lado = i.isEven ? 1.0 : -1.0;
      final tt = nBase == 1 ? 0.5 : i / (nBase - 1);
      final caida = _marchitado ? lado * 0.45 : 0.0;
      _hoja(
        canvas,
        Offset(cx + lado * w * 0.02, baseY - h * 0.012),
        _anguloHoja(lado, 0.9 - 0.3 * tt) + caida,
        h * 0.24 * perfil.densidad * (0.6 + 0.45 * tE),
        perfil.marchitar(
          i.isEven ? perfil.hojaOscura : perfil.hojaMedia,
          _sed,
        ),
      );
    }

    // Ramas laterales para portes frondosos/ramificados.
    final nRamas = _nRamas;
    for (var r = 0; r < nRamas; r++) {
      final origen = _puntoCuadratico(p0, p1, p2, 0.3 + 0.25 * r);
      final lado = r.isEven ? 1.0 : -1.0;
      final ramaFin = Offset(
        origen.dx + lado * w * 0.16 * perfil.anchura,
        origen.dy - h * (0.05 + 0.05 * r) * tE,
      );
      final ramaCtl = Offset(
        origen.dx + lado * w * 0.09,
        origen.dy - h * (0.02 + 0.03 * r),
      );
      _ramaConica(
        canvas,
        origen,
        ramaCtl,
        ramaFin,
        grosor * 0.5,
        perfil.marchitar(perfil.tallo.oscuro(0.1), _sed),
      );
      for (var j = 0; j < 2; j++) {
        _hoja(
          canvas,
          Offset(
            ramaFin.dx + (j - 0.5) * w * 0.05,
            ramaFin.dy + j * h * 0.012,
          ),
          _anguloHoja(lado, 0.8 - 0.2 * j) +
              (_marchitado ? lado * 0.5 : 0),
          h * 0.12 * perfil.densidad * tE,
          perfil.marchitar(
            j == 0 ? perfil.hojaMedia : perfil.hojaOscura,
            _sed,
          ),
        );
      }
    }

    // Tallo principal.
    _ramaConica(
      canvas,
      p0,
      p1,
      p2,
      grosor,
      perfil.marchitar(perfil.tallo, _sed),
    );

    // Hojas por nudos, de abajo hacia arriba, cada vez más pequeñas.
    final nNudos = switch (etapa) {
      EtapaCrecimiento.brote => 2,
      EtapaCrecimiento.plantaPequena => 4,
      EtapaCrecimiento.plantaMediana => 6,
      EtapaCrecimiento.plantaAdulta ||
      EtapaCrecimiento.floracion => 8,
      _ => 2,
    };
    for (var i = 0; i < nNudos; i++) {
      final posicion = 0.18 + 0.78 * (i / math.max(1, nNudos - 1));
      final punto = _puntoCuadratico(p0, p1, p2, posicion);
      final lado = i.isEven ? 1.0 : -1.0;
      final caida = _marchitado ? lado * 0.5 : 0.0;
      final wobble =
          math.sin(_t * 2 * math.pi + 2 + i * 2.7) * 0.06 * (1 - _sed);
      final tam = h *
          0.21 *
          perfil.densidad *
          (1.05 - 0.5 * posicion) *
          (0.6 + 0.45 * tE);
      _hoja(
        canvas,
        punto,
        _anguloHoja(lado, 0.9 + 0.3 * posicion) + wobble + caida,
        tam,
        perfil.marchitar(
          _alternar(i, perfil.hojaClara, perfil.hojaMedia),
          _sed,
        ),
      );
      if (i.isEven) {
        _hoja(
          canvas,
          Offset(punto.dx, punto.dy - h * 0.012),
          _anguloHoja(lado, 0.98) + wobble * 0.6 + caida,
          tam * 0.68,
          perfil.marchitar(perfil.hojaOscura.claro(0.1), _sed),
        );
      }
    }

    // Brotes de flores (yemas) desde etapa mediana.
    if (etapa.index >= EtapaCrecimiento.plantaMediana.index &&
        perfil.floresAdultas &&
        !_esAdulta) {
      final punto = _puntoCuadratico(p0, p1, p2, 0.9);
      _florCerrada(canvas, punto, h * 0.028 * perfil.densidad);
    }

    // En adulta: flores abiertas y frutos colgando.
    if (_esAdulta) {
      final cima = Offset(topX + w * 0.04, topY);
      if (perfil.floresAdultas) {
        _florAbierta(canvas, cima, h * 0.05 * perfil.densidad);
      }
      if (perfil.frutosAdultos) {
        for (var i = 0; i < 3; i++) {
          _fruto(
            canvas,
            Offset(
              topX + (i - 1) * w * 0.08 + sway * w * 0.08,
              topY + h * 0.10 + i % 2 * h * 0.02,
            ),
          );
        }
      }
    }
  }

  void _pintarRoseta(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final capas = etapa.index >= EtapaCrecimiento.plantaAdulta.index
        ? 4
        : etapa.index >= EtapaCrecimiento.plantaPequena.index
        ? 3
        : 2;
    final tE = _progresoEnEtapa;
    final centro = Offset(cx + sway * w * 0.08, baseY - h * 0.02);

    for (var capa = 0; capa < capas; capa++) {
      final radio = (0.45 + capa * 0.34) * h * 0.17 * perfil.anchura;
      final anguloNivel = capa.isEven ? 0.0 : 0.5;
      final n = 2 + capa;
      for (var i = 0; i < n; i++) {
        final angulo = anguloNivel + i * 2 * math.pi / n;
        final posicion = Offset(
          centro.dx + math.cos(angulo) * radio,
          centro.dy - math.sin(angulo) * radio * 0.62 + capa * h * 0.012,
        );
        final Color tono;
        if (capa >= 3) {
          tono = perfil.hojaOscura;
        } else if (capa >= 1) {
          tono = perfil.hojaMedia;
        } else {
          tono = (i + capa) % 2 == 0 ? perfil.hojaMedia : perfil.hojaClara;
        }
        final wobble = math.sin(_t * 2 * math.pi + capa * 3 + i * 1.7) *
            0.05 *
            (1 - _sed);
        _hoja(
          canvas,
          posicion,
          -angulo + wobble + (_marchitado ? 0.5 : 0),
          h * 0.28 * perfil.densidad * (1 - capa * 0.08) * tE,
          perfil.marchitar(tono, _sed),
        );
      }
    }

    if (etapa.index >= EtapaCrecimiento.plantaAdulta.index &&
        perfil.floresAdultas) {
      _florAbierta(
        canvas,
        Offset(centro.dx, centro.dy - h * 0.16 * perfil.anchura),
        h * 0.05 * perfil.densidad,
      );
    }
    if (_esAdulta && perfil.frutosAdultos) {
      for (var i = 0; i < 2; i++) {
        _fruto(
          canvas,
          Offset(centro.dx + (i - 0.5) * w * 0.16, centro.dy - h * 0.02),
        );
      }
    }
  }

  void _pintarArbol(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final tE = _progresoEnEtapa;
    final altura = h * _alturaGlobal * perfil.anchura;
    final topX = cx + sway * w * 0.11;
    final topY = baseY - altura;
    final controlX = cx + sway * w * 0.03;
    final controlY = baseY - altura * 0.5;
    final p0 = Offset(cx, baseY);
    final p1 = Offset(controlX, controlY);
    final p2 = Offset(topX, topY);

    final grosorTronco = (h *
            (etapa.index >= EtapaCrecimiento.plantaPequena.index ? 0.06 : 0.032) *
            perfil.densidad)
        .clamp(2.4, 9.0);
    _sombraDeContacto(canvas, w * 0.5, h * 0.5, cx, baseY + h * 0.01);
    _ramaConica(
      canvas,
      p0,
      p1,
      p2,
      grosorTronco,
      perfil.marchitar(perfil.tallo, _sed),
    );

    if (etapa.index < EtapaCrecimiento.plantaPequena.index) {
      _hoja(
        canvas,
        Offset(topX - w * 0.025, topY + h * 0.02),
        -0.6,
        h * 0.08,
        perfil.marchitar(perfil.hojaClara, _sed),
      );
      _hoja(
        canvas,
        Offset(topX + w * 0.025, topY + h * 0.015),
        0.6,
        h * 0.08,
        perfil.marchitar(perfil.hojaClara, _sed),
      );
      return;
    }

    final nRamas = etapa.index >= EtapaCrecimiento.plantaMediana.index ? 4 : 2;
    final radioRama = h * 0.10 * perfil.densidad;
    for (var i = 0; i < nRamas; i++) {
      final posRama = 0.42 + 0.2 * (i % 2);
      final origen = _puntoCuadratico(p0, p1, p2, posRama);
      final lado = i.isEven ? 1.0 : -1.0;
      final ramaCtl = Offset(
        origen.dx + lado * w * 0.09,
        origen.dy - h * 0.05,
      );
      final ramaFin = Offset(
        origen.dx + lado * w * 0.14,
        origen.dy - h * (0.05 + 0.06 * (i % 2)),
      );
      _ramaConica(
        canvas,
        origen,
        ramaCtl,
        ramaFin,
        grosorTronco * 0.45,
        perfil.marchitar(perfil.tallo.oscuro(0.08), _sed),
      );
      _copaPequena(
        canvas,
        ramaFin,
        radioRama * (0.55 + 0.15 * (i % 2)),
        tE,
      );
    }

    final copaRadio = h * 0.22 * perfil.densidad;
    if (_esAdulta) {
      _copaCompleta(canvas, Offset(topX, topY), copaRadio, tE);
      if (perfil.floresAdultas) {
        for (var i = 0; i < 5; i++) {
          final angulo = i * 2 * math.pi / 5 + fase;
          final punto = Offset(
            topX + math.cos(angulo) * copaRadio * 0.82,
            topY + math.sin(angulo) * copaRadio * 0.6,
          );
          _florAbierta(canvas, punto, h * 0.018 * perfil.densidad);
        }
      }
      if (perfil.frutosAdultos) {
        for (var i = 0; i < 4; i++) {
          final x = topX + (i - 1.5) * w * 0.08;
          _fruto(canvas, Offset(x, topY + copaRadio * (0.3 + (i % 2) * 0.25)));
        }
      }
    } else {
      _copaPequena(canvas, Offset(topX, topY), copaRadio * 0.9, tE);
    }
  }

  void _copaPequena(Canvas canvas, Offset centro, double radio, double tE) {
    final dia = radio * 2 * (0.85 + 0.2 * tE);
    final base = Rect.fromCenter(
      center: Offset(centro.dx, centro.dy - radio * 0.25),
      width: dia,
      height: dia * 0.85,
    );
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.9, radio * 0.06)
      ..color = perfil.hojaOscura.oscuro(0.45).withValues(alpha: 0.5);
    canvas.drawOval(
      base,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.6),
          colors: [
            perfil.marchitar(perfil.hojaClara.claro(0.35), _sed),
            perfil.marchitar(perfil.hojaMedia, _sed),
            perfil.marchitar(perfil.hojaOscura, _sed),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(base),
    );
    canvas.drawOval(base, trazo);
    final bajo = Rect.fromCenter(
      center: Offset(centro.dx - radio * 0.6, centro.dy + radio * 0.15),
      width: dia * 0.62,
      height: dia * 0.5,
    );
    canvas.drawOval(
      bajo,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [
            perfil.marchitar(perfil.hojaMedia, _sed),
            perfil.marchitar(perfil.hojaOscura.oscuro(0.2), _sed),
          ],
        ).createShader(bajo),
    );
    canvas.drawOval(bajo, trazo);
  }

  void _copaCompleta(Canvas canvas, Offset centro, double radio, double tE) {
    final dia = radio * 2 * (0.97 + 0.08 * tE);

    void blob(Offset c, double w2, double h2, Color color) {
      final r = Rect.fromCenter(center: c, width: w2, height: h2);
      canvas.drawOval(
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.45, -0.6),
            colors: [
              color.claro(0.4),
              color,
              color.oscuro(0.35),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(r),
      );
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.9, radio * 0.05)
          ..color = perfil.hojaOscura.oscuro(0.45).withValues(alpha: 0.45),
      );
    }

    // Copa en capas de profundidad: atrás oscura, delante clara.
    blob(
      Offset(centro.dx - radio * 0.78, centro.dy + radio * 0.15),
      dia * 0.7,
      dia * 0.55,
      perfil.marchitar(perfil.hojaOscura.oscuro(0.12), _sed),
    );
    blob(
      Offset(centro.dx + radio * 0.8, centro.dy + radio * 0.05),
      dia * 0.68,
      dia * 0.52,
      perfil.marchitar(perfil.hojaOscura, _sed),
    );
    blob(
      Offset(centro.dx - radio * 0.3, centro.dy - radio * 0.3),
      dia * 0.85,
      dia * 0.68,
      perfil.marchitar(perfil.hojaClara, _sed),
    );
    blob(
      Offset(centro.dx + radio * 0.35, centro.dy - radio * 0.18),
      dia * 0.8,
      dia * 0.62,
      perfil.marchitar(perfil.hojaMedia, _sed),
    );
    blob(
      Offset(centro.dx - radio * 0.05, centro.dy + radio * 0.22),
      dia * 0.95,
      dia * 0.6,
      perfil.marchitar(perfil.hojaMedia.claro(0.1), _sed),
    );
    blob(
      Offset(centro.dx, centro.dy - radio * 0.02),
      dia * 0.88,
      dia * 0.7,
      perfil.marchitar(perfil.hojaClara.claro(0.08), _sed),
    );

    // Hojitas sueltas en el borde (silueta viva).
    for (var i = 0; i < 8; i++) {
      final angulo = i * 2 * math.pi / 8 + 0.4;
      final p = Offset(
        centro.dx + math.cos(angulo) * radio * 0.92,
        centro.dy + math.sin(angulo) * radio * 0.75,
      );
      _hoja(
        canvas,
        p,
        -angulo * 0.6,
        radio * 0.3,
        perfil.marchitar(
          _alternar(i, perfil.hojaClara, perfil.hojaOscura),
          _sed,
        ),
      );
    }

    // Destellos de luz sobre la copa.
    final brillo = Paint()..color = Colors.white.withValues(alpha: 0.16);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx - radio * 0.6, centro.dy - radio * 0.5),
        width: radio * 0.6,
        height: radio * 0.3,
      ),
      brillo,
    );
  }

  void _pintarTrepador(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    if (perfil.colgante) {
      _pintarColgante(canvas, w, h, cx, baseY, sway);
    } else {
      _pintarTrepadorVertical(canvas, w, h, cx, baseY, sway);
    }
  }

  /// Enredadera que trepa por un tutor de madera: guía principal en zigzag
  /// suave, hojas acorazonadas, zarcillos en la punta y flores al ser adulta.
  void _pintarTrepadorVertical(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final altura = h * _alturaGlobal * perfil.anchura;
    if (altura <= 0) return;
    final crecimiento = (_alturaGlobal / 0.82).clamp(0.0, 1.0);

    // Tutor: la estructura que la planta trepa.
    final altoTutor = altura * 1.14 + h * 0.02;
    _tutor(
      canvas,
      Offset(cx - w * 0.015, baseY + h * 0.01),
      altoTutor,
      sway * w * 0.018 - w * 0.02,
      h * 0.022 * perfil.densidad,
      perfil.tallo.oscuro(0.35),
    );
    _tutor(
      canvas,
      Offset(cx + w * 0.055, baseY + h * 0.005),
      altoTutor * 0.8,
      sway * w * 0.022 + w * 0.02,
      h * 0.017 * perfil.densidad,
      perfil.tallo.oscuro(0.45),
    );

    // Guía principal que sube enrollándose alrededor del tutor.
    final nSegmentos = math.max(3, (7 * crecimiento).round());
    final puntos = <Offset>[];
    for (var i = 0; i <= nSegmentos; i++) {
      final tt = i / nSegmentos;
      final balanceo =
          math.sin(tt * math.pi * 2.6 + fase) *
          w *
          (0.17 - 0.05 * crecimiento);
      puntos.add(
        Offset(cx + balanceo + sway * w * 0.10 * tt, baseY - altura * tt),
      );
    }
    for (var i = 0; i < puntos.length - 1; i++) {
      final p0 = puntos[i];
      final p1 = puntos[i + 1];
      final medio = Offset(
        (p0.dx + p1.dx) / 2 + math.sin(i * 1.7 + fase) * w * 0.035,
        (p0.dy + p1.dy) / 2,
      );
      _ramaConica(
        canvas,
        p0,
        medio,
        p1,
        (h * 0.026 * perfil.densidad).clamp(1.8, 4.6) *
            (0.65 + 0.35 * crecimiento),
        perfil.marchitar(perfil.tallo, _sed),
      );
    }

    // Hojas a lo largo de la guía, cada vez más grandes.
    for (var i = 1; i < puntos.length; i++) {
      final p = puntos[i];
      final lado = i.isEven ? 1.0 : -1.0;
      final posicion = i / puntos.length;
      final wobble = math.sin(_t * 2 * math.pi + i * 2.1) * 0.07 * (1 - _sed);
      final tam =
          h *
          0.14 *
          perfil.densidad *
          (0.55 + 0.45 * crecimiento) *
          (1.05 - 0.22 * posicion);
      _hoja(
        canvas,
        p,
        _anguloHoja(lado, 0.85 - 0.15 * posicion) +
            wobble +
            (_marchitado ? lado * 0.5 : 0),
        tam,
        perfil.marchitar(
          _alternar(i, perfil.hojaMedia, perfil.hojaOscura.claro(0.12)),
          _sed,
        ),
      );
      if (i.isEven && !_marchitado) {
        _hoja(
          canvas,
          Offset(p.dx + lado * w * 0.035, p.dy + h * 0.02),
          _anguloHoja(lado, 1.05) + wobble * 0.6,
          tam * 0.7,
          perfil.marchitar(perfil.hojaClara, _sed),
        );
      }
    }

    // Zarcillos enroscados en la punta.
    if (crecimiento > 0.35 && !_marchitado) {
      final punta = puntos.last;
      _zarcillo(
        canvas,
        punta,
        h * 0.12,
        1.0 + sway * 2,
        fase,
        perfil.tallo,
      );
      _zarcillo(
        canvas,
        Offset(punta.dx - w * 0.05, punta.dy + h * 0.05),
        h * 0.09,
        -1.0 + sway,
        fase + 0.4,
        perfil.tallo.oscuro(0.1),
      );
    }

    if (_esAdulta && perfil.floresAdultas) {
      _florAbierta(
        canvas,
        Offset(puntos.last.dx + w * 0.03, puntos.last.dy),
        h * 0.045 * perfil.densidad,
      );
    }
  }

  /// Planta colgante: macetero artesanal con guías que caen y se mecen.
  void _pintarColgante(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final crecimiento = (_alturaGlobal / 0.82).clamp(0.0, 1.0);
    final largoGuias = h * (0.22 + 0.5 * crecimiento);
    final centro = Offset(cx, baseY - h * 0.58);

    // Cuerdas del macramé.
    final cuerda = Paint()
      ..color = const Color(0xFFC9B48F).withValues(alpha: 0.85)
      ..strokeWidth = math.max(1.1, w * 0.008)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centro.dx - w * 0.11, centro.dy - h * 0.05),
      Offset(centro.dx - w * 0.06, 0),
      cuerda,
    );
    canvas.drawLine(
      Offset(centro.dx + w * 0.11, centro.dy - h * 0.05),
      Offset(centro.dx + w * 0.06, 0),
      cuerda,
    );

    _macetaColgante(canvas, centro, w * 0.38, h * 0.17);

    final nGuias = 3 + (crecimiento > 0.5 ? 1 : 0);
    for (var g = 0; g < nGuias; g++) {
      final lado = g.isEven ? 1.0 : -1.0;
      final separacion = nGuias == 1 ? 0.0 : (g / (nGuias - 1) - 0.5) * 2;
      final largo = largoGuias * (0.7 + 0.3 * (((g * 37) % 11) / 11));
      final puntos = <Offset>[];
      const pasos = 7;
      for (var i = 0; i <= pasos; i++) {
        final tt = i / pasos;
        final x =
            centro.dx +
            separacion * w * 0.24 +
            math.sin(tt * 3 + g * 1.3 + fase) * w * 0.06 +
            sway * w * 0.07 * tt * lado;
        final y = centro.dy + h * 0.03 + largo * tt;
        puntos.add(Offset(x, y));
      }
      for (var i = 0; i < puntos.length - 1; i++) {
        _ramaConica(
          canvas,
          puntos[i],
          Offset(
            (puntos[i].dx + puntos[i + 1].dx) / 2,
            (puntos[i].dy + puntos[i + 1].dy) / 2,
          ),
          puntos[i + 1],
          (h * 0.018).clamp(1.4, 3.0),
          perfil.marchitar(perfil.tallo, _sed),
        );
      }
      for (var i = 1; i < puntos.length; i++) {
        final p = puntos[i];
        final ladoHoja = i.isEven ? 1.0 : -1.0;
        final wobble =
            math.sin(_t * 2 * math.pi + i * 1.9 + g) * 0.08 * (1 - _sed);
        _hoja(
          canvas,
          p,
          _anguloHoja(ladoHoja, 0.55) +
              wobble +
              (_marchitado ? ladoHoja * 0.5 : 0),
          h * 0.115 * perfil.densidad * (0.6 + 0.4 * crecimiento),
          perfil.marchitar(
            _alternar(i, perfil.hojaMedia, perfil.hojaClara),
            _sed,
          ),
        );
      }
    }

    if (_esAdulta && perfil.floresAdultas) {
      _florAbierta(
        canvas,
        Offset(centro.dx, centro.dy + h * 0.02),
        h * 0.04 * perfil.densidad,
      );
    }
  }

  /// Tutor de madera con brillo lateral.
  void _tutor(
    Canvas canvas,
    Offset base,
    double alto,
    double inclinacion,
    double grosor,
    Color color,
  ) {
    final punta = Offset(base.dx + inclinacion, base.dy - alto);
    final medio = Offset(
      (base.dx + punta.dx) / 2 + inclinacion * 0.25,
      (base.dy + punta.dy) / 2,
    );
    final madera = perfil.marchitar(color, _sed * 0.5);
    _ramaConica(canvas, base, medio, punta, grosor, madera);
    canvas.drawLine(
      Offset(base.dx - grosor * 0.18, base.dy),
      Offset(punta.dx - grosor * 0.18, punta.dy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..strokeWidth = math.max(0.8, grosor * 0.16)
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Zarcillo que se enrosca en el aire.
  void _zarcillo(
    Canvas canvas,
    Offset base,
    double largo,
    double direccion,
    double semilla,
    Color color,
  ) {
    final paint = Paint()
      ..color = perfil.marchitar(color, _sed)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(base.dx, base.dy);
    var p = base;
    const pasos = 10;
    for (var i = 1; i <= pasos; i++) {
      final tt = i / pasos;
      final angulo = direccion * tt * math.pi * 2.3 + semilla;
      final radio = largo * tt * 0.5;
      final next = Offset(
        base.dx + math.cos(angulo) * radio,
        base.dy - math.sin(angulo) * radio * 0.5 - largo * tt * 0.85,
      );
      final ctl = Offset(
        (p.dx + next.dx) / 2 + math.sin(angulo) * 4,
        (p.dy + next.dy) / 2 - 3,
      );
      path.quadraticBezierTo(ctl.dx, ctl.dy, next.dx, next.dy);
      p = next;
    }
    canvas.drawPath(path, paint);
  }

  /// Macetero de barro con borde y tierra.
  void _macetaColgante(
    Canvas canvas,
    Offset centro,
    double ancho,
    double alto,
  ) {
    final cuerpo = Path()
      ..moveTo(centro.dx - ancho / 2, centro.dy - alto / 2)
      ..lineTo(centro.dx + ancho / 2, centro.dy - alto / 2)
      ..lineTo(centro.dx + ancho * 0.32, centro.dy + alto / 2)
      ..quadraticBezierTo(
        centro.dx,
        centro.dy + alto * 0.78,
        centro.dx - ancho * 0.32,
        centro.dy + alto / 2,
      )
      ..close();
    final rect = Rect.fromCenter(
      center: centro,
      width: ancho,
      height: alto * 1.5,
    );
    canvas.drawPath(
      cuerpo,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFD98A5A),
            const Color(0xFFB86A3E),
            const Color(0xFF8A4A2A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centro.dx, centro.dy - alto * 0.5),
          width: ancho * 1.08,
          height: alto * 0.2,
        ),
        Radius.circular(alto * 0.1),
      ),
      Paint()..color = const Color(0xFFE09A6A),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx, centro.dy - alto * 0.44),
        width: ancho * 0.86,
        height: alto * 0.18,
      ),
      Paint()..color = perfil.marchitar(const Color(0xFF5A3E2A), _sed),
    );
  }

  void _pintarCarnivora(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final tE = _progresoEnEtapa;
    final altura = h * _alturaGlobal * perfil.anchura;
    final nTallos = _esAdulta ? 4 : 1 + etapa.index ~/ 2;

    // Roseta basal de hojas carnosas.
    for (var i = 0; i < 3; i++) {
      final lado = i.isEven ? 1.0 : -1.0;
      _hoja(
        canvas,
        Offset(cx + lado * w * 0.02, baseY - h * 0.01),
        _anguloHoja(lado, 0.95 - 0.12 * i),
        h * 0.18 * perfil.densidad * (0.6 + 0.4 * tE),
        perfil.marchitar(perfil.hojaOscura.claro(0.08), _sed),
      );
    }

    for (var i = 0; i < nTallos; i++) {
      final lado = i.isEven ? 1.0 : -1.0;
      final anchoTallo = w * (0.1 + 0.05 * i) * perfil.anchura;
      final altoTallo = altura * (0.72 + 0.12 * (i % 2)) * tE;
      final punta = Offset(
        cx + lado * anchoTallo * 1.15 + sway * w * 0.10,
        baseY - altoTallo,
      );
      final ctl = Offset(
        cx + lado * anchoTallo * 0.6,
        baseY - altoTallo * 0.6,
      );
      _ramaConica(
        canvas,
        Offset(cx + lado * w * 0.02, baseY),
        ctl,
        punta,
        (h * 0.03 * perfil.densidad).clamp(2.0, 5.0),
        perfil.marchitar(perfil.tallo, _sed),
      );
      _trampa(canvas, punta, h * 0.13 * perfil.densidad, i.isEven);
    }
  }

  void _trampa(Canvas canvas, Offset punta, double tam, bool derecha) {
    final latido = math.sin(_t * 2 * math.pi * 2.2) * 0.04;
    final cuerpo = Rect.fromCenter(
      center: Offset(punta.dx, punta.dy - tam * 0.55),
      width: tam * 0.62,
      height: tam * (1.1 + latido),
    );
    canvas.drawOval(
      cuerpo,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [
            perfil.marchitar(perfil.hojaMedia.claro(0.3), _sed),
            perfil.marchitar(perfil.hojaMedia, _sed),
            perfil.marchitar(perfil.hojaOscura, _sed),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(cuerpo),
    );
    final boca = Rect.fromCenter(
      center: Offset(punta.dx, punta.dy - tam * 0.45),
      width: tam * 0.64,
      height: tam * (0.55 + latido),
    );
    canvas.drawOval(
      boca,
      Paint()
        ..shader = RadialGradient(
          colors: [
            perfil.marchitar(perfil.hojaClara.claro(0.25), _sed),
            perfil.marchitar(perfil.hojaMedia.claro(0.15), _sed),
          ],
        ).createShader(boca),
    );
    // Labios con acento de color y dientes de zarcillo.
    final labio = Paint()
      ..color = perfil.marchitar(perfil.flor, _sed)
      ..strokeWidth = tam * 0.09
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(punta.dx, punta.dy - tam * 1.05),
        width: tam * 0.8,
        height: tam * 0.55,
      ),
      derecha ? -2.5 : -0.5,
      1.8,
      false,
      labio,
    );
    // Destello de luz en el cuerpo.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(punta.dx - tam * 0.12, punta.dy - tam * 0.8),
        width: tam * 0.14,
        height: tam * 0.22,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _pintarFlotante(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double baseY,
    double sway,
  ) {
    final tE = _progresoEnEtapa;
    final agua = Rect.fromCenter(
      center: Offset(cx, baseY + h * 0.012),
      width: w * 0.68,
      height: h * 0.105,
    );
    canvas.drawOval(
      agua,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.5),
          colors: [
            const Color(0xFFCDEDF5).withValues(alpha: 0.75),
            const Color(0xFF6FAFC9).withValues(alpha: 0.55),
          ],
        ).createShader(agua),
    );

    // Almohadillas flotantes en capas.
    final nPads = etapa.index >= EtapaCrecimiento.plantaMediana.index ? 3 : 2;
    for (var i = 0; i < nPads; i++) {
      final s = ((i * 37) % 11) / 11;
      final padRect = Rect.fromCenter(
        center: Offset(
          cx + (s - 0.5) * w * 0.5 + sway * w * 0.05,
          baseY - h * (0.004 + 0.032 * i),
        ),
        width: w * (0.17 + s * 0.06) * perfil.anchura * (0.7 + 0.3 * tE),
        height: h * 0.045,
      );
      canvas.drawOval(
        padRect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.6),
            colors: [
              perfil.marchitar(perfil.hojaMedia.claro(0.22), _sed),
              perfil.marchitar(perfil.hojaMedia, _sed),
              perfil.marchitar(perfil.hojaOscura, _sed),
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(padRect),
      );
      canvas.drawOval(
        padRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = perfil
              .marchitar(perfil.hojaOscura.oscuro(0.4), _sed)
              .withValues(alpha: 0.5),
      );
    }

    final altura = h * _alturaGlobal * perfil.anchura;
    final punta = Offset(cx + sway * w * 0.08, baseY - altura);
    _ramaConica(
      canvas,
      Offset(cx, baseY - h * 0.005),
      Offset(cx + sway * w * 0.04, baseY - altura * 0.5),
      punta,
      (h * 0.024).clamp(1.8, 4.5),
      perfil.marchitar(perfil.tallo.oscuro(0.1), _sed),
    );
    if (_esAdulta && perfil.floresAdultas) {
      _florAbierta(canvas, punta, h * 0.085 * perfil.densidad);
    } else if (etapa.index >= EtapaCrecimiento.plantaMediana.index) {
      _florCerrada(canvas, punta, h * 0.034);
    } else {
      _florCerrada(canvas, punta, h * 0.026);
    }
  }

  // ---------------------------------------------------------------------------
  // Piezas
  // ---------------------------------------------------------------------------

  void _ramaConica(
    Canvas canvas,
    Offset p0,
    Offset p1,
    Offset p2,
    double grosor,
    Color color,
  ) {
    if (grosor <= 0) return;
    const n = 16;
    final centro = List<Offset>.generate(n + 1, (i) {
      return _puntoCuadratico(p0, p1, p2, i / n);
    });
    final izquierda = <Offset>[];
    final derecha = <Offset>[];
    var minX = double.infinity, minY = double.infinity;
    var maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (var i = 0; i <= n; i++) {
      final prev = centro[i > 0 ? i - 1 : 0];
      final next = centro[i < n ? i + 1 : n];
      var dx = next.dx - prev.dx;
      var dy = next.dy - prev.dy;
      final inv = math.sqrt(dx * dx + dy * dy);
      if (inv > 1e-6) {
        dx /= inv;
        dy /= inv;
      }
      final nx = -dy;
      final ny = dx;
      final ancho = grosor / 2 * (1 - 0.48 * i / n);
      final izq = Offset(centro[i].dx + nx * ancho, centro[i].dy + ny * ancho);
      final der = Offset(centro[i].dx - nx * ancho, centro[i].dy - ny * ancho);
      izquierda.add(izq);
      derecha.add(der);
      minX = math.min(minX, math.min(izq.dx, der.dx));
      minY = math.min(minY, math.min(izq.dy, der.dy));
      maxX = math.max(maxX, math.max(izq.dx, der.dx));
      maxY = math.max(maxY, math.max(izq.dy, der.dy));
    }
    final path = Path()..moveTo(izquierda[0].dx, izquierda[0].dy);
    for (final p in izquierda.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    for (final p in derecha.reversed) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    final rect = Rect.fromLTRB(minX, minY, maxX, maxY);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.claro(0.34), color.claro(0.05), color.oscuro(0.24)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
  }

  double get _aspectoHoja {
    return switch (perfil.formaHoja) {
      FormaHoja.oval => 0.26,
      FormaHoja.redondeada => 0.48,
      FormaHoja.lanceolada => 0.14,
      FormaHoja.acicular => 0.05,
      FormaHoja.serrada => 0.26,
      FormaHoja.palmeada => 0.32,
      FormaHoja.carnosa => 0.24,
      FormaHoja.espada => 0.1,
    };
  }

  void _hoja(
    Canvas canvas,
    Offset base,
    double angulo,
    double largo,
    Color color,
  ) {
    if (largo <= 0) return;
    final estirada =
        perfil.formaHoja == FormaHoja.espada ||
        perfil.formaHoja == FormaHoja.acicular;
    final l = estirada ? largo * 1.5 : largo;
    final hh = largo * _aspectoHoja;
    final rectLoca = Rect.fromLTRB(0, -l * 0.8, l * 1.1, l * 0.8);
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angulo);
    final pintura = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color.claro(0.34), color, color.oscuro(0.42)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rectLoca);
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.9, l * 0.045)
      ..strokeJoin = StrokeJoin.round
      ..color = color.oscuro(0.55).withValues(alpha: 0.5);

    switch (perfil.formaHoja) {
      case FormaHoja.oval:
        _lente(canvas, l, hh, pintura, trazo);
      case FormaHoja.lanceolada:
        _lente(canvas, l, hh * 0.55, pintura, trazo);
        _veta(canvas, l);
      case FormaHoja.espada:
        _lente(canvas, l, hh * 0.5, pintura, trazo);
        _veta(canvas, l);
      case FormaHoja.acicular:
        for (var a = -1; a <= 1; a++) {
          canvas.save();
          canvas.rotate(a * 0.12);
          _lente(canvas, l, hh, pintura, trazo);
          canvas.restore();
        }
      case FormaHoja.redondeada:
        _corazon(canvas, l, hh, pintura, trazo);
        _veta(canvas, l);
      case FormaHoja.serrada:
        _lente(canvas, l, hh, pintura, trazo);
        _dientes(canvas, l, hh, color);
        _veta(canvas, l);
      case FormaHoja.palmeada:
        _palmeada(canvas, l, hh, pintura, trazo, color);
      case FormaHoja.carnosa:
        _carnosa(canvas, l, hh, pintura, trazo, color);
    }

    // Brillo húmedo en la cara superior.
    if (!_marchitado || recienRegada) {
      final destello = Paint()..color = Colors.white.withValues(alpha: 0.16);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(l * 0.3, -hh * 0.4),
          width: l * 0.34,
          height: l * 0.12,
        ),
        destello,
      );
    }
    canvas.restore();
  }

  void _lente(Canvas canvas, double largo, double hh, Paint pintura, Paint trazo) {
    final ruta = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(largo * 0.5, -hh * 2.4, largo, 0)
      ..quadraticBezierTo(largo * 0.5, hh * 2.4, 0, 0)
      ..close();
    canvas.drawPath(ruta, pintura);
    canvas.drawPath(ruta, trazo);
  }

  void _corazon(Canvas canvas, double largo, double hh, Paint pintura, Paint trazo) {
    final ruta = Path()
      ..moveTo(0, -hh * 0.1)
      ..quadraticBezierTo(-largo * 0.06, -hh * 1.7, largo * 0.25, -hh * 1.9)
      ..quadraticBezierTo(largo * 0.8, -hh * 1.8, largo * 0.95, -hh * 0.1)
      ..quadraticBezierTo(largo * 0.8, hh * 1.9, largo * 0.25, hh * 2.0)
      ..quadraticBezierTo(-largo * 0.05, hh * 1.6, 0, -hh * 0.1)
      ..close();
    canvas.drawPath(ruta, pintura);
    canvas.drawPath(ruta, trazo);
  }

  void _palmeada(
    Canvas canvas,
    double largo,
    double hh,
    Paint pintura,
    Paint trazo,
    Color color,
  ) {
    _lente(canvas, largo, hh, pintura, trazo);
    for (final lado in [-1.0, 1.0]) {
      canvas.save();
      canvas.rotate(lado * 0.5);
      canvas.translate(largo * 0.3, 0);
      _lente(canvas, largo * 0.62, hh, pintura, trazo);
      canvas.restore();
    }
    _veta(canvas, largo);
  }

  void _carnosa(
    Canvas canvas,
    double largo,
    double hh,
    Paint pintura,
    Paint trazo,
    Color c,
  ) {
    final ruta = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0, -hh * 1.45, largo, hh * 1.45),
          Radius.circular(largo * 0.45),
        ),
      );
    canvas.drawPath(ruta, pintura);
    canvas.drawPath(ruta, trazo);
    _veta(canvas, largo);
    // Pliegue jugoso central.
    canvas.drawLine(
      Offset(largo * 0.12, 0),
      Offset(largo * 0.85, 0),
      Paint()
        ..color = c.oscuro(0.15).withValues(alpha: 0.4)
        ..strokeWidth = 1.1,
    );
  }

  void _veta(Canvas canvas, double largo) {
    canvas.drawLine(
      Offset(largo * 0.08, 0),
      Offset(largo * 0.9, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
  }

  void _dientes(Canvas canvas, double largo, double hh, Color c) {
    final pintura = Paint()
      ..color = c.oscuro(0.25).withValues(alpha: 0.85)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var d = 0; d < 3; d++) {
      final eje = largo * (0.18 + d * 0.26);
      canvas.drawLine(
        Offset(eje, -hh * 0.55),
        Offset(eje + largo * 0.05, -hh * 1.15),
        pintura,
      );
      canvas.drawLine(
        Offset(eje, hh * 0.55),
        Offset(eje + largo * 0.05, hh * 1.15),
        pintura,
      );
    }
  }

  void _florCerrada(Canvas canvas, Offset centro, double radio) {
    final yema = Rect.fromCenter(
      center: Offset(centro.dx, centro.dy - radio * 0.6),
      width: radio * 1.4,
      height: radio * 1.7,
    );
    canvas.drawOval(
      yema,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.55),
          colors: [
            perfil.flor.claro(0.28),
            perfil.flor,
            perfil.flor.oscuro(0.28),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(yema),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx - radio * 0.5, centro.dy - radio * 0.95),
        width: radio * 0.7,
        height: radio * 0.4,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            perfil.flor.claro(0.45),
            perfil.flor.claro(0.2),
          ],
        ).createShader(Rect.fromCenter(
          center: Offset(centro.dx - radio * 0.5, centro.dy - radio * 0.95),
          width: radio * 0.7,
          height: radio * 0.4,
        )),
    );
  }

  void _florAbierta(Canvas canvas, Offset centro, double radio) {
    // Halo de luz detrás de la flor.
    _halo(
      canvas,
      centro,
      radio * 2.1,
      perfil.flor.withValues(alpha: 0.18 + 0.08 * math.sin(_t * 2 * math.pi)),
    );

    // Pétalos traseros (oscuros).
    const petalos = 6;
    for (var i = 0; i < petalos; i++) {
      final angulo = i * 2 * math.pi / petalos + math.sin(_t * 2 * math.pi) * 0.04;
      _petalo(
        canvas,
        centro,
        angulo,
        radio * 1.05,
        radio * 0.68,
        perfil.flor.oscuro(0.22),
      );
    }
    // Pétalos delanteros por encima.
    for (var i = 0; i < petalos; i++) {
      final angulo = i * 2 * math.pi / petalos + math.pi / petalos + math.sin(_t * 2 * math.pi + 0.4) * 0.04;
      _petalo(
        canvas,
        centro,
        angulo,
        radio * 0.95,
        radio * 0.62,
        _alternar(i, perfil.flor, perfil.flor.claro(0.14)),
      );
    }
    // Centro con gradiente.
    canvas.drawCircle(
      centro,
      radio * 0.62,
      Paint()
        ..shader = RadialGradient(
          colors: [
            perfil.florCentro.claro(0.2),
            perfil.florCentro,
            perfil.florCentro.oscuro(0.3),
          ],
          stops: const [0.4, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: centro, radius: radio * 0.62)),
    );
    // Granitos de polen.
    final polenP = Paint()..color = const Color(0xFFFFF3C9);
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 + 0.3;
      final p = Offset(
        centro.dx + math.cos(a) * radio * 0.44,
        centro.dy + math.sin(a) * radio * 0.44,
      );
      canvas.drawCircle(p, radio * 0.06, polenP);
    }
  }

  void _petalo(
    Canvas canvas,
    Offset centro,
    double angulo,
    double distancia,
    double tamanio,
    Color color,
  ) {
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(angulo);
    canvas.translate(distancia, 0);
    final rectL = Rect.fromCenter(
      center: Offset(tamanio * 0.5, 0),
      width: tamanio,
      height: tamanio * 0.62,
    );
    canvas.drawOval(
      rectL,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.5),
          colors: [color.claro(0.2), color, color.oscuro(0.22)],
        ).createShader(rectL),
    );
    canvas.restore();
  }

  void _fruto(Canvas canvas, Offset centro) {
    final rect = Rect.fromCircle(center: centro, radius: 3.6);
    canvas.drawCircle(
      centro,
      3.6,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: [
            perfil.marchitar(perfil.fruto.claro(0.35), _sed),
            perfil.marchitar(perfil.fruto, _sed),
            perfil.marchitar(perfil.fruto.oscuro(0.3), _sed),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(centro.dx - 1.0, centro.dy - 1.2),
      1.1,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  // ---------------------------------------------------------------------------
  // Animaciones de vida
  // ---------------------------------------------------------------------------

  void _motasDeCrecimiento(Canvas canvas, double w, double h, double cx, double tope) {
    if (etapa.index < EtapaCrecimiento.brote.index) return;
    final baseColor = perfil.hojaClara.claro(0.45);
    for (var i = 0; i < 3; i++) {
      final semilla = ((i * 53) % 17) / 17;
      final ciclo = (_t * 0.6 + i * 0.21) % 1.0;
      final alfa = math.sin(ciclo * math.pi).clamp(0.0, 1.0);
      final x = cx + math.sin((_t + i) * 2.3) * w * 0.16 + (semilla - 0.5) * w * 0.3;
      final y = tope - h * 0.1 - ciclo * h * 0.4;
      canvas.drawCircle(
        Offset(x, y),
        h * 0.006 * (1 - ciclo * 0.5),
        Paint()..color = baseColor.withValues(alpha: alfa * 0.8),
      );
    }
  }

  void _rocio(Canvas canvas, double w, double h, double cx, double tope) {
    for (var i = 0; i < 4; i++) {
      final semilla = ((i * 71) % 23) / 23;
      final parpadeo = 0.5 + 0.5 * math.sin(_t * 2 * math.pi * 3 + i * 1.7);
      final x = cx + (semilla - 0.45) * w * 0.5;
      final y = tope + h * (semilla * 0.5) + h * 0.18;
      _destello(canvas, Offset(x, y), h * 0.013, parpadeo);
    }
  }

  void _destello(Canvas canvas, Offset p, double tam, double intensidad) {
    if (intensidad < 0.15) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: intensidad * 0.85)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(p.dx - tam, p.dy),
      Offset(p.dx + tam, p.dy),
      paint,
    );
    canvas.drawLine(
      Offset(p.dx, p.dy - tam),
      Offset(p.dx, p.dy + tam),
      paint,
    );
    canvas.drawCircle(
      p,
      tam * 0.55,
      Paint()..color = const Color(0xFFBFE9FF).withValues(alpha: intensidad * 0.5),
    );
  }

  void _pintarPolen(Canvas canvas, double w, double h) {
    final base = perfil.florCentro;
    for (var i = 0; i < 4; i++) {
      final semilla = ((i * 37) % 11) / 11;
      final ciclo = ((_t + i * 0.13) * 1.5) % 1.0;
      final x = w * (0.3 + semilla * 0.4) + math.sin((_t + i) * 5) * w * 0.08;
      final y = h * (0.26 + semilla * 0.25) - ciclo * h * 0.22;
      canvas.drawCircle(
        Offset(x, y),
        h * 0.008 * (1 - ciclo * 0.3),
        Paint()..color = base.withValues(alpha: math.sin(ciclo * math.pi) * 0.65),
      );
    }
  }

  void _iniciarRespiro(Canvas canvas, double cx, double baseY) {
    final respiro = 1 + 0.016 * math.sin(_t * 2 * math.pi * 3);
    canvas.save();
    canvas.translate(cx, baseY);
    canvas.scale(
      respiro,
      respiro * (1 + 0.007 * math.sin(_t * 2 * math.pi * 3 + 0.6)),
    );
    canvas.translate(-cx, -baseY);
  }

  // ---------------------------------------------------------------------------
  // Utilidades
  // ---------------------------------------------------------------------------

  Color _claro(Color c, double f) => c.claro(f);
  Color _oscuro(Color c, double f) => c.oscuro(f);

  Color _alternar(int i, Color a, Color b) => i.isEven ? a : b;

  /// Ángulo para una hoja que sale del tallo hacia [lado] (1 derecha,
  /// -1 izquierda). [inclinacion] es la apertura respecto a la vertical:
  /// 0 = recta hacia arriba, pi/2 = horizontal.
  double _anguloHoja(double lado, double inclinacion) =>
      -math.pi / 2 + lado * (math.pi / 2 - inclinacion);

  Offset _puntoCuadratico(Offset p0, Offset p1, Offset p2, double tt) {
    final u = 1 - tt;
    return Offset(
      u * u * p0.dx + 2 * u * tt * p1.dx + tt * tt * p2.dx,
      u * u * p0.dy + 2 * u * tt * p1.dy + tt * tt * p2.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _PlantSpritePainter oldDelegate) {
    return oldDelegate.etapa != etapa ||
        oldDelegate.progreso != progreso ||
        oldDelegate.horas != horas ||
        oldDelegate.perfil != perfil ||
        oldDelegate.tienePlaga != tienePlaga ||
        oldDelegate.marchita != marchita ||
        oldDelegate.marchitez != marchitez ||
        oldDelegate.recienRegada != recienRegada ||
        oldDelegate.tieneFloracion != tieneFloracion ||
        oldDelegate.fase != fase ||
        oldDelegate.aura != aura;
  }
}

/// Anillo luminoso que celebra la subida de etapa. Se instancia con una clave
/// nueva por etapa para que la animación se dispare una sola vez.
class GrowthRing extends StatefulWidget {
  final Color color;

  const GrowthRing({super.key, required this.color});

  @override
  State<GrowthRing> createState() => _GrowthRingState();
}

class _GrowthRingState extends State<GrowthRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
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
          painter: _RingPainter(
            ease: Curves.easeOutCubic.transform(_controlador.value),
            color: widget.color,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ease;
  final Color color;

  const _RingPainter({required this.ease, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.7;
    final radio = size.height * (0.12 + ease * 0.5);
    final alfa = (1 - ease) * 0.6;

    final anillo = Paint()
      ..color = color.withValues(alpha: alfa)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.02 * (1 - ease * 0.4)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, baseY), radio, anillo);
    canvas.drawCircle(Offset(cx, baseY), radio * 0.72, anillo);

    // Chispas radiales que suben desde la base.
    for (var i = 0; i < 6; i++) {
      final angulo = -math.pi / 2 + (i - 2.5) * 0.5;
      final largo = size.height * 0.05 * (1 - ease);
      final dx = math.cos(angulo) * radio * 0.85;
      final dy = math.sin(angulo) * radio * 0.85;
      canvas.drawLine(
        Offset(cx + dx * ease, baseY + dy * ease),
        Offset(
          cx + dx * ease + math.cos(angulo) * largo,
          baseY + dy * ease + math.sin(angulo) * largo,
        ),
        Paint()
          ..color = color.withValues(alpha: alfa * 0.9)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.ease != ease;
}

/// Explosión de partículas (hojitas) al subir de etapa o cuidar una planta.
/// Es de un solo uso y se elimina al terminar la animación.
class GrowthBurst extends StatefulWidget {
  final Color color;
  final int particulas;

  const GrowthBurst({
    super.key,
    this.color = AppColors.gardenGrass,
    this.particulas = 12,
  });

  @override
  State<GrowthBurst> createState() => _GrowthBurstState();
}

class _GrowthBurstState extends State<GrowthBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
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
          painter: _BurstPainter(
            t: Curves.easeOut.transform(_controlador.value),
            color: widget.color,
            particulas: widget.particulas,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double t;
  final Color color;
  final int particulas;

  const _BurstPainter({
    required this.t,
    required this.color,
    required this.particulas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.72;
    for (var i = 0; i < particulas; i++) {
      final semilla = ((i * 37) % 19) / 19;
      final lado = i.isEven ? 1.0 : -1.0;
      final angulo = -math.pi / 2 + lado * (0.25 + semilla * 0.8);
      final distancia = (0.4 + semilla * 0.6) * size.height * 0.85;
      final dx = math.cos(angulo) * distancia * t;
      final dy = math.sin(angulo) * distancia * t + size.height * 0.15 * t * t;
      final alpha = (1 - t).clamp(0.0, 1.0);
      final radio = size.height * 0.02 * (1 - t * 0.35);

      canvas.save();
      canvas.translate(cx + dx, baseY + dy);
      canvas.rotate(angulo + t * 2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: radio * 2.2, height: radio),
        Paint()..color = color.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.t != t;
}