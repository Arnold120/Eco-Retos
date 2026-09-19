




library;

import '../../models/gamification/gamification_models.dart';

class RetoMaterial {
  final String nombre;
  final int cantidad;

  const RetoMaterial(this.nombre, this.cantidad);

  @override
  bool operator ==(Object other) =>
      other is RetoMaterial &&
      other.nombre == nombre &&
      other.cantidad == cantidad;

  @override
  int get hashCode => Object.hash(nombre, cantidad);

  @override
  String toString() => '$nombre ×$cantidad';
}



enum RetoCategoria {
  reciclaje(
    1,
    'RECICLAJE',
    '♻️ Reciclaje',
    'Acciones relacionadas con la separación, reutilización y correcta disposición de residuos.',
    0xFF2E7D5B,
  ),
  movilidad(
    2,
    'MOVILIDAD',
    '🚲 Movilidad sostenible',
    'Acciones que promueven medios de transporte sostenibles y reducen el impacto ambiental.',
    0xFFEF6C00,
  ),
  reforestacion(
    3,
    'REFORESTACION',
    '🌳 Reforestación y biodiversidad',
    'Acciones relacionadas con la siembra de árboles, conservación de áreas verdes y biodiversidad.',
    0xFF43A047,
  ),
  consumo(
    4,
    'CONSUMO',
    '🛍️ Consumo responsable',
    'Acciones que promueven compras conscientes, reducción del consumo y disminución de residuos.',
    0xFFFF7043,
  ),
  eficienciaEnergetica(
    5,
    'EFICIENCIA_ENERGETICA',
    '⚡ Eficiencia energética',
    'Acciones destinadas a reducir el consumo de energía y mejorar su aprovechamiento.',
    0xFFF6C85F,
  ),
  alimentacion(
    6,
    'ALIMENTACION',
    '🥕 Alimentación sostenible',
    'Acciones relacionadas con hábitos alimentarios que reducen el impacto ambiental.',
    0xFFE64A19,
  ),
  economiaCircular(
    7,
    'ECONOMIA_CIRCULAR',
    '🔄 Economía circular y reparación',
    'Acciones que buscan reparar, reutilizar y extender la vida útil de productos y materiales.',
    0xFF5E35B1,
  );

  const RetoCategoria(
    this.categoriaId,
    this.id,
    this.nombre,
    this.descripcion,
    this.lightColor,
  );


  final int categoriaId;

  final String id;

  final String nombre;


  final String descripcion;


  final int lightColor;

  String get emoji => nombre.split(' ').first;

  static RetoCategoria? porId(int categoriaId) {
    for (final categoria in values) {
      if (categoria.categoriaId == categoriaId) return categoria;
    }
    return null;
  }
}

enum RetoDificultad { facil, intermedio, dificil, experto }



RetoDificultad retoDificultadDesde(String? nombre) {
  for (final d in RetoDificultad.values) {
    if (d.name.toUpperCase() == (nombre ?? '').toUpperCase()) return d;
  }
  return RetoDificultad.facil;
}

extension RetoDificultadInfo on RetoDificultad {
  String get label {
    switch (this) {
      case RetoDificultad.facil:
        return 'Fácil';
      case RetoDificultad.intermedio:
        return 'Intermedio';
      case RetoDificultad.dificil:
        return 'Difícil';
      case RetoDificultad.experto:
        return 'Experto';
    }
  }


  int get xpMultiplier {
    switch (this) {
      case RetoDificultad.facil:
        return 1;
      case RetoDificultad.intermedio:
        return 2;
      case RetoDificultad.dificil:
        return 4;
      case RetoDificultad.experto:
        return 8;
    }
  }
}

enum RetoTipo {
  individual,
  fotografia,
  educativo,
  cantidad,
  temporal,
  racha,
  comunitario,
  creativo,
  observacion,
  investigacion,
}



RetoTipo retoTipoDesde(String? nombre) {
  for (final t in RetoTipo.values) {
    if (t.name.toUpperCase() == (nombre ?? '').toUpperCase()) return t;
  }
  return RetoTipo.individual;
}

extension RetoTipoInfo on RetoTipo {
  String get label {
    switch (this) {
      case RetoTipo.individual:
        return 'Individual';
      case RetoTipo.fotografia:
        return 'Con fotografía';
      case RetoTipo.educativo:
        return 'Educativo';
      case RetoTipo.cantidad:
        return 'De cantidad';
      case RetoTipo.temporal:
        return 'Temporal';
      case RetoTipo.racha:
        return 'De racha';
      case RetoTipo.comunitario:
        return 'Comunitario';
      case RetoTipo.creativo:
        return 'Creativo';
      case RetoTipo.observacion:
        return 'De observación';
      case RetoTipo.investigacion:
        return 'De investigación';
    }
  }
}

enum RetoTipoEvidencia { foto, galeria, video, texto, cantidad, respuesta }



RetoTipoEvidencia retoTipoEvidenciaDesde(String? nombre) {
  for (final e in RetoTipoEvidencia.values) {
    if (e.name.toUpperCase() == (nombre ?? '').toUpperCase()) return e;
  }
  return RetoTipoEvidencia.foto;
}

