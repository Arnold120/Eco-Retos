import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/models/trivia/diario_models.dart' show AyudaTrivia;
import '../../../data/models/trivia/trivia_models.dart';
import '../../../data/repositories/trivia_recompensa_local.dart';
import '../../../data/services/categoria_service.dart';
import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/services/gamification_service.dart';
import '../../../data/services/trivia_service.dart' show TriviaService;
import '../trivia_question_generator.dart';
import 'modo_libre_state.dart';

/// Dirige el flujo completo de Modo Libre: configuración, partida,
/// temporización, feedback, puntuación/recompensas y resultados.
///
/// Una única instancia por partida, creada por la pantalla dueña del flujo y
/// siempre proveída por encima de todos sus consumidores. Todos los timers se
/// cancelan al cerrar el cubit para evitar fugas de memoria o emisiones
/// posteriores al dispose.
class ModoLibreCubit extends Cubit<ModoLibreState> {
  final int usuarioId;
  final CategoriaService _categoriaService;
  final TriviaService _triviaService;
  final MonederoService _monederoService;
  final ProgresoService _progresoService;
  final RecompensaLibreStore _recompensaStore;
  final VoidCallback? _onTriviaCompleted;

  final GeneradorPreguntaTrivia _generador = const GeneradorPreguntaTrivia();
  final Random _random = Random();
  List<TriviaResponse> _registros = [];

  Timer? _timerTemporizador;
  Timer? _timerAvanceAutomatico;
  Stopwatch? _cronometro;
  bool _recompensasRegistradas = false;

  ModoLibreCubit({
    required this.usuarioId,
    required CategoriaService categoriaService,
    required TriviaService triviaService,
    required MonederoService monederoService,
    required ProgresoService progresoService,
    required RecompensaLibreStore recompensaStore,
    VoidCallback? onTriviaCompleted,
  }) : _categoriaService = categoriaService,
       _triviaService = triviaService,
       _monederoService = monederoService,
       _progresoService = progresoService,
       _recompensaStore = recompensaStore,
       _onTriviaCompleted = onTriviaCompleted,
       super(const ModoLibreState());

  void _emit(ModoLibreState nuevo) {
    if (!isClosed) emit(nuevo);
  }

  // ---------------------------------------------------------------------------
  // Carga inicial y pantalla de configuración
  // ---------------------------------------------------------------------------

