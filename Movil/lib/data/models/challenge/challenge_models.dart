import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../catalogos/retos/reto_model.dart';

class CategoriaResponse extends Equatable {
  final int categoriaId;
  final String nombreCategoria;
  final String descripcion;

  const CategoriaResponse({
    required this.categoriaId,
    required this.nombreCategoria,
    required this.descripcion,
  });

  factory CategoriaResponse.fromJson(Map<String, dynamic> json) {
    return CategoriaResponse(
      categoriaId: json['categoriaId'] ?? 0,
      nombreCategoria: json['nombreCategoria']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [categoriaId, nombreCategoria, descripcion];
}

class RetoResponse extends Equatable {
  final int retoId;
  final String? codigo;
  final int categoriaId;
  final String nombreCategoria;
  final String titulo;
  final String descripcion;
  final String instrucciones;
  final int experienciaRecompensa;
  final int monedasRecompensa;
  final String dificultad;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String estado;

  // Metadata extendida del catálogo (columnas adicionales del backend).
  final String? subcategoria;
  final String? tipo;
  final int? tiempoMin;
  final String? materiales;
  final int? cantidadObjetivo;
  final String? consejos;
  final String? advertencias;
  final String? requisitos;
  final String? evidencia;
  final String? etiquetas;
  final bool destacado;
  final bool esDiario;
  final bool esSemanal;
  final bool esEspecial;

  const RetoResponse({
    required this.retoId,
    this.codigo,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.titulo,
    required this.descripcion,
    required this.instrucciones,
    required this.experienciaRecompensa,
    this.monedasRecompensa = 0,
    required this.dificultad,
    required this.fechaInicio,
    this.fechaFin,
    required this.estado,
    this.subcategoria,
    this.tipo,
    this.tiempoMin,
    this.materiales,
    this.cantidadObjetivo,
    this.consejos,
    this.advertencias,
    this.requisitos,
    this.evidencia,
    this.etiquetas,
    this.destacado = false,
    this.esDiario = false,
    this.esSemanal = false,
    this.esEspecial = false,
  });

  factory RetoResponse.fromJson(Map<String, dynamic> json) {
    return RetoResponse(
      retoId: json['retoId'] ?? json['id'] ?? 0,
      codigo: json['codigo']?.toString(),
      categoriaId: json['categoriaId'] ?? 0,
      nombreCategoria: json['nombreCategoria']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      instrucciones: json['instrucciones']?.toString() ?? '',
      experienciaRecompensa:
          json['experienciaRecompensa'] ?? json['puntos'] ?? 0,
      monedasRecompensa: json['monedasRecompensa'] ?? 0,
      dificultad: json['dificultad']?.toString() ?? 'FACIL',
      fechaInicio:
          DateTime.tryParse(json['fechaInicio'].toString()) ?? DateTime.now(),
      fechaFin: json['fechaFin'] != null
          ? DateTime.tryParse(json['fechaFin'].toString())
          : null,
      estado: json['estado']?.toString() ?? 'ACTIVO',
      subcategoria: json['subcategoria']?.toString(),
      tipo: json['tipo']?.toString(),
      tiempoMin: int.tryParse(json['tiempoMin']?.toString() ?? ''),
      materiales: json['materiales']?.toString(),
      cantidadObjetivo:
          int.tryParse(json['cantidadObjetivo']?.toString() ?? ''),
      consejos: json['consejos']?.toString(),
      advertencias: json['advertencias']?.toString(),
      requisitos: json['requisitos']?.toString(),
      evidencia: json['evidencia']?.toString(),
      etiquetas: json['etiquetas']?.toString(),
      destacado: json['destacado'] == true,
      esDiario: json['esDiario'] == true,
      esSemanal: json['esSemanal'] == true,
      esEspecial: json['esEspecial'] == true,
    );
  }

  /// Convierte la respuesta del backend al modelo de dominio del catálogo.
  ///
  /// Los campos JSON (materiales, consejos, etiquetas...) y las instrucciones
  /// (unidas por salto de línea) se decodifican a sus contrapartes de Dart.
  Reto toReto() {
    final categoria =
        RetoCategoria.porId(categoriaId) ?? RetoCategoria.reciclaje;
    final codigoFinal = (codigo?.isNotEmpty ?? false)
        ? codigo!
        : (retoId != 0
              ? 'reto-$retoId'
              : 'reto-${DateTime.now().millisecondsSinceEpoch}');
    return Reto(
      id: codigoFinal,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      subcategoria: subcategoria,
      dificultad: retoDificultadDesde(dificultad),
      tipo: retoTipoDesde(tipo),
      tiempoMin: tiempoMin ?? 30,
      xp: experienciaRecompensa,
      monedas: monedasRecompensa,
      materiales: _materialesDesdeJson(materiales),
      cantidadObjetivo: cantidadObjetivo,
      instrucciones: _lineas(instrucciones),
      consejos: _listaDesdeJson(consejos),
      advertencias: _listaDesdeJson(advertencias),
      requisitos: _listaDesdeJson(requisitos),
      evidencia: retoTipoEvidenciaDesde(evidencia),
      etiquetas: _listaDesdeJson(etiquetas),
      destacado: destacado,
      diario: esDiario,
      semanal: esSemanal,
      especial: esEspecial,
      retoBackendId: retoId != 0 ? retoId : null,
    );
  }

  @override
  List<Object?> get props => [
    retoId,
    codigo,
    categoriaId,
    nombreCategoria,
    titulo,
    descripcion,
    instrucciones,
    experienciaRecompensa,
    monedasRecompensa,
    dificultad,
    fechaInicio,
    fechaFin,
    estado,
    subcategoria,
    tipo,
    tiempoMin,
    materiales,
    cantidadObjetivo,
    consejos,
    advertencias,
    requisitos,
    evidencia,
    etiquetas,
    destacado,
    esDiario,
    esSemanal,
    esEspecial,
  ];
}

class UsuarioRetoResponse extends Equatable {
  final int usuarioRetoId;
  final int usuarioId;
  final int retoId;
  final String? codigo;
  final String nombreUsuario;
  final String tituloReto;
  final String estado;
  final String? evidencia;
  final String? motivoRechazo;
  final int puntosObtenidos;
  final int puntosReto;
  final DateTime fechaInicio;
  final DateTime? fechaCompletado;

  const UsuarioRetoResponse({
    required this.usuarioRetoId,
    required this.usuarioId,
    required this.retoId,
    this.codigo,
    this.nombreUsuario = '',
    required this.tituloReto,
    required this.estado,
    this.evidencia,
    this.motivoRechazo,
    required this.puntosObtenidos,
    this.puntosReto = 0,
    required this.fechaInicio,
    this.fechaCompletado,
  });

  factory UsuarioRetoResponse.fromJson(Map<String, dynamic> json) {
    return UsuarioRetoResponse(
      usuarioRetoId: json['usuarioRetoId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      retoId: json['retoId'] ?? 0,
      codigo: json['codigo']?.toString(),
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      tituloReto: json['tituloReto']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'INICIADO',
      evidencia: json['evidencia']?.toString(),
      motivoRechazo: json['motivoRechazo']?.toString(),
      puntosObtenidos: json['puntosObtenidos'] ?? 0,
      // El backend expone la recompensa del reto como
      // `experienciaRecompensaReto`; `puntosReto` se mantiene como respaldo
      // por compatibilidad.
      puntosReto:
          json['experienciaRecompensaReto'] ?? json['puntosReto'] ?? 0,
      fechaInicio:
          DateTime.tryParse(json['fechaInicio'].toString()) ?? DateTime.now(),
      fechaCompletado: json['fechaCompletado'] != null
          ? DateTime.tryParse(json['fechaCompletado'].toString())
          : null,
    );
  }

  UsuarioRetoResponse copyWith({
    int? usuarioRetoId,
    int? usuarioId,
    int? retoId,
    String? codigo,
    String? nombreUsuario,
    String? tituloReto,
    String? estado,
    String? evidencia,
    String? motivoRechazo,
    int? puntosObtenidos,
    int? puntosReto,
    DateTime? fechaInicio,
    DateTime? fechaCompletado,
  }) {
    return UsuarioRetoResponse(
      usuarioRetoId: usuarioRetoId ?? this.usuarioRetoId,
      usuarioId: usuarioId ?? this.usuarioId,
      retoId: retoId ?? this.retoId,
      codigo: codigo ?? this.codigo,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      tituloReto: tituloReto ?? this.tituloReto,
      estado: estado ?? this.estado,
      evidencia: evidencia ?? this.evidencia,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      puntosObtenidos: puntosObtenidos ?? this.puntosObtenidos,
      puntosReto: puntosReto ?? this.puntosReto,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
    );
  }

  @override
  List<Object?> get props => [
    usuarioRetoId,
    usuarioId,
    retoId,
    codigo,
    nombreUsuario,
    tituloReto,
    estado,
    evidencia,
    motivoRechazo,
    puntosObtenidos,
    puntosReto,
    fechaInicio,
    fechaCompletado,
  ];
}

/// Parte un texto en líneas no vacías (instrucciones almacenadas con \n).
List<String> _lineas(String texto) => texto
    .split('\n')
    .map((l) => l.trim())
    .where((l) => l.isNotEmpty)
    .toList();

/// Decodifica un JSON de lista de strings (consejos, advertencias, requisitos,
/// etiquetas). Si el valor viene como texto plano, lo parte por comas.
List<String> _listaDesdeJson(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
  } catch (_) {}
  return json
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

/// Decodifica el JSON de materiales: [{"nombre": "...", "cantidad": n}].
List<RetoMaterial> _materialesDesdeJson(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return RetoMaterial(
          map['nombre']?.toString() ?? '',
          int.tryParse(map['cantidad']?.toString() ?? '') ?? 1,
        );
      }).toList();
    }
  } catch (_) {}
  return const [];
}
