import 'package:equatable/equatable.dart';

enum TipoPublicacion { general, logro, actividad, iniciativa }

class TipoHelpers {
  const TipoHelpers._();

  static TipoPublicacion fromString(String? tipo) {
    switch ((tipo ?? 'GENERAL').toUpperCase()) {
      case 'LOGRO':
        return TipoPublicacion.logro;
      case 'ACTIVIDAD':
        return TipoPublicacion.actividad;
      case 'INICIATIVA':
        return TipoPublicacion.iniciativa;
      default:
        return TipoPublicacion.general;
    }
  }

  static String toApi(TipoPublicacion tipo) {
    switch (tipo) {
      case TipoPublicacion.logro:
        return 'LOGRO';
      case TipoPublicacion.actividad:
        return 'ACTIVIDAD';
      case TipoPublicacion.iniciativa:
        return 'INICIATIVA';
      case TipoPublicacion.general:
        return 'GENERAL';
    }
  }
}

class AmbientCategories {
  const AmbientCategories._();

  static const Map<String, String> all = {
    'RECICLAJE': '♻️ Reciclaje',
    'REFORESTACION': '🌱 Reforestación',
    'AGUA': '💧 Agua',
    'ENERGIA': '⚡ Energía',
    'LIMPIEZA': '🌎 Limpieza',
    'REUTILIZACION': '🔄 Reutilización',
    'MOVILIDAD': '🚲 Movilidad sostenible',
    'EDUCACION': '🏫 Educación ambiental',
    'NATURALEZA': '🌿 Naturaleza',
    'COMUNIDAD': '🤝 Comunidad',
  };

  static String? emoji(String key) {
    final v = all[key];
    if (v == null) return null;
    return v.split(' ').first;
  }

  static String nombre(String key) {
    return all[key] ?? key;
  }
}

typedef MultimediaItem = ({
  String url,
  String tipo, 
  String? duracion,
  String? poster, 
});

class PublicacionResponse extends Equatable {
  final int publicacionId;
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String contenido;
  final String? imagen;
  final String tipo;
  final DateTime fechaPublicacion;
  final String estado;
  final int cantidadComentarios;

  final int cantidadLikes;
  final bool meGusta;
  final bool guardada;
  final int cantidadCompartidos;
  final String? ubicacion;
  final String? categoria;
  final String visibilidad;
  final bool esDestacada;
  final bool editada;
  final DateTime? fechaEdicion;
  final List<MultimediaItem> multimedia;
  final List<String> etiquetas;


  final int? compartidoDeId;
  final String? compartidoDeNombreUsuario;
  final String? compartidoDeContenido;
  final String? compartidoDeImagen;
  final bool compartidoEliminado;


  final int xpOtorgado;
  final int monedasOtorgadas;
  final String? retoRelacionado;
  final int participantes;
  final String? fechaEvento;

  const PublicacionResponse({
    required this.publicacionId,
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.contenido,
    this.imagen,
    required this.tipo,
    required this.fechaPublicacion,
    required this.estado,
    required this.cantidadComentarios,
    this.cantidadLikes = 0,
    this.meGusta = false,
    this.guardada = false,
    this.cantidadCompartidos = 0,
    this.ubicacion,
    this.categoria,
    this.visibilidad = 'PUBLICO',
    this.esDestacada = false,
    this.editada = false,
    this.fechaEdicion,
    this.multimedia = const [],
    this.etiquetas = const [],
    this.compartidoDeId,
    this.compartidoDeNombreUsuario,
    this.compartidoDeContenido,
    this.compartidoDeImagen,
    this.compartidoEliminado = false,
    this.xpOtorgado = 0,
    this.monedasOtorgadas = 0,
    this.retoRelacionado,
    this.participantes = 0,
    this.fechaEvento,
  });

  TipoPublicacion get tipoEnum => TipoHelpers.fromString(tipo);

  bool get esCompartido => compartidoDeId != null || compartidoEliminado;

