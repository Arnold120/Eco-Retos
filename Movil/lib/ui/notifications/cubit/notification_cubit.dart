import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/social/social_models.dart';
import '../../../data/services/social_service.dart';

class NotificationState extends Equatable {
  final List<NotificacionResponse> notificaciones;
  final int noLeidas;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notificaciones = const [],
    this.noLeidas = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificacionResponse>? notificaciones,
    int? noLeidas,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notificaciones: notificaciones ?? this.notificaciones,
      noLeidas: noLeidas ?? this.noLeidas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [notificaciones, noLeidas, isLoading, error];
}

class NotificationCubit extends Cubit<NotificationState> {
  final int usuarioId;
  final NotificacionService _service;

  Timer? _poll;

  NotificationCubit({
    required this.usuarioId,
    required NotificacionService service,
  })  : _service = service,
        super(const NotificationState());

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }

  /// Refresca en segundo plano para que el badge se mantenga al dia.
  void iniciarPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _refrescarSilencioso(),
    );
  }

  Future<void> _refrescarSilencioso() async {
    try {
      final results = await Future.wait([
        _service.getNotificaciones(usuarioId),
        _service.getNoLeidas(usuarioId),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        notificaciones: results[0],
        noLeidas: results[1].length,
      ));
    } catch (_) {
      // Silencioso: se reintenta en el siguiente ciclo.
    }
  }

  Future<void> loadNotificaciones() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _service.getNotificaciones(usuarioId),
        _service.getNoLeidas(usuarioId),
      ]);
      emit(state.copyWith(
        isLoading: false,
        notificaciones: results[0],
        noLeidas: results[1].length,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar notificaciones',
      ));
    }
  }

  Future<void> marcarLeida(int notificacionId) async {
    final anterior = state.notificaciones;
    final actualizadas = anterior
        .map((n) => n.notificacionId == notificacionId
            ? NotificacionResponse(
                notificacionId: n.notificacionId,
                usuarioId: n.usuarioId,
                titulo: n.titulo,
                mensaje: n.mensaje,
                tipo: n.tipo,
                leida: true,
                fecha: n.fecha,
                referenciaTipo: n.referenciaTipo,
                referenciaId: n.referenciaId,
                actorUsuarioId: n.actorUsuarioId,
              )
            : n)
        .toList();
    emit(state.copyWith(
      notificaciones: actualizadas,
      noLeidas: (state.noLeidas - 1).clamp(0, 1 << 31),
    ));
    try {
      await _service.marcarLeida(notificacionId);
    } catch (_) {
      emit(state.copyWith(notificaciones: anterior));
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      await _service.marcarTodasLeidas(usuarioId);
      await loadNotificaciones();
    } catch (_) {
      emit(state.copyWith(error: 'No se pudieron marcar como leídas.'));
    }
  }

  Future<void> eliminar(int notificacionId) async {
    final anterior = state.notificaciones;
    final actualizadas =
        anterior.where((n) => n.notificacionId != notificacionId).toList();
    emit(state.copyWith(
      notificaciones: actualizadas,
      noLeidas: actualizadas.where((n) => !n.leida).length,
    ));
    try {
      await _service.eliminar(notificacionId);
    } catch (_) {
      emit(state.copyWith(
        notificaciones: anterior,
        noLeidas: anterior.where((n) => !n.leida).length,
        error: 'No se pudo eliminar la notificación.',
      ));
    }
  }

  Future<void> eliminarTodas() async {
    final anterior = state.notificaciones;
    emit(state.copyWith(notificaciones: const [], noLeidas: 0));
    try {
      await _service.eliminarTodas(usuarioId);
    } catch (_) {
      emit(state.copyWith(
        notificaciones: anterior,
        noLeidas: anterior.where((n) => !n.leida).length,
        error: 'No se pudieron eliminar las notificaciones.',
      ));
    }
  }
}
