import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:developer' as developer;

import '../../../data/models/trivia/trivia_models.dart';
import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/services/categoria_service.dart';
import '../../../data/services/gamification_service.dart';
import '../../../data/services/trivia_service.dart' show TriviaService;
import '../trivia_question_generator.dart';
import 'trivia_state.dart';

class TriviaCubit extends Cubit<TriviaState> {
  final int usuarioId;
  final CategoriaService _categoriaService;
  final TriviaService _triviaService;
  final MonederoService _monederoService;
  final ProgresoService _progresoService;
  final VoidCallback? _onTriviaCompleted;

  final GeneradorPreguntaTrivia _generador = const GeneradorPreguntaTrivia();

  /// `true` cuando la partida se juega con preguntas generadas localmente
  /// (respaldo cuando la trivia no tiene preguntas/preguntas y opciones en
  /// el servidor). En ese modo se omiten las llamadas que dependen de
  /// intentos registrados en la base de datos.
  bool _usandoPreguntasVirtuales = false;

  TriviaCubit({
    required this.usuarioId,
    required CategoriaService categoriaService,
    required TriviaService triviaService,
    required MonederoService monederoService,
    required ProgresoService progresoService,
    VoidCallback? onTriviaCompleted,
  }) : _categoriaService = categoriaService,
       _triviaService = triviaService,
       _monederoService = monederoService,
       _progresoService = progresoService,
       _onTriviaCompleted = onTriviaCompleted,
       super(const TriviaState());