  factory PublicacionResponse.fromJson(Map<String, dynamic> json) {
    final multimediaRaw = json['multimedia'];
    return PublicacionResponse(
      publicacionId: json['publicacionId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      fotoPerfil: _vacioANull(json['fotoPerfil']),
      contenido: json['contenido']?.toString() ?? '',
      imagen: _vacioANull(json['imagen']),
      tipo: json['tipo']?.toString() ?? 'GENERAL',
      fechaPublicacion:
          DateTime.tryParse(json['fechaPublicacion'].toString()) ??
              DateTime.now(),
      estado: json['estado']?.toString() ?? 'PUBLICADA',
      cantidadComentarios: json['cantidadComentarios'] ?? 0,
      cantidadLikes: json['cantidadLikes'] ?? 0,
      meGusta: json['meGusta'] ?? false,
      guardada: json['guardada'] ?? false,
      cantidadCompartidos: json['cantidadCompartidos'] ?? 0,
      ubicacion: _vacioANull(json['ubicacion']),
      categoria: _vacioANull(json['categoria']),
      visibilidad: json['visibilidad']?.toString() ?? 'PUBLICO',
      esDestacada: json['esDestacada'] ?? false,
      editada: json['editada'] ?? false,
      fechaEdicion: json['fechaEdicion'] == null
          ? null
          : DateTime.tryParse(json['fechaEdicion'].toString()),
      multimedia: _parseMultimedia(multimediaRaw, json['imagen']),
      etiquetas: _parseEtiquetas(json['etiquetas'], json['contenido']),
      compartidoDeId: json['compartidoDeId'],
      compartidoDeNombreUsuario: _vacioANull(json['compartidoDeNombreUsuario']),
      compartidoDeContenido: _vacioANull(json['compartidoDeContenido']),
      compartidoDeImagen: _vacioANull(json['compartidoDeImagen']),
      compartidoEliminado: json['compartidoEliminado'] ?? false,
      xpOtorgado: json['xpOtorgado'] ?? 0,
      monedasOtorgadas: json['monedasOtorgadas'] ?? 0,
      retoRelacionado: _vacioANull(json['retoRelacionado']),
      participantes: json['participantes'] ?? 0,
      fechaEvento: _vacioANull(json['fechaEvento']),
    );
  }

  static String? _vacioANull(Object? valor) {
    final texto = valor?.toString();
    if (texto == null || texto.trim().isEmpty || texto == 'null') return null;
    return texto;
  }

  static List<MultimediaItem> _parseMultimedia(Object? raw, Object? imagen) {
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) {
        final m = e is Map ? Map<String, dynamic>.from(e) : const {};
        return (
          url: m['url']?.toString() ?? '',
          tipo: m['tipo']?.toString() ?? 'imagen',
          duracion: m['duracion']?.toString(),
          poster: _vacioANull(m['poster']),
        );
      }).where((m) => m.url.isNotEmpty).toList();
    }
    if (imagen is String && imagen.isNotEmpty) {
      return [(url: imagen, tipo: 'imagen', duracion: null, poster: null)];
    }
    return const [];
  }

  static List<String> _parseEtiquetas(Object? raw, Object? contenido) {
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).toList();
    }
    if (contenido is String) {
      return RegExp(r'#\w+')
          .allMatches(contenido)
          .map((m) => m.group(0) ?? '')
          .where((h) => h.isNotEmpty)
          .toList();
    }
    return const [];
  }

  PublicacionResponse copyWith({
    int? publicacionId,
    int? usuarioId,
    String? nombreUsuario,
    String? fotoPerfil,
    String? contenido,
    String? imagen,
    String? tipo,
    DateTime? fechaPublicacion,
    String? estado,
    int? cantidadComentarios,
    int? cantidadLikes,
    bool? meGusta,
    bool? guardada,
    int? cantidadCompartidos,
    String? ubicacion,
    String? categoria,
    String? visibilidad,
    bool? esDestacada,
    bool? editada,
    DateTime? fechaEdicion,
    List<MultimediaItem>? multimedia,
    List<String>? etiquetas,
    int? compartidoDeId,
    String? compartidoDeNombreUsuario,
    String? compartidoDeContenido,
    String? compartidoDeImagen,
    bool? compartidoEliminado,
    int? xpOtorgado,
    int? monedasOtorgadas,
    String? retoRelacionado,
    int? participantes,
    String? fechaEvento,
  }) {
    return PublicacionResponse(
      publicacionId: publicacionId ?? this.publicacionId,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      contenido: contenido ?? this.contenido,
      imagen: imagen ?? this.imagen,
      tipo: tipo ?? this.tipo,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      estado: estado ?? this.estado,
      cantidadComentarios: cantidadComentarios ?? this.cantidadComentarios,
      cantidadLikes: cantidadLikes ?? this.cantidadLikes,
      meGusta: meGusta ?? this.meGusta,
      guardada: guardada ?? this.guardada,
      cantidadCompartidos: cantidadCompartidos ?? this.cantidadCompartidos,
      ubicacion: ubicacion ?? this.ubicacion,
      categoria: categoria ?? this.categoria,
      visibilidad: visibilidad ?? this.visibilidad,
      esDestacada: esDestacada ?? this.esDestacada,
      editada: editada ?? this.editada,
      fechaEdicion: fechaEdicion ?? this.fechaEdicion,
      multimedia: multimedia ?? this.multimedia,
      etiquetas: etiquetas ?? this.etiquetas,
      compartidoDeId: compartidoDeId ?? this.compartidoDeId,
      compartidoDeNombreUsuario:
          compartidoDeNombreUsuario ?? this.compartidoDeNombreUsuario,
      compartidoDeContenido:
          compartidoDeContenido ?? this.compartidoDeContenido,
      compartidoDeImagen: compartidoDeImagen ?? this.compartidoDeImagen,
      compartidoEliminado: compartidoEliminado ?? this.compartidoEliminado,
      xpOtorgado: xpOtorgado ?? this.xpOtorgado,
      monedasOtorgadas: monedasOtorgadas ?? this.monedasOtorgadas,
      retoRelacionado: retoRelacionado ?? this.retoRelacionado,
      participantes: participantes ?? this.participantes,
      fechaEvento: fechaEvento ?? this.fechaEvento,
    );
  }

  @override
  List<Object?> get props => [
        publicacionId,
        usuarioId,
        nombreUsuario,
        fotoPerfil,
        contenido,
        imagen,
        tipo,
        fechaPublicacion,
        estado,
        cantidadComentarios,
        cantidadLikes,
        meGusta,
        guardada,
        cantidadCompartidos,
        ubicacion,
        categoria,
        visibilidad,
        esDestacada,
        editada,
        fechaEdicion,
        multimedia,
        etiquetas,
        compartidoDeId,
        compartidoDeNombreUsuario,
        compartidoDeContenido,
        compartidoDeImagen,
        compartidoEliminado,
        xpOtorgado,
        monedasOtorgadas,
        retoRelacionado,
        participantes,
        fechaEvento,
      ];
}

