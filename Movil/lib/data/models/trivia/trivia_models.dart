import 'package:equatable/equatable.dart';

class TriviaResponse extends Equatable {
  final int triviaId;
  final int categoriaId;
  final String nombreCategoria;
  final String titulo;
  final String descripcion;
  final String dificultad;
  final int puntosMaximos;
  final String estado;

  const TriviaResponse({
    required this.triviaId,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.titulo,
    required this.descripcion,
    required this.dificultad,
    required this.puntosMaximos,
    required this.estado,
  });

  factory TriviaResponse.fromJson(Map<String, dynamic> json) {
    return TriviaResponse(
      triviaId: json['triviaId'] ?? 0,
      categoriaId: json['categoriaId'] ?? 0,
      nombreCategoria: json['nombreCategoria']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      dificultad: json['dificultad']?.toString() ?? 'FACIL',
      puntosMaximos: json['puntosMaximos'] ?? 0,
      estado: json['estado']?.toString() ?? 'ACTIVA',
    );
  }

  @override
  List<Object?> get props => [
        triviaId,
        categoriaId,
        nombreCategoria,
        titulo,
        descripcion,
        dificultad,
        puntosMaximos,
        estado,
      ];
}

class PreguntaResponse extends Equatable {
  final int preguntaId;
  final int triviaId;
  final String preguntaTexto;
  final int puntos;
  final List<OpcionRespuesta> opciones;

  const PreguntaResponse({
    required this.preguntaId,
    required this.triviaId,
    required this.preguntaTexto,
    required this.puntos,
    this.opciones = const [],
  });

  factory PreguntaResponse.fromJson(Map<String, dynamic> json) {
    return PreguntaResponse(
      preguntaId: json['preguntaId'] ?? 0,
      triviaId: json['triviaId'] ?? 0,
      preguntaTexto: json['preguntaTexto']?.toString() ?? '',
      puntos: json['puntos'] ?? 1,
      opciones: (json['opciones'] as List<dynamic>?)
              ?.map((e) => OpcionRespuesta.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [preguntaId, triviaId, preguntaTexto, puntos, opciones];
}

class OpcionRespuesta extends Equatable {
  final int opcionId;
  final int preguntaId;
  final String textoOpcion;
  final bool esCorrecta;

  const OpcionRespuesta({
    required this.opcionId,
    required this.preguntaId,
    required this.textoOpcion,
    required this.esCorrecta,
  });

  factory OpcionRespuesta.fromJson(Map<String, dynamic> json) {
    return OpcionRespuesta(
      opcionId: json['opcionId'] ?? 0,
      preguntaId: json['preguntaId'] ?? 0,
      textoOpcion: json['textoOpcion']?.toString() ?? '',
      esCorrecta: json['esCorrecta'] ?? false,
    );
  }

  @override
  List<Object?> get props => [opcionId, preguntaId, textoOpcion, esCorrecta];
}

class IntentoTriviaResponse extends Equatable {
  final int intentoId;
  final int usuarioId;
  final int triviaId;
  final String tituloTrivia;
  final int puntuacion;
  final DateTime fechaInicio;
  final DateTime? fechaFinalizacion;

  const IntentoTriviaResponse({
    required this.intentoId,
    required this.usuarioId,
    required this.triviaId,
    required this.tituloTrivia,
    required this.puntuacion,
    required this.fechaInicio,
    this.fechaFinalizacion,
  });

  factory IntentoTriviaResponse.fromJson(Map<String, dynamic> json) {
    return IntentoTriviaResponse(
      intentoId: json['intentoId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      triviaId: json['triviaId'] ?? 0,
      tituloTrivia: json['tituloTrivia']?.toString() ?? '',
      puntuacion: json['puntuacion'] ?? 0,
      fechaInicio:
          DateTime.tryParse(json['fechaInicio'].toString()) ?? DateTime.now(),
      fechaFinalizacion: json['fechaFinalizacion'] != null
          ? DateTime.tryParse(json['fechaFinalizacion'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
        intentoId,
        usuarioId,
        triviaId,
        tituloTrivia,
        puntuacion,
        fechaInicio,
        fechaFinalizacion,
      ];
}

class RespuestaUsuarioResponse extends Equatable {
  final int respuestaId;
  final int intentoId;
  final int preguntaId;
  final int opcionId;
  final bool esCorrecta;

  const RespuestaUsuarioResponse({
    required this.respuestaId,
    required this.intentoId,
    required this.preguntaId,
    required this.opcionId,
    required this.esCorrecta,
  });

  factory RespuestaUsuarioResponse.fromJson(Map<String, dynamic> json) {
    return RespuestaUsuarioResponse(
      respuestaId: json['respuestaId'] ?? 0,
      intentoId: json['intentoId'] ?? 0,
      preguntaId: json['preguntaId'] ?? 0,
      opcionId: json['opcionId'] ?? 0,
      esCorrecta: json['esCorrecta'] ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [respuestaId, intentoId, preguntaId, opcionId, esCorrecta];
}
