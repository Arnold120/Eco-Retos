import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/social/social_models.dart';
import '../../../data/services/calificacion_service.dart';
import '../../../data/services/perfil_social_service.dart';
import '../../../data/services/social_interaction_service.dart';
import '../../../data/services/social_service.dart';

class PublicProfileState extends Equatable {
  final PerfilPublicoResponse? perfil;
  final List<PublicacionResponse> publicaciones;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool guardandoSeguimiento;
  final ResumenCalificaciones? calificaciones;
  final bool cargandoCalificaciones;
  final List<PublicacionResponse> menciones;
  final bool cargandoMenciones;
  final String? error;

  const PublicProfileState({
    this.perfil,
    this.publicaciones = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.guardandoSeguimiento = false,
    this.calificaciones,
    this.cargandoCalificaciones = false,
    this.menciones = const [],
    this.cargandoMenciones = false,
    this.error,
  });

  PublicProfileState copyWith({
    PerfilPublicoResponse? perfil,
    List<PublicacionResponse>? publicaciones,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? guardandoSeguimiento,
    ResumenCalificaciones? calificaciones,
    bool? cargandoCalificaciones,
    List<PublicacionResponse>? menciones,
    bool? cargandoMenciones,
    String? error,
    bool clearError = false,
  }) {
    return PublicProfileState(
      perfil: perfil ?? this.perfil,
      publicaciones: publicaciones ?? this.publicaciones,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      guardandoSeguimiento: guardandoSeguimiento ?? this.guardandoSeguimiento,
      calificaciones: calificaciones ?? this.calificaciones,
      cargandoCalificaciones:
          cargandoCalificaciones ?? this.cargandoCalificaciones,
      menciones: menciones ?? this.menciones,
      cargandoMenciones: cargandoMenciones ?? this.cargandoMenciones,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        perfil,
        publicaciones,
        isLoading,
        isLoadingMore,
        hasMore,
        guardandoSeguimiento,
        calificaciones,
        cargandoCalificaciones,
        menciones,
        cargandoMenciones,
        error,
      ];
}

class PublicProfileCubit extends Cubit<PublicProfileState> {
  final int usuarioId;
  final PerfilSocialService _perfiles;
  final PublicacionService _publicaciones;
  final SeguimientoService _seguimientos;
  final CalificacionService _calificaciones;

  static const _tamanoPagina = 30;
  int _pagina = 1;

  PublicProfileCubit({
    required this.usuarioId,
    required PerfilSocialService perfilService,
    required PublicacionService publicacionService,
    required SeguimientoService seguimientoService,
    required CalificacionService calificacionService,
  })  : _perfiles = perfilService,
        _publicaciones = publicacionService,
        _seguimientos = seguimientoService,
        _calificaciones = calificacionService,
        super(const PublicProfileState());

  Future<void> load() async {
    emit(state.copyWith(
      isLoading: true,
      cargandoCalificaciones: state.calificaciones == null,
      cargandoMenciones: state.menciones.isEmpty,
      clearError: true,
    ));
    _pagina = 1;
    try {
      final perfil = await _perfiles.getPerfilPublico(usuarioId);
      final publicaciones = await _publicaciones.getFeed(
        pagina: 1,
        tamano: _tamanoPagina,
        autorId: usuarioId,
      );
      emit(state.copyWith(
        isLoading: false,
        perfil: perfil,
        publicaciones: publicaciones,
        hasMore: publicaciones.length >= _tamanoPagina,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No pudimos cargar este perfil. Inténtalo nuevamente.',
      ));
    }
    await _cargarExtras();
  }