class ComentarioResponse extends Equatable {
  final int comentarioId;
  final int publicacionId;
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String comentarioTexto;
  final DateTime fechaComentario;
  final int? comentarioPadreId;
  final bool editado;
  final int cantidadLikes;
  final bool meGusta;

  const ComentarioResponse({
    required this.comentarioId,
    required this.publicacionId,
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.comentarioTexto,
    required this.fechaComentario,
    this.comentarioPadreId,
    this.editado = false,
    this.cantidadLikes = 0,
    this.meGusta = false,
  });

  bool get esRespuesta => comentarioPadreId != null;

  factory ComentarioResponse.fromJson(Map<String, dynamic> json) {
    return ComentarioResponse(
      comentarioId: json['comentarioId'] ?? 0,
      publicacionId: json['publicacionId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      fotoPerfil: PublicacionResponse._vacioANull(json['fotoPerfil']),
      comentarioTexto: json['comentarioTexto']?.toString() ?? '',
      fechaComentario:
          DateTime.tryParse(json['fechaComentario'].toString()) ??
              DateTime.now(),
      comentarioPadreId: json['comentarioPadreId'],
      editado: json['editado'] ?? false,
      cantidadLikes: json['cantidadLikes'] ?? 0,
      meGusta: json['meGusta'] ?? false,
    );
  }

  ComentarioResponse copyWith({
    String? comentarioTexto,
    bool? editado,
    int? cantidadLikes,
    bool? meGusta,
    String? fotoPerfil,
  }) {
    return ComentarioResponse(
      comentarioId: comentarioId,
      publicacionId: publicacionId,
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      comentarioTexto: comentarioTexto ?? this.comentarioTexto,
      fechaComentario: fechaComentario,
      comentarioPadreId: comentarioPadreId,
      editado: editado ?? this.editado,
      cantidadLikes: cantidadLikes ?? this.cantidadLikes,
      meGusta: meGusta ?? this.meGusta,
    );
  }

  @override
  List<Object?> get props => [
        comentarioId,
        publicacionId,
        usuarioId,
        nombreUsuario,
        fotoPerfil,
        comentarioTexto,
        fechaComentario,
        comentarioPadreId,
        editado,
        cantidadLikes,
        meGusta,
      ];
}

class CrearPublicacionRequest extends Equatable {
  final int usuarioId;
  final String contenido;
  final String? imagen;
  final String tipo;
  final String? ubicacion;
  final String? categoria;
  final String visibilidad;
  final int? compartidoDeId;
  final List<MultimediaItem> multimedia;

