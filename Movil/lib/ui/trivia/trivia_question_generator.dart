import 'dart:math';

import '../../../data/models/trivia/trivia_models.dart';

/// Pregunta generada por [GeneradorPreguntaTrivia] a partir de los registros
/// de la tabla `Trivia`.
///
/// `opciones` contiene las 4 opciones etiquetadas con A, B, C y D.
/// `respuestaCorrecta` contiene únicamente la letra de la opción correcta.
class TriviaPreguntaGenerada {
  final int triviaId;
  final String pregunta;
  final int categoriaId;
  final String dificultad;
  final int puntos;
  final Map<String, String> opciones;
  final String respuestaCorrecta;

  const TriviaPreguntaGenerada({
    required this.triviaId,
    required this.pregunta,
    required this.categoriaId,
    required this.dificultad,
    required this.puntos,
    required this.opciones,
    required this.respuestaCorrecta,
  });

  String get respuestaCorrectaTexto =>
      opciones[respuestaCorrecta] ?? opciones.values.first;

  List<String> get opcionesLista =>
      const ['A', 'B', 'C', 'D'].map((letra) => opciones[letra] ?? '').toList();

  bool esLetraCorrecta(String letra) => letra == respuestaCorrecta;
}

/// Generador de preguntas de opción múltiple basado en la tabla `Trivia`.
///
/// Implementa las reglas:
/// * Solo registros con `Estado` ACTIVA, filtrados por categoría/dificultad y
///   excluyendo las preguntas ya utilizadas.
/// * La respuesta correcta es siempre `Descripcion`.
/// * Los distractores provienen de `Descripcion` de otros registros de la
///   MISMA categoría, priorizando la misma dificultad.
/// * Sin opciones duplicadas ni equivalentes a la correcta.
/// * Exactamente 4 opciones con la posición de la correcta aleatorizada.
class GeneradorPreguntaTrivia {
  static const int opcionesPorPregunta = 4;

  const GeneradorPreguntaTrivia();

  /// Genera una pregunta con sus 4 opciones. Devuelve `null` si no existen
  /// suficientes registros compatibles para construir una pregunta válida.
  TriviaPreguntaGenerada? generarPregunta({
    required List<TriviaResponse> registros,
    int? categoriaId,
    String? dificultad,
    Set<int>? yaUtilizadas,
    Random? random,
  }) {
    final rng = random ?? Random();
    final dificultadNormalizada = dificultad?.trim().toLowerCase();
    final utilizadas = yaUtilizadas ?? const <int>{};

    final activas = registros
        .where((r) => r.estado.trim().toLowerCase() == 'activa')
        .toList();

    final elegibles = activas.where((r) {
      if (categoriaId != null && r.categoriaId != categoriaId) return false;
      if (dificultadNormalizada != null &&
          r.dificultad.trim().toLowerCase() != dificultadNormalizada) {
        return false;
      }
      if (utilizadas.contains(r.triviaId)) return false;
      return true;
    }).toList();

    if (elegibles.isEmpty) return null;

    elegibles.shuffle(rng);

    for (final seleccionada in elegibles) {
      final correcta = seleccionada.descripcion.trim();
      if (correcta.isEmpty) continue;

      final distractores = _buscarDistractores(
        registros: activas,
        seleccionada: seleccionada,
        correcta: correcta,
        random: rng,
      );
      if (distractores == null) continue;

      final opciones = <String>[correcta, ...distractores];
      opciones.shuffle(rng);

      final mapa = <String, String>{
        for (var i = 0; i < opciones.length; i++)
          String.fromCharCode(65 + i): opciones[i],
      };

      String? letraCorrecta;
      for (final entrada in mapa.entries) {
        if (entrada.value == correcta) letraCorrecta = entrada.key;
      }

      if (letraCorrecta == null) continue;

      final generada = TriviaPreguntaGenerada(
        triviaId: seleccionada.triviaId,
        pregunta: seleccionada.titulo,
        categoriaId: seleccionada.categoriaId,
        dificultad: seleccionada.dificultad,
        puntos: seleccionada.puntosMaximos,
        opciones: mapa,
        respuestaCorrecta: letraCorrecta,
      );

      if (_validar(
        generada,
        categoriaSolicitada: categoriaId,
        correctaEsperada: correcta,
      )) {
        return generada;
      }
    }

    return null;
  }

  /// Busca hasta 3 distractores válidos en la MISMA categoría, priorizando la
  /// misma dificultad. Devuelve `null` si no se alcanzan suficientes.
  List<String>? _buscarDistractores({
    required List<TriviaResponse> registros,
    required TriviaResponse seleccionada,
    required String correcta,
    required Random random,
  }) {
    final candidatos = registros.where((r) {
      if (r.categoriaId != seleccionada.categoriaId) return false;
      if (r.triviaId == seleccionada.triviaId) return false;
      return true;
    }).toList();

    final mismaDificultad = <TriviaResponse>[];
    final otraDificultad = <TriviaResponse>[];
    for (final r in candidatos) {
      if (r.descripcion.trim().isEmpty) continue;
      if (r.dificultad.trim().toLowerCase() ==
          seleccionada.dificultad.trim().toLowerCase()) {
        mismaDificultad.add(r);
      } else {
        otraDificultad.add(r);
      }
    }

    mismaDificultad.shuffle(random);
    otraDificultad.shuffle(random);

    final seleccionados = <String>[];
    for (final pool in [mismaDificultad, otraDificultad]) {
      for (final candidato in pool) {
        if (seleccionados.length >= opcionesPorPregunta - 1) break;
        final texto = candidato.descripcion.trim();
        if (_esEquivalente(texto, correcta)) continue;
        if (seleccionados.any((s) => _esEquivalente(texto, s))) continue;
        seleccionados.add(texto);
      }
      if (seleccionados.length >= opcionesPorPregunta - 1) break;
    }

    if (seleccionados.length < opcionesPorPregunta - 1) return null;
    return seleccionados.take(opcionesPorPregunta - 1).toList();
  }

