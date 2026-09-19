import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/social/social_models.dart';
import '../../../data/services/mensaje_service.dart';

class MessagesState extends Equatable {
  final List<ConversacionResumen> conversaciones;
  final bool isLoading;
  final String? error;
  final int totalNoLeidos;

  const MessagesState({
    this.conversaciones = const [],
    this.isLoading = false,
    this.error,
    this.totalNoLeidos = 0,
  });

  MessagesState copyWith({
    List<ConversacionResumen>? conversaciones,
    bool? isLoading,
    String? error,
    int? totalNoLeidos,
    bool clearError = false,
  }) {
    return MessagesState(
      conversaciones: conversaciones ?? this.conversaciones,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      totalNoLeidos: totalNoLeidos ?? this.totalNoLeidos,
    );
  }

  @override
  List<Object?> get props =>
      [conversaciones, isLoading, error, totalNoLeidos];
}


class MessagesCubit extends Cubit<MessagesState> {
  final MensajeService _service;

  Timer? _poll;

  MessagesCubit(this._service) : super(const MessagesState());

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final conversaciones = await _service.getConversaciones();
      emit(state.copyWith(
        isLoading: false,
        conversaciones: conversaciones,
        totalNoLeidos:
            conversaciones.fold<int>(0, (a, c) => a + c.noLeidos),
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No pudimos cargar tus conversaciones. Inténtalo nuevamente.',
      ));
    }
  }


  Future<void> refrescarNoLeidos() async {
    try {
      final total = await _service.getConteoNoLeidos();
      emit(state.copyWith(totalNoLeidos: total));
    } catch (_) {

    }
  }

  void iniciarPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final conversaciones = await _service.getConversaciones();
        if (isClosed) return;
        emit(state.copyWith(
          conversaciones: conversaciones,
          totalNoLeidos:
              conversaciones.fold<int>(0, (a, c) => a + c.noLeidos),
        ));
      } catch (_) {

      }
    });
  }

  Future<ConversacionResumen?> abrirConversacion(int usuarioId) async {
    try {
      return await _service.abrirConversacion(usuarioId);
    } catch (_) {
      emit(state.copyWith(
        error: 'No pudimos abrir la conversación. Inténtalo nuevamente.',
      ));
      return null;
    }
  }
}