  const CrearPublicacionRequest({
    required this.usuarioId,
    required this.contenido,
    this.imagen,
    this.tipo = 'GENERAL',
    this.ubicacion,
    this.categoria,
    this.visibilidad = 'PUBLICO',
    this.compartidoDeId,
    this.multimedia = const [],
  });

  Map<String, dynamic> toJson() => {
        'UsuarioId': usuarioId,
        'Contenido': contenido,
        if (imagen != null) 'Imagen': imagen,
        'Tipo': tipo,
        if (ubicacion != null) 'Ubicacion': ubicacion,
        if (categoria != null) 'Categoria': categoria,
        'Visibilidad': visibilidad,
        if (compartidoDeId != null) 'CompartidoDeId': compartidoDeId,
        if (multimedia.isNotEmpty)
          'Multimedia': multimedia
              .map((m) => {
                    'Url': m.url,
                    'Tipo': m.tipo,
                    if (m.duracion != null) 'Duracion': m.duracion,
                    if (m.poster != null) 'Poster': m.poster,
                  })
              .toList(),
      };

  @override
  List<Object?> get props => [
        usuarioId,
        contenido,
        imagen,
        tipo,
        ubicacion,
        categoria,
        visibilidad,
        compartidoDeId,
        multimedia,
      ];
}

class ActualizarPublicacionRequest extends Equatable {
  final String contenido;
  final String? imagen;
  final String tipo;
  final String estado;
  final String? ubicacion;
  final String? categoria;
  final String visibilidad;
  final List<MultimediaItem>? multimedia;

  const ActualizarPublicacionRequest({
    required this.contenido,
    this.imagen,
    this.tipo = 'GENERAL',
    this.estado = 'PUBLICADA',
    this.ubicacion,
    this.categoria,
    this.visibilidad = 'PUBLICO',
    this.multimedia,
  });

  Map<String, dynamic> toJson() => {
        'Contenido': contenido,
        if (imagen != null) 'Imagen': imagen,
        'Tipo': tipo,
        'Estado': estado,
        if (ubicacion != null) 'Ubicacion': ubicacion,
        if (categoria != null) 'Categoria': categoria,
        'Visibilidad': visibilidad,
        if (multimedia != null)
          'Multimedia': multimedia!
              .map((m) => {
                    'Url': m.url,
                    'Tipo': m.tipo,
                    if (m.duracion != null) 'Duracion': m.duracion,
                    if (m.poster != null) 'Poster': m.poster,
                  })
              .toList(),
      };

  @override
  List<Object?> get props => [
        contenido,
        imagen,
        tipo,
        estado,
        ubicacion,
        categoria,
        visibilidad,
        multimedia,
      ];
}

class CrearComentarioRequest extends Equatable {
  final int publicacionId;
  final int usuarioId;
  final String comentarioTexto;
  final int? comentarioPadreId;

  const CrearComentarioRequest({
    required this.publicacionId,
    required this.usuarioId,
    required this.comentarioTexto,
    this.comentarioPadreId,
  });

  Map<String, dynamic> toJson() => {
        'PublicacionId': publicacionId,
        'UsuarioId': usuarioId,
        'ComentarioTexto': comentarioTexto,
        if (comentarioPadreId != null) 'ComentarioPadreId': comentarioPadreId,
      };

  @override
  List<Object?> get props =>
      [publicacionId, usuarioId, comentarioTexto, comentarioPadreId];
}

class NotificacionResponse extends Equatable {
  final int notificacionId;
  final int usuarioId;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final DateTime fecha;
  final String? referenciaTipo;
  final int? referenciaId;
  final int? actorUsuarioId;

