import 'package:eco_reto/data/models/trivia/diario_models.dart';
import 'package:flutter_test/flutter_test.dart';

SesionPreguntaDiaria _pregunta({
  int triviaId = 1,
  int categoriaId = 1,
  String correcta = 'A',
  int puntosBase = 50,
}) {
  return SesionPreguntaDiaria(
    triviaId: triviaId,
    categoriaId: categoriaId,
    dificultad: 'Facil',
    pregunta: '¿Pregunta?',
    opciones: const {'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd'},
    respuestaCorrecta: correcta,
    puntosBase: puntosBase,
  );
}

SesionDiario _sesionCompletada(DateTime fecha, int categoriaId) {
  return SesionDiario(
    fecha: fecha,
    categoriaId: categoriaId,
    dificultad: 'Facil',
    preguntas: [_pregunta(categoriaId: categoriaId, correcta: 'A').responder(letra: 'A')],
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Helpers de fecha
  // ---------------------------------------------------------------------------

  group('Helpers de fecha', () {
    test('indiceCategoriaDelDia mapea weekday 1-7', () {
      expect(indiceCategoriaDelDia(DateTime(2026, 9, 7)), 1); // lunes
      expect(indiceCategoriaDelDia(DateTime(2026, 9, 13)), 7); // domingo
    });

    test('inicioSemana devuelve el lunes de la semana', () {
      final miercoles = DateTime(2026, 9, 16);
      final inicio = inicioSemana(miercoles);
      expect(inicio.weekday, 1);
      expect(inicio.day, 14);
    });

    test('claveSemana es estable para la misma semana', () {
      expect(
        claveSemana(DateTime(2026, 9, 14)),
        claveSemana(DateTime(2026, 9, 20)),
      );
      expect(
        claveSemana(DateTime(2026, 9, 14)),
        isNot(claveSemana(DateTime(2026, 9, 21))),
      );
    });

    test('esMismoDia compara solo fecha', () {
      expect(
        esMismoDia(DateTime(2026, 9, 13, 8, 30), DateTime(2026, 9, 13, 23, 59)),
        isTrue,
      );
    });

    test('esDiaConsecutivo detecta días seguidos', () {
      expect(
        esDiaConsecutivo(DateTime(2026, 9, 12), DateTime(2026, 9, 13)),
        isTrue,
      );
      expect(
        esDiaConsecutivo(DateTime(2026, 9, 11), DateTime(2026, 9, 13)),
        isFalse,
      );
    });

    test('esDiferenciaDeDias comprueba separación exacta', () {
      expect(
        esDiferenciaDeDias(
          DateTime(2026, 9, 6),
          DateTime(2026, 9, 13),
          dias: 7,
        ),
        isTrue,
      );
      expect(
        esDiferenciaDeDias(
          DateTime(2026, 9, 5),
          DateTime(2026, 9, 13),
          dias: 7,
        ),
        isFalse,
      );
    });

    test('fechaClave produce aaaa-mm-dd', () {
      expect(fechaClave(DateTime(2026, 9, 5)), '2026-09-05');
    });
  });

  // ---------------------------------------------------------------------------
  // Recompensas
  // ---------------------------------------------------------------------------

  group('Recompensas', () {
    test('calcularXp y calcularMonedas siguen la fórmula 150/150/15', () {
      expect(calcularXp(150), 150);
      expect(calcularMonedas(150), 15);
      expect(calcularXp(80), 80);
      expect(calcularMonedas(80), 8);
      expect(calcularXp(0), 0);
      expect(calcularMonedas(0), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // Racha
  // ---------------------------------------------------------------------------

  group('RachaDiario', () {
    test('registrarDiaCompletado incrementa solo si es día consecutivo', () {
      final lunes = DateTime(2026, 9, 7);

      var racha = RachaDiario();
      racha = racha.registrarDiaCompletado(lunes);
      expect(racha.actual, 1);

      // Mismo día: no vuelve a contar.
      racha = racha.registrarDiaCompletado(lunes);
      expect(racha.actual, 1);

      // Día siguiente: incrementa.
      final martes = DateTime(2026, 9, 8);
      racha = racha.registrarDiaCompletado(martes);
      expect(racha.actual, 2);

      // Hueco de un día: se reinicia a 1.
      final jueves = DateTime(2026, 9, 10);
      racha = racha.registrarDiaCompletado(jueves);
      expect(racha.actual, 1);

      expect(racha.mejor, 2);
      expect(racha.fechaUltimaCompletada, jueves);
    });

    test('serializa y restaura RachaDiario', () {
      final racha = RachaDiario(
        actual: 4,
        mejor: 7,
        fechaUltimaCompletada: DateTime(2026, 9, 12),
      );
      expect(RachaDiario.fromJson(racha.toJson()), racha);
    });
  });

  // ---------------------------------------------------------------------------
  // Dificultad por categoría
  // ---------------------------------------------------------------------------

  group('ProgresoCategoriaDiario', () {
    test('sube de dificultad tras kSemanas semanas completadas seguidas', () {
      var cat = ProgresoCategoriaDiario.inicial(
        categoriaId: 1,
        categoriaNombre: 'Lunes',
      );
      expect(cat.dificultad, DificultadTrivia.facil);

      final lunes1 = DateTime(2026, 9, 7);
      for (var i = 0; i < kSemanasParaSubirDificultad; i++) {
        cat = cat.registrarSemanaCompletada(
          DateTime(lunes1.year, lunes1.month, lunes1.day + i * 7),
        );
      }

      expect(cat.dificultad, DificultadTrivia.intermedia);
      expect(cat.cicloDificultad, 1);
      expect(cat.semanasCompletadasConsecutivas, 0);
    });

    test('no sube si la semana anterior no fue exactamente 7 días antes', () {
      var cat = ProgresoCategoriaDiario.inicial(
        categoriaId: 1,
        categoriaNombre: 'Lunes',
      );

      cat = cat.registrarSemanaCompletada(DateTime(2026, 9, 7)); // semana 1
      expect(cat.semanasCompletadasConsecutivas, 1);

      // 2 días después: rompe la contigüidad y vuelve a contar desde 1.
      cat = cat.registrarSemanaCompletada(DateTime(2026, 9, 9));
      expect(cat.semanasCompletadasConsecutivas, 1);

      // Hueco entre 09-09 y 09-12: tampoco suma.
      cat = cat.registrarSemanaCompletada(DateTime(2026, 9, 12));
      expect(cat.semanasCompletadasConsecutivas, 1);

      expect(cat.dificultad, DificultadTrivia.facil);
      expect(cat.cicloDificultad, 0);
    });

    test('registrarPartida acumula estadísticas y mejor puntuación', () {
      var cat = ProgresoCategoriaDiario.inicial(
        categoriaId: 1,
        categoriaNombre: 'Lunes',
      );
      cat = cat.registrarPartida(aciertos: 2, respuestas: 3, puntos: 120);
      expect(cat.totalPartidas, 1);
      expect(cat.totalAciertos, 2);
      expect(cat.totalRespuestas, 3);
      expect(cat.mejorPuntuacion, 120);
      expect(cat.porcentajeAciertos, (2 / 3 * 100).roundToDouble());

      cat = cat.registrarPartida(aciertos: 1, respuestas: 3, puntos: 60);
      expect(cat.totalPartidas, 2);
      expect(cat.mejorPuntuacion, 120);
    });
  });

  // ---------------------------------------------------------------------------
  // Sesión
  // ---------------------------------------------------------------------------

  group('SesionPreguntaDiaria', () {
    test('responder correcta otorga puntos y es resuelta', () {
      final p = _pregunta();
      final resuelta = p.responder(letra: 'A');
      expect(resuelta.esCorrecta, isTrue);
      expect(resuelta.puntosGanados, 50);
      expect(resuelta.resuelta, isTrue);
      expect(resuelta.respuestaLetra, 'A');
    });

    test('responder incorrecta no otorga puntos', () {
      final p = _pregunta();
      final resuelta = p.responder(letra: 'B');
      expect(resuelta.esCorrecta, isFalse);
      expect(resuelta.puntosGanados, 0);
      expect(resuelta.resuelta, isTrue);
    });

    test('marcarSinRespuesta marca resuelta sin puntos', () {
      final p = _pregunta();
      final resuelta = p.marcarSinRespuesta();
      expect(resuelta.resuelta, isTrue);
      expect(resuelta.esCorrecta, isFalse);
      expect(resuelta.puntosGanados, 0);
      expect(resuelta.respuestaLetra, isNull);
    });

    test('serializa y restaura SesionPreguntaDiaria', () {
      final p = _pregunta(triviaId: 7).responder(letra: 'C', ayudaUsada: 'Pista');
      expect(SesionPreguntaDiaria.fromJson(p.toJson()), p);
    });
  });

  group('SesionDiario', () {
    test('puntosTotales y completada dependen de las preguntas', () {
      final preguntas = [
        _pregunta(triviaId: 1, correcta: 'A').responder(letra: 'A'),
        _pregunta(triviaId: 2, correcta: 'B').marcarSinRespuesta(),
        _pregunta(triviaId: 3, correcta: 'C', puntosBase: 40)
            .responder(letra: 'C'),
      ];

      final sesion = SesionDiario(
        fecha: DateTime(2026, 9, 13),
        categoriaId: 1,
        dificultad: 'Facil',
        preguntas: preguntas,
      );

      expect(sesion.completada, isTrue);
      expect(sesion.enProgreso, isFalse);
      expect(sesion.puntosTotales, 90);
      expect(sesion.xpGanados, 90);
      expect(sesion.monedasGanadas, 9);
    });

    test('una sesión vacía no cuenta como completada', () {
      final sesion = SesionDiario(fecha: DateTime(2026, 9, 13));
      expect(sesion.completada, isFalse);
      expect(sesion.enProgreso, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Progreso diario
  // ---------------------------------------------------------------------------

  group('ProgresoDiario', () {
    test('diasCompletadosEnSemana cuenta las sesiones de la semana', () {
      var progreso = ProgresoDiario();
      final lunes = DateTime(2026, 9, 7);
      final miercoles = DateTime(2026, 9, 9);

      progreso = progreso.registrarSesion(_sesionCompletada(lunes, 1));
      progreso = progreso.registrarSesion(_sesionCompletada(miercoles, 3));

      expect(progreso.diasCompletadosEnSemana(lunes), 2);

      // La semana anterior queda fuera.
      expect(progreso.diasCompletadosEnSemana(DateTime(2026, 8, 31)), 0);
    });

    test('semanaCompletadaEn exige las 7 sesiones de la semana', () {
      var progreso = ProgresoDiario();
      final lunes = DateTime(2026, 9, 7);
      for (var i = 0; i < 7; i++) {
        progreso = progreso.registrarSesion(
          _sesionCompletada(
            DateTime(lunes.year, lunes.month, lunes.day + i),
            i + 1,
          ),
        );
      }
      expect(progreso.semanaCompletadaEn(lunes), isTrue);
      expect(progreso.diasCompletadosEnSemana(lunes), 7);
    });

    test('marcarSemanaRecompensada guarda la clave de la semana', () {
      final progreso = ProgresoDiario().marcarSemanaRecompensada(
        DateTime(2026, 9, 7),
      );
      expect(
        progreso.semanaUltimaRecompensada,
        claveSemana(DateTime(2026, 9, 7)),
      );
    });

    test('sesionDeDia devuelve null si no existe y la sesión si existe', () {
      final progreso = ProgresoDiario().registrarSesion(
        _sesionCompletada(DateTime(2026, 9, 13), 7),
      );
      expect(progreso.sesionDeDia(DateTime(2026, 9, 12)), isNull);
      expect(
        progreso.sesionDeDia(DateTime(2026, 9, 13))?.completada,
        isTrue,
      );
    });

    test('toJson/fromJson redondea el ciclo', () {
      final fecha = DateTime(2026, 9, 13);
      final sesion = _sesionCompletada(fecha, 7);
      final racha = RachaDiario(
        actual: 1,
        mejor: 1,
        fechaUltimaCompletada: fecha,
      );
      final progreso = ProgresoDiario(
        sesiones: {fechaClave(fecha): sesion},
        racha: racha,
        semanaUltimaRecompensada: claveSemana(fecha),
      );

      final restaurado = ProgresoDiario.fromJson(progreso.toJson());
      expect(restaurado.sesiones.keys, progreso.sesiones.keys);
      expect(
        restaurado.sesionDeDia(fecha)?.completada,
        isTrue,
      );
      expect(restaurado.semanaUltimaRecompensada, claveSemana(fecha));
      expect(restaurado.racha.actual, 1);
      expect(restaurado.racha.mejor, 1);
    });
  });
}