  static const _letras = ['A', 'B', 'C', 'D'];

  /// Comprobaciones finales (CHECK 1-8).
  bool _validar(
    TriviaPreguntaGenerada generada, {
    int? categoriaSolicitada,
    required String correctaEsperada,
  }) {
    if (generada.opciones.length != opcionesPorPregunta) return false;
    if (categoriaSolicitada != null &&
        generada.categoriaId != categoriaSolicitada) {
      return false;
    }

    final valores = _letras.map((l) => generada.opciones[l]).toList();
    if (valores.any((v) => v == null || v.isEmpty)) return false;

    if (valores.toSet().length != opcionesPorPregunta) return false;

    final coincidencias = valores
        .where((v) => v != null && _esEquivalente(v, correctaEsperada))
        .length;
    if (coincidencias != 1) return false;

    if (generada.opciones[generada.respuestaCorrecta] != correctaEsperada) {
      return false;
    }

    final correctaEnMapa = _letras
        .where(
          (l) =>
              generada.opciones[l] != null &&
              _esEquivalente(generada.opciones[l]!, correctaEsperada),
        )
        .toList();
    if (correctaEnMapa.length != 1 ||
        correctaEnMapa.first != generada.respuestaCorrecta) {
      return false;
    }

    for (final letra in _letras) {
      if (letra == generada.respuestaCorrecta) continue;
      if (generada.opciones[letra] != null &&
          _esEquivalente(generada.opciones[letra]!, correctaEsperada)) {
        return false;
      }
    }

    return true;
  }

  /// Compara dos textos ignorando mayúsculas, espacios redundantes y tildes.
  /// Devuelve verdadero cuando son iguales o esencialmente iguales.
  static bool _esEquivalente(String a, String b) {
    final na = _normalizar(a);
    final nb = _normalizar(b);
    if (na == nb) return true;
    if (na.isEmpty || nb.isEmpty) return false;
    return _similitud(na, nb) >= 0.92;
  }

  static String _normalizar(String texto) {
    final sinTildes = texto
        .toLowerCase()
        .replaceAll(RegExp(r'[\u00e1\u00e0\u00e2\u00e3\u00e4]'), 'a')
        .replaceAll(RegExp(r'[\u00e9\u00e8\u00ea\u00eb]'), 'e')
        .replaceAll(RegExp(r'[\u00ed\u00ec\u00ee\u00ef]'), 'i')
        .replaceAll(RegExp(r'[\u00f3\u00f2\u00f4\u00f5\u00f6]'), 'o')
        .replaceAll(RegExp(r'[\u00fa\u00f9\u00fb\u00fc]'), 'u')
        .replaceAll(RegExp(r'[\u00f1]'), 'n');
    return sinTildes
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll(
          RegExp(r'[.,;:!?\u0022\u0027\u201c\u201d\u2018\u2019\u00ab\u00bb]'),
          '',
        );
  }

  /// Similitud de Levenshtein normalizada (0..1).
  static double _similitud(String a, String b) {
    if (a == b) return 1;
    final maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1;
    return 1 - _levenshtein(a, b) / maxLen;
  }

  static int _levenshtein(String a, String b) {
    final dp = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1]
            : 1 + min(dp[i - 1][j], min(dp[i][j - 1], dp[i - 1][j - 1]));
      }
    }
    return dp[a.length][b.length];
  }

  /// Genera un lote de hasta [cantidad] preguntas válidas y sin repetir entre
  /// sí. Cada pregunta consume el material de distractores propio de su
  /// categoría, por lo que el lote devuelve las preguntas que sea posible
  /// construir (mínimo 1); si ninguna es construible devuelve lista vacía.
  List<TriviaPreguntaGenerada> generarLote({
    required List<TriviaResponse> registros,
    int? categoriaId,
    String? dificultad,
    int cantidad = 10,
    Set<int>? yaUtilizadas,
    Random? random,
  }) {
    final rng = random ?? Random();
    final utilizadas = {...?yaUtilizadas};
    final lote = <TriviaPreguntaGenerada>[];
    for (var i = 0; i < cantidad; i++) {
      final pregunta = generarPregunta(
        registros: registros,
        categoriaId: categoriaId,
        dificultad: dificultad,
        yaUtilizadas: utilizadas,
        random: rng,
      );
      if (pregunta == null) break;
      lote.add(pregunta);
      utilizadas.add(pregunta.triviaId);
    }
    return lote;
  }
}
