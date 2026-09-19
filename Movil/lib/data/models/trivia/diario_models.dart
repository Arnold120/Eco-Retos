import 'dart:math';

import 'package:equatable/equatable.dart';


const Duration kTiempoPorPreguntaDiario = Duration(seconds: 30);


const int kPreguntasPorDia = 3;



const int kSemanasParaSubirDificultad = 3;


const int kXpSemanaCompletada = 100;


const int kMonedasSemanaCompletada = 50;





enum DificultadTrivia {
  facil('Facil', 'Fácil'),
  intermedia('Intermedia', 'Normal'),
  dificil('Dificil', 'Difícil');

  const DificultadTrivia(this.valorDb, this.etiqueta);


  final String valorDb;


  final String etiqueta;

  static DificultadTrivia desdeDb(String? valor) {
    switch (valor?.trim().toLowerCase()) {
      case 'facil':
        return DificultadTrivia.facil;
      case 'intermedia':
        return DificultadTrivia.intermedia;
      case 'dificil':
        return DificultadTrivia.dificil;
      default:
        return DificultadTrivia.facil;
    }
  }


  DificultadTrivia? get siguiente {
    switch (this) {
      case DificultadTrivia.facil:
        return DificultadTrivia.intermedia;
      case DificultadTrivia.intermedia:
        return DificultadTrivia.dificil;
      case DificultadTrivia.dificil:
        return null;
    }
  }
}





enum AyudaTrivia {
  pista(50, 'Pista'),
  cincuentaCincuenta(80, '50/50'),
  saltar(100, 'Saltar');

  const AyudaTrivia(this.costo, this.nombre);


  final int costo;

  final String nombre;

  static AyudaTrivia desdePersistencia(String? valor) {
    for (final ayuda in AyudaTrivia.values) {
      if (ayuda.name == valor) return ayuda;
    }
    return AyudaTrivia.pista;
  }
}





String _dosDigitos(int n) => n.toString().padLeft(2, '0');


String fechaClave(DateTime fecha) =>
    '${fecha.year}-${_dosDigitos(fecha.month)}-${_dosDigitos(fecha.day)}';


DateTime inicioSemana(DateTime fecha) {
  final base = DateTime(fecha.year, fecha.month, fecha.day);
  return base.subtract(Duration(days: base.weekday - DateTime.monday));
}



String claveSemana(DateTime fecha) => fechaClave(inicioSemana(fecha));


int indiceCategoriaDelDia(DateTime fecha) => fecha.weekday;

bool esMismoDia(DateTime a, DateTime b) => fechaClave(a) == fechaClave(b);


bool esDiaConsecutivo(DateTime anterior, DateTime actual) {
  final siguiente = DateTime(anterior.year, anterior.month, anterior.day + 1);
  return fechaClave(siguiente) == fechaClave(actual);
}


bool esDiferenciaDeDias(DateTime a, DateTime b, {required int dias}) {
  final base = DateTime(a.year, a.month, a.day);
  final otro = DateTime(b.year, b.month, b.day);
  return base.difference(otro).inDays.abs() == dias;
}






int calcularXp(int puntos) => puntos;


int calcularMonedas(int puntos) => puntos ~/ 10;










class ProgresoCategoriaDiario extends Equatable {
  final int categoriaId;
  final String categoriaNombre;
  final DificultadTrivia dificultad;
  final int cicloDificultad;
  final int semanasCompletadasConsecutivas;
  final DateTime? fechaUltimaSemanaCompletada;
  final int totalPartidas;
  final int totalAciertos;
  final int totalRespuestas;
  final int mejorPuntuacion;

  const ProgresoCategoriaDiario({
    required this.categoriaId,
    required this.categoriaNombre,
    this.dificultad = DificultadTrivia.facil,
    this.cicloDificultad = 0,
    this.semanasCompletadasConsecutivas = 0,
    this.fechaUltimaSemanaCompletada,
    this.totalPartidas = 0,
    this.totalAciertos = 0,
    this.totalRespuestas = 0,
    this.mejorPuntuacion = 0,
  });

  factory ProgresoCategoriaDiario.inicial({
    required int categoriaId,
    required String categoriaNombre,
  }) {
    return ProgresoCategoriaDiario(
      categoriaId: categoriaId,
      categoriaNombre: categoriaNombre,
    );
  }

