import 'dart:math';

import 'package:equatable/equatable.dart';

/// Segundos disponibles para responder cada pregunta del Modo Diario.
const Duration kTiempoPorPreguntaDiario = Duration(seconds: 30);

/// Cantidad fija de preguntas que compone la partida diaria.
const int kPreguntasPorDia = 3;

/// Semanas consecutivas completando la trivia diaria necesarias para subir
/// de dificultad en una categoría.
const int kSemanasParaSubirDificultad = 3;

/// XP extra por completar los 7 días de una semana, entregada una sola vez.
const int kXpSemanaCompletada = 100;

/// Monedas extra por completar los 7 días de una semana, entregada una vez.
const int kMonedasSemanaCompletada = 50;

/// Dificultades reales de la base de datos (`Facil`, `Intermedia`, `Dificil`).
///
/// Además de la etiqueta legible para la UI expone la dificultad siguiente en
/// el orden creciente, usada por la progresión del Modo Diario.
enum DificultadTrivia {
  facil('Facil', 'Fácil'),
  intermedia('Intermedia', 'Normal'),
  dificil('Dificil', 'Difícil');

  const DificultadTrivia(this.valorDb, this.etiqueta);

  /// Valor tal y como se guarda en la tabla `Trivia`.
  final String valorDb;

  /// Etiqueta legible para mostrar al usuario.
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

  /// Dificultad superior, o `null` si esta es la máxima.
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

/// Ayudas disponibles en las partidas de trivia.
///
/// `pista` elimina una opción incorrecta, `cincuentaCincuenta` elimina dos y
/// `saltar` descarta la pregunta actual (solo disponible en Modo Libre).
enum AyudaTrivia {
  pista(50, 'Pista'),
  cincuentaCincuenta(80, '50/50'),
  saltar(100, 'Saltar');

  const AyudaTrivia(this.costo, this.nombre);

  /// Monedas que cuesta activar la ayuda.
  final int costo;

  final String nombre;

  static AyudaTrivia desdePersistencia(String? valor) {
    for (final ayuda in AyudaTrivia.values) {
      if (ayuda.name == valor) return ayuda;
    }
    return AyudaTrivia.pista;
  }
}

// ---------------------------------------------------------------------------
// Helpers de fecha
// ---------------------------------------------------------------------------

String _dosDigitos(int n) => n.toString().padLeft(2, '0');

/// Clave de fecha `aaaa-mm-dd` usada para persistir y comparar días.
String fechaClave(DateTime fecha) =>
    '${fecha.year}-${_dosDigitos(fecha.month)}-${_dosDigitos(fecha.day)}';

/// Devuelve el lunes (a medianoche) de la semana que contiene [fecha].
DateTime inicioSemana(DateTime fecha) {
  final base = DateTime(fecha.year, fecha.month, fecha.day);
  return base.subtract(Duration(days: base.weekday - DateTime.monday));
}

/// Clave única de la semana (el lunes de su `aaaa-mm-dd`), usada para saber
/// si la recompensa semanal ya fue entregada.
String claveSemana(DateTime fecha) => fechaClave(inicioSemana(fecha));

/// Categoría asignada al día según `DateTime.weekday` (Lunes→1 ... Domingo→7).
int indiceCategoriaDelDia(DateTime fecha) => fecha.weekday;

bool esMismoDia(DateTime a, DateTime b) => fechaClave(a) == fechaClave(b);

/// Devuelve `true` si [actual] es el día inmediatamente posterior a [anterior].
bool esDiaConsecutivo(DateTime anterior, DateTime actual) {
  final siguiente = DateTime(anterior.year, anterior.month, anterior.day + 1);
  return fechaClave(siguiente) == fechaClave(actual);
}

/// Devuelve `true` si entre ambas fechas hay exactamente [dias] de diferencia.
bool esDiferenciaDeDias(DateTime a, DateTime b, {required int dias}) {
  final base = DateTime(a.year, a.month, a.day);
  final otro = DateTime(b.year, b.month, b.day);
  return base.difference(otro).inDays.abs() == dias;
}

// ---------------------------------------------------------------------------
// Recompensas
// ---------------------------------------------------------------------------

/// La XP entregada coincide con los puntos obtenidos.
int calcularXp(int puntos) => puntos;

/// Las monedas se obtienen a razón de 1 por cada 10 puntos.
int calcularMonedas(int puntos) => puntos ~/ 10;

// ---------------------------------------------------------------------------
// Progreso por categoría
// ---------------------------------------------------------------------------

/// Progreso individual de una categoría en el Modo Diario.
///
/// `semanasCompletadasConsecutivas` acumula semanas seguidas completadas;
/// al llegar a [kSemanasParaSubirDificultad] la dificultad sube y el contador
/// se reinicia. `cicloDificultad` cuenta cuántas veces subió la dificultad.
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

  /// Actualiza las estadísticas acumuladas tras finalizar una partida.
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

  /// Registra una semana completada. Si viene después de una semana contigua
  /// (exactamente 7 días) suma al contador; cuando se alcanzan
  /// [kSemanasParaSubirDificultad] sube la dificultad, incrementa el ciclo y
  /// reinicia el contador.
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

// ---------------------------------------------------------------------------
// Sesión diaria
// ---------------------------------------------------------------------------

/// Resultado de una pregunta dentro de la sesión diaria.
///
/// `resuelta` es `true` cuando la pregunta llegó a su estado final (respondida
/// o tiempo agotado) y `respuestaLetra` guarda la letra elegida o `null` si el
/// tiempo se agotó. Ambos permiten reanudar una sesión a medias.
/// `ayudaUsada` guarda el nombre de `AyudaTrivia` que se aplicó, si usó alguna.
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

  /// El usuario respondió una letra (no aplica cuando se agotó el tiempo).
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

  /// Marca la pregunta como resuelta sin respuesta (tiempo agotado).
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

/// Sesión del Modo Diario correspondiente a un día.
///
/// `completada` no depende de los aciertos: el día se considera completado
/// cuando se respondieron todas las preguntas disponibles.
class SesionDiario extends Equatable {
  final DateTime fecha;
  final int? categoriaId;
  final String dificultad;
  final List<SesionPreguntaDiaria> preguntas;

  /// Indica si la recompensa del día ya fue reclamada (entrega única).
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

// ---------------------------------------------------------------------------
// Racha
// ---------------------------------------------------------------------------

/// Racha global de días consecutivos completando la trivia diaria.
class RachaDiario extends Equatable {
  final int actual;
  final int mejor;
  final DateTime? fechaUltimaCompletada;

  const RachaDiario({
    this.actual = 0,
    this.mejor = 0,
    this.fechaUltimaCompletada,
  });

  /// Registra un día completado. Suma si es consecutivo al anterior, se
  /// reinicia a 1 si hubo un hueco y no hace nada si ya se repitió el mismo día.
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

// ---------------------------------------------------------------------------
// Progreso global del Modo Diario
// ---------------------------------------------------------------------------

/// Estado global persistido del Modo Diario de un usuario.
class ProgresoDiario extends Equatable {
  final Map<int, ProgresoCategoriaDiario> categorias;

  /// Sesiones por clave de fecha `aaaa-mm-dd`.
  final Map<String, SesionDiario> sesiones;
  final RachaDiario racha;

  /// Clave de la última semana (lunes `aaaa-mm-dd`) que recibió recompensa.
  final String? semanaUltimaRecompensada;

  const ProgresoDiario({
    this.categorias = const {},
    this.sesiones = const {},
    this.racha = const RachaDiario(),
    this.semanaUltimaRecompensada,
  });

  ProgresoCategoriaDiario? categoriaDe(int categoriaId) => categorias[categoriaId];

  /// Sesión del día [hoy], si ya fue iniciada.
  SesionDiario? sesionDeDia(DateTime hoy) {
    final clave = fechaClave(hoy);
    return sesiones.containsKey(clave) ? sesiones[clave] : null;
  }

  /// Cantidad de días completados dentro de la semana que contiene [ref].
  int diasCompletadosEnSemana(DateTime ref) {
    final inicio = inicioSemana(ref);
    return sesiones.values.where((s) {
      if (!s.completada) return false;
      return esMismoDia(inicioSemana(s.fecha), inicio);
    }).length;
  }

  bool semanaCompletadaEn(DateTime ref) =>
      diasCompletadosEnSemana(ref) >= 7;

  /// Registra la sesión del día (iniciada o finalizada).
  ProgresoDiario registrarSesion(SesionDiario sesionDia) {
    return copyWith(
      sesiones: {...sesiones, fechaClave(sesionDia.fecha): sesionDia},
    );
  }

  /// Actualiza racha, estadísticas de categoría y la sesión tras finalizar
  /// la partida del día.
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

  /// Reemplaza la sesión persistida de un día (p. ej. al reclamar la
  /// recompensa) conservando el resto del progreso.
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

// ---------------------------------------------------------------------------
// Fuente única global de la racha diaria
// ---------------------------------------------------------------------------

/// Racha efectiva del Modo Diario. Fuente única que deben consultar Inicio,
/// Perfil, Trivias y los resultados: conserva el valor mientras la última vez
/// fue hoy o ayer; si quedó un día sin completar, se muestra en 0.
int rachaEfectivaDiaria(ProgresoDiario progreso, DateTime hoy) {
  final ultima = progreso.racha.fechaUltimaCompletada;
  if (ultima == null) return 0;
  if (esMismoDia(ultima, hoy) || esDiaConsecutivo(ultima, hoy)) {
    return progreso.racha.actual;
  }
  return 0;
}