extension RetoTipoEvidenciaInfo on RetoTipoEvidencia {
  String get label {
    switch (this) {
      case RetoTipoEvidencia.foto:
        return 'Fotografía';
      case RetoTipoEvidencia.galeria:
        return 'Galería de fotos';
      case RetoTipoEvidencia.video:
        return 'Video';
      case RetoTipoEvidencia.texto:
        return 'Texto';
      case RetoTipoEvidencia.cantidad:
        return 'Cantidad';
      case RetoTipoEvidencia.respuesta:
        return 'Respuesta';
    }
  }
}

enum RetoEstado {
  disponible,
  bloqueado,
  enProgreso,
  completado,
  requiereEvidencia,
  pendienteRevision,
  rechazado,
  expirado,
}

extension RetoEstadoInfo on RetoEstado {
  String get label {
    switch (this) {
      case RetoEstado.disponible:
        return 'Disponible';
      case RetoEstado.bloqueado:
        return 'Bloqueado';
      case RetoEstado.enProgreso:
        return 'En progreso';
      case RetoEstado.completado:
        return 'Completado';
      case RetoEstado.requiereEvidencia:
        return 'Requiere evidencia';
      case RetoEstado.pendienteRevision:
        return 'Pendiente de revisión';
      case RetoEstado.rechazado:
        return 'Rechazado';
      case RetoEstado.expirado:
        return 'Expirado';
    }
  }

  bool get esFinal {
    switch (this) {
      case RetoEstado.completado:
      case RetoEstado.rechazado:
        return true;
      default:
        return false;
    }
  }
}



class Reto {
  final String id;
  final String titulo;
  final String descripcion;
  final RetoCategoria categoria;
  final String? subcategoria;
  final RetoDificultad dificultad;
  final RetoTipo tipo;
  final int tiempoMin;
  final int xp;
  final int monedas;
  final List<RetoMaterial> materiales;
  final int? cantidadObjetivo;
  final List<String> instrucciones;
  final List<String> consejos;
  final List<String> advertencias;
  final List<String> requisitos;
  final RetoTipoEvidencia evidencia;
  final List<String> etiquetas;
  final String? imagen;
  final String? icono;
  final bool destacado;
  final bool diario;
  final bool semanal;
  final bool especial;
  final int? retoBackendId;

  const Reto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.dificultad,
    required this.tipo,
    required this.tiempoMin,
    required this.xp,
    required this.monedas,
    this.subcategoria,
    this.materiales = const [],
    this.cantidadObjetivo,
    this.instrucciones = const [],
    this.consejos = const [],
    this.advertencias = const [],
    this.requisitos = const [],
    this.evidencia = RetoTipoEvidencia.foto,
    this.etiquetas = const [],
    this.imagen,
    this.icono,
    this.destacado = false,
    this.diario = false,
    this.semanal = false,
    this.especial = false,
    this.retoBackendId,
  });

  bool get requiereEvidencia => evidencia != RetoTipoEvidencia.cantidad;

  @override
  bool operator ==(Object other) => other is Reto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}



class RetoProgreso {
  final Reto reto;
  final RetoEstado estado;
  final int progresoActual;
  final int? pasosCompletadas;
  final DateTime? fechaInicio;
  final DateTime? fechaCompletado;
  final String? evidenciaPendiente;
  final String? motivoRechazo;

  const RetoProgreso({
    required this.reto,
    this.estado = RetoEstado.disponible,
    this.progresoActual = 0,
    this.pasosCompletadas,
    this.fechaInicio,
    this.fechaCompletado,
    this.evidenciaPendiente,
    this.motivoRechazo,
  });

  double get porcentaje {


    final totalPasos = reto.instrucciones.length;
    if (totalPasos > 0) {
      final pasos = (pasosCompletadas ?? progresoActual).clamp(0, totalPasos);
      return pasos / totalPasos;
    }
    final objetivo = reto.cantidadObjetivo ?? 1;
    if (objetivo <= 0) return 0;
    return (progresoActual / objetivo).clamp(0.0, 1.0);
  }

  RetoProgreso copyWith({
    RetoEstado? estado,
    int? progresoActual,
    int? pasosCompletadas,
    DateTime? fechaInicio,
    DateTime? fechaCompletado,
    String? evidenciaPendiente,
    bool clearEvidencia = false,
    String? motivoRechazo,
    bool clearMotivo = false,
  }) {
    return RetoProgreso(
      reto: reto,
      estado: estado ?? this.estado,
      progresoActual: progresoActual ?? this.progresoActual,
      pasosCompletadas: pasosCompletadas ?? this.pasosCompletadas,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      evidenciaPendiente: clearEvidencia
          ? null
          : (evidenciaPendiente ?? this.evidenciaPendiente),
      motivoRechazo: clearMotivo ? null : (motivoRechazo ?? this.motivoRechazo),
    );
  }
}



class AprobacionReciente {
  final RetoProgreso progreso;
  final List<InsigniaResponse> logros;

  const AprobacionReciente(this.progreso, this.logros);
}
