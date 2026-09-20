import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/social/social_models.dart';
import '../../../data/services/mensaje_service.dart';

class ConversationState extends Equatable {
  final List<MensajeResponse> mensajes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSending;
  final bool hasMore;
  final String? error;

  const ConversationState({
    this.mensajes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.hasMore = false,
    this.error,
  });

  ConversationState copyWith({
    List<MensajeResponse>? mensajes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ConversationState(
      mensajes: mensajes ?? this.mensajes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [mensajes, isLoading, isLoadingMore, isSending, hasMore, error];
}


class ConversationCubit extends Cubit<ConversationState> {
  final int conversacionId;
  final int usuarioId;
  final MensajeService _service;

  Timer? _poll;
  static const _limite = 40;

  ConversationCubit({
    required this.conversacionId,
    required this.usuarioId,
    required MensajeService service,
  })  : _service = service,
        super(const ConversationState());

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final mensajes = await _service.getMensajes(
        conversacionId,
        limite: _limite,
      );
      emit(state.copyWith(
        isLoading: false,
        mensajes: mensajes,
        hasMore: mensajes.length >= _limite,
      ));
      await marcarLeidos();
      iniciarPolling();
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No pudimos cargar la conversación. Inténtalo nuevamente.',
      ));
    }
  }

  Future<void> cargarMas() async {
    if (state.isLoadingMore || !state.hasMore || state.mensajes.isEmpty) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final anteriores = await _service.getMensajes(
        conversacionId,
        antesDe: state.mensajes.first.mensajeId,
        limite: _limite,
      );
      emit(state.copyWith(
        isLoadingMore: false,
        mensajes: [...anteriores, ...state.mensajes],
        hasMore: anteriores.length >= _limite,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: 'No pudimos cargar mensajes anteriores.',
      ));
    }
  }

  Future<bool> enviar(
    String contenido, {
    String tipo = 'TEXTO',
    String? archivoUrl,
    int? publicacionId,
    int? respuestaAId,
  }) async {
    final texto = contenido.trim();
    final tieneAdjunto = archivoUrl != null || publicacionId != null;
    if ((texto.isEmpty && !tieneAdjunto) || state.isSending) return false;
    emit(state.copyWith(isSending: true, clearError: true));
    try {
      final mensaje = await _service.enviarMensaje(
        conversacionId,
        texto,
        tipo: tipo,
        archivoUrl: archivoUrl,
        publicacionId: publicacionId,
        respuestaAId: respuestaAId,
      );
      emit(state.copyWith(
        isSending: false,
        mensajes: [...state.mensajes, mensaje],
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(
        isSending: false,
        error: 'No se pudo enviar el mensaje. Inténtalo nuevamente.',
      ));
      return false;
    }
  }

  Future<bool> editar(int mensajeId, String contenido) async {
    try {
      final actualizado = await _service.editarMensaje(
        conversacionId,
        mensajeId,
        contenido,
      );
      emit(state.copyWith(
        mensajes: state.mensajes
            .map((m) => m.mensajeId == mensajeId ? actualizado : m)
            .toList(),
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(error: 'No se pudo editar el mensaje.'));
      return false;
    }
  }

  Future<bool> eliminar(int mensajeId, {required bool paraTodos}) async {
    try {
      await _service.eliminarMensaje(
        conversacionId,
        mensajeId,
        paraTodos: paraTodos,
      );
      emit(state.copyWith(
        mensajes:
            state.mensajes.where((m) => m.mensajeId != mensajeId).toList(),
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(error: 'No se pudo eliminar el mensaje.'));
      return false;
    }
  }

  Future<void> marcarLeidos() async {
    try {
      await _service.marcarLeidos(conversacionId);
    } catch (_) {

    }
  }

  void iniciarPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _refrescar());
  }

  Future<void> _refrescar() async {
    try {
      final mensajes = await _service.getMensajes(
        conversacionId,
        limite: _limite,
      );
      if (isClosed) return;

      final frescos = {for (final m in mensajes) m.mensajeId: m};
      final actualizados =
          state.mensajes.map((m) => frescos[m.mensajeId] ?? m).toList();
      final ids = state.mensajes.map((m) => m.mensajeId).toSet();
      final nuevos = mensajes.where((m) => !ids.contains(m.mensajeId)).toList();
      final lista = [...actualizados, ...nuevos];

      var huboCambio = lista.length != state.mensajes.length;
      if (!huboCambio) {
        for (var i = 0; i < lista.length; i++) {
          if (lista[i].leido != state.mensajes[i].leido ||
              lista[i].contenido != state.mensajes[i].contenido ||
              lista[i].editado != state.mensajes[i].editado) {
            huboCambio = true;
            break;
          }
        }
      }
      if (!huboCambio) return;

      emit(state.copyWith(mensajes: lista));
      if (nuevos.isNotEmpty) await marcarLeidos();
    } catch (_) {

    }
  }
}
