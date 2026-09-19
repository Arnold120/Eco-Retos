import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/social/social_models.dart';
import '../../../data/services/busqueda_service.dart';

class SearchState extends Equatable {
  final String consulta;
  final bool buscando;
  final bool yaBusco;
  final ResultadoBusqueda? resultado;
  final String? error;

  const SearchState({
    this.consulta = '',
    this.buscando = false,
    this.yaBusco = false,
    this.resultado,
    this.error,
  });

  SearchState copyWith({
    String? consulta,
    bool? buscando,
    bool? yaBusco,
    ResultadoBusqueda? resultado,
    String? error,
    bool clearResultado = false,
    bool clearError = false,
  }) {
    return SearchState(
      consulta: consulta ?? this.consulta,
      buscando: buscando ?? this.buscando,
      yaBusco: yaBusco ?? this.yaBusco,
      resultado: clearResultado ? null : (resultado ?? this.resultado),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [consulta, buscando, yaBusco, resultado, error];
}

class SearchCubit extends Cubit<SearchState> {
  final BusquedaService _service;

  Timer? _debounce;
  int _consultaActual = 0;

  SearchCubit(this._service) : super(const SearchState());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void buscar(String termino) {
    _debounce?.cancel();
    final limpio = termino.trim();

    if (limpio.isEmpty) {
      _consultaActual++;
      emit(state.copyWith(
        consulta: '',
        buscando: false,
        yaBusco: false,
        clearResultado: true,
        clearError: true,
      ));
      return;
    }

    emit(state.copyWith(
      consulta: termino,
      buscando: true,
      clearError: true,
    ));

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _ejecutar(limpio);
    });
  }

  Future<void> _ejecutar(String termino) async {
    final consulta = ++_consultaActual;
    try {
      final resultado = await _service.buscar(termino);
      if (isClosed || consulta != _consultaActual) return;
      emit(state.copyWith(
        buscando: false,
        yaBusco: true,
        resultado: resultado,
      ));
    } catch (_) {
      if (isClosed || consulta != _consultaActual) return;
      emit(state.copyWith(
        buscando: false,
        yaBusco: true,
        error: 'No pudimos buscar. Revisa tu conexión e inténtalo de nuevo.',
      ));
    }
  }

  void limpiar() {
    _debounce?.cancel();
    _consultaActual++;
    emit(const SearchState());
  }
}
