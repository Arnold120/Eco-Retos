import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trivia/diario_models.dart';

/// Almacén local del progreso del Modo Diario (SharedPreferences).
///
/// Los datos se guardan por usuario con la clave `trivias_diario_v1_<id>`,
/// siguiendo el mismo patrón de [RetoProgresoLocal]: carga perezosa con caché
/// en memoria y tolerancia a preferencias corruptas (se reinicia desde cero).
class DiarioStore {
  final int usuarioId;

  DiarioStore({required this.usuarioId});

  static const _prefijoClave = 'trivias_diario_v1';

  late final String _clave = '${_prefijoClave}_$usuarioId';

  ProgresoDiario? _memoria;
  Future<SharedPreferences>? _prefsFuture;
  bool _cargado = false;

  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  Future<ProgresoDiario> cargar() async {
    if (_cargado) return _memoria ?? const ProgresoDiario();
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_clave);
      if (raw != null) {
        final decodeado = jsonDecode(raw);
        if (decodeado is Map) {
          _memoria = ProgresoDiario.fromJson(
            Map<String, dynamic>.from(decodeado),
          );
        }
      }
    } catch (_) {
      // Preferencias corruptas: se parte de cero.
      _memoria = null;
    } finally {
      _cargado = true;
    }
    return _memoria ?? const ProgresoDiario();
  }

  Future<void> guardar(ProgresoDiario progreso) async {
    _memoria = progreso;
    final prefs = await _prefs;
    await prefs.setString(_clave, jsonEncode(progreso.toJson()));
  }

  Future<void> limpiar() async {
    _memoria = null;
    final prefs = await _prefs;
    await prefs.remove(_clave);
  }
}