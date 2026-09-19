import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/social/social_models.dart';
import '../../../data/services/social_interaction_service.dart';
import '../../../data/services/social_service.dart';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final int usuarioId;
  final PublicacionService _publicaciones;
  final ReaccionService _reacciones;
  final SeguimientoService _seguimientos;
  final GuardadoService _guardados;

  Timer? _debounceBusqueda;
  Timer? _sondeo;
  int _consultaBusqueda = 0;

  static const _tamanoPagina = 10;

  CommunityCubit({
    required this.usuarioId,
    required PublicacionService publicacionService,
    required ReaccionService reaccionService,
    required SeguimientoService seguimientoService,
    required GuardadoService guardadoService,
  })  : _publicaciones = publicacionService,
        _reacciones = reaccionService,
        _seguimientos = seguimientoService,
        _guardados = guardadoService,
        super(const CommunityState());

  @override
  Future<void> close() {
    _debounceBusqueda?.cancel();
    _sondeo?.cancel();
    return super.close();
  }

  // ─── Actualizacion automatica ───────────────────────────────────────────

  /// Refresca la primera pagina sin mostrar cargando ni perder el scroll.
  /// Sirve para que los cambios de otros usuarios aparezcan sin tener que
  /// recargar manualmente.
  Future<void> refrescarSilencioso() async {
    if (state.isLoading || state.isLoadingMore || state.esBusqueda) return;
    try {
      final nuevas = await _cargarSegunFiltro(pagina: 1);
      if (isClosed) return;

      final existentes = {
        for (final p in state.publicaciones) p.publicacionId: p,
      };
      final actualizadas = <PublicacionResponse>[];
      for (final p in nuevas) {
        final existente = existentes[p.publicacionId];
        if (existente != null && state.procesando.contains(p.publicacionId)) {
          actualizadas.add(existente);
        } else {
          actualizadas.add(p);
        }
      }

      final idsPrimeraPagina = nuevas.map((p) => p.publicacionId).toSet();
      final resto = state.publicaciones
          .where((p) => !idsPrimeraPagina.contains(p.publicacionId));

      emit(state.copyWith(
        publicaciones: [...actualizadas, ...resto],
        guardadasIds: {
          ...state.guardadasIds,
          ...nuevas
              .where((p) => p.guardada)
              .map((p) => p.publicacionId),
        },
      ));
    } catch (_) {
      // Silencioso: se reintenta en el siguiente ciclo o al refrescar.
    }
  }

  /// Sondea el feed cada 25 s mientras el muro esta visible.
  void iniciarSondeo() {
    _sondeo?.cancel();
    _sondeo = Timer.periodic(
      const Duration(seconds: 25),
      (_) => refrescarSilencioso(),
    );
  }

  void detenerSondeo() {
    _sondeo?.cancel();
    _sondeo = null;
  }

  // ─── Carga del feed ─────────────────────────────────────────────────────

  Future<void> loadPublicaciones() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      // El feed y el seguimiento se cargan por separado: si uno falla, el
      // otro se conserva (evita que las sugerencias muestren usuarios ya
      // seguidos cuando el feed tiene problemas).
      List<int> seguidos = state.siguiendoIds.toList();
      try {
        seguidos = await _seguimientos.getIdsSeguidos();
      } catch (_) {
        // Se conservan los seguidos que ya estuvieran cargados.
      }
      final posts = await _cargarSegunFiltro(pagina: 1);
      final ocultas = await _cargarOcultas();

      emit(state.copyWith(
        isLoading: false,
        publicaciones: posts,
        siguiendoIds: seguidos.toSet(),
        ocultadasIds: ocultas,
        guardadasIds: posts
            .where((p) => p.guardada)
            .map((p) => p.publicacionId)
            .toSet(),
        pagina: 1,
        hasMore: posts.length >= _tamanoPagina,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No pudimos cargar las publicaciones. Inténtalo nuevamente.',
      ));
    }
  }

  Future<List<PublicacionResponse>> _cargarSegunFiltro({required int pagina}) {
    switch (state.filtro) {
      case MuroFiltro.guardadas:
        return _publicaciones.getPublicacionesGuardadas();
      case MuroFiltro.misPublicaciones:
        return _publicaciones.getFeed(
          pagina: pagina,
          tamano: _tamanoPagina,
          autorId: usuarioId,
        );
      case MuroFiltro.siguiendo:
        return _publicaciones.getFeed(
          pagina: pagina,
          tamano: _tamanoPagina,
          siguiendo: true,
        );
      case MuroFiltro.paraTi:
      case MuroFiltro.recientes:
      case MuroFiltro.populares:
      case MuroFiltro.cercaDeTi:
        return _publicaciones.getFeed(pagina: pagina, tamano: _tamanoPagina);
    }
  }

  Future<void> cargarMas() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    if (state.filtro == MuroFiltro.guardadas) {
      emit(state.copyWith(hasMore: false));
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final siguientes = await _cargarSegunFiltro(pagina: state.pagina + 1);
      final existentes = state.publicaciones.map((p) => p.publicacionId).toSet();
      final nuevos =
          siguientes.where((p) => !existentes.contains(p.publicacionId)).toList();

      emit(state.copyWith(
        isLoadingMore: false,
        publicaciones: [...state.publicaciones, ...nuevos],
        pagina: state.pagina + 1,
        hasMore: siguientes.length >= _tamanoPagina && nuevos.isNotEmpty,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingMore: false,
        hasMore: false,
        error: 'No pudimos cargar más publicaciones.',
      ));
    }
  }

  Future<void> refresh() => loadPublicaciones();

  // ─── Filtros y búsqueda ─────────────────────────────────────────────────

  Future<void> cambiarFiltro(MuroFiltro filtro) async {
    if (state.filtro == filtro) return;
    _debounceBusqueda?.cancel();
    emit(state.copyWith(
      filtro: filtro,
      esBusqueda: false,
      clearBusqueda: true,
      publicaciones: const [],
      pagina: 1,
      hasMore: true,
      clearError: true,
    ));
    await loadPublicaciones();
  }

  /// Búsqueda con debounce contra el backend.
  void buscar(String termino) {
    _debounceBusqueda?.cancel();
    final limpio = termino.trim();
    if (limpio.isEmpty) {
      limpiarBusqueda();
      return;
    }
    emit(state.copyWith(
      busqueda: termino,
      esBusqueda: true,
      isLoading: true,
      clearError: true,
    ));
    _debounceBusqueda = Timer(const Duration(milliseconds: 350), () {
      _ejecutarBusqueda(limpio);
    });
  }

  Future<void> _ejecutarBusqueda(String termino) async {
    final consulta = ++_consultaBusqueda;
    try {
      final resultados = await _publicaciones.buscar(termino);
      if (isClosed || consulta != _consultaBusqueda) return;
      emit(state.copyWith(
        isLoading: false,
        publicaciones: resultados,
        pagina: 1,
        hasMore: false,
      ));
    } catch (_) {
      if (isClosed || consulta != _consultaBusqueda) return;
      emit(state.copyWith(
        isLoading: false,
        error: 'No pudimos realizar la búsqueda. Inténtalo nuevamente.',
      ));
    }
  }

  void limpiarBusqueda() {
    _debounceBusqueda?.cancel();
    _consultaBusqueda++;
    emit(state.copyWith(
      clearBusqueda: true,
      esBusqueda: false,
      isLoading: false,
      clearError: true,
    ));
    loadPublicaciones();
  }

  // ─── Reacciones ─────────────────────────────────────────────────────────

  Future<void> toggleMeGusta(PublicacionResponse post) async {
    if (state.procesando.contains(post.publicacionId)) return;
    final activo = !post.meGusta;

    _actualizarPost(
      post.publicacionId,
      (p) => p.copyWith(
        meGusta: activo,
        cantidadLikes: (p.cantidadLikes + (activo ? 1 : -1)).clamp(0, 1 << 31),
      ),
    );
    _marcarProcesando(post.publicacionId, true);

    try {
      final resultado = await _reacciones.alternar(
        publicacionId: post.publicacionId,
        tipo: 'ME_GUSTA',
      );
      _actualizarPost(
        post.publicacionId,
        (p) => p.copyWith(
          meGusta: resultado.activa,
          cantidadLikes: resultado.total,
        ),
      );
    } catch (_) {
      _actualizarPost(
        post.publicacionId,
        (p) => p.copyWith(
          meGusta: post.meGusta,
          cantidadLikes: post.cantidadLikes,
        ),
      );
      emit(state.copyWith(
        error: 'No pudimos registrar tu reacción. Revisa tu conexión.',
      ));
    } finally {
      _marcarProcesando(post.publicacionId, false);
    }
  }

  Future<ResultadoReaccion?> toggleMeGustaComentario(
      ComentarioResponse comentario) async {
    try {
      return await _reacciones.alternar(
        comentarioId: comentario.comentarioId,
        tipo: 'ME_GUSTA',
      );
    } catch (_) {
      emit(state.copyWith(
        error: 'No pudimos registrar tu reacción al comentario.',
      ));
      return null;
    }
  }

  // ─── Guardados ──────────────────────────────────────────────────────────

  Future<void> toggleGuardada(PublicacionResponse post) async {
    if (state.procesando.contains(post.publicacionId)) return;
    final guardar = !post.guardada;

    _actualizarPost(
      post.publicacionId,
      (p) => p.copyWith(guardada: guardar),
    );
    _marcarProcesando(post.publicacionId, true);

    try {
      final resultado = await _guardados.alternar(post.publicacionId);
      _actualizarPost(
        post.publicacionId,
        (p) => p.copyWith(guardada: resultado),
      );
      final ids = Set<int>.of(state.guardadasIds);
      if (resultado) {
        ids.add(post.publicacionId);
      } else {
        ids.remove(post.publicacionId);
      }
      emit(state.copyWith(
        guardadasIds: ids,
        mensajeExito:
            resultado ? 'Guardado en tus publicaciones' : 'Se quitó de guardadas',
      ));
    } catch (_) {
      _actualizarPost(
        post.publicacionId,
        (p) => p.copyWith(guardada: post.guardada),
      );
      emit(state.copyWith(
        error: 'No pudimos actualizar el guardado. Inténtalo nuevamente.',
      ));
    } finally {
      _marcarProcesando(post.publicacionId, false);
    }
  }

  // ─── Seguimiento ────────────────────────────────────────────────────────

  /// Sincroniza el estado de seguimiento cuando otra pantalla lo obtuvo del
  /// backend (perfil publico), sin lanzar peticiones adicionales.
  void sincronizarSeguimiento(int objetivoId, bool siguiendo) {
    if (objetivoId == usuarioId) return;
    final ids = Set<int>.of(state.siguiendoIds);
    final cambio = siguiendo ? ids.add(objetivoId) : ids.remove(objetivoId);
    if (cambio) emit(state.copyWith(siguiendoIds: ids));
  }

  Future<void> toggleSeguir(int objetivoId) async {
    if (objetivoId == usuarioId) return;
    final siguiendo = state.siguiendoIds.contains(objetivoId);
    final ids = Set<int>.of(state.siguiendoIds);
    if (siguiendo) {
      ids.remove(objetivoId);
    } else {
      ids.add(objetivoId);
    }
    emit(state.copyWith(siguiendoIds: ids));

    try {
      if (siguiendo) {
        await _seguimientos.dejarDeSeguir(objetivoId);
      } else {
        await _seguimientos.seguir(objetivoId);
      }
    } catch (_) {
      final revertidas = Set<int>.of(state.siguiendoIds);
      if (siguiendo) {
        revertidas.add(objetivoId);
      } else {
        revertidas.remove(objetivoId);
      }
      emit(state.copyWith(
        siguiendoIds: revertidas,
        error: siguiendo
            ? 'No pudimos dejar de seguir a este usuario.'
            : 'No pudimos seguir a este usuario.',
      ));
    }
  }

  // ─── Publicaciones ──────────────────────────────────────────────────────

  Future<PublicacionResponse?> crearPublicacion({
    required String contenido,
    String? imagen,
    String tipo = 'GENERAL',
    String? ubicacion,
    String? categoria,
    String visibilidad = 'PUBLICO',
    List<MultimediaItem> multimedia = const [],
    int? compartidoDeId,
  }) async {
    try {
      final creada = await _publicaciones.crearPublicacion(
        CrearPublicacionRequest(
          usuarioId: usuarioId,
          contenido: contenido,
          imagen: imagen,
          tipo: tipo,
          ubicacion: ubicacion,
          categoria: categoria,
          visibilidad: visibilidad,
          multimedia: multimedia,
          compartidoDeId: compartidoDeId,
        ),
      );
      emit(state.copyWith(
        publicaciones: [creada, ...state.publicaciones],
        mensajeExito:
            compartidoDeId != null ? 'Compartido en tu muro' : 'Publicación creada correctamente',
      ));
      return creada;
    } catch (_) {
      emit(state.copyWith(
        error: 'No se pudo publicar. Inténtalo nuevamente.',
      ));
      return null;
    }
  }

  Future<PublicacionResponse?> editarPublicacion(
    PublicacionResponse post, {
    required String contenido,
    String? imagen,
    String? ubicacion,
    String? categoria,
    String? visibilidad,
    List<MultimediaItem>? multimedia,
  }) async {
    try {
      final actualizada = await _publicaciones.actualizarPublicacion(
        post.publicacionId,
        ActualizarPublicacionRequest(
          contenido: contenido,
          imagen: imagen,
          tipo: post.tipo,
          estado: post.estado,
          ubicacion: ubicacion,
          categoria: categoria,
          visibilidad: visibilidad ?? post.visibilidad,
          multimedia: multimedia,
        ),
      );
      _reemplazarPost(actualizada);
      emit(state.copyWith(mensajeExito: 'Publicación actualizada'));
      return actualizada;
    } catch (_) {
      emit(state.copyWith(
        error: 'No se pudo actualizar la publicación. Inténtalo nuevamente.',
      ));
      return null;
    }
  }

  Future<bool> eliminarPublicacion(int publicacionId) async {
    final respaldo = state.publicaciones;
    emit(state.copyWith(
      publicaciones: respaldo
          .where((p) => p.publicacionId != publicacionId)
          .toList(),
    ));

    try {
      await _publicaciones.eliminarPublicacion(publicacionId);
      emit(state.copyWith(mensajeExito: 'Publicación eliminada'));
      return true;
    } catch (_) {
      emit(state.copyWith(
        publicaciones: respaldo,
        error: 'No se pudo eliminar la publicación. Inténtalo nuevamente.',
      ));
      return false;
    }
  }

  Future<void> ocultarPublicacion(PublicacionResponse post) async {
    final ocultas = Set<int>.of(state.ocultadasIds)..add(post.publicacionId);
    emit(state.copyWith(
      ocultadasIds: ocultas,
      mensajeExito: 'Publicación ocultada',
    ));
    await _guardarOcultas(ocultas);
  }

  // ─── Comentarios ────────────────────────────────────────────────────────

  Future<List<ComentarioResponse>> getComentarios(int publicacionId) async {
    try {
      return await _publicaciones.getComentarios(publicacionId);
    } catch (_) {
      emit(state.copyWith(
        error: 'No pudimos cargar los comentarios. Inténtalo nuevamente.',
      ));
      return [];
    }
  }

  Future<ComentarioResponse?> agregarComentario(
    int publicacionId,
    String texto, {
    int? comentarioPadreId,
  }) async {
    try {
      final creado = await _publicaciones.crearComentario(
        CrearComentarioRequest(
          publicacionId: publicacionId,
          usuarioId: usuarioId,
          comentarioTexto: texto,
          comentarioPadreId: comentarioPadreId,
        ),
      );
      _actualizarPost(
        publicacionId,
        (p) => p.copyWith(cantidadComentarios: p.cantidadComentarios + 1),
      );
      return creado;
    } catch (_) {
      emit(state.copyWith(
        error: 'No se pudo publicar el comentario. Inténtalo nuevamente.',
      ));
      return null;
    }
  }

  Future<ComentarioResponse?> editarComentario(
      int comentarioId, String texto) async {
    try {
      return await _publicaciones.actualizarComentario(comentarioId, texto);
    } catch (_) {
      emit(state.copyWith(
        error: 'No se pudo editar el comentario. Inténtalo nuevamente.',
      ));
      return null;
    }
  }

  Future<bool> eliminarComentario(
      int publicacionId, int comentarioId) async {
    try {
      await _publicaciones.eliminarComentario(comentarioId);
      _actualizarPost(
        publicacionId,
        (p) => p.copyWith(
          cantidadComentarios: (p.cantidadComentarios - 1).clamp(0, 1 << 31),
        ),
      );
      return true;
    } catch (_) {
      emit(state.copyWith(
        error: 'No se pudo eliminar el comentario. Inténtalo nuevamente.',
      ));
      return false;
    }
  }

  // ─── Utilidades ─────────────────────────────────────────────────────────

  void _actualizarPost(
    int publicacionId,
    PublicacionResponse Function(PublicacionResponse) transform,
  ) {
    final publicaciones = state.publicaciones.map((p) {
      if (p.publicacionId != publicacionId) return p;
      return transform(p);
    }).toList();
    emit(state.copyWith(publicaciones: publicaciones));
  }

  void _reemplazarPost(PublicacionResponse nuevo) {
    final existe =
        state.publicaciones.any((p) => p.publicacionId == nuevo.publicacionId);
    final publicaciones = existe
        ? state.publicaciones
            .map((p) => p.publicacionId == nuevo.publicacionId ? nuevo : p)
            .toList()
        : [nuevo, ...state.publicaciones];
    emit(state.copyWith(publicaciones: publicaciones));
  }

  void _marcarProcesando(int publicacionId, bool valor) {
    final ids = Set<int>.of(state.procesando);
    if (valor) {
      ids.add(publicacionId);
    } else {
      ids.remove(publicacionId);
    }
    emit(state.copyWith(procesando: ids));
  }

  Future<Set<int>> _cargarOcultas() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('muro_ocultas_$usuarioId') ?? const [];
    return lista.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }

  Future<void> _guardarOcultas(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'muro_ocultas_$usuarioId',
      ids.map((e) => e.toString()).toList(),
    );
  }

  void limpiarMensajes() {
    emit(state.copyWith(clearMensaje: true, clearError: true));
  }

  void avisoSoporte(String mensaje) {
    emit(state.copyWith(mensajeExito: mensaje, clearError: true));
  }
}
