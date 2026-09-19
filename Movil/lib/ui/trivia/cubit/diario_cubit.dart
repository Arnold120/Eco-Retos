import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/models/trivia/diario_models.dart';
import '../../../data/models/trivia/trivia_models.dart';
import '../../../data/repositories/trivias_diario_local.dart';
import '../../../data/services/categoria_service.dart';
import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/services/gamification_service.dart';
import '../../../data/services/trivia_service.dart' show TriviaService;
import '../trivia_question_generator.dart';
import 'diario_state.dart';

/// Dirige el flujo del Modo Diario: preparación del día, partida de 3
/// preguntas, temporización, ayudas, recompensas, racha, dificultad por
/// categoría y persistencia local.
///
/// Una única instancia por pantalla, creada y proveída por la pantalla dueña
/// del flujo. Todos los timers se cancelan al cerrar el cubit.
class DiarioCubit extends Cubit<DiarioState> {
  final int usuarioId;
  final DiarioStore _store;
  final CategoriaService _categoriaService;
  final TriviaService _triviaService;
  final MonederoService _monederoService;
  final ProgresoService _progresoService;
  final VoidCallback? _onTriviaCompleted;

  final GeneradorPreguntaTrivia _generador = const GeneradorPreguntaTrivia();
  final Random _random = Random();

  List<TriviaResponse> _registrosTrivia = [];
  List<CategoriaResponse> _categorias = [];

  Timer? _timerTemporizador;
  Timer? _timerSeleccion;
  Timer? _timerAvanceAutomatico;
  bool _recompensasRegistradas = false;

  DiarioCubit({
    required this.usuarioId,
    required DiarioStore store,
    required CategoriaService categoriaService,
    required TriviaService triviaService,
    required MonederoService monederoService,
    required ProgresoService progresoService,
    VoidCallback? onTriviaCompleted,
  }) : _store = store,
       _categoriaService = categoriaService,
       _triviaService = triviaService,
       _monederoService = monederoService,
       _progresoService = progresoService,
       _onTriviaCompleted = onTriviaCompleted,
       super(DiarioState.inicial());

  void _emit(DiarioState nuevo) {
    if (!isClosed) emit(nuevo);
  }

  // ---------------------------------------------------------------------------
  // Carga inicial
  // ---------------------------------------------------------------------------

