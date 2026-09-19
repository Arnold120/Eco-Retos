import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../catalogos/retos/reto_model.dart';
import '../catalogos/retos/retos_catalogo.dart';






class RetoProgresoLocal {
  static const _key = 'reto_progreso_v1';

  final Map<String, RetoProgreso> _memoria = {};
  Future<SharedPreferences>? _prefsFuture;
  bool _cargado = false;

  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  Future<Map<String, RetoProgreso>> _cargar() async {
    if (_cargado) return _memoria;
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final datos = Map<String, dynamic>.from(entry.value as Map);
            final reto = RetoCatalogo.porId(entry.key.toString());
            if (reto == null) continue;
            _memoria[reto.id] = RetoProgreso(
              reto: reto,
              estado: _estadoDe(datos['estado']),
              progresoActual: datos['progreso'] ?? 0,
              pasosCompletadas: datos['pasos'],
              fechaInicio: _fechaDe(datos['inicio']),
              fechaCompletado: _fechaDe(datos['completado']),
              evidenciaPendiente: datos['evidencia']?.toString(),
              motivoRechazo: datos['motivo']?.toString(),
            );
          }
        }
      }
    } catch (_) {

      _memoria.clear();
    } finally {
      _cargado = true;
    }
    return _memoria;
  }

  Future<RetoProgreso?> progresoDe(Reto reto) async {
    final memoria = await _cargar();
    return memoria[reto.id];
  }

  Future<void> guardar(RetoProgreso progreso) async {
    final memoria = await _cargar();
    memoria[progreso.reto.id] = progreso;
    await _persistir(memoria);
  }

  Future<void> limpiarReto(String retoId) async {
    final memoria = await _cargar();
    memoria.remove(retoId);
    await _persistir(memoria);
  }

  Future<void> _persistir(Map<String, RetoProgreso> memoria) async {
    final prefs = await _prefs;
    final json = {
      for (final entry in memoria.entries)
        entry.key: {
          'estado': entry.value.estado.name,
          'progreso': entry.value.progresoActual,
          'pasos': entry.value.pasosCompletadas,
          'inicio': entry.value.fechaInicio?.toIso8601String(),
          'completado': entry.value.fechaCompletado?.toIso8601String(),
          'evidencia': entry.value.evidenciaPendiente,
          'motivo': entry.value.motivoRechazo,
        },
    };
    await prefs.setString(_key, jsonEncode(json));
  }

  static RetoEstado _estadoDe(Object? nombre) {
    for (final estado in RetoEstado.values) {
      if (estado.name == nombre) return estado;
    }
    return RetoEstado.disponible;
  }

  static DateTime? _fechaDe(Object? valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
