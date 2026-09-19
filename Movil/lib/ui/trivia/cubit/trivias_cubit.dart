import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/models/trivia/diario_models.dart';
import '../../../data/repositories/trivia_recompensa_local.dart';
import '../../../data/repositories/trivias_diario_local.dart';
import '../../../data/services/categoria_service.dart';
import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/services/gamification_service.dart';
import 'trivias_state.dart';

/// Alimenta la pantalla principal de trivias: Modo Libre, Modo Diario y el
/// progreso semanal de la trivia diaria.
class TriviasCubit extends Cubit<TriviasState> {
  final int usuarioId;
  final DiarioStore _store;
  final CategoriaService _categoriaService;
  final MonederoService _monederoService;
  final ProgresoService _progresoService;
  final RecompensaLibreStore _recompensaStore;

  static const _inicialesSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  TriviasCubit({
    required this.usuarioId,
    required DiarioStore store,
    required CategoriaService categoriaService,
    required MonederoService monederoService,
    required ProgresoService progresoService,
    required RecompensaLibreStore recompensaStore,
  }) : _store = store,
       _categoriaService = categoriaService,
       _monederoService = monederoService,
       _progresoService = progresoService,
       _recompensaStore = recompensaStore,
       super(TriviasState.inicial());

  void _emit(TriviasState nuevo) {
    if (!isClosed) emit(nuevo);
  }

  Future<void> cargar() async {
    _emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final resultados = await Future.wait([
        _categoriaService.getCategorias(),
        _store.cargar(),
        // Saldo único de Monedas Eco.
        _monederoService.getSaldo(),
        _recompensaStore.cargar(),
      ]);
      if (isClosed) return;
      final categorias = resultados[0] as List<CategoriaResponse>;
      final progreso = resultados[1] as ProgresoDiario;
      final saldo = resultados[2] as SaldoMonederoResponse;
      final recompensaLibre = resultados[3] as RecompensaLibre?;

      final hoy = state.hoy;
      final inicio = inicioSemana(hoy);

      final semana = <DiaSemanaTrivia>[];
      for (var i = 0; i < 7; i++) {
        final fecha = DateTime(inicio.year, inicio.month, inicio.day + i);
        final weekday = fecha.weekday;
        final categoriaId = indiceCategoriaDelDia(fecha);
        final categoria = _buscarCategoria(categorias, categoriaId);
        final sesion = progreso.sesionDeDia(fecha);
        semana.add(
          DiaSemanaTrivia(
            weekday: weekday,
            inicial: _inicialesSemana[weekday - 1],
            categoriaId: categoriaId,
            categoriaNombre: categoria?.nombreCategoria ?? 'Categoría',
            completado: sesion?.completada ?? false,
            esHoy: esMismoDia(fecha, hoy),
          ),
        );
      }

      _emit(
        state.copyWith(
          isLoading: false,
          status: TriviasStatus.listo,
          racha: rachaEfectivaDiaria(progreso, hoy),
          mejorRacha: progreso.racha.mejor,
          monedasDisponibles: saldo.saldo,
          semana: semana,
          recompensaLibre: recompensaLibre,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar la pantalla de trivias',
        name: 'TriviasCubit',
        error: e,
        stackTrace: stackTrace,
      );
      if (isClosed) return;
      _emit(
        state.copyWith(
          isLoading: false,
          status: TriviasStatus.error,
          error:
              'No pudimos cargar las trivias. Revisa tu conexión e inténtalo de nuevo.',
        ),
      );
    }
  }

  /// Reclama la recompensa de Modo Libre que quedó pendiente en la pantalla
  /// principal. Entrega única: marca reclamada localmente antes del backend.
  Future<bool> reclamarRecompensaLibre() async {
    final recompensa = state.recompensaLibre;
    if (recompensa == null || !recompensa.pendiente) return false;
    if (state.recompensaReclamando) return false;

    _emit(state.copyWith(recompensaReclamando: true));

    // 1) Persistir reclamada PRIMERO (anti-duplicado offline-first)
    final reclamada = recompensa.copyWith(reclamada: true);
    await _recompensaStore.guardar(reclamada);

    // 2) Backend: recompensa idempotente calculada por el servidor.
    try {
      final clave = recompensa.clave.isNotEmpty
          ? recompensa.clave
          : DateTime.now().microsecondsSinceEpoch.toString();
      final respuesta = await _monederoService.reclamarRecompensa(
        tipo: 'TRIVIA',
        claveIdempotencia: 'TRIVIA_LIBRE:$clave',
        puntuacion: recompensa.puntos,
        totalPreguntas: recompensa.totalPreguntas,
        descripcion: 'Modo libre completado',
      );
      await _progresoService.incrementarTrivias(usuarioId);
      if (!isClosed) {
        _emit(state.copyWith(monedasDisponibles: respuesta.saldo));
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error al reclamar recompensa libre desde Trivias',
        name: 'TriviasCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }

    if (isClosed) return false;

    _emit(
      state.copyWith(
        recompensaLibre: reclamada,
        recompensaReclamando: false,
      ),
    );
    developer.log(
      'Recompensas del modo libre reclamadas desde Trivias',
      name: 'TriviasCubit',
    );
    return true;
  }

  static CategoriaResponse? _buscarCategoria(
    List<CategoriaResponse> categorias,
    int categoriaId,
  ) {
    for (final categoria in categorias) {
      if (categoria.categoriaId == categoriaId) return categoria;
    }
    return null;
  }
}