  double get porcentajeAciertos => totalRespuestas == 0
      ? 0
      : (totalAciertos / totalRespuestas * 100).roundToDouble();

  factory ProgresoCategoriaDiario.fromJson(Map<String, dynamic> json) {
    return ProgresoCategoriaDiario(
      categoriaId: json['categoriaId'] ?? 0,
      categoriaNombre: json['categoriaNombre']?.toString() ?? '',
      dificultad: DificultadTrivia.desdeDb(json['dificultad']?.toString()),
      cicloDificultad: json['cicloDificultad'] ?? 0,
      semanasCompletadasConsecutivas:
          json['semanasCompletadasConsecutivas'] ?? 0,
      fechaUltimaSemanaCompletada: json['fechaUltimaSemanaCompletada'] != null
          ? DateTime.tryParse(json['fechaUltimaSemanaCompletada'].toString())
          : null,
      totalPartidas: json['totalPartidas'] ?? 0,
      totalAciertos: json['totalAciertos'] ?? 0,
      totalRespuestas: json['totalRespuestas'] ?? 0,
      mejorPuntuacion: json['mejorPuntuacion'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoriaId': categoriaId,
        'categoriaNombre': categoriaNombre,
        'dificultad': dificultad.valorDb,
        'cicloDificultad': cicloDificultad,
        'semanasCompletadasConsecutivas': semanasCompletadasConsecutivas,
        'fechaUltimaSemanaCompletada':
            fechaUltimaSemanaCompletada?.toIso8601String(),
        'totalPartidas': totalPartidas,
        'totalAciertos': totalAciertos,
        'totalRespuestas': totalRespuestas,
        'mejorPuntuacion': mejorPuntuacion,
      };

  ProgresoCategoriaDiario copyWith({
    String? categoriaNombre,
    DificultadTrivia? dificultad,
    int? cicloDificultad,
    int? semanasCompletadasConsecutivas,
    DateTime? fechaUltimaSemanaCompletada,
    bool limpiarFechaSemana = false,
    int? totalPartidas,
    int? totalAciertos,
    int? totalRespuestas,
    int? mejorPuntuacion,
  }) {
    return ProgresoCategoriaDiario(
      categoriaId: categoriaId,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      dificultad: dificultad ?? this.dificultad,
      cicloDificultad: cicloDificultad ?? this.cicloDificultad,
      semanasCompletadasConsecutivas:
          semanasCompletadasConsecutivas ?? this.semanasCompletadasConsecutivas,
      fechaUltimaSemanaCompletada: limpiarFechaSemana
          ? null
          : (fechaUltimaSemanaCompletada ?? this.fechaUltimaSemanaCompletada),
      totalPartidas: totalPartidas ?? this.totalPartidas,
      totalAciertos: totalAciertos ?? this.totalAciertos,
      totalRespuestas: totalRespuestas ?? this.totalRespuestas,
      mejorPuntuacion: mejorPuntuacion ?? this.mejorPuntuacion,
    );
  }


  ProgresoCategoriaDiario registrarPartida({
    required int aciertos,
    required int respuestas,
    required int puntos,
  }) {
    return copyWith(
      totalPartidas: totalPartidas + 1,
      totalAciertos: totalAciertos + aciertos,
      totalRespuestas: totalRespuestas + respuestas,
      mejorPuntuacion: max(puntos, mejorPuntuacion),
    );
  }





  ProgresoCategoriaDiario registrarSemanaCompletada(DateTime fechaCompletado) {
    final ultima = fechaUltimaSemanaCompletada;
    final contigua =
        ultima != null && esDiferenciaDeDias(ultima, fechaCompletado, dias: 7);
    var semanas = contigua ? semanasCompletadasConsecutivas + 1 : 1;
    var nuevaDificultad = dificultad;
    var nuevoCiclo = cicloDificultad;

    if (semanas >= kSemanasParaSubirDificultad) {
      final siguienteDificultad = nuevaDificultad.siguiente;
      if (siguienteDificultad != null) {
        nuevaDificultad = siguienteDificultad;
      }
      nuevoCiclo += 1;
      semanas = 0;
    }

    return copyWith(
      dificultad: nuevaDificultad,
      cicloDificultad: nuevoCiclo,
      semanasCompletadasConsecutivas: semanas,
      fechaUltimaSemanaCompletada: fechaCompletado,
    );
  }

  @override
  List<Object?> get props => [
        categoriaId,
        categoriaNombre,
        dificultad,
        cicloDificultad,
        semanasCompletadasConsecutivas,
        fechaUltimaSemanaCompletada,
        totalPartidas,
        totalAciertos,
        totalRespuestas,
        mejorPuntuacion,
      ];
}











class SesionPreguntaDiaria extends Equatable {
  final int triviaId;
  final int categoriaId;
  final String dificultad;
  final String pregunta;
  final Map<String, String> opciones;
  final String respuestaCorrecta;
  final int puntosBase;
  final bool resuelta;
  final String? respuestaLetra;
  final String? ayudaUsada;

  const SesionPreguntaDiaria({
    required this.triviaId,
    required this.categoriaId,
    required this.dificultad,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    this.puntosBase = 0,
    this.resuelta = false,
    this.respuestaLetra,
    this.ayudaUsada,
  });


  bool get respondida => respuestaLetra != null;

  bool get esCorrecta =>
      resuelta && respondida && respuestaLetra == respuestaCorrecta;

  int get puntosGanados => esCorrecta ? puntosBase : 0;

  factory SesionPreguntaDiaria.fromJson(Map<String, dynamic> json) {
    return SesionPreguntaDiaria(
      triviaId: json['triviaId'] ?? 0,
      categoriaId: json['categoriaId'] ?? 0,
      dificultad: json['dificultad']?.toString() ?? '',
      pregunta: json['pregunta']?.toString() ?? '',
      opciones: (json['opciones'] as Map? ?? const {})
          .map((k, v) => MapEntry(k.toString(), v.toString())),
      respuestaCorrecta: json['respuestaCorrecta']?.toString() ?? '',
      puntosBase: json['puntosBase'] ?? 0,
      resuelta: json['resuelta'] ?? false,
      respuestaLetra: json['respuestaLetra']?.toString(),
      ayudaUsada: json['ayudaUsada']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'triviaId': triviaId,
        'categoriaId': categoriaId,
        'dificultad': dificultad,
        'pregunta': pregunta,
        'opciones': opciones,
        'respuestaCorrecta': respuestaCorrecta,
        'puntosBase': puntosBase,
        'resuelta': resuelta,
        'respuestaLetra': respuestaLetra,
        'ayudaUsada': ayudaUsada,
      };

  SesionPreguntaDiaria responder({
    required String letra,
    String? ayudaUsada,
  }) {
    return copyWith(
      resuelta: true,
      respuestaLetra: letra,
      ayudaUsada: ayudaUsada ?? this.ayudaUsada,
    );
  }


  SesionPreguntaDiaria marcarSinRespuesta() {
    return copyWith(resuelta: true, limpiarRespuesta: true);
  }

  SesionPreguntaDiaria copyWith({
    bool? resuelta,
    String? respuestaLetra,
    bool limpiarRespuesta = false,
    String? ayudaUsada,
  }) {
    return SesionPreguntaDiaria(
      triviaId: triviaId,
      categoriaId: categoriaId,
      dificultad: dificultad,
      pregunta: pregunta,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      puntosBase: puntosBase,
      resuelta: resuelta ?? this.resuelta,
      respuestaLetra: limpiarRespuesta
          ? null
          : (respuestaLetra ?? this.respuestaLetra),
      ayudaUsada: ayudaUsada ?? this.ayudaUsada,
    );
  }

  @override
  List<Object?> get props => [
        triviaId,
        categoriaId,
        dificultad,
        pregunta,
        opciones,
        respuestaCorrecta,
        puntosBase,
        resuelta,
        respuestaLetra,
        ayudaUsada,
      ];
}





class SesionDiario extends Equatable {
  final DateTime fecha;
  final int? categoriaId;
  final String dificultad;
  final List<SesionPreguntaDiaria> preguntas;


  final bool recompensaReclamada;

  const SesionDiario({
    required this.fecha,
    this.categoriaId,
    this.dificultad = '',
    this.preguntas = const [],
    this.recompensaReclamada = false,
  });

  bool get completada =>
      preguntas.isNotEmpty && preguntas.every((p) => p.resuelta);

  int get puntosTotales =>
      preguntas.fold(0, (suma, p) => suma + p.puntosGanados);

  int get xpGanados => calcularXp(puntosTotales);

  int get monedasGanadas => calcularMonedas(puntosTotales);

  int get aciertos => preguntas.where((p) => p.esCorrecta).length;

  bool get enProgreso => preguntas.isNotEmpty && !completada;

  factory SesionDiario.fromJson(Map<String, dynamic> json) {
    return SesionDiario(
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
      categoriaId: json['categoriaId'],
      dificultad: json['dificultad']?.toString() ?? '',
      preguntas: (json['preguntas'] as List<dynamic>? ?? const [])
          .map((e) => SesionPreguntaDiaria.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      recompensaReclamada: json['recompensaReclamada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'fecha': fecha.toIso8601String(),
        'categoriaId': categoriaId,
        'dificultad': dificultad,
        'preguntas': preguntas.map((p) => p.toJson()).toList(),
        'recompensaReclamada': recompensaReclamada,
      };

  SesionDiario copyWith({
    DateTime? fecha,
    int? categoriaId,
    String? dificultad,
    List<SesionPreguntaDiaria>? preguntas,
    bool? recompensaReclamada,
  }) {
    return SesionDiario(
      fecha: fecha ?? this.fecha,
      categoriaId: categoriaId ?? this.categoriaId,
      dificultad: dificultad ?? this.dificultad,
      preguntas: preguntas ?? this.preguntas,
      recompensaReclamada: recompensaReclamada ?? this.recompensaReclamada,
    );
  }

  @override
  List<Object?> get props =>
      [fecha, categoriaId, dificultad, preguntas, recompensaReclamada];
}






class RachaDiario extends Equatable {
  final int actual;
  final int mejor;
  final DateTime? fechaUltimaCompletada;

  const RachaDiario({
    this.actual = 0,
    this.mejor = 0,
    this.fechaUltimaCompletada,
  });



  RachaDiario registrarDiaCompletado(DateTime hoy) {
    final ultima = fechaUltimaCompletada;
    if (ultima != null && esMismoDia(ultima, hoy)) return this;

    var nueva = 1;
    if (ultima != null && esDiaConsecutivo(ultima, hoy)) {
      nueva = actual + 1;
    }
    return RachaDiario(
      actual: nueva,
      mejor: max(nueva, mejor),
      fechaUltimaCompletada: hoy,
    );
  }

  factory RachaDiario.fromJson(Map<String, dynamic> json) {
    return RachaDiario(
      actual: json['actual'] ?? 0,
      mejor: json['mejor'] ?? 0,
      fechaUltimaCompletada: json['fechaUltimaCompletada'] != null
          ? DateTime.tryParse(json['fechaUltimaCompletada'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'actual': actual,
        'mejor': mejor,
        'fechaUltimaCompletada': fechaUltimaCompletada?.toIso8601String(),
      };

  RachaDiario copyWith({
    int? actual,
    int? mejor,
    DateTime? fechaUltimaCompletada,
  }) {
    return RachaDiario(
      actual: actual ?? this.actual,
      mejor: mejor ?? this.mejor,
      fechaUltimaCompletada:
          fechaUltimaCompletada ?? this.fechaUltimaCompletada,
    );
  }

  @override
  List<Object?> get props => [actual, mejor, fechaUltimaCompletada];
}






class ProgresoDiario extends Equatable {
  final Map<int, ProgresoCategoriaDiario> categorias;


  final Map<String, SesionDiario> sesiones;
  final RachaDiario racha;


  final String? semanaUltimaRecompensada;

  const ProgresoDiario({
    this.categorias = const {},
    this.sesiones = const {},
    this.racha = const RachaDiario(),
    this.semanaUltimaRecompensada,
  });

  ProgresoCategoriaDiario? categoriaDe(int categoriaId) => categorias[categoriaId];


  SesionDiario? sesionDeDia(DateTime hoy) {
    final clave = fechaClave(hoy);
    return sesiones.containsKey(clave) ? sesiones[clave] : null;
  }


  int diasCompletadosEnSemana(DateTime ref) {
    final inicio = inicioSemana(ref);
    return sesiones.values.where((s) {
      if (!s.completada) return false;
      return esMismoDia(inicioSemana(s.fecha), inicio);
    }).length;
  }

  bool semanaCompletadaEn(DateTime ref) =>
      diasCompletadosEnSemana(ref) >= 7;


  ProgresoDiario registrarSesion(SesionDiario sesionDia) {
    return copyWith(
      sesiones: {...sesiones, fechaClave(sesionDia.fecha): sesionDia},
    );
  }



  ProgresoDiario completarDia({
    required SesionDiario sesionFinal,
    required ProgresoCategoriaDiario categoriaActualizada,
  }) {
    final nuevasSesiones = {
      ...sesiones,
      fechaClave(sesionFinal.fecha): sesionFinal,
    };
    final nuevasCategorias = {
      ...categorias,
      categoriaActualizada.categoriaId: categoriaActualizada,
    };
    return ProgresoDiario(
      categorias: nuevasCategorias,
      sesiones: nuevasSesiones,
      racha: racha.registrarDiaCompletado(sesionFinal.fecha),
      semanaUltimaRecompensada: semanaUltimaRecompensada,
    );
  }

  ProgresoDiario marcarSemanaRecompensada(DateTime referencia) {
    return copyWith(semanaUltimaRecompensada: claveSemana(referencia));
  }



  ProgresoDiario actualizarSesion(SesionDiario sesionActualizada) {
    return copyWith(
      sesiones: {
        ...sesiones,
        fechaClave(sesionActualizada.fecha): sesionActualizada,
      },
    );
  }

  factory ProgresoDiario.fromJson(Map<String, dynamic> json) {
    final categorias = <int, ProgresoCategoriaDiario>{};
    for (final entrada in (json['categorias'] as Map? ?? const {}).entries) {
      final id = int.tryParse(entrada.key.toString());
      if (id == null) continue;
      categorias[id] = ProgresoCategoriaDiario.fromJson(
        Map<String, dynamic>.from(entrada.value as Map),
      );
    }
    final sesiones = <String, SesionDiario>{};
    for (final entrada in (json['sesiones'] as Map? ?? const {}).entries) {
      sesiones[entrada.key.toString()] = SesionDiario.fromJson(
        Map<String, dynamic>.from(entrada.value as Map),
      );
    }
    return ProgresoDiario(
      categorias: categorias,
      sesiones: sesiones,
      racha: json['racha'] is Map
          ? RachaDiario.fromJson(Map<String, dynamic>.from(json['racha'] as Map))
          : const RachaDiario(),
      semanaUltimaRecompensada: json['semanaUltimaRecompensada']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'categorias': {
          for (final entrada in categorias.entries)
            '${entrada.key}': entrada.value.toJson(),
        },
        'sesiones': {
          for (final entrada in sesiones.entries)
            entrada.key: entrada.value.toJson(),
        },
        'racha': racha.toJson(),
        'semanaUltimaRecompensada': semanaUltimaRecompensada,
      };

  ProgresoDiario copyWith({
    Map<int, ProgresoCategoriaDiario>? categorias,
    Map<String, SesionDiario>? sesiones,
    RachaDiario? racha,
    String? semanaUltimaRecompensada,
  }) {
    return ProgresoDiario(
      categorias: categorias ?? this.categorias,
      sesiones: sesiones ?? this.sesiones,
      racha: racha ?? this.racha,
      semanaUltimaRecompensada:
          semanaUltimaRecompensada ?? this.semanaUltimaRecompensada,
    );
  }

  @override
  List<Object?> get props => [
        categorias,
        sesiones,
        racha,
        semanaUltimaRecompensada,
      ];
}








int rachaEfectivaDiaria(ProgresoDiario progreso, DateTime hoy) {
  final ultima = progreso.racha.fechaUltimaCompletada;
  if (ultima == null) return 0;
  if (esMismoDia(ultima, hoy) || esDiaConsecutivo(ultima, hoy)) {
    return progreso.racha.actual;
  }
  return 0;
}