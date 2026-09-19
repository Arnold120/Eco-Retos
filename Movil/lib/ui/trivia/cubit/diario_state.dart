import 'package:equatable/equatable.dart';

import '../../../data/models/trivia/diario_models.dart';

/// Fases por las que pasa el flujo del Modo Diario.
enum DiarioStatus {
  /// Estado inicial antes de cargar.
  initial,

  /// Cargando datos iniciales.
  loading,

  /// Pantalla de introducción/espera lista para arrancar o reanudar.
  ready,

  /// Una pregunta está visible y se puede responder.
  questionActive,

  /// El usuario seleccionó una opción (feedback breve).
  answerSelected,

  /// La respuesta fue correcta.
  answerCorrect,

  /// La respuesta fue incorrecta.
  answerIncorrect,

  /// El tiempo de la pregunta se agotó.
  timeExpired,

  /// Partida del día finalizada, pantalla de resultados.
  completed,

  /// La trivia diaria de hoy ya fue completada.
  todayDone,

  /// No hay suficientes preguntas para la categoría/dificultad del día.
  sinPreguntas,

  /// Ocurrió un error recuperable.
  error,
}

/// Mensaje motivador según el porcentaje de aciertos de la partida.
String mensajePorDesempeno(double porcentaje) {
  if (porcentaje >= 100) return '🏆 ¡PERFECTO!';
  if (porcentaje >= 81) return '¡Excelente!';
  if (porcentaje >= 61) return '¡Muy bien!';
  if (porcentaje >= 41) return '¡Buen trabajo!';
  if (porcentaje >= 21) return 'Vas progresando';
  return '¡No te rindas!';
}

/// Resumen final de una partida diaria para la pantalla de resultados.
class ResultadoDiario extends Equatable {
  final int puntos;
  final int aciertos;
  final int totalPreguntas;
  final int xpGanados;
  final int monedasGanadas;
  final int rachaNueva;
  final int mejorRacha;
  final bool subioDificultad;
  final DificultadTrivia dificultadAnterior;
  final DificultadTrivia dificultadNueva;
  final bool semanaCompletada;
  final int xpSemana;
  final int monedasSemana;

  const ResultadoDiario({
    required this.puntos,
    required this.aciertos,
    required this.totalPreguntas,
    required this.xpGanados,
    required this.monedasGanadas,
    required this.rachaNueva,
    required this.mejorRacha,
    required this.subioDificultad,
    required this.dificultadAnterior,
    required this.dificultadNueva,
    required this.semanaCompletada,
    this.xpSemana = 0,
    this.monedasSemana = 0,
  });

  int get porcentaje => totalPreguntas == 0
      ? 0
      : (aciertos / totalPreguntas * 100).round();

  String get mensaje => mensajePorDesempeno(porcentaje.toDouble());

  @override
  List<Object?> get props => [
        puntos,
        aciertos,
        totalPreguntas,
        xpGanados,
        monedasGanadas,
        rachaNueva,
        mejorRacha,
        subioDificultad,
        dificultadAnterior,
        dificultadNueva,
        semanaCompletada,
        xpSemana,
        monedasSemana,
      ];
}

/// Estado inmutable del flujo del Modo Diario.
class DiarioState extends Equatable {
  final DiarioStatus status;
  final bool isLoading;
  final String? error;

  /// Día actual (a medianoche) sobre el que se juega.
  final DateTime hoy;
  final int categoriaId;
  final String categoriaNombre;
  final DificultadTrivia dificultad;
  final int cicloDificultad;
  final int semanasCompletadasConsecutivas;

  final List<SesionPreguntaDiaria> preguntas;
  final int preguntaActualIndex;
  final String? opcionSeleccionada;
  final Set<String> opcionesEliminadas;
  final Duration tiempoRestante;
  final bool esCorrecta;
  final bool tiempoAgotado;
  final String? respuestaCorrectaTexto;
  final int puntos;
  final int respuestasCorrectas;

  final ProgresoDiario progreso;
  final int monedasDisponibles;
  final bool reanudando;
  final ResultadoDiario? resultado;

  /// La recompensa de la partida del día ya fue reclamada (entrega única).
  final bool recompensaReclamada;

  /// Hay un reclamo de recompensas en curso (estado del botón).
  final bool recompensaReclamando;

  const DiarioState({
    this.status = DiarioStatus.initial,
    this.isLoading = false,
    this.error,
    required this.hoy,
    this.categoriaId = 0,
    this.categoriaNombre = '',
    this.dificultad = DificultadTrivia.facil,
    this.cicloDificultad = 0,
    this.semanasCompletadasConsecutivas = 0,
    this.preguntas = const [],
    this.preguntaActualIndex = 0,
    this.opcionSeleccionada,
    this.opcionesEliminadas = const {},
    this.tiempoRestante = kTiempoPorPreguntaDiario,
    this.esCorrecta = false,
    this.tiempoAgotado = false,
    this.respuestaCorrectaTexto,
    this.puntos = 0,
    this.respuestasCorrectas = 0,
    this.progreso = const ProgresoDiario(),
    this.monedasDisponibles = 0,
    this.reanudando = false,
    this.resultado,
    this.recompensaReclamada = false,
    this.recompensaReclamando = false,
  });

  factory DiarioState.inicial({DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    final hoyMidnight = DateTime(ahora.year, ahora.month, ahora.day);
    return DiarioState(hoy: hoyMidnight);
  }

  SesionPreguntaDiaria? get preguntaActual =>
      preguntas.isEmpty ? null : preguntas[preguntaActualIndex];

  int get totalPreguntas => preguntas.length;

  bool get enFeedback =>
      status == DiarioStatus.answerCorrect ||
      status == DiarioStatus.answerIncorrect ||
      status == DiarioStatus.timeExpired;

  double get progresoBarra =>
      totalPreguntas == 0 ? 0 : (preguntaActualIndex + 1) / totalPreguntas;

  int get rachaEfectiva => rachaEfectivaDiaria(progreso, hoy);

  int get mejorRacha => progreso.racha.mejor;

  int get diasCompletadosSemana => progreso.diasCompletadosEnSemana(hoy);

  bool get semanaCompletada => progreso.semanaCompletadaEn(hoy);

  bool get hoyCompletado {
    final sesion = progreso.sesionDeDia(hoy);
    return sesion != null && sesion.completada;
  }

  bool get recompensaPendiente =>
      (status == DiarioStatus.completed || status == DiarioStatus.todayDone) &&
      !recompensaReclamada;

  bool get puedeReclamar =>
      (status == DiarioStatus.completed || status == DiarioStatus.todayDone) &&
      !recompensaReclamada &&
      !recompensaReclamando;

  String get respuestaCorrectaDeActual =>
      preguntaActual?.opciones[preguntaActual?.respuestaCorrecta] ?? '';

  DiarioState copyWith({
    DiarioStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
    DateTime? hoy,
    int? categoriaId,
    String? categoriaNombre,
    DificultadTrivia? dificultad,
    int? cicloDificultad,
    int? semanasCompletadasConsecutivas,
    List<SesionPreguntaDiaria>? preguntas,
    int? preguntaActualIndex,
    String? opcionSeleccionada,
    bool limpiarOpcion = false,
    Set<String>? opcionesEliminadas,
    bool limpiarEliminadas = false,
    Duration? tiempoRestante,
    bool limpiarTiempo = false,
    bool? esCorrecta,
    bool? tiempoAgotado,
    String? respuestaCorrectaTexto,
    bool limpiarFeedback = false,
    int? puntos,
    int? respuestasCorrectas,
    bool resetPuntos = false,
    ProgresoDiario? progreso,
    int? monedasDisponibles,
    bool? reanudando,
    ResultadoDiario? resultado,
    bool? recompensaReclamada,
    bool? recompensaReclamando,
  }) {
    return DiarioState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hoy: hoy ?? this.hoy,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      dificultad: dificultad ?? this.dificultad,
      cicloDificultad: cicloDificultad ?? this.cicloDificultad,
      semanasCompletadasConsecutivas:
          semanasCompletadasConsecutivas ??
              this.semanasCompletadasConsecutivas,
      preguntas: preguntas ?? this.preguntas,
      preguntaActualIndex: preguntaActualIndex ?? this.preguntaActualIndex,
      opcionSeleccionada: limpiarOpcion
          ? null
          : (opcionSeleccionada ?? this.opcionSeleccionada),
      opcionesEliminadas: limpiarEliminadas
          ? const {}
          : (opcionesEliminadas ?? this.opcionesEliminadas),
      tiempoRestante: limpiarTiempo
          ? kTiempoPorPreguntaDiario
          : (tiempoRestante ?? this.tiempoRestante),
      esCorrecta: esCorrecta ?? this.esCorrecta,
      tiempoAgotado: tiempoAgotado ?? this.tiempoAgotado,
      respuestaCorrectaTexto: limpiarFeedback
          ? null
          : (respuestaCorrectaTexto ?? this.respuestaCorrectaTexto),
      puntos: resetPuntos ? 0 : (puntos ?? this.puntos),
      respuestasCorrectas:
          resetPuntos ? 0 : (respuestasCorrectas ?? this.respuestasCorrectas),
      progreso: progreso ?? this.progreso,
      monedasDisponibles: monedasDisponibles ?? this.monedasDisponibles,
      reanudando: reanudando ?? this.reanudando,
      resultado: resultado ?? this.resultado,
      recompensaReclamada: recompensaReclamada ?? this.recompensaReclamada,
      recompensaReclamando: recompensaReclamando ?? this.recompensaReclamando,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoading,
        error,
        hoy,
        categoriaId,
        categoriaNombre,
        dificultad,
        cicloDificultad,
        semanasCompletadasConsecutivas,
        preguntas,
        preguntaActualIndex,
        opcionSeleccionada,
        opcionesEliminadas,
        tiempoRestante,
        esCorrecta,
        tiempoAgotado,
        respuestaCorrectaTexto,
        puntos,
        respuestasCorrectas,
        progreso,
        monedasDisponibles,
        reanudando,
        resultado,
        recompensaReclamada,
        recompensaReclamando,
      ];
}