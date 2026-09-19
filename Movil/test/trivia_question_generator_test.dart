import 'dart:math';

import 'package:eco_reto/data/models/trivia/trivia_models.dart';
import 'package:eco_reto/ui/trivia/trivia_question_generator.dart';
import 'package:flutter_test/flutter_test.dart';

TriviaResponse _registro(
  int id,
  int categoriaId,
  String descripcion, {
  String dificultad = 'Facil',
  int puntos = 10,
  String estado = 'ACTIVA',
}) {
  return TriviaResponse(
    triviaId: id,
    categoriaId: categoriaId,
    nombreCategoria: 'Categoria $categoriaId',
    titulo: '¿Qué es $descripcion?',
    descripcion: descripcion,
    dificultad: dificultad,
    puntosMaximos: puntos,
    estado: estado,
  );
}

void main() {
  const generador = GeneradorPreguntaTrivia();
  final rng = Random(42);

  final respuestasDistintas = [
    'Reciclaje de plástico',
    'Compostaje orgánico',
    'Ahorro de energía',
    'Reutilización de envases',
    'Separación de residuos',
    'Movilidad sostenible',
    'Cuidado del agua',
    'Reforestación urbana',
    'Energía renovable',
    'Consumo responsable',
  ];
  final registrosDistintos = [
    for (var i = 0; i < respuestasDistintas.length; i++)
      _registro(i, 1, respuestasDistintas[i]),
  ];

  group('GeneradorPreguntaTrivia', () {
    test('genera una pregunta con exactamente 4 opciones únicas', () {
      final pregunta = generador.generarPregunta(
        registros: registrosDistintos,
        random: rng,
      );

      expect(pregunta, isNotNull);
      expect(pregunta!.opciones.length, 4);
      expect(pregunta.opciones.values.toSet().length, 4);
      expect(pregunta.opciones.keys.toSet(), {'A', 'B', 'C', 'D'});
      expect(['A', 'B', 'C', 'D'], contains(pregunta.respuestaCorrecta));
      expect(pregunta.opciones[pregunta.respuestaCorrecta], isNotNull);
    });

    test('la respuesta correcta coincide con Descripcion del registro', () {
      final registros = [
        _registro(1, 1, 'Reciclaje de plástico'),
        _registro(2, 1, 'Compostaje orgánico'),
        _registro(3, 1, 'Ahorro de energía'),
        _registro(4, 1, 'Reutilización de envases'),
        _registro(5, 1, 'Separación de residuos'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        random: rng,
      );

      expect(pregunta, isNotNull);
      final p = pregunta!;
      final seleccionado = registros.firstWhere(
        (r) => r.triviaId == p.triviaId,
      );
      expect(p.pregunta, '¿Qué es ${seleccionado.descripcion}?');
      expect(p.opciones[p.respuestaCorrecta], seleccionado.descripcion);
      for (final letra in p.opciones.keys) {
        if (letra != p.respuestaCorrecta) {
          expect(p.opciones[letra], isNot(seleccionado.descripcion));
        }
      }
    });

    test('solo usa registros con Estado ACTIVA', () {
      final registros = [
        _registro(1, 1, 'Reciclaje de plástico', estado: 'ACTIVA'),
        _registro(2, 1, 'Compostaje orgánico', estado: 'ACTIVA'),
        _registro(3, 1, 'Ahorro de energía', estado: 'ACTIVA'),
        _registro(4, 1, 'Reutilización de envases', estado: 'ACTIVA'),
        _registro(5, 1, 'Opción inactiva', estado: 'INACTIVA'),
        _registro(6, 1, 'Opción suspendida', estado: 'SUSPENDIDA'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        random: rng,
      );

      expect(pregunta, isNotNull);
      final valores = pregunta!.opciones.values;
      expect(valores, isNot(contains('Opción inactiva')));
      expect(valores, isNot(contains('Opción suspendida')));
    });

    test('filtra por categoría solicitada', () {
      final registros = [
        _registro(1, 1, 'Cat 1 reciclaje'),
        _registro(2, 1, 'Cat 1 compostaje'),
        _registro(3, 1, 'Cat 1 reutilización'),
        _registro(4, 1, 'Cat 1 cuidado del agua'),
        _registro(5, 2, 'Cat 2 ahorro de energía'),
        _registro(6, 2, 'Cat 2 movilidad sostenible'),
        _registro(7, 2, 'Cat 2 reforestación'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        categoriaId: 1,
        random: rng,
      );

      expect(pregunta, isNotNull);
      expect(pregunta!.categoriaId, 1);
      for (final valor in pregunta.opciones.values) {
        expect(valor.startsWith('Cat 1 '), isTrue);
      }
    });

    test('filtra por dificultad solicitada', () {
      final registros = [
        _registro(1, 1, 'Reciclaje de plástico', dificultad: 'Facil'),
        _registro(2, 1, 'Compostaje orgánico', dificultad: 'Facil'),
        _registro(3, 1, 'Ahorro de energía', dificultad: 'Facil'),
        _registro(4, 1, 'Reutilización de envases', dificultad: 'Facil'),
        _registro(5, 1, 'Bioenergía avanzada', dificultad: 'Dificil'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        dificultad: 'Facil',
        random: rng,
      );

      expect(pregunta, isNotNull);
      expect(pregunta!.dificultad, 'Facil');
      for (final valor in pregunta.opciones.values) {
        expect(valor, isNot('Bioenergía avanzada'));
      }
    });

    test('excluye preguntas ya utilizadas', () {
      final usadas = <int>{};
      for (var i = 0; i < 4; i++) {
        final pregunta = generador.generarPregunta(
          registros: registrosDistintos,
          yaUtilizadas: usadas,
          random: Random(i),
        );
        expect(pregunta, isNotNull);
        usadas.add(pregunta!.triviaId);
      }

      expect(usadas.length, 4);
    });

    test('prioriza distractores de la misma dificultad', () {
      final registros = [
        _registro(1, 1, 'Vidrio', dificultad: 'Facil'),
        _registro(2, 1, 'Papel y cartón', dificultad: 'Facil'),
        _registro(3, 1, 'Envases plásticos', dificultad: 'Facil'),
        _registro(4, 1, 'Residuos orgánicos', dificultad: 'Facil'),
        _registro(5, 1, 'Poliuretano rígido', dificultad: 'Dificil'),
        _registro(6, 1, 'Hormigón reforzado', dificultad: 'Dificil'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        categoriaId: 1,
        random: rng,
      );

      expect(pregunta, isNotNull);
      final correcta = pregunta!.opciones[pregunta.respuestaCorrecta]!;
      final distractores = pregunta.opciones.values
          .where((v) => v != correcta)
          .toList();
      expect(distractores, hasLength(3));

      final seleccionado = registros.firstWhere(
        (r) => r.triviaId == pregunta.triviaId,
      );
      final mismosEnCategoria = registros
          .where(
            (r) =>
                r.categoriaId == seleccionado.categoriaId &&
                r.dificultad == seleccionado.dificultad,
          )
          .length;
      final esperados = min(3, mismosEnCategoria - 1);

      final distractoresMismaDificultad = distractores
          .where(
            (d) => registros.any(
              (r) =>
                  r.dificultad == seleccionado.dificultad && r.descripcion == d,
            ),
          )
          .length;
      expect(distractoresMismaDificultad, esperados);
    });

    test('rechaza opciones equivalentes por mayúsculas, espacios y tildes', () {
      final registros = [
        _registro(1, 1, 'Reciclaje de plástico'),
        _registro(2, 1, 'RECICLAJE   DE PLASTICO'),
        _registro(3, 1, 'reciclaje de plástico.'),
        _registro(4, 1, 'Ahorro de energía'),
        _registro(5, 1, 'Ahorro  de  energía'),
        _registro(6, 1, 'Separación de residuos'),
        _registro(7, 1, 'separación de residuos'),
        _registro(8, 1, 'Compostaje'),
        _registro(9, 1, 'Reutilización'),
        _registro(10, 1, 'Movilidad sostenible'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        random: rng,
      );

      expect(pregunta, isNotNull);
      final valores = [...pregunta!.opciones.values];

      expect(
        valores.where((v) => v.toLowerCase().contains('reciclaje')).length,
        lessThanOrEqualTo(1),
      );
      expect(
        valores.where((v) => v.toLowerCase().contains('ahorro')).length,
        lessThanOrEqualTo(1),
      );
      expect(
        valores.where((v) => v.toLowerCase().contains('separación')).length,
        lessThanOrEqualTo(1),
      );
      expect(valores.toSet().length, 4);
    });

    test('ningún distractor es equivalente a la respuesta correcta', () {
      final registros = [
        _registro(1, 1, 'Reciclaje de plástico'),
        _registro(2, 1, 'Compostaje orgánico'),
        _registro(3, 1, 'Ahorro de energía'),
        _registro(4, 1, 'Reutilización de envases'),
        _registro(5, 1, 'Separación de residuos'),
      ];

      final pregunta = generador.generarPregunta(
        registros: registros,
        random: rng,
      );

      expect(pregunta, isNotNull);
      final correcta = pregunta!.opciones[pregunta.respuestaCorrecta]!;
      expect(correcta, isNotNull);
      for (final letra in pregunta.opciones.keys) {
        if (letra != pregunta.respuestaCorrecta) {
          expect(pregunta.opciones[letra], isNot(correcta));
        }
      }
    });

    test('la posición de la respuesta correcta es aleatoria', () {
      final posicionesCorrectas = <String>{};
      for (var i = 0; i < 30; i++) {
        final pregunta = generador.generarPregunta(
          registros: registrosDistintos,
          random: Random(i),
        );
        expect(pregunta, isNotNull);
        posicionesCorrectas.add(pregunta!.respuestaCorrecta);
      }

      expect(
        posicionesCorrectas.length,
        greaterThan(1),
        reason: 'La respuesta correcta no debe caer siempre en la misma letra',
      );
    });

    test(
      'devuelve null si no hay suficientes distractores en la categoría',
      () {
        final registros = [
          _registro(1, 1, 'Único registro'),
          _registro(2, 2, 'Otra categoría A'),
          _registro(3, 2, 'Otra categoría B'),
        ];

        final pregunta = generador.generarPregunta(
          registros: registros,
          categoriaId: 1,
          random: rng,
        );

        expect(pregunta, isNull);
      },
    );

    test('devuelve null cuando no hay registros compatibles', () {
      final pregunta = generador.generarPregunta(registros: [], random: rng);

      expect(pregunta, isNull);
    });

    test('devuelve null cuando el registro utilizado cae sin reemplazo', () {
      final registros = [
        _registro(1, 1, 'Reciclaje de plástico'),
        _registro(2, 1, 'Compostaje orgánico'),
        _registro(3, 1, 'Ahorro de energía'),
        _registro(4, 1, 'Reutilización de envases'),
      ];

      expect(
        generador.generarPregunta(registros: registros, random: rng),
        isNotNull,
      );
      expect(
        generador.generarPregunta(
          registros: registros,
          random: rng,
          yaUtilizadas: const {1, 2, 3, 4},
        ),
        isNull,
      );
    });
  });

  group('generarLote', () {
    final frasesDistintas = [
      'Separación de residuos',
      'Reciclaje de latas',
      'Ahorro de electricidad',
      'Reutilización de botellas',
      'Compostaje en casa',
      'Huertos urbanos',
      'Carga de batería solar',
      'Ventanales de bajo consumo',
      'Recolección de lluvia',
      'Focos LED eficientes',
      'Riego por goteo',
      'Papel Kraft reciclado',
      'Vidrio triturado',
      'Cableado ecológico',
      'Paneles fotovoltaicos',
      'Termos de agua',
      'Bolsas de tela',
      'Vajilla renovable',
      'Madera certificada',
      'Plásticos biodegradables',
      'Cerámica sustentable',
      'Textiles orgánicos',
      'Metal recuperado',
      'Eco ladrillos verdes',
    ];
    final registrosAmplios = List.generate(
      24,
      (i) => _registro(i + 1, (i % 3) + 1, frasesDistintas[i]),
    );

    test('genera hasta el máximo solicitado sin repetir preguntas', () {
      final lote = generador.generarLote(
        registros: registrosAmplios,
        cantidad: 10,
        random: rng,
      );

      expect(lote, hasLength(10));
      final ids = lote.map((p) => p.triviaId).toSet();
      expect(ids, hasLength(10));
      for (final pregunta in lote) {
        expect(pregunta.opcionesLista, hasLength(4));
        expect(pregunta.opcionesLista.toSet(), hasLength(4));
      }
    });

    test('limita el lote al material disponible', () {
      final pocos = [
        _registro(1, 1, 'Única pregunta disponible uno'),
        _registro(2, 1, 'Única pregunta disponible dos'),
        _registro(3, 1, 'Única pregunta disponible tres'),
        _registro(4, 1, 'Única pregunta disponible cuatro'),
        _registro(5, 2, 'Otra categoría A'),
        _registro(6, 2, 'Otra categoría B'),
        _registro(7, 2, 'Otra categoría C'),
        _registro(8, 2, 'Otra categoría D'),
      ];

      final lote = generador.generarLote(
        registros: pocos,
        categoriaId: 1,
        cantidad: 5,
        random: rng,
      );

      expect(lote, hasLength(4));
      for (final pregunta in lote) {
        expect(pregunta.categoriaId, 1);
      }
      expect(lote.map((p) => p.triviaId).toSet(), hasLength(4));
    });

    test('devuelve lista vacía cuando no hay preguntas construibles', () {
      final lote = generador.generarLote(
        registros: [_registro(1, 1, 'Solo un único registro')],
        cantidad: 5,
        random: rng,
      );

      expect(lote, isEmpty);
    });
  });
}
