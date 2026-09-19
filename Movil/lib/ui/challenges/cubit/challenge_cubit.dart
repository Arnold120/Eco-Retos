import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/catalogos/retos/reto_model.dart';
import '../../../data/catalogos/retos/retos_catalogo.dart';
import '../../../data/repositories/reto_repository.dart';
import 'challenge_state.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  final RetoRepository _repositorio;

  ChallengeCubit({required RetoRepository repositorio})
    : _repositorio = repositorio,
      super(const ChallengeState());



  Future<void> cargar() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final retos = await _repositorio.obtener();
      final delDia = _retosDelDia(retos);
      emit(
        state.copyWith(
          isLoading: false,
          retos: retos,
          retoDelDia: delDia,
          aprobacionesRecientes: List.of(_repositorio.aprobacionesRecientes),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(isLoading: false, error: 'No se pudo cargar los retos'),
      );
    }
  }


  void limpiarAprobaciones() {
    if (state.aprobacionesRecientes.isEmpty) return;
    emit(state.copyWith(aprobacionesRecientes: const []));
  }

  RetoProgreso? _retosDelDia(List<RetoProgreso> todos) {
    final reto = RetoCatalogo.retoDelDia(DateTime.now());
    if (reto == null) return null;
    for (final p in todos) {
      if (p.reto.id == reto.id) return p;
    }
    return RetoProgreso(reto: reto);
  }

  Future<void> refresh() => cargar();



  void buscar(String termino) => emit(state.copyWith(busqueda: termino));

  void filtrarDificultad(RetoDificultad? dificultad) {
    emit(
      dificultad == null || dificultad == state.dificultadSeleccionada
          ? state.copyWith(clearDificultad: true)
          : state.copyWith(dificultadSeleccionada: dificultad),
    );
  }

  void filtrarCategoria(RetoCategoria? categoria) {
    emit(
      categoria == null || categoria == state.categoriaSeleccionada
          ? state.copyWith(clearCategoria: true)
          : state.copyWith(categoriaSeleccionada: categoria),
    );
  }

  void filtrarTipo(RetoTipo? tipo) {
    emit(
      tipo == null || tipo == state.tipoSeleccionado
          ? state.copyWith(clearTipo: true)
          : state.copyWith(tipoSeleccionado: tipo),
    );
  }

  void cambiarSeccion(RetosSeccion seccion) =>
      emit(state.copyWith(seccion: seccion));




  Future<RetoProgreso?> comenzar(Reto reto) async {
    final progreso = await _repositorio.comenzar(reto);
    _actualizar(progreso);
    return _estadoDe(reto.id);
  }


  Future<RetoProgreso?> avanzarPaso(Reto reto, int pasoCompletado) async {
    final progreso = await _repositorio.avanzarPaso(reto, pasoCompletado);
    _actualizar(progreso);
    return _estadoDe(reto.id);
  }


  Future<RetoProgreso?> enviarEvidencia(Reto reto, String evidencia) async {
    final progreso = await _repositorio.enviarEvidencia(reto, evidencia);
    _actualizar(progreso);
    return _estadoDe(reto.id);
  }


  Future<CompletarResultado> completar(Reto reto) async {
    final resultado = await _repositorio.completar(reto);
    _actualizar(resultado.progreso);
    return resultado;
  }

  void _actualizar(RetoProgreso progreso) {
    final lista = state.retos
        .map((p) => p.reto.id == progreso.reto.id ? progreso : p)
        .toList();
    emit(state.copyWith(retos: lista));
  }

  RetoProgreso? _estadoDe(String retoId) {
    for (final p in state.retos) {
      if (p.reto.id == retoId) return p;
    }
    for (final r in RetoCatalogo.todos) {
      if (r.id == retoId) return RetoProgreso(reto: r);
    }
    return null;
  }
}