  Future<void> iniciar() async {
    _emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        status: DiarioStatus.loading,
      ),
    );
    try {
      final resultados = await Future.wait([
        _categoriaService.getCategorias(),
        _triviaService.getTriviasActivas(),
        _store.cargar(),
        // Saldo único de Monedas Eco.
        _monederoService.getSaldo(),
      ]);
      if (isClosed) return;

      final categorias = resultados[0] as List<CategoriaResponse>;
      _categorias = categorias;
      _registrosTrivia = resultados[1] as List<TriviaResponse>;
      final progreso = resultados[2] as ProgresoDiario;
      final saldo = resultados[3] as SaldoMonederoResponse;

      final categoriaId = indiceCategoriaDelDia(state.hoy);
      final categoria = _buscarCategoria(categoriaId);
      final categoriaNombre =
          categoria?.nombreCategoria ?? 'Categoría $categoriaId';
      final meta = progreso.categoriaDe(categoriaId) ??
          ProgresoCategoriaDiario.inicial(
            categoriaId: categoriaId,
            categoriaNombre: categoriaNombre,
          );

      final sesionHoy = progreso.sesionDeDia(state.hoy);

      if (sesionHoy != null && sesionHoy.completada) {
        final resultadoHoy = ResultadoDiario(
          puntos: sesionHoy.puntosTotales,
          aciertos: sesionHoy.aciertos,
          totalPreguntas: sesionHoy.preguntas.length,
          xpGanados: sesionHoy.xpGanados,
          monedasGanadas: sesionHoy.monedasGanadas,
          rachaNueva: rachaEfectivaDiaria(progreso, state.hoy),
          mejorRacha: progreso.racha.mejor,
          subioDificultad: false,
          dificultadAnterior: meta.dificultad,
          dificultadNueva: meta.dificultad,
          semanaCompletada: false,
        );
        _emit(
          state.copyWith(
            isLoading: false,
            status: DiarioStatus.todayDone,
            progreso: progreso,
            monedasDisponibles: saldo.saldo,
            categoriaId: categoriaId,
            categoriaNombre: categoriaNombre,
            dificultad: meta.dificultad,
            cicloDificultad: meta.cicloDificultad,
            semanasCompletadasConsecutivas:
                meta.semanasCompletadasConsecutivas,
            recompensaReclamada: sesionHoy.recompensaReclamada,
            resultado: resultadoHoy,
            clearError: true,
          ),
        );
        return;
      }

      final preguntas = sesionHoy?.preguntas ?? const <SesionPreguntaDiaria>[];
      final parcial = sesionHoy?.enProgreso ?? false;
      final indicePendiente = preguntas.indexWhere((p) => !p.resuelta);
      final indiceInicial = indicePendiente < 0 ? 0 : indicePendiente;

      _emit(
        state.copyWith(
          isLoading: false,
          status: DiarioStatus.ready,
          progreso: progreso,
          monedasDisponibles: saldo.saldo,
          categoriaId: categoriaId,
          categoriaNombre: categoriaNombre,
          dificultad: meta.dificultad,
          cicloDificultad: meta.cicloDificultad,
          semanasCompletadasConsecutivas:
              meta.semanasCompletadasConsecutivas,
          preguntas: preguntas,
          preguntaActualIndex: indiceInicial,
          reanudando: parcial,
          clearError: true,
        ),
      );
      developer.log('Modo diario cargado', name: 'DiarioCubit');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar el modo diario',
        name: 'DiarioCubit',
        error: e,
        stackTrace: stackTrace,
      );
      if (isClosed) return;
      _emit(
        state.copyWith(
          isLoading: false,
          status: DiarioStatus.error,
          error:
              'No pudimos cargar la trivia diaria. Revisa tu conexión e inténtalo de nuevo.',
        ),
      );
    }
  }

  void reintentar() => iniciar();

  CategoriaResponse? _buscarCategoria(int categoriaId) {
    for (final categoria in _categorias) {
      if (categoria.categoriaId == categoriaId) return categoria;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Partida
  // ---------------------------------------------------------------------------

  Future<void> comenzarPartida() async {
    if (_registrosTrivia.isEmpty) {
      _emit(state.copyWith(status: DiarioStatus.sinPreguntas, clearError: true));
      return;
    }

    List<SesionPreguntaDiaria> preguntas;
    final esNueva = state.preguntas.isEmpty;
    if (esNueva) {
      final generadas = _generarPreguntasDia();
      if (generadas == null) {
        _emit(
          state.copyWith(
            status: DiarioStatus.sinPreguntas,
            clearError: true,
          ),
        );
        return;
      }
      preguntas = generadas;
    } else {
      preguntas = state.preguntas;
    }

    final indicePendiente = preguntas.indexWhere((p) => !p.resuelta);
    final indice = indicePendiente < 0 ? preguntas.length - 1 : indicePendiente;

    _emit(
      state.copyWith(
        status: DiarioStatus.questionActive,
        preguntas: preguntas,
        preguntaActualIndex: indice,
        limpiarOpcion: true,
        limpiarEliminadas: true,
        limpiarFeedback: true,
        limpiarTiempo: true,
        esCorrecta: false,
        tiempoAgotado: false,
        resetPuntos: true,
        clearError: true,
      ),
    );

    if (esNueva) {
      await _persistirSesion(preguntas);
      if (isClosed) return;
    }
    _iniciarTemporizador();
  }

  /// Genera 3 preguntas con fallback progresivo de material:
  /// categoría+dificultad → categoría completa → todas las activas.
  List<SesionPreguntaDiaria>? _generarPreguntasDia() {
    final categoriaId = state.categoriaId;
    final dificultad = state.dificultad.valorDb;
    final usadas = <int>{};

    var generadas = _generador.generarLote(
      registros: _registrosTrivia,
      categoriaId: categoriaId,
      dificultad: dificultad,
      cantidad: kPreguntasPorDia,
      yaUtilizadas: usadas,
      random: _random,
    );
    usadas.addAll(generadas.map((p) => p.triviaId));

    if (generadas.length < kPreguntasPorDia) {
      final restantes = _generador.generarLote(
        registros: _registrosTrivia,
        categoriaId: categoriaId,
        cantidad: kPreguntasPorDia - generadas.length,
        yaUtilizadas: usadas,
        random: _random,
      );
      generadas = [...generadas, ...restantes];
      usadas.addAll(restantes.map((p) => p.triviaId));
    }

    if (generadas.length < kPreguntasPorDia) {
      final restantes = _generador.generarLote(
        registros: _registrosTrivia,
        cantidad: kPreguntasPorDia - generadas.length,
        yaUtilizadas: usadas,
        random: _random,
      );
      generadas = [...generadas, ...restantes];
    }

    if (generadas.length < kPreguntasPorDia) return null;

    return generadas
        .map(
          (p) => SesionPreguntaDiaria(
            triviaId: p.triviaId,
            categoriaId: p.categoriaId,
            dificultad: p.dificultad,
            pregunta: p.pregunta,
            opciones: p.opciones,
            respuestaCorrecta: p.respuestaCorrecta,
            puntosBase: p.puntos,
          ),
        )
        .toList();
  }

  Future<void> _persistirSesion(List<SesionPreguntaDiaria> preguntas) async {
    final sesion = SesionDiario(
      fecha: state.hoy,
      categoriaId: state.categoriaId,
      dificultad: state.dificultad.valorDb,
      preguntas: preguntas,
    );
    final nuevoProgreso = state.progreso.registrarSesion(sesion);
    await _store.guardar(nuevoProgreso);
    if (isClosed) return;
    _emit(state.copyWith(progreso: nuevoProgreso));
  }

  // ---------------------------------------------------------------------------
  // Respuestas
  // ---------------------------------------------------------------------------

  void seleccionarOpcion(String letra) {
    if (state.status != DiarioStatus.questionActive) return;
    if (state.opcionSeleccionada != null) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null || pregunta.resuelta) return;

    _detenerTemporizador();
    _timerSeleccion?.cancel();
    _timerSeleccion = Timer(const Duration(milliseconds: 350), () {
      if (!isClosed) _resolverRespuesta(letra: letra, tiempoAgotado: false);
    });

    _emit(
      state.copyWith(
        status: DiarioStatus.answerSelected,
        opcionSeleccionada: letra,
      ),
    );
  }

  void _resolverRespuesta({
    required String? letra,
    required bool tiempoAgotado,
  }) {
    final pregunta = state.preguntaActual;
    if (pregunta == null) return;
    _detenerTemporizador();
    _timerSeleccion?.cancel();

    final esCorrecta =
        !tiempoAgotado && letra != null && letra == pregunta.respuestaCorrecta;
    final actualizadas = [...state.preguntas];
    actualizadas[state.preguntaActualIndex] = tiempoAgotado
        ? pregunta.marcarSinRespuesta()
        : pregunta.responder(letra: letra!);

    final puntos = actualizadas.fold(0, (suma, p) => suma + p.puntosGanados);
    final aciertos = actualizadas.where((p) => p.esCorrecta).length;

    final siguiente = tiempoAgotado
        ? DiarioStatus.timeExpired
        : (esCorrecta ? DiarioStatus.answerCorrect : DiarioStatus.answerIncorrect);

    _emit(
      state.copyWith(
        status: siguiente,
        preguntas: actualizadas,
        opcionSeleccionada: letra,
        esCorrecta: esCorrecta,
        tiempoAgotado: tiempoAgotado,
        respuestaCorrectaTexto: pregunta.opciones[pregunta.respuestaCorrecta],
        puntos: puntos,
        respuestasCorrectas: aciertos,
        limpiarEliminadas: true,
        limpiarTiempo: true,
      ),
    );

    unawaited(_persistirSesion(actualizadas));
    _programarAvanceAutomatico();
  }

  void siguientePregunta() {
    if (!state.enFeedback) return;
    _detenerAvanceAutomatico();

    if (state.preguntas.every((p) => p.resuelta)) {
      _finalizar();
      return;
    }

    final siguiente = state.preguntas.indexWhere((p) => !p.resuelta);
    _emit(
      state.copyWith(
        status: DiarioStatus.questionActive,
        preguntaActualIndex: siguiente,
        limpiarOpcion: true,
        limpiarEliminadas: true,
        limpiarFeedback: true,
        limpiarTiempo: true,
        esCorrecta: false,
        tiempoAgotado: false,
      ),
    );
    _iniciarTemporizador();
  }

  // ---------------------------------------------------------------------------
  // Ayudas
  // ---------------------------------------------------------------------------

  Future<void> usarAyuda(AyudaTrivia ayuda) async {
    if (state.status != DiarioStatus.questionActive) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null || pregunta.resuelta) return;

    final costo = ayuda.costo;
    if (state.monedasDisponibles < costo) return;

    final disponibles = const ['A', 'B', 'C', 'D']
        .where(
          (letra) =>
              letra != pregunta.respuestaCorrecta &&
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
        descripcion: 'Ayuda "${ayuda.nombre}" en modo diario',
        categoriaId: state.categoriaId,
      );
      if (!isClosed) {
        _emit(state.copyWith(monedasDisponibles: gasto.saldo));
      }
    } catch (e, stackTrace) {
      developer.log(
        'No se pudo descontar la ayuda',
        name: 'DiarioCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Temporizador por pregunta
  // ---------------------------------------------------------------------------

  void _iniciarTemporizador() {
    _detenerTemporizador();
    _emit(state.copyWith(tiempoRestante: kTiempoPorPreguntaDiario));
    _timerTemporizador = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickTemporizador();
    });
  }

  void _tickTemporizador() {
    if (state.status != DiarioStatus.questionActive) return;
    final restante = state.tiempoRestante - const Duration(seconds: 1);
    if (restante <= Duration.zero) {
      _emit(state.copyWith(tiempoRestante: Duration.zero));
      _resolverRespuesta(letra: null, tiempoAgotado: true);
    } else {
      _emit(state.copyWith(tiempoRestante: restante));
    }
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
      if (!isClosed) siguientePregunta();
    });
  }

  void _detenerAvanceAutomatico() {
    _timerAvanceAutomatico?.cancel();
    _timerAvanceAutomatico = null;
  }

  // ---------------------------------------------------------------------------
  // Finalización y recompensas
  // ---------------------------------------------------------------------------

  /// Calcula la semana y prepara la sesión pero NO registra en backend.
  /// Las recompensas se entregan una sola vez en `reclamarRecompensas()`.
  Future<void> _finalizar() async {
    if (_recompensasRegistradas) return;
    _recompensasRegistradas = true;
    _detenerTemporizador();
    _detenerAvanceAutomatico();
    _timerSeleccion?.cancel();

    final preguntas = state.preguntas;
    final sesion = SesionDiario(
      fecha: state.hoy,
      categoriaId: state.categoriaId,
      dificultad: state.dificultad.valorDb,
      preguntas: preguntas,
      recompensaReclamada: false,
    );
    final puntos = sesion.puntosTotales;
    final aciertos = sesion.aciertos;
    final xp = calcularXp(puntos);
    final monedas = calcularMonedas(puntos);

    final categoriaActual = state.progreso.categoriaDe(state.categoriaId) ??
        ProgresoCategoriaDiario.inicial(
          categoriaId: state.categoriaId,
          categoriaNombre: state.categoriaNombre,
        );
    final dificultadAnterior = categoriaActual.dificultad;
    final catRegistrada = categoriaActual.registrarPartida(
      aciertos: aciertos,
      respuestas: preguntas.length,
      puntos: puntos,
    );
    final catFinal = catRegistrada.registrarSemanaCompletada(state.hoy);
    final subioDificultad = catFinal.dificultad != dificultadAnterior;

    final racha = state.progreso.racha.registrarDiaCompletado(state.hoy);

    final progreso = ProgresoDiario(
      categorias: {...state.progreso.categorias, state.categoriaId: catFinal},
      sesiones: {...state.progreso.sesiones, fechaClave(state.hoy): sesion},
      racha: racha,
      semanaUltimaRecompensada: state.progreso.semanaUltimaRecompensada,
    );

    final semanaCompletada = progreso.semanaCompletadaEn(state.hoy);
    final semanaPendiente = semanaCompletada &&
        progreso.semanaUltimaRecompensada != claveSemana(state.hoy);

    await _store.guardar(progreso);
    if (isClosed) return;

    // Si no hay recompensas, auto-reclamar (register backend como best-effort)
    final autoReclamado = xp == 0 && monedas == 0 && !semanaPendiente;
    final progresoGuardado = autoReclamado
        ? progreso.actualizarSesion(sesion.copyWith(recompensaReclamada: true))
        : progreso;
    if (autoReclamado) {
      await _store.guardar(progresoGuardado);
      await _registrarEnBackend(xp, monedas, 0, 0, semanaPendiente);
      if (isClosed) return;
      _onTriviaCompleted?.call();
    }

    _emit(
      state.copyWith(
        status: DiarioStatus.completed,
        preguntas: preguntas,
        progreso: progresoGuardado,
        recompensaReclamada: autoReclamado,
        resultado: ResultadoDiario(
          puntos: puntos,
          aciertos: aciertos,
          totalPreguntas: preguntas.length,
          xpGanados: xp,
          monedasGanadas: monedas,
          rachaNueva: racha.actual,
          mejorRacha: racha.mejor,
          subioDificultad: subioDificultad,
          dificultadAnterior: dificultadAnterior,
          dificultadNueva: catFinal.dificultad,
          semanaCompletada: semanaCompletada,
          xpSemana: 0,
          monedasSemana: 0,
        ),
      ),
    );
    developer.log(
      'Modo diario finalizado: $xp XP, $monedas monedas',
      name: 'DiarioCubit',
    );
  }

  /// Registra las recompensas (una sola vez) en el backend. El backend calcula
  /// la XP y las monedas; aquí solo se reclama con claves idempotentes.
  Future<void> _registrarEnBackend(
    int xp,
    int monedas,
    int xpSemana,
    int monedasSemana,
    bool semanaPendiente,
  ) async {
    try {
      final resultado = state.resultado;
      final claveDia =
          'TRIVIA_DIARIA:${state.hoy.year}-${state.hoy.month}-${state.hoy.day}';
      await _monederoService.reclamarRecompensa(
        tipo: 'TRIVIA',
        claveIdempotencia: claveDia,
        puntuacion: resultado?.puntos ?? xp,
        totalPreguntas: resultado?.totalPreguntas ?? (xp > 0 ? 1 : 0),
        categoriaId: state.categoriaId,
        descripcion: 'Modo diario completado',
      );
      if (semanaPendiente) {
        await _monederoService.reclamarRecompensa(
          tipo: 'TRIVIA_SEMANA',
          claveIdempotencia: 'TRIVIA_SEMANA:${claveSemana(state.hoy)}',
          descripcion: 'Semana de trivia diaria completada',
        );
      }
      final saldo = await _monederoService.getSaldo();
      if (!isClosed) {
        _emit(state.copyWith(monedasDisponibles: saldo.saldo));
      }
      await _progresoService.incrementarTrivias(usuarioId);
    } catch (e, stackTrace) {
      developer.log(
        'Error al registrar recompensas en backend',
        name: 'DiarioCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reclama las recompensas de la partida del día. Llamado por el botón
  /// "RECLAMAR RECOMPENSAS". El reclamo solo se ejecuta una vez y se
  /// persiste antes de llamar al backend (anti-duplicado offline-first).
  Future<bool> reclamarRecompensas() async {
    if (!state.puedeReclamar) return false;
    final resultado = state.resultado;
    if (resultado == null) return false;

    _emit(state.copyWith(recompensaReclamando: true));

    // Calcular semana
    var progreso = state.progreso;
    final semanaCompletada = progreso.semanaCompletadaEn(state.hoy);
    final semanaPendiente = semanaCompletada &&
        progreso.semanaUltimaRecompensada != claveSemana(state.hoy);
    var xpSemana = 0;
    var monedasSemana = 0;
    if (semanaPendiente) {
      progreso = progreso.marcarSemanaRecompensada(state.hoy);
      xpSemana = kXpSemanaCompletada;
      monedasSemana = kMonedasSemanaCompletada;
    }

    // 1) Persistir local PRIMERO (anti-duplicado offline)
    final sesionHoy = progreso.sesionDeDia(state.hoy);
    if (sesionHoy != null) {
      final sesionMarcada = sesionHoy.copyWith(recompensaReclamada: true);
      progreso = progreso.actualizarSesion(sesionMarcada);
    }
    await _store.guardar(progreso);

    // 2) Backend best-effort
    await _registrarEnBackend(
      resultado.xpGanados,
      resultado.monedasGanadas,
      xpSemana,
      monedasSemana,
      semanaPendiente,
    );

    if (isClosed) return false;

    _emit(
      state.copyWith(
        recompensaReclamada: true,
        recompensaReclamando: false,
        progreso: progreso,
      ),
    );

    _onTriviaCompleted?.call();
    developer.log(
      'Recompensas reclamadas: +${resultado.xpGanados} XP, '
      '+${resultado.monedasGanadas} monedas',
      name: 'DiarioCubit',
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
    _timerSeleccion?.cancel();
    return super.close();
  }
}