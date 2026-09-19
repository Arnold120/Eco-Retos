import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recompensa pendiente o reclamada de la última partida de Modo Libre.
///
/// Se persiste localmente para que la recompensa siga disponible (reclamable)
/// aunque la app se cierre antes de pulsar "RECLAMAR RECOMPENSAS". Cada vez
/// que se inicia una partida nueva la pendiente anterior se descarta.
class RecompensaLibre extends Equatable {
  final int puntos;
  final int xp;
  final int monedas;
  final int respuestasCorrectas;
  final int totalPreguntas;
  final bool reclamada;
  /// Clave única de la partida (idempotencia del reclamo en el backend).
  final String clave;

  const RecompensaLibre({
    required this.puntos,
    required this.xp,
    required this.monedas,
    required this.respuestasCorrectas,
    required this.totalPreguntas,
    this.reclamada = false,
    this.clave = '',
  });

  bool get pendiente => !reclamada;

  factory RecompensaLibre.fromJson(Map<String, dynamic> json) {
    return RecompensaLibre(
      puntos: json['puntos'] ?? 0,
      xp: json['xp'] ?? 0,
      monedas: json['monedas'] ?? 0,
      respuestasCorrectas: json['respuestasCorrectas'] ?? 0,
      totalPreguntas: json['totalPreguntas'] ?? 0,
      reclamada: json['reclamada'] ?? false,
      clave: json['clave']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'puntos': puntos,
        'xp': xp,
        'monedas': monedas,
        'respuestasCorrectas': respuestasCorrectas,
        'totalPreguntas': totalPreguntas,
        'reclamada': reclamada,
        'clave': clave,
      };

  RecompensaLibre copyWith({
    int? puntos,
    int? xp,
    int? monedas,
    int? respuestasCorrectas,
    int? totalPreguntas,
    bool? reclamada,
    String? clave,
  }) {
    return RecompensaLibre(
      puntos: puntos ?? this.puntos,
      xp: xp ?? this.xp,
      monedas: monedas ?? this.monedas,
      respuestasCorrectas: respuestasCorrectas ?? this.respuestasCorrectas,
      totalPreguntas: totalPreguntas ?? this.totalPreguntas,
      reclamada: reclamada ?? this.reclamada,
      clave: clave ?? this.clave,
    );
  }

  @override
  List<Object?> get props =>
      [
        puntos,
        xp,
        monedas,
        respuestasCorrectas,
        totalPreguntas,
        reclamada,
        clave,
      ];
}

/// Almacén local de la recompensa de la última partida de Modo Libre
/// (SharedPreferences), con la misma robustez ante preferencias corruptas que
/// `DiarioStore`.
class RecompensaLibreStore {
  final int usuarioId;

  RecompensaLibreStore({required this.usuarioId});

  static const _prefijoClave = 'trivia_recompensa_libre_v1';

  late final String _clave = '${_prefijoClave}_$usuarioId';

  RecompensaLibre? _memoria;
  Future<SharedPreferences>? _prefsFuture;
  bool _cargado = false;

  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  Future<RecompensaLibre?> cargar() async {
    if (_cargado) return _memoria;
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_clave);
      if (raw != null) {
        final decodeado = jsonDecode(raw);
        if (decodeado is Map) {
          _memoria = RecompensaLibre.fromJson(
            Map<String, dynamic>.from(decodeado),
          );
        }
      }
    } catch (_) {
      // Preferencias corruptas: se descarta la recompensa pendiente.
      _memoria = null;
    } finally {
      _cargado = true;
    }
    return _memoria;
  }

  Future<void> guardar(RecompensaLibre recompensa) async {
    _memoria = recompensa;
    final prefs = await _prefs;
    await prefs.setString(_clave, jsonEncode(recompensa.toJson()));
  }

  Future<void> limpiar() async {
    _memoria = null;
    final prefs = await _prefs;
    await prefs.remove(_clave);
  }
}