  Future<void> _cargarExtras() async {
    try {
      final resumen = await _calificaciones.getResumen(usuarioId);
      if (isClosed) return;
      emit(state.copyWith(
        calificaciones: resumen,
        cargandoCalificaciones: false,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(cargandoCalificaciones: false));
    }
    try {
      final menciones = await _publicaciones.getMenciones(usuarioId);
      if (isClosed) return;
      emit(state.copyWith(
        menciones: menciones,
        cargandoMenciones: false,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(cargandoMenciones: false));
    }
  }

  Future<void> cargarMas() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final siguientes = await _publicaciones.getFeed(
        pagina: _pagina + 1,
        tamano: _tamanoPagina,
        autorId: usuarioId,
      );
      _pagina++;
      final ids = state.publicaciones.map((p) => p.publicacionId).toSet();
      final nuevos =
          siguientes.where((p) => !ids.contains(p.publicacionId)).toList();
      emit(state.copyWith(
        isLoadingMore: false,
        publicaciones: [...state.publicaciones, ...nuevos],
        hasMore: siguientes.length >= _tamanoPagina && nuevos.isNotEmpty,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingMore: false,
        hasMore: false,
      ));
    }
  }

  Future<void> toggleSeguir() async {
    final perfil = state.perfil;
    if (perfil == null || perfil.esMiPerfil || state.guardandoSeguimiento) {
      return;
    }

    final siguiendo = !perfil.siguiendo;
    emit(state.copyWith(
      guardandoSeguimiento: true,
      perfil: perfil.copyWith(
        siguiendo: siguiendo,
        cantidadSeguidores:
            (perfil.cantidadSeguidores + (siguiendo ? 1 : -1)).clamp(0, 1 << 31),
      ),
    ));

    try {
      final estado = siguiendo
          ? await _seguimientos.seguir(usuarioId)
          : await _seguimientos.dejarDeSeguir(usuarioId);
      emit(state.copyWith(
        guardandoSeguimiento: false,
        perfil: perfil.copyWith(
          siguiendo: estado.siguiendo,
          cantidadSeguidores: estado.seguidores,
        ),
      ));
    } catch (_) {
      emit(state.copyWith(
        guardandoSeguimiento: false,
        perfil: perfil,
        error: siguiendo
            ? 'No pudimos seguir a este usuario.'
            : 'No pudimos dejar de seguir a este usuario.',
      ));
    }
  }

  void actualizarPost(PublicacionResponse post) {
    final publicaciones = state.publicaciones
        .map((p) => p.publicacionId == post.publicacionId ? post : p)
        .toList();
    emit(state.copyWith(publicaciones: publicaciones));
  }

  Future<void> recargarExtras() async {
    emit(state.copyWith(
      cargandoCalificaciones: state.calificaciones == null,
      cargandoMenciones: true,
    ));
    await _cargarExtras();
  }

  void quitarPost(int publicacionId) {
    final perfil = state.perfil;
    emit(state.copyWith(
      publicaciones: state.publicaciones
          .where((p) => p.publicacionId != publicacionId)
          .toList(),
      perfil: perfil?.copyWith(
        cantidadPublicaciones:
            (perfil.cantidadPublicaciones - 1).clamp(0, 1 << 31),
      ),
    ));
  }

  Future<bool> calificar({
    required int calificacion,
    String? comentario,
  }) async {
    if (state.perfil?.esMiPerfil == true) return false;
    try {
      final resumen = await _calificaciones.calificar(
        usuarioId,
        calificacion: calificacion,
        comentario: comentario,
      );
      emit(state.copyWith(calificaciones: resumen));
      return true;
    } catch (_) {
      emit(state.copyWith(
        error: 'No pudimos guardar tu calificación. Inténtalo nuevamente.',
      ));
      return false;
    }
  }

  Future<bool> eliminarCalificacion() async {
    if (state.perfil?.esMiPerfil == true) return false;
    try {
      await _calificaciones.eliminar(usuarioId);
      final resumen = await _calificaciones.getResumen(usuarioId);
      emit(state.copyWith(calificaciones: resumen));
      return true;
    } catch (_) {
      emit(state.copyWith(
        error: 'No pudimos quitar tu calificación. Inténtalo nuevamente.',
      ));
      return false;
    }
  }
}
