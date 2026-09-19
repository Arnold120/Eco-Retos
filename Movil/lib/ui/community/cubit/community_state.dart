import 'package:equatable/equatable.dart';

import '../../../data/models/social/social_models.dart';

enum MuroFiltro {
  paraTi,
  siguiendo,
  recientes,
  populares,
  cercaDeTi,
  misPublicaciones,
  guardadas,
}

class CommunityState extends Equatable {
  final List<PublicacionResponse> publicaciones;
  final MuroFiltro filtro;
  final String busqueda;
  final bool esBusqueda;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int pagina;
  final String? error;
  final String? mensajeExito;
  final Set<int> siguiendoIds;
  final Set<int> guardadasIds;
  final Set<int> ocultadasIds;
  final Set<int> procesando;

  const CommunityState({
    this.publicaciones = const [],
    this.filtro = MuroFiltro.paraTi,
    this.busqueda = '',
    this.esBusqueda = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.pagina = 1,
    this.error,
    this.mensajeExito,
    this.siguiendoIds = const {},
    this.guardadasIds = const {},
    this.ocultadasIds = const {},
    this.procesando = const {},
  });

  /// Publicaciones visibles con los filtros locales aplicados.
  List<PublicacionResponse> get feed {
    var lista = publicaciones
        .where((p) => !ocultadasIds.contains(p.publicacionId))
        .toList();

    switch (filtro) {
      case MuroFiltro.paraTi:
        // Cronologico estricto: lo mas reciente arriba.
        lista.sort((a, b) => b.fechaPublicacion.compareTo(a.fechaPublicacion));
      case MuroFiltro.populares:
        lista.sort((a, b) =>
            (b.cantidadLikes + b.cantidadComentarios * 2)
                .compareTo(a.cantidadLikes + a.cantidadComentarios * 2));
      case MuroFiltro.cercaDeTi:
        lista = lista
            .where((p) =>
                (p.ubicacion?.isNotEmpty ?? false) ||
                p.tipoEnum == TipoPublicacion.iniciativa)
            .toList();
      case MuroFiltro.siguiendo:
        lista = lista
            .where((p) => siguiendoIds.contains(p.usuarioId))
            .toList();
      case MuroFiltro.guardadas:
        lista = lista.where((p) => p.guardada).toList();
      case MuroFiltro.recientes:
      case MuroFiltro.misPublicaciones:
        break;
    }

    if (esBusqueda && busqueda.trim().isNotEmpty) {
      final q = busqueda.trim().toLowerCase();
      lista = lista.where((p) {
        final texto =
            '${p.nombreUsuario} ${p.contenido} ${p.etiquetas.join(' ')} ${p.ubicacion ?? ''}'
                .toLowerCase();
        return texto.contains(q);
      }).toList();
    }

    return lista;
  }

  bool get cargandoInicial => isLoading && publicaciones.isEmpty;

  CommunityState copyWith({
    List<PublicacionResponse>? publicaciones,
    MuroFiltro? filtro,
    String? busqueda,
    bool? esBusqueda,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? pagina,
    String? error,
    String? mensajeExito,
    Set<int>? siguiendoIds,
    Set<int>? guardadasIds,
    Set<int>? ocultadasIds,
    Set<int>? procesando,
    bool clearBusqueda = false,
    bool clearError = false,
    bool clearMensaje = false,
  }) {
    return CommunityState(
      publicaciones: publicaciones ?? this.publicaciones,
      filtro: filtro ?? this.filtro,
      busqueda: clearBusqueda ? '' : (busqueda ?? this.busqueda),
      esBusqueda: esBusqueda ?? this.esBusqueda,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      pagina: pagina ?? this.pagina,
      error: clearError ? null : (error ?? this.error),
      mensajeExito:
          clearMensaje ? null : (mensajeExito ?? this.mensajeExito),
      siguiendoIds: siguiendoIds ?? this.siguiendoIds,
      guardadasIds: guardadasIds ?? this.guardadasIds,
      ocultadasIds: ocultadasIds ?? this.ocultadasIds,
      procesando: procesando ?? this.procesando,
    );
  }

  PublicacionResponse? postResponsePorId(int id) {
    for (final p in publicaciones) {
      if (p.publicacionId == id) return p;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        publicaciones,
        filtro,
        busqueda,
        esBusqueda,
        isLoading,
        isLoadingMore,
        hasMore,
        pagina,
        error,
        mensajeExito,
        siguiendoIds,
        guardadasIds,
        ocultadasIds,
        procesando,
      ];
}