  const NotificacionResponse({
    required this.notificacionId,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.fecha,
    this.referenciaTipo,
    this.referenciaId,
    this.actorUsuarioId,
  });

  factory NotificacionResponse.fromJson(Map<String, dynamic> json) {
    return NotificacionResponse(
      notificacionId: json['notificacionId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      titulo: json['titulo']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      leida: json['leida'] ?? false,
      fecha: DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now(),
      referenciaTipo:
          PublicacionResponse._vacioANull(json['referenciaTipo']),
      referenciaId: json['referenciaId'],
      actorUsuarioId: json['actorUsuarioId'],
    );
  }

  @override
  List<Object?> get props => [
        notificacionId,
        usuarioId,
        titulo,
        mensaje,
        tipo,
        leida,
        fecha,
        referenciaTipo,
        referenciaId,
        actorUsuarioId,
      ];
}

class SeguimientoEstado extends Equatable {
  final int usuarioId;
  final bool siguiendo;
  final int seguidores;
  final int seguidos;

  const SeguimientoEstado({
    required this.usuarioId,
    required this.siguiendo,
    required this.seguidores,
    required this.seguidos,
  });

  factory SeguimientoEstado.fromJson(Map<String, dynamic> json) {
    return SeguimientoEstado(
      usuarioId: json['usuarioId'] ?? 0,
      siguiendo: json['siguiendo'] ?? false,
      seguidores: json['seguidores'] ?? 0,
      seguidos: json['seguidos'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [usuarioId, siguiendo, seguidores, seguidos];
}

class ResultadoReaccion extends Equatable {
  final bool activa;
  final String tipo;
  final int total;

  const ResultadoReaccion({
    required this.activa,
    required this.tipo,
    required this.total,
  });

  factory ResultadoReaccion.fromJson(Map<String, dynamic> json) {
    return ResultadoReaccion(
      activa: json['activa'] ?? false,
      tipo: json['tipo']?.toString() ?? 'ME_GUSTA',
      total: json['total'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [activa, tipo, total];
}

class ConversacionResumen extends Equatable {
  final int conversacionId;
  final int otroUsuarioId;
  final String otroNombreUsuario;
  final String? otroFotoPerfil;
  final String? ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final int noLeidos;

  const ConversacionResumen({
    required this.conversacionId,
    required this.otroUsuarioId,
    required this.otroNombreUsuario,
    this.otroFotoPerfil,
    this.ultimoMensaje,
    this.fechaUltimoMensaje,
    this.noLeidos = 0,
  });

  factory ConversacionResumen.fromJson(Map<String, dynamic> json) {
    return ConversacionResumen(
      conversacionId: json['conversacionId'] ?? 0,
      otroUsuarioId: json['otroUsuarioId'] ?? 0,
      otroNombreUsuario: json['otroNombreUsuario']?.toString() ?? '',
      otroFotoPerfil: PublicacionResponse._vacioANull(json['otroFotoPerfil']),
      ultimoMensaje: PublicacionResponse._vacioANull(json['ultimoMensaje']),
      fechaUltimoMensaje: json['fechaUltimoMensaje'] == null
          ? null
          : DateTime.tryParse(json['fechaUltimoMensaje'].toString()),
      noLeidos: json['noLeidos'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        conversacionId,
        otroUsuarioId,
        otroNombreUsuario,
        otroFotoPerfil,
        ultimoMensaje,
        fechaUltimoMensaje,
        noLeidos,
      ];
}

class MensajeResponse extends Equatable {
  final int mensajeId;
  final int conversacionId;
  final int remitenteId;
  final String contenido;
  final DateTime fecha;
  final bool leido;

  const MensajeResponse({
    required this.mensajeId,
    required this.conversacionId,
    required this.remitenteId,
    required this.contenido,
    required this.fecha,
    this.leido = false,
  });

  factory MensajeResponse.fromJson(Map<String, dynamic> json) {
    return MensajeResponse(
      mensajeId: json['mensajeId'] ?? 0,
      conversacionId: json['conversacionId'] ?? 0,
      remitenteId: json['remitenteId'] ?? 0,
      contenido: json['contenido']?.toString() ?? '',
      fecha: DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now(),
      leido: json['leido'] ?? false,
    );
  }

  MensajeResponse copyWith({bool? leido}) {
    return MensajeResponse(
      mensajeId: mensajeId,
      conversacionId: conversacionId,
      remitenteId: remitenteId,
      contenido: contenido,
      fecha: fecha,
      leido: leido ?? this.leido,
    );
  }

  @override
  List<Object?> get props =>
      [mensajeId, conversacionId, remitenteId, contenido, fecha, leido];
}

class PerfilPublicoResponse extends Equatable {
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String? nombreCompleto;
  final String? centroEducativo;
  final String? grado;
  final int cantidadPublicaciones;
  final int cantidadSeguidores;
  final int cantidadSeguidos;
  final bool siguiendo;
  final bool esMiPerfil;

  const PerfilPublicoResponse({
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoPerfil,
    this.nombreCompleto,
    this.centroEducativo,
    this.grado,
    this.cantidadPublicaciones = 0,
    this.cantidadSeguidores = 0,
    this.cantidadSeguidos = 0,
    this.siguiendo = false,
    this.esMiPerfil = false,
  });

  factory PerfilPublicoResponse.fromJson(Map<String, dynamic> json) {
    return PerfilPublicoResponse(
      usuarioId: json['usuarioId'] ?? 0,
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      fotoPerfil: PublicacionResponse._vacioANull(json['fotoPerfil']),
      nombreCompleto: PublicacionResponse._vacioANull(json['nombreCompleto']),
      centroEducativo:
          PublicacionResponse._vacioANull(json['centroEducativo']),
      grado: PublicacionResponse._vacioANull(json['grado']),
      cantidadPublicaciones: json['cantidadPublicaciones'] ?? 0,
      cantidadSeguidores: json['cantidadSeguidores'] ?? 0,
      cantidadSeguidos: json['cantidadSeguidos'] ?? 0,
      siguiendo: json['siguiendo'] ?? false,
      esMiPerfil: json['esMiPerfil'] ?? false,
    );
  }

  PerfilPublicoResponse copyWith({
    int? cantidadPublicaciones,
    int? cantidadSeguidores,
    int? cantidadSeguidos,
    bool? siguiendo,
    String? fotoPerfil,
  }) {
    return PerfilPublicoResponse(
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      nombreCompleto: nombreCompleto,
      centroEducativo: centroEducativo,
      grado: grado,
      cantidadPublicaciones:
          cantidadPublicaciones ?? this.cantidadPublicaciones,
      cantidadSeguidores: cantidadSeguidores ?? this.cantidadSeguidores,
      cantidadSeguidos: cantidadSeguidos ?? this.cantidadSeguidos,
      siguiendo: siguiendo ?? this.siguiendo,
      esMiPerfil: esMiPerfil,
    );
  }

  @override
  List<Object?> get props => [
        usuarioId,
        nombreUsuario,
        fotoPerfil,
        nombreCompleto,
        centroEducativo,
        grado,
        cantidadPublicaciones,
        cantidadSeguidores,
        cantidadSeguidos,
        siguiendo,
        esMiPerfil,
      ];
}

class UsuarioResumen extends Equatable {
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoPerfil;

  const UsuarioResumen({
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoPerfil,
  });

  factory UsuarioResumen.fromJson(Map<String, dynamic> json) {
    return UsuarioResumen(
      usuarioId: json['usuarioId'] ?? 0,
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      fotoPerfil: PublicacionResponse._vacioANull(json['fotoPerfil']),
    );
  }

  @override
  List<Object?> get props => [usuarioId, nombreUsuario, fotoPerfil];
}

class ResultadoBusqueda extends Equatable {
  final List<UsuarioResumen> usuarios;
  final List<PublicacionResponse> publicaciones;

  const ResultadoBusqueda({
    this.usuarios = const [],
    this.publicaciones = const [],
  });

  bool get estaVacio => usuarios.isEmpty && publicaciones.isEmpty;

  factory ResultadoBusqueda.fromJson(Map<String, dynamic> json) {
    final usuariosRaw = json['usuarios'];
    final publicacionesRaw = json['publicaciones'];
    return ResultadoBusqueda(
      usuarios: usuariosRaw is List
          ? usuariosRaw
              .map((e) => UsuarioResumen.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      publicaciones: publicacionesRaw is List
          ? publicacionesRaw
              .map((e) => PublicacionResponse.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [usuarios, publicaciones];
}
