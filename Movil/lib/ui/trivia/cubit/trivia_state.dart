import 'package:equatable/equatable.dart';

import '../../../data/models/trivia/trivia_models.dart';
import '../../../data/models/challenge/challenge_models.dart';

enum TriviaScreenMode { list, playing, results }

class TriviaState extends Equatable {
  final TriviaScreenMode mode;
  final List<TriviaResponse> trivias;
  final List<CategoriaResponse> categorias;
  final int? categoriaSeleccionada;
  final TriviaResponse? triviaActual;
  final List<PreguntaResponse> preguntas;
  final int preguntaActualIndex;
  final int? opcionSeleccionada;
  final bool? respuestaCorrecta;
  final bool showingFeedback;
  final bool? ultimaRespuestaCorrecta;
  final String? respuestaCorrectaTexto;
  final int xpGanados;
  final int monedasGanadas;
  final int puntuacion;
  final int respuestasCorrectas;
  final int totalPreguntas;
  final IntentoTriviaResponse? intentoActual;
  final bool isLoading;
  final String? error;

  const TriviaState({
    this.mode = TriviaScreenMode.list,
    this.trivias = const [],
    this.categorias = const [],
    this.categoriaSeleccionada,
    this.triviaActual,
    this.preguntas = const [],
    this.preguntaActualIndex = 0,
    this.opcionSeleccionada,
    this.respuestaCorrecta,
    this.showingFeedback = false,
    this.ultimaRespuestaCorrecta,
    this.respuestaCorrectaTexto,
    this.xpGanados = 0,
    this.monedasGanadas = 0,
    this.puntuacion = 0,
    this.respuestasCorrectas = 0,
    this.totalPreguntas = 0,
    this.intentoActual,
    this.isLoading = false,
    this.error,
  });

  List<TriviaResponse> get triviasFiltradas {
    if (categoriaSeleccionada == null) return trivias;
    return trivias
        .where((t) => t.categoriaId == categoriaSeleccionada)
        .toList();
  }

  PreguntaResponse? get preguntaActual {
    if (preguntaActualIndex < preguntas.length) {
      return preguntas[preguntaActualIndex];
    }
    return null;
  }

  bool get esUltimaPregunta => preguntaActualIndex >= preguntas.length - 1;

  TriviaState copyWith({
    TriviaScreenMode? mode,
    List<TriviaResponse>? trivias,
    List<CategoriaResponse>? categorias,
    int? categoriaSeleccionada,
    TriviaResponse? triviaActual,
    List<PreguntaResponse>? preguntas,
    int? preguntaActualIndex,
    int? opcionSeleccionada,
    bool? respuestaCorrecta,
    bool? showingFeedback,
    bool? ultimaRespuestaCorrecta,
    String? respuestaCorrectaTexto,
    int? xpGanados,
    int? monedasGanadas,
    int? puntuacion,
    int? respuestasCorrectas,
    int? totalPreguntas,
    IntentoTriviaResponse? intentoActual,
    bool? isLoading,
    String? error,
    bool clearCategoria = false,
    bool clearOpcion = false,
  }) {
    return TriviaState(
      mode: mode ?? this.mode,
      trivias: trivias ?? this.trivias,
      categorias: categorias ?? this.categorias,
      categoriaSeleccionada: clearCategoria
          ? null
          : (categoriaSeleccionada ?? this.categoriaSeleccionada),
      triviaActual: triviaActual ?? this.triviaActual,
      preguntas: preguntas ?? this.preguntas,
      preguntaActualIndex: preguntaActualIndex ?? this.preguntaActualIndex,
      opcionSeleccionada: clearOpcion
          ? null
          : (opcionSeleccionada ?? this.opcionSeleccionada),
      respuestaCorrecta: respuestaCorrecta,
      showingFeedback: showingFeedback ?? this.showingFeedback,
      ultimaRespuestaCorrecta:
          ultimaRespuestaCorrecta ?? this.ultimaRespuestaCorrecta,
      respuestaCorrectaTexto:
          respuestaCorrectaTexto ?? this.respuestaCorrectaTexto,
      xpGanados: xpGanados ?? this.xpGanados,
      monedasGanadas: monedasGanadas ?? this.monedasGanadas,
      puntuacion: puntuacion ?? this.puntuacion,
      respuestasCorrectas: respuestasCorrectas ?? this.respuestasCorrectas,
      totalPreguntas: totalPreguntas ?? this.totalPreguntas,
      intentoActual: intentoActual ?? this.intentoActual,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    trivias,
    categorias,
    categoriaSeleccionada,
    triviaActual,
    preguntas,
    preguntaActualIndex,
    opcionSeleccionada,
    respuestaCorrecta,
    showingFeedback,
    ultimaRespuestaCorrecta,
    respuestaCorrectaTexto,
    xpGanados,
    monedasGanadas,
    puntuacion,
    respuestasCorrectas,
    totalPreguntas,
    intentoActual,
    isLoading,
    error,
  ];
}