  Future<void> iniciar() async {
    _emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait([
        _categoriaService.getCategorias(),
        _triviaService.getTriviasActivas(),
        // Saldo único de Monedas Eco.
        _monederoService.getSaldo(),
      ]);
      if (isClosed) return;
      _registros = results[1] as List<TriviaResponse>;
      final saldo = results[2] as SaldoMonederoResponse;
      _emit(
        state.copyWith(
          isLoading: false,
          status: ModoLibreStatus.configurando,
          categorias: results[0] as List<CategoriaResponse>,
          monedasDisponibles: saldo.saldo,
        ),
      );
      developer.log('Modo libre cargado', name: 'ModoLibreCubit');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar el modo libre',
        name: 'ModoLibreCubit',
        error: e,
        stackTrace: stackTrace,
      );
      if (isClosed) return;
      _emit(
        state.copyWith(
          isLoading: false,
          status: ModoLibreStatus.error,
          error:
              'No pudimos cargar la trivia. Revisa tu conexión e inténtalo de nuevo.',
        ),
      );
    }
  }

  void reintentar() => iniciar();

  void actualizarConfiguracion(ModoLibreConfiguracion config) {
    if (state.status != ModoLibreStatus.configurando) return;
    _emit(state.copyWith(config: config, clearError: true));
  }

  void irAConfiguracion() {
    _detenerTemporizador();
    _detenerAvanceAutomatico();
    _cronometro?.stop();
    _cronometro = null;
    _emit(
      state.copyWith(
        status: ModoLibreStatus.configurando,
        preguntas: const [],
        preguntaActualIndex: 0,
        limpiarOpcion: true,
        limpiarEliminadas: true,
        limpiarFeedback: true,
        esCorrecta: false,
        tiempoAgotado: false,
        saltada: false,
        bonusRapidez: 0,
        clearError: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Partida
  // ---------------------------------------------------------------------------

  Future<void> iniciarPartida() async {
    if (state.status != ModoLibreStatus.configurando) return;

    final config = state.config;
    if (_registros.isEmpty) {
      _emit(
        state.copyWith(status: ModoLibreStatus.sinPreguntas, clearError: true),
      );
      return;
    }

    _emit(state.copyWith(isLoading: true, clearError: true));

    final lote = _generador.generarLote(
      registros: _registros,
      categoriaId: config.categoriaId,
      dificultad: config.dificultad,
      cantidad: config.cantidadPreguntas,
      random: _random,
    );

    if (lote.isEmpty) {
      _emit(
        state.copyWith(isLoading: false, status: ModoLibreStatus.sinPreguntas),
      );
      return;
    }

    _recompensasRegistradas = false;
    _cronometro = Stopwatch()..start();
    unawaited(_recompensaStore.limpiar());

    _emit(
      state.copyWith(
        isLoading: false,
        status: ModoLibreStatus.jugando,
        preguntas: lote,
        preguntaActualIndex: 0,
        puntuacion: 0,
        respuestasCorrectas: 0,
        rachaActual: 0,
        mejorRacha: 0,
        bonusRapidez: 0,
        puntosGanadosPregunta: 0,
        xpGanados: 0,
        monedasGanadas: 0,
        tiempoTotal: Duration.zero,
        recompensaReclamada: false,
        recompensaReclamando: false,
        limpiarOpcion: true,
        limpiarEliminadas: true,
        limpiarFeedback: true,
        esCorrecta: false,
        tiempoAgotado: false,
        saltada: false,
      ),
    );
    _iniciarTemporizador();
  }

  void repetirPartida() {
    if (state.status != ModoLibreStatus.resultados) return;
    _emit(state.copyWith(status: ModoLibreStatus.configurando));
    iniciarPartida();
  }

  void seleccionarOpcion(String letra) {
    if (state.status != ModoLibreStatus.jugando) return;
    if (state.opcionSeleccionada != null) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null) return;

    _resolverRespuesta(
      opcionSeleccionada: letra,
      esCorrecta: pregunta.esLetraCorrecta(letra),
      tiempoAgotado: false,
    );
  }

  /// Avanza a la siguiente pregunta (manual o automática).
  void siguienteRespuesta() {
    if (state.status != ModoLibreStatus.retroalimentacion) return;
    _detenerAvanceAutomatico();

    if (state.esUltimaPregunta) {
      _finalizar();
      return;
    }

    final siguienteIndex = state.preguntaActualIndex + 1;
    _emit(
      state.copyWith(
        status: ModoLibreStatus.jugando,
        preguntaActualIndex: siguienteIndex,
        limpiarOpcion: true,
        limpiarEliminadas: true,
        limpiarFeedback: true,
        esCorrecta: false,
        tiempoAgotado: false,
        saltada: false,
        bonusRapidez: 0,
        puntosGanadosPregunta: 0,
      ),
    );
    _iniciarTemporizador();
  }

  // ---------------------------------------------------------------------------
  // Resolución de respuestas y puntuación
  // ---------------------------------------------------------------------------

  void _resolverRespuesta({
    required String? opcionSeleccionada,
    required bool esCorrecta,
    required bool tiempoAgotado,
  }) {
    final pregunta = state.preguntaActual;
    if (pregunta == null) return;

    _detenerTemporizador();

    var bonus = 0;
    var nuevosPuntos = state.puntuacion;
    var nuevasCorrectas = state.respuestasCorrectas;
    var racha = state.rachaActual;
    var mejorRacha = state.mejorRacha;
    String? correctaTexto;
    var puntosPregunta = 0;

    if (esCorrecta) {
      bonus = _calcularBonusRapidez();
      puntosPregunta = pregunta.puntos + bonus;
      nuevosPuntos += puntosPregunta;
      nuevasCorrectas += 1;
      racha += 1;
      if (racha > mejorRacha) mejorRacha = racha;
    } else {
      racha = 0;
      correctaTexto = pregunta.respuestaCorrectaTexto;
    }

    _emit(
      state.copyWith(
        status: ModoLibreStatus.retroalimentacion,
        opcionSeleccionada: opcionSeleccionada,
        limpiarEliminadas: true,
        esCorrecta: esCorrecta,
        tiempoAgotado: tiempoAgotado,
        saltada: false,
        respuestaCorrectaTexto: correctaTexto,
        bonusRapidez: bonus,
        puntosGanadosPregunta: puntosPregunta,
        puntuacion: nuevosPuntos,
        respuestasCorrectas: nuevasCorrectas,
        rachaActual: racha,
        mejorRacha: mejorRacha,
      ),
    );
    _programarAvanceAutomatico();
  }

  int _calcularBonusRapidez() {
    final tiempo = state.config.tiempoPorPregunta;
    if (tiempo == null || tiempo == Duration.zero) return 0;
    final totalMs = tiempo.inMilliseconds;
    final restanteMs = state.tiempoRestante?.inMilliseconds ?? 0;
    final usadoMs = totalMs - restanteMs;
    if (totalMs == 0 || usadoMs > totalMs * 0.6) return 0;
    final puntos = state.preguntaActual?.puntos ?? 0;
    return max(5, (puntos * 0.25).round());
  }

  // ---------------------------------------------------------------------------
  // Ayudas
  // ---------------------------------------------------------------------------

  /// Aplica una ayuda durante la pregunta activa. `saltar` descarta la
  /// pregunta actual; pista/50/50 eliminan opciones incorrectas.
  Future<void> usarAyuda(AyudaTrivia ayuda) async {
    if (ayuda == AyudaTrivia.saltar) {
      saltarPregunta();
      return;
    }
    if (state.status != ModoLibreStatus.jugando) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null) return;

    final costo = ayuda.costo;
    if (state.monedasDisponibles < costo) return;

    final disponibles = const ['A', 'B', 'C', 'D']
        .where(
          (letra) =>
              !pregunta.esLetraCorrecta(letra) &&
              !state.opcionesEliminadas.contains(letra),
        )
        .toList();
    if (disponibles.isEmpty) return;
    disponibles.shuffle(_random);
    final aEliminar = disponibles.take(
      ayuda == AyudaTrivia.cincuentaCincuenta ? 2 : 1,
    ).toList();

    _emit(
      state.copyWith(
        opcionesEliminadas: {...state.opcionesEliminadas, ...aEliminar},
        monedasDisponibles: state.monedasDisponibles - costo,
      ),
    );

    try {
      final gasto = await _monederoService.gastar(
        cantidad: costo,
        tipo: 'TRIVIA_AYUDA',
        descripcion: 'Ayuda "${ayuda.nombre}" en modo libre',
        categoriaId: state.config.categoriaId,
      );
      if (!isClosed) {
        _emit(state.copyWith(monedasDisponibles: gasto.saldo));
      }
    } catch (e, stackTrace) {
      developer.log(
        'No se pudo descontar la ayuda del modo libre',
        name: 'ModoLibreCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Descarta la pregunta actual (solo disponible en Modo Libre).
  void saltarPregunta() {
    if (state.status != ModoLibreStatus.jugando) return;
    if (state.opcionSeleccionada != null) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null || state.monedasDisponibles < AyudaTrivia.saltar.costo) {
      return;
    }

    _detenerTemporizador();
    _emit(
      state.copyWith(
        status: ModoLibreStatus.retroalimentacion,
        opcionSeleccionada: null,
        limpiarEliminadas: true,
        esCorrecta: false,
        tiempoAgotado: false,
        saltada: true,
        respuestaCorrectaTexto: pregunta.respuestaCorrectaTexto,
        bonusRapidez: 0,
        puntosGanadosPregunta: 0,
        monedasDisponibles:
            state.monedasDisponibles - AyudaTrivia.saltar.costo,
      ),
    );

    _monederoService
        .gastar(
          cantidad: AyudaTrivia.saltar.costo,
          tipo: 'TRIVIA_AYUDA',
          descripcion: 'Ayuda "Saltar" en modo libre',
          categoriaId: state.config.categoriaId,
        )
        .then((gasto) {
          if (!isClosed) {
            _emit(state.copyWith(monedasDisponibles: gasto.saldo));
          }
        })
        .catchError((e, stackTrace) {
          developer.log(
            'No se pudo descontar la ayuda de saltar',
            name: 'ModoLibreCubit',
            error: e,
            stackTrace: stackTrace,
          );
        });

    _programarAvanceAutomatico();
  }

  // ---------------------------------------------------------------------------
  // Temporizador por pregunta
  // ---------------------------------------------------------------------------

  void _iniciarTemporizador() {
    _detenerTemporizador();
    final tiempo = state.config.tiempoPorPregunta;
    if (tiempo == null || tiempo == Duration.zero) return;
    _emit(state.copyWith(tiempoRestante: tiempo));
    _timerTemporizador = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickTemporizador(),
    );
  }

  void _tickTemporizador() {
    if (state.status != ModoLibreStatus.jugando) return;
    final restante =
        (state.tiempoRestante ?? Duration.zero) - const Duration(seconds: 1);
    if (restante <= Duration.zero) {
      _emit(state.copyWith(tiempoRestante: Duration.zero));
      _manejarTiempoAgotado();
    } else {
      _emit(state.copyWith(tiempoRestante: restante));
    }
  }

  void _manejarTiempoAgotado() {
    _detenerTemporizador();
    _resolverRespuesta(
      opcionSeleccionada: null,
      esCorrecta: false,
      tiempoAgotado: true,
    );
  }

  void _detenerTemporizador() {
    _timerTemporizador?.cancel();
    _timerTemporizador = null;
  }

  // ---------------------------------------------------------------------------
  // Avance automático
  // ---------------------------------------------------------------------------

  void _programarAvanceAutomatico() {
    _detenerAvanceAutomatico();
    _timerAvanceAutomatico = Timer(const Duration(milliseconds: 1600), () {
      if (!isClosed) siguienteRespuesta();
    });
  }

  void _detenerAvanceAutomatico() {
    _timerAvanceAutomatico?.cancel();
    _timerAvanceAutomatico = null;
  }

  // ---------------------------------------------------------------------------
  // Finalización y recompensas
  // ---------------------------------------------------------------------------

  Future<void> _finalizar() async {
    if (_recompensasRegistradas) return;
    _recompensasRegistradas = true;
    _detenerTemporizador();
    _detenerAvanceAutomatico();
    _cronometro?.stop();
    final tiempoTotal = _cronometro?.elapsed ?? Duration.zero;

    final xp = state.puntuacion;
    final monedas = state.puntuacion ~/ 10;
    final clave = DateTime.now().microsecondsSinceEpoch.toString();

    // Sin recompensas: reclamar automáticamente (solo marca local + onCompleted).
    final autoReclamado = xp == 0 && monedas == 0;
    if (autoReclamado) {
      await _recompensaStore.guardar(
        RecompensaLibre(
          puntos: state.puntuacion,
          xp: xp,
          monedas: monedas,
          respuestasCorrectas: state.respuestasCorrectas,
          totalPreguntas: state.totalPreguntas,
          reclamada: true,
          clave: clave,
        ),
      );
      await _registrarEnBackend(clave);
      if (isClosed) return;
      _onTriviaCompleted?.call();
    } else {
      // Se persiste la recompensa pendiente; la entrega real ocurre al pulsar
      // "RECLAMAR RECOMPENSAS" (sobrevive al cierre de la app).
      await _recompensaStore.guardar(
        RecompensaLibre(
          puntos: state.puntuacion,
          xp: xp,
          monedas: monedas,
          respuestasCorrectas: state.respuestasCorrectas,
          totalPreguntas: state.totalPreguntas,
          clave: clave,
        ),
      );
    }

    if (isClosed) return;
    _emit(
      state.copyWith(
        status: ModoLibreStatus.resultados,
        tiempoTotal: tiempoTotal,
        xpGanados: xp,
        monedasGanadas: monedas,
        recompensaReclamada: autoReclamado,
      ),
    );
    developer.log(
      'Modo libre finalizado: $xp XP, $monedas monedas',
      name: 'ModoLibreCubit',
    );
  }

  /// Reclama la recompensa de la partida en el backend (idempotente).
  /// El backend calcula la XP y las monedas desde la puntuación.
  Future<void> _registrarEnBackend(String clave) async {
    try {
      final recompensa = await _monederoService.reclamarRecompensa(
        tipo: 'TRIVIA',
        claveIdempotencia: 'TRIVIA_LIBRE:$clave',
        puntuacion: state.puntuacion,
        totalPreguntas: state.totalPreguntas,
        categoriaId: state.config.categoriaId,
        descripcion: 'Modo libre completado',
      );
      if (!isClosed) {
        _emit(state.copyWith(monedasDisponibles: recompensa.saldo));
      }
      await _progresoService.incrementarTrivias(usuarioId);
    } catch (e, stackTrace) {
      developer.log(
        'Error al registrar recompensas del modo libre',
        name: 'ModoLibreCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reclama las recompensas de la partida finalizada. Solo se ejecuta una vez:
  /// antes de tocar el backend se marca reclamada en el almacén local
  /// (anti-duplicado offline-first).
  Future<bool> reclamarRecompensas() async {
    if (!state.recompensaPendiente) return false;
    final xp = state.xpGanados;
    final monedas = state.monedasGanadas;

    _emit(state.copyWith(recompensaReclamando: true));

    // 1) Persistir reclamada PRIMERO (anti-duplicado) conservando la clave.
    final almacenada = await _recompensaStore.cargar();
    final clave = (almacenada != null && almacenada.clave.isNotEmpty)
        ? almacenada.clave
        : DateTime.now().microsecondsSinceEpoch.toString();
    await _recompensaStore.guardar(
      RecompensaLibre(
        puntos: state.puntuacion,
        xp: xp,
        monedas: monedas,
        respuestasCorrectas: state.respuestasCorrectas,
        totalPreguntas: state.totalPreguntas,
        reclamada: true,
        clave: clave,
      ),
    );

    // 2) Backend: recompensa idempotente calculada por el servidor.
    await _registrarEnBackend(clave);

    if (isClosed) return false;

    _emit(
      state.copyWith(
        recompensaReclamada: true,
        recompensaReclamando: false,
        monedasGanadas: monedas,
        xpGanados: xp,
      ),
    );

    if (isClosed) return false;

    _emit(
      state.copyWith(
        recompensaReclamada: true,
        recompensaReclamando: false,
      ),
    );

    _onTriviaCompleted?.call();
    developer.log(
      'Recompensas reclamadas: +$xp XP, +$monedas monedas',
      name: 'ModoLibreCubit',
    );
    return true;
  }

  // ---------------------------------------------------------------------------
  // Ciclo de vida
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() {
    _detenerTemporizador();
    _detenerAvanceAutomatico();
    _cronometro?.stop();
    _cronometro = null;
    return super.close();
  }
}