  Future<void> loadTrivias() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _categoriaService.getCategorias(),
        _triviaService.getTriviasActivas(),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          categorias: results[0] as List<CategoriaResponse>,
          trivias: results[1] as List<TriviaResponse>,
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar trivias',
        name: 'TriviaCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(isLoading: false, error: 'Error al cargar las trivias'),
      );
    }
  }

  void filtrarPorCategoria(int? categoriaId) {
    if (categoriaId == state.categoriaSeleccionada) {
      emit(state.copyWith(clearCategoria: true));
    } else {
      emit(state.copyWith(categoriaSeleccionada: categoriaId));
    }
  }

  Future<void> iniciarTrivia(TriviaResponse trivia) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      var preguntas = await _triviaService.getPreguntasConOpciones(
        trivia.triviaId,
      );
      IntentoTriviaResponse? intento;
      var modoVirtual = false;

      if (preguntas.isEmpty) {
        preguntas = _generarPreguntasVirtuales(trivia);
        modoVirtual = true;
      } else {
        try {
          intento = await _triviaService.iniciarIntento(
            usuarioId,
            trivia.triviaId,
          );
        } catch (e, stackTrace) {
          developer.log(
            'No se pudo crear el intento, se juega en modo local',
            name: 'TriviaCubit',
            error: e,
            stackTrace: stackTrace,
          );
        }
        if (intento == null) modoVirtual = true;
      }

      if (preguntas.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Esta trivia no tiene preguntas disponibles',
          ),
        );
        return;
      }

      _usandoPreguntasVirtuales = modoVirtual;
      emit(
        state.copyWith(
          isLoading: false,
          mode: TriviaScreenMode.playing,
          triviaActual: trivia,
          preguntas: preguntas,
          intentoActual: intento,
          preguntaActualIndex: 0,
          puntuacion: 0,
          respuestasCorrectas: 0,
          totalPreguntas: preguntas.length,
          xpGanados: 0,
          monedasGanadas: 0,
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error al iniciar trivia',
        name: 'TriviaCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(isLoading: false, error: 'Error al iniciar la trivia'),
      );
    }
  }

  /// Genera preguntas de respaldo a partir de los registros activos de trivia
  /// cuando la trivia no tiene preguntas en el servidor.
  List<PreguntaResponse> _generarPreguntasVirtuales(TriviaResponse trivia) {
    final registros = state.trivias;
    if (registros.length < 4) return [];

    var lote = _generador.generarLote(
      registros: registros,
      categoriaId: trivia.categoriaId,
      dificultad: trivia.dificultad,
      cantidad: 10,
    );
    if (lote.isEmpty) {
      lote = _generador.generarLote(
        registros: registros,
        categoriaId: trivia.categoriaId,
        cantidad: 10,
      );
    }
    if (lote.isEmpty) {
      lote = _generador.generarLote(registros: registros, cantidad: 10);
    }

    const letras = ['A', 'B', 'C', 'D'];
    final base = trivia.triviaId * 1000;
    return lote.asMap().entries.map((entrada) {
      final pregunta = entrada.value;
      final preguntaIdVirtual = -(base + entrada.key + 1);
      return PreguntaResponse(
        preguntaId: preguntaIdVirtual,
        triviaId: trivia.triviaId,
        preguntaTexto: pregunta.pregunta,
        puntos: pregunta.puntos,
        opciones: letras
            .asMap()
            .entries
            .map(
              (e) => OpcionRespuesta(
                opcionId: -(preguntaIdVirtual * 10 + e.key + 1),
                preguntaId: preguntaIdVirtual,
                textoOpcion: pregunta.opciones[e.value] ?? '',
                esCorrecta: pregunta.esLetraCorrecta(e.value),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  Future<void> seleccionarOpcion(int opcionId, bool esCorrecta) async {
    emit(
      state.copyWith(
        opcionSeleccionada: opcionId,
        respuestaCorrecta: esCorrecta,
      ),
    );
  }

  Future<void> confirmarRespuesta() async {
    if (state.opcionSeleccionada == null) return;

    final pregunta = state.preguntaActual;
    if (pregunta == null) return;

    final esCorrecta = state.respuestaCorrecta ?? false;

    if (!_usandoPreguntasVirtuales && state.intentoActual != null) {
      try {
        await _triviaService.registrarRespuesta(
          state.intentoActual!.intentoId,
          pregunta.preguntaId,
          state.opcionSeleccionada!,
          esCorrecta,
        );
      } catch (e, stackTrace) {
        developer.log(
          'Error al registrar respuesta',
          name: 'TriviaCubit',
          error: e,
          stackTrace: stackTrace,
        );
        emit(state.copyWith(error: 'Error al registrar respuesta'));
        return;
      }
    }

    final nuevosPuntos = state.puntuacion + (esCorrecta ? pregunta.puntos : 0);
    final nuevasCorrectas = state.respuestasCorrectas + (esCorrecta ? 1 : 0);
    final nuevosXp = state.xpGanados + (esCorrecta ? pregunta.puntos * 10 : 0);
    final nuevasMonedas =
        state.monedasGanadas + (esCorrecta ? pregunta.puntos : 0);

    String? respuestaCorrectaTexto;
    if (!esCorrecta) {
      final correcta = pregunta.opciones.firstWhere(
        (o) => o.esCorrecta,
        orElse: () => pregunta.opciones.first,
      );
      respuestaCorrectaTexto = correcta.textoOpcion;
    }

    emit(
      state.copyWith(
        showingFeedback: true,
        ultimaRespuestaCorrecta: esCorrecta,
        respuestaCorrectaTexto: respuestaCorrectaTexto,
        puntuacion: nuevosPuntos,
        respuestasCorrectas: nuevasCorrectas,
        xpGanados: nuevosXp,
        monedasGanadas: nuevasMonedas,
      ),
    );
  }

  void siguientePregunta() {
    if (state.esUltimaPregunta) {
      _finalizarTrivia();
    } else {
      emit(
        state.copyWith(
          showingFeedback: false,
          preguntaActualIndex: state.preguntaActualIndex + 1,
          clearOpcion: true,
          respuestaCorrecta: null,
          ultimaRespuestaCorrecta: null,
          respuestaCorrectaTexto: null,
        ),
      );
    }
  }

  Future<void> _finalizarTrivia() async {
    final xp = state.xpGanados;
    final monedas = state.monedasGanadas;
    final titulo = state.triviaActual?.titulo ?? 'Trivia completada';
    var guardadoConError = false;
    try {
      if (!_usandoPreguntasVirtuales && state.intentoActual != null) {
        await _triviaService.finalizarIntento(
          state.intentoActual!.intentoId,
          state.puntuacion,
        );
      }
      if (xp > 0 || monedas > 0) {
        final clave =
            'TRIVIA:${DateTime.now().microsecondsSinceEpoch}:$titulo';
        await _monederoService.reclamarRecompensa(
          tipo: 'TRIVIA',
          claveIdempotencia: clave,
          puntuacion: state.puntuacion,
          totalPreguntas: state.totalPreguntas,
          descripcion: 'Trivia "$titulo" completada',
        );
      }
      await _progresoService.incrementarTrivias(usuarioId);
    } catch (e, stackTrace) {
      developer.log(
        'Error al guardar resultados de trivia',
        name: 'TriviaCubit',
        error: e,
        stackTrace: stackTrace,
      );
      guardadoConError = true;
    }
    if (guardadoConError) {
      emit(state.copyWith(error: 'No se pudieron guardar tus resultados'));
    }
    emit(
      state.copyWith(mode: TriviaScreenMode.results, showingFeedback: false),
    );
    // Notify profile to refresh
    _onTriviaCompleted?.call();
    developer.log(
      'Trivia completada: $xp XP, $monedas monedas',
      name: 'TriviaCubit',
    );
  }

  void volverALista() {
    _usandoPreguntasVirtuales = false;
    emit(
      state.copyWith(
        mode: TriviaScreenMode.list,
        triviaActual: null,
        preguntas: [],
        intentoActual: null,
        showingFeedback: false,
        ultimaRespuestaCorrecta: null,
        respuestaCorrectaTexto: null,
        clearOpcion: true,
      ),
    );
  }

  Future<void> refresh() => loadTrivias();
}
