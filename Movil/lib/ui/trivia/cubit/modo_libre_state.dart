import 'package:equatable/equatable.dart';

import '../../../data/models/challenge/challenge_models.dart';
import '../trivia_question_generator.dart';

/// Fases por las que pasa el flujo de Modo Libre.
enum ModoLibreStatus {
  /// Precarga de categorías y preguntas al abrir la pantalla.
  cargando,

  /// Pantalla de configuración de la partida.
  configurando,

  /// Una pregunta está visible y se puede responder.
  jugando,

  /// La pregunta fue respondida o el tiempo se agotó: se muestra el feedback.
  retroalimentacion,

  /// Partida terminada, pantalla de resultados.
  resultados,

  /// Ocurrió un error recuperable (pantalla amigable con reintento).
  error,

  /// No hay suficientes preguntas para la configuración elegida.
  sinPreguntas,
}

/// Configuración de una partida de Modo Libre.
///
/// `dificultad` usa los valores reales de la base de datos
/// (`Facil`, `Intermedia`, `Dificil`). `tiempoPorPregunta` es `null` cuando
/// no hay límite de tiempo.
class ModoLibreConfiguracion extends Equatable {
  final int? categoriaId;
  final String? dificultad;
  final int cantidadPreguntas;
  final Duration? tiempoPorPregunta;

  const ModoLibreConfiguracion({
    this.categoriaId,
    this.dificultad,
    this.cantidadPreguntas = 10,
    this.tiempoPorPregunta,
  });

  bool get tieneTiempo => tiempoPorPregunta != null;

  ModoLibreConfiguracion copyWith({
    int? categoriaId,
    bool limpiarCategoria = false,
    String? dificultad,
    bool limpiarDificultad = false,
    int? cantidadPreguntas,
    Duration? tiempoPorPregunta,
    bool limpiarTiempo = false,
  }) {
    return ModoLibreConfiguracion(
      categoriaId: limpiarCategoria ? null : (categoriaId ?? this.categoriaId),
      dificultad: limpiarDificultad ? null : (dificultad ?? this.dificultad),
      cantidadPreguntas: cantidadPreguntas ?? this.cantidadPreguntas,
      tiempoPorPregunta: limpiarTiempo
          ? null
          : (tiempoPorPregunta ?? this.tiempoPorPregunta),
    );
  }

  @override
  List<Object?> get props => [
    categoriaId,
    dificultad,
    cantidadPreguntas,
    tiempoPorPregunta,
  ];
}

/// Estado inmutable del flujo de Modo Libre.
class ModoLibreState extends Equatable {
  final ModoLibreStatus status;
  final bool isLoading;
  final String? error;
  final List<CategoriaResponse> categorias;
  final ModoLibreConfiguracion config;
  final List<TriviaPreguntaGenerada> preguntas;
  final int preguntaActualIndex;
  final String? opcionSeleccionada;
  final Set<String> opcionesEliminadas;
  final bool saltada;
  final bool esCorrecta;
  final bool tiempoAgotado;
  final String? respuestaCorrectaTexto;
  final int bonusRapidez;
  final int puntosGanadosPregunta;
  final int puntuacion;
  final int respuestasCorrectas;
  final int rachaActual;
  final int mejorRacha;
  final Duration? tiempoRestante;
  final Duration tiempoTotal;
  final int xpGanados;
  final int monedasGanadas;
  final int monedasDisponibles;

  /// La recompensa de la partida ya fue reclamada (entrega única).
  final bool recompensaReclamada;

  /// Hay un reclamo de recompensas en curso (estado del botón).
  final bool recompensaReclamando;

  const ModoLibreState({
    this.status = ModoLibreStatus.cargando,
    this.isLoading = false,
    this.error,
    this.categorias = const [],
    this.config = const ModoLibreConfiguracion(),
    this.preguntas = const [],
    this.preguntaActualIndex = 0,
    this.opcionSeleccionada,
    this.opcionesEliminadas = const {},
    this.saltada = false,
    this.esCorrecta = false,
    this.tiempoAgotado = false,
    this.respuestaCorrectaTexto,
    this.bonusRapidez = 0,
    this.puntosGanadosPregunta = 0,
    this.puntuacion = 0,
    this.respuestasCorrectas = 0,
    this.rachaActual = 0,
    this.mejorRacha = 0,
    this.tiempoRestante,
    this.tiempoTotal = Duration.zero,
    this.xpGanados = 0,
    this.monedasGanadas = 0,
    this.monedasDisponibles = 0,
    this.recompensaReclamada = false,
    this.recompensaReclamando = false,
  });

  TriviaPreguntaGenerada? get preguntaActual =>
      preguntas.isEmpty ? null : preguntas[preguntaActualIndex];

  int get totalPreguntas => preguntas.length;

  bool get esUltimaPregunta =>
      preguntas.isNotEmpty && preguntaActualIndex >= preguntas.length - 1;

  double get progreso =>
      totalPreguntas == 0 ? 0 : (preguntaActualIndex + 1) / totalPreguntas;

  int get porcentajeAciertos => totalPreguntas == 0
      ? 0
      : (respuestasCorrectas / totalPreguntas * 100).round();

  bool get puedeUsarAyuda => opcionesEliminadas.length < 3;

  bool get recompensaPendiente =>
      status == ModoLibreStatus.resultados &&
      !recompensaReclamada &&
      !recompensaReclamando;

  String get nombreCategoriaActual {
    if (config.categoriaId == null) return 'Todas';
    for (final cat in categorias) {
      if (cat.categoriaId == config.categoriaId) return cat.nombreCategoria;
    }
    return 'Todas';
  }

  String get nombreDificultadActual {
    switch (config.dificultad) {
      case 'Facil':
        return 'Fácil';
      case 'Intermedia':
        return 'Normal';
      case 'Dificil':
        return 'Difícil';
      default:
        return 'Todas';
    }
  }

  ModoLibreState copyWith({
    ModoLibreStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<CategoriaResponse>? categorias,
    ModoLibreConfiguracion? config,
    List<TriviaPreguntaGenerada>? preguntas,
    int? preguntaActualIndex,
    String? opcionSeleccionada,
    bool limpiarOpcion = false,
    Set<String>? opcionesEliminadas,
    bool limpiarEliminadas = false,
    bool? saltada,
    bool? esCorrecta,
    bool? tiempoAgotado,
    String? respuestaCorrectaTexto,
    bool limpiarFeedback = false,
    int? bonusRapidez,
    int? puntosGanadosPregunta,
    int? puntuacion,
    int? respuestasCorrectas,
    int? rachaActual,
    int? mejorRacha,
    Duration? tiempoRestante,
    bool limpiarTiempo = false,
    Duration? tiempoTotal,
    int? xpGanados,
    int? monedasGanadas,
    int? monedasDisponibles,
    bool? recompensaReclamada,
    bool? recompensaReclamando,
  }) {
    return ModoLibreState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      categorias: categorias ?? this.categorias,
      config: config ?? this.config,
      preguntas: preguntas ?? this.preguntas,
      preguntaActualIndex: preguntaActualIndex ?? this.preguntaActualIndex,
      opcionSeleccionada: limpiarOpcion
          ? null
          : (opcionSeleccionada ?? this.opcionSeleccionada),
      opcionesEliminadas: limpiarEliminadas
          ? const {}
          : (opcionesEliminadas ?? this.opcionesEliminadas),
      saltada: saltada ?? this.saltada,
      esCorrecta: esCorrecta ?? this.esCorrecta,
      tiempoAgotado: tiempoAgotado ?? this.tiempoAgotado,
      respuestaCorrectaTexto: limpiarFeedback
          ? null
          : (respuestaCorrectaTexto ?? this.respuestaCorrectaTexto),
      bonusRapidez: bonusRapidez ?? this.bonusRapidez,
      puntosGanadosPregunta: puntosGanadosPregunta ?? this.puntosGanadosPregunta,
      puntuacion: puntuacion ?? this.puntuacion,
      respuestasCorrectas: respuestasCorrectas ?? this.respuestasCorrectas,
      rachaActual: rachaActual ?? this.rachaActual,
      mejorRacha: mejorRacha ?? this.mejorRacha,
      tiempoRestante: limpiarTiempo
          ? null
          : (tiempoRestante ?? this.tiempoRestante),
      tiempoTotal: tiempoTotal ?? this.tiempoTotal,
      xpGanados: xpGanados ?? this.xpGanados,
      monedasGanadas: monedasGanadas ?? this.monedasGanadas,
      monedasDisponibles: monedasDisponibles ?? this.monedasDisponibles,
      recompensaReclamada: recompensaReclamada ?? this.recompensaReclamada,
      recompensaReclamando:
          recompensaReclamando ?? this.recompensaReclamando,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isLoading,
    error,
    categorias,
    config,
    preguntas,
    preguntaActualIndex,
    opcionSeleccionada,
    opcionesEliminadas,
    saltada,
    esCorrecta,
    tiempoAgotado,
    respuestaCorrectaTexto,
    bonusRapidez,
    puntosGanadosPregunta,
    puntuacion,
    respuestasCorrectas,
    rachaActual,
    mejorRacha,
    tiempoRestante,
    tiempoTotal,
    xpGanados,
    monedasGanadas,
    monedasDisponibles,
    recompensaReclamada,
    recompensaReclamando,
  ];
}
