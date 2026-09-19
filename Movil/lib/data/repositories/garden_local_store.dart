import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden/garden_catalog.dart';
import '../models/garden/plant_growth.dart';

/// Almacén local del jardín virtual (SharedPreferences): plantas e inventario
/// de herramientas por usuario. Migra automáticamente el formato anterior
/// (`jardin_virtual_v1`, solo lista de plantas).
class GardenLocalStore {
  final int usuarioId;

  GardenLocalStore({required this.usuarioId});

  static const _prefijoClave = 'jardin_virtual_v2';
  static const _prefijoClaveV1 = 'jardin_virtual_v1';

  late final String _clave = '${_prefijoClave}_$usuarioId';
  late final String _claveV1 = '${_prefijoClaveV1}_$usuarioId';

  List<PlantGrowth>? _plantas;
  InventarioJardin? _inventario;
  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  Future<void> _cargarSiHaceFalta() async {
    if (_plantas != null && _inventario != null) return;
    var plantas = <PlantGrowth>[];
    var inventario = const InventarioJardin();
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_clave);
      if (raw != null) {
        final decodificado = jsonDecode(raw);
        if (decodificado is Map) {
          final datos = Map<String, dynamic>.from(decodificado);
          final lista = datos['plantas'];
          if (lista is List) {
            for (final item in lista) {
              if (item is Map) {
                final planta = PlantGrowth.fromJson(
                  Map<String, dynamic>.from(item),
                );
                if (planta.id.isNotEmpty) plantas.add(planta);
              }
            }
          }
          final inv = datos['inventario'];
          if (inv is Map) {
            inventario = InventarioJardin.fromJson(
              Map<String, dynamic>.from(inv),
            );
          }
        }
      } else {
        plantas = await _migrarDesdeV1(prefs);
      }
    } catch (_) {
      // Preferencias corruptas: se parte de un jardín vacío.
      plantas = [];
      inventario = const InventarioJardin();
    }
    plantas.sort((a, b) => a.slot.compareTo(b.slot));
    _plantas = plantas;
    _inventario = inventario;
  }

  Future<List<PlantGrowth>> _migrarDesdeV1(SharedPreferences prefs) async {
    final plantas = <PlantGrowth>[];
    try {
      final raw = prefs.getString(_claveV1);
      if (raw == null) return plantas;
      final decodificado = jsonDecode(raw);
      if (decodificado is! List) return plantas;
      final ahora = DateTime.now();
      for (final item in decodificado) {
        if (item is! Map) continue;
        final datos = Map<String, dynamic>.from(item);
        final progreso = (datos['progreso'] as num?)?.toDouble() ?? 0;
        datos['horas'] = progreso / 100 * GardenGrowthConfig.horasHastaAdulta;
        datos['ultimaActualizacion'] = ahora.toIso8601String();
        datos['ultimoRiego'] = datos['ultimoCuidado'];
        if (CatalogoJardin.porId(datos['catalogoId']?.toString() ?? '') ==
            null) {
          final modelo = datos['modelo']?.toString() ?? '';
          for (final especie in CatalogoJardin.especies) {
            final archivo = especie.modelo.replaceAll('.glb', '');
            if (modelo.contains(archivo)) {
              datos['catalogoId'] = especie.id;
              break;
            }
          }
        }
        final planta = PlantGrowth.fromJson(datos);
        if (planta.id.isNotEmpty) plantas.add(planta);
      }
      if (plantas.isNotEmpty) {
        await guardar(plantas: plantas, inventario: const InventarioJardin());
      }
    } catch (_) {
      plantas.clear();
    }
    return plantas;
  }

  Future<List<PlantGrowth>> cargarPlantas() async {
    await _cargarSiHaceFalta();
    return List<PlantGrowth>.from(_plantas ?? const []);
  }

  Future<InventarioJardin> cargarInventario() async {
    await _cargarSiHaceFalta();
    return _inventario ?? const InventarioJardin();
  }

  Future<void> guardar({
    required List<PlantGrowth> plantas,
    required InventarioJardin inventario,
  }) async {
    _plantas = List<PlantGrowth>.from(plantas);
    _inventario = inventario;
    try {
      final prefs = await _prefs;
      final json = {
        'version': 2,
        'plantas': [for (final planta in plantas) planta.toJson()],
        'inventario': inventario.toJson(),
        'guardadoEl': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_clave, jsonEncode(json));
    } catch (_) {
      // Si falla el guardado local, el jardín sigue funcionando en memoria.
    }
  }

  Future<void> limpiar() async {
    _plantas = [];
    _inventario = const InventarioJardin();
    try {
      final prefs = await _prefs;
      await prefs.remove(_clave);
    } catch (_) {}
  }
}
