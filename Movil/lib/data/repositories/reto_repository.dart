import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../catalogos/retos/reto_model.dart';
import '../catalogos/retos/retos_catalogo.dart';
import '../models/challenge/challenge_models.dart';
import '../models/gamification/gamification_models.dart';
import '../services/gamification_service.dart';
import '../services/reto_service.dart';
import 'reto_progreso_local.dart';

/// Repositorio de retos: único punto donde se fusiona el catálogo
/// (contenido) con el progreso local persistido y el backend.
///
/// Reglas de oro:
/// - La UI nunca consume `Reto` solo: siempre consume `RetoProgreso`.
/// - El completado es transaccional (anti doble recompensa).
class RetoRepository {
  final int usuarioId;
  final RetoService _retoService;
  final RetoProgresoLocal _local;
  final MonederoService _monedero;
  final ProgresoService _progreso;
  final InsigniaService _insignias;

  RetoRepository({
    required this.usuarioId,
    required RetoService retoService,
    required MonederoService monederoService,
    required ProgresoService progresoService,
    required InsigniaService insigniaService,
    RetoProgresoLocal? local,
  }) : _retoService = retoService,
       _monedero = monederoService,
       _progreso = progresoService,
       _insignias = insigniaService,
       _local = local ?? RetoProgresoLocal();

  /// Carga el catálogo de retos desde el backend (una sola vez, compartido
  /// entre llamadas concurrentes). Si no hay conexión, el catálogo queda
  /// vacío o con lo ya cargado y se reintenta en la próxima carga.
  static Future<void> cargarCatalogo(RetoService retoService) {
    return RetoCatalogo.cargar(() async {
      final respuestas = await retoService.getRetos();
      final lista = <Reto>[];
      for (final respuesta in respuestas) {
        final reto = respuesta.toReto();
        if (reto.id.isNotEmpty) lista.add(reto);
      }
      return lista;
    });
  }

  /// Estados del servidor por retoBackendId (cuando el reto del catálogo
  /// está vinculado a uno del backend). NO es la fuente primaria.
  Map<int, UsuarioRetoResponse> _backendRetos = {};
  bool _backendCargado = false;

  static const _idsBackendKey = 'reto_backend_ids_v1';
  static const _recompensasOkKey = 'reto_recompensa_ok_v1';

  /// Retos del catálogo cuya recompensa ya fue reclamada al backend.
  /// Evita reintentos innecesarios en cada carga (el servidor, además, es
  /// idempotente por clave).
  Set<String> _recompensasOk = {};
  bool _recompensasOkCargadas = false;

  Future<void> _cargarRecompensasOk() async {
    if (_recompensasOkCargadas) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recompensasOk = {...?prefs.getStringList(_recompensasOkKey)};
    } catch (_) {
      _recompensasOk = {};
    } finally {
      _recompensasOkCargadas = true;
    }
  }

  Future<void> _marcarRecompensaOk(String retoId) async {
    await _cargarRecompensasOk();
    if (_recompensasOk.add(retoId)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_recompensasOkKey, _recompensasOk.toList());
      } catch (_) {}
    }
  }

  /// Traducción id de catálogo → RetoId del backend (auto-registrado).
  /// Persistida para que la app funcione offline y no re-cree retos.
  Map<String, int> _backendIdsPorCodigo = {};
  bool _idsBackendCargados = false;

  Future<void> _cargarIdsBackend() async {
    if (_idsBackendCargados) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_idsBackendKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _backendIdsPorCodigo = {
            for (final entry in decoded.entries)
              entry.key.toString(): int.tryParse(entry.value.toString()) ?? 0,
          };
          _backendIdsPorCodigo.removeWhere((_, id) => id <= 0);
        }
      }
    } catch (_) {
      _backendIdsPorCodigo = {};
    } finally {
      _idsBackendCargados = true;
    }
  }

  Future<void> _guardarIdsBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idsBackendKey, jsonEncode(_backendIdsPorCodigo));
    } catch (_) {}
  }

  /// RetoId conocido para un reto del catálogo, sin hacer red: el fijado en
  /// el catálogo o, si no, el auto-registrado por Codigo (cache persistida).
  int? _idBackendDeReto(Reto reto) {
    final fijo = reto.retoBackendId;
    if (fijo != null) return fijo;
    return _backendIdsPorCodigo[reto.id];
  }

  static String _dificultadBackend(RetoDificultad dificultad) {
    return switch (dificultad) {
      RetoDificultad.facil => 'FACIL',
      RetoDificultad.intermedio => 'INTERMEDIO',
      RetoDificultad.dificil => 'DIFICIL',
      RetoDificultad.experto => 'EXPERTO',
    };
  }

  /// Retos cuya evidencia fue APROBADA por un admin desde la última carga:
  /// la UI los celebra (la recompensa ya se otorgó aquí mismo).
  final List<AprobacionReciente> aprobacionesRecientes = [];

  Future<void> _cargarBackend() async {
    if (_backendCargado) return;
    try {
      final misRetos = await _retoService.getRetosUsuario(usuarioId);
      _backendRetos = {
        for (final ur in misRetos)
          if (ur.retoId != 0) ur.retoId: ur,
      };
      // Reconstruye el vínculo catálogo ↔ backend por Codigo: aunque se
      // pierda la cache local (reinstalación u otro dispositivo), los retos
      // completados en el servidor vuelven a mostrarse en la app.
      var cambios = false;
      for (final ur in misRetos) {
        final codigo = ur.codigo;
        if (codigo == null || codigo.isEmpty || ur.retoId == 0) continue;
        if (_backendIdsPorCodigo[codigo] != ur.retoId) {
          _backendIdsPorCodigo[codigo] = ur.retoId;
          cambios = true;
        }
      }
      if (cambios) await _guardarIdsBackend();
    } catch (_) {
      // Offline o backend inaccesible: se usa exclusivamente el progreso local.
    } finally {
      _backendCargado = true;
    }
  }

  /// Re-intenta la sincronización (p. ej. tras reconexión o al reabrir).
  Future<void> resincronizarBackend() async {
    _backendCargado = false;
    _backendRetos = {};
    await _cargarBackend();
  }

  /// Todo el catálogo con el estado/progreso de cada reto.
  ///
  /// Además reconcilia con el backend: si un admin aprobó la evidencia de
  /// un reto que aquí estaba "pendiente de revisión", este método lo
  /// completa y otorga la recompensa (XP + ECO + logros) una sola vez.
  Future<List<RetoProgreso>> obtener() async {
    await RetoRepository.cargarCatalogo(_retoService);
    await _cargarIdsBackend();
    await _cargarBackend();
    aprobacionesRecientes.clear();
    final lista = <RetoProgreso>[];
    final porSincronizar = <RetoProgreso>[];
    for (final reto in RetoCatalogo.todos) {
      final local = await _local.progresoDe(reto) ?? _progresoBackend(reto);
      final reconciliado = await _reconciliar(reto, local);
      lista.add(reconciliado);

      // Solo los retos que el usuario realmente "hizo" se suben al backend
      // (los 1000 del catálogo nunca se envían en masa). Los que ya existen
      // por Codigo se reutilizan; los demás se crean. Todo en UN solo viaje.
      if (_backendCargado && _requiereSincronizacion(reto, reconciliado)) {
        porSincronizar.add(reconciliado);
      }
    }
    if (porSincronizar.isNotEmpty) {
      await _sincronizarLoteBackend(porSincronizar);
    }
    return lista;
  }

  /// Un reto necesita sincronización solo si el usuario lo completó o lo
  /// envió a revisión y el backend aún no refleja ese estado (ni el reto
  /// ni su participación existen, o están desactualizados).
  bool _requiereSincronizacion(Reto reto, RetoProgreso progreso) {
    if (progreso.estado != RetoEstado.completado &&
        progreso.estado != RetoEstado.pendienteRevision) {
      return false;
    }
    final backendId = _idBackendDeReto(reto);
    if (backendId == null) return true;
    final existente = _backendRetos[backendId];
    if (existente == null) return true;
    return progreso.estado == RetoEstado.completado
        ? existente.estado != 'COMPLETADO'
        : existente.estado != 'EN_REVISION';
  }

  /// Copia los retos "hechos" al backend en un solo lote (verificado/existente
  /// o creado, y asignado a este usuario). Best-effort: si no hay conexión el
  /// estado queda local y se reintenta al abrir.
  Future<void> _sincronizarLoteBackend(List<RetoProgreso> progresos) async {
    final items = <Map<String, dynamic>>[];
    for (final p in progresos) {
      items.add({
        'Codigo': p.reto.id,
        'CategoriaId': p.reto.categoria.categoriaId,
        'Titulo': p.reto.titulo,
        'Descripcion': p.reto.descripcion,
        'Instrucciones': p.reto.instrucciones.isNotEmpty
            ? p.reto.instrucciones.join('\n')
            : p.reto.descripcion,
        'ExperienciaRecompensa': p.reto.xp,
        'MonedasRecompensa': p.reto.monedas,
        // Compatibilidad con backend anterior.
        'Puntos': p.reto.xp,
        'Dificultad': _dificultadBackend(p.reto.dificultad),
        'Estado': p.estado == RetoEstado.completado
            ? 'COMPLETADO'
            : 'EN_REVISION',
        'Evidencia': p.evidenciaPendiente,
        'PuntosObtenidos': p.reto.xp,
      });
    }
    try {
      final resultados = await _retoService.sincronizarParticipaciones(
        usuarioId,
        items,
      );
      for (final ur in resultados) {
        if (ur.retoId == 0) continue;
        _backendRetos[ur.retoId] = ur;
        if (ur.codigo != null && ur.codigo!.isNotEmpty) {
          _backendIdsPorCodigo[ur.codigo!] = ur.retoId;
        }
      }
      await _guardarIdsBackend();
    } catch (_) {
      // Sin conexión: los estados quedan locales y se reintentan en la próxima.
    }
  }

  Future<RetoProgreso> _reconciliar(Reto reto, RetoProgreso local) async {
    final backendId = _idBackendDeReto(reto);
    final backend = backendId == null ? null : _backendRetos[backendId];
    if (backend == null) return local;

    // ✅ El reto ya está completado en el servidor (aprobado por un admin o
    // completado desde otro dispositivo): reflejarlo también en local.
    if (backend.estado == 'COMPLETADO' &&
        local.estado != RetoEstado.completado) {
      final aprobadoPorAdmin =
          local.estado == RetoEstado.pendienteRevision;
      final completo = RetoProgreso(
        reto: reto,
        estado: RetoEstado.completado,
        progresoActual: reto.cantidadObjetivo ?? reto.instrucciones.length,
        pasosCompletadas: reto.instrucciones.isNotEmpty
            ? reto.instrucciones.length
            : null,
        fechaInicio: local.fechaInicio,
        fechaCompletado: backend.fechaCompletado ?? DateTime.now(),
      );
      await _local.guardar(completo);
      if (aprobadoPorAdmin) {
        // La recompensa se paga una sola vez: tras esto el estado local ya es
        // `completado` y esta rama no volverá a ejecutarse.
        final logros = await _otorgarRecompensa(reto);
        aprobacionesRecientes.add(AprobacionReciente(completo, logros));
      }
      return completo;
    }

    // ❌ El admin rechazó la evidencia: informar el motivo y liberar el
    // reto para que el estudiante pueda reenviarla.
    if (backend.estado == 'RECHAZADO' && local.estado != RetoEstado.rechazado) {
      final rechazado = local.copyWith(
        estado: RetoEstado.rechazado,
        motivoRechazo: backend.motivoRechazo ?? 'La evidencia no fue aceptada.',
        clearEvidencia: true,
      );
      await _local.guardar(rechazado);
      return rechazado;
    }

    return local;
  }

  RetoProgreso _progresoBackend(Reto reto) {
    final backendId = _idBackendDeReto(reto);
    final backend = backendId == null || !_backendCargado
        ? null
        : _backendRetos[backendId];
    final estado = backend?.estado;
    if (estado == null) return RetoProgreso(reto: reto);
    return switch (estado) {
      'COMPLETADO' => RetoProgreso(
        reto: reto,
        estado: RetoEstado.completado,
        fechaCompletado: backend?.fechaCompletado,
        progresoActual: reto.cantidadObjetivo ?? reto.instrucciones.length,
      ),
      'INICIADO' || 'EN_PROGRESO' || 'EN_REVISION' => RetoProgreso(
        reto: reto,
        estado: RetoEstado.enProgreso,
        fechaInicio: DateTime.now(),
      ),
      'RECHAZADO' => RetoProgreso(
        reto: reto,
        estado: RetoEstado.rechazado,
        motivoRechazo:
            backend?.motivoRechazo ?? 'La evidencia no fue aceptada.',
      ),
      _ => RetoProgreso(reto: reto),
    };
  }

  /// Comienza un reto: pasa a "En progreso" y persiste.
  Future<RetoProgreso> comenzar(Reto reto) async {
    final anterior = await _local.progresoDe(reto);
    if (anterior != null &&
        anterior.estado != RetoEstado.disponible &&
        anterior.estado != RetoEstado.rechazado) {
      return anterior;
    }
    final progreso = RetoProgreso(
      reto: reto,
      estado: RetoEstado.enProgreso,
      fechaInicio: DateTime.now(),
    );
    await _local.guardar(progreso);
    _sincronizarBackend(reto, progreso);
    return progreso;
  }

  /// Marca un paso como completado.
  Future<RetoProgreso> avanzarPaso(Reto reto, int pasoCompletado) async {
    final local =
        await _local.progresoDe(reto) ??
        RetoProgreso(
          reto: reto,
          estado: RetoEstado.enProgreso,
          fechaInicio: DateTime.now(),
        );
    final nuevo = local.copyWith(
      estado: RetoEstado.enProgreso,
      progresoActual: pasoCompletado,
      pasosCompletadas: pasoCompletado,
    );
    await _local.guardar(nuevo);
    return nuevo;
  }

  /// Registra evidencia y pasa el reto a "Pendiente de revisión".
  Future<RetoProgreso> enviarEvidencia(Reto reto, String evidencia) async {
    final local =
        await _local.progresoDe(reto) ??
        RetoProgreso(reto: reto, estado: RetoEstado.enProgreso);
    final nuevo = local.copyWith(
      estado: RetoEstado.pendienteRevision,
      evidenciaPendiente: evidencia,
      clearMotivo: true,
    );
    await _local.guardar(nuevo);
    if (_backendCargado) {
      try {
        await _asignarRetoBackend(reto, 'EN_REVISION', evidencia: evidencia);
        _backendCargado = false;
      } catch (_) {}
    }
    return nuevo;
  }

  /// Completa un reto de forma TRANSACCIONAL.
  ///
  /// Devuelve [CompletadoNuevo] la primera vez (recompensa otorgada) o
  /// [CompletoYa] si ya estaba completado (NO se vuelve a otorgar XP).
  Future<CompletarResultado> completar(Reto reto) async {
    final previo = await _local.progresoDe(reto);
    if (previo?.estado == RetoEstado.completado) {
      return CompletoYa(previo!);
    }

    final objetivo = reto.cantidadObjetivo ?? reto.instrucciones.length;
    final completo = RetoProgreso(
      reto: reto,
      estado: RetoEstado.completado,
      progresoActual: objetivo,
      pasosCompletadas: reto.instrucciones.isNotEmpty
          ? reto.instrucciones.length
          : null,
      fechaInicio: previo?.fechaInicio,
      fechaCompletado: DateTime.now(),
    );

    await _local.guardar(completo);

    if (_backendCargado) {
      try {
        await _asignarRetoBackend(reto, 'COMPLETADO');
        _backendCargado = false;
      } catch (_) {}
    }

    // Recompensa real en la economía del usuario (XP + monedas + contador).
    // Best-effort: un fallo aquí no bloquea la finalización del reto.
    final logros = await _otorgarRecompensa(reto);

    return CompletadoNuevo(completo, logros: logros);
  }

  /// Otorga la recompensa económica del reto y, de paso, evalúa y otorga
  /// las insignias/logros por retos completados.
  ///
  /// La XP y las Monedas Eco las calcula el backend desde la configuración
  /// del reto. Antes de reclamar se asegura de que el reto y la participación
  /// existan y estén en COMPLETADO (esto también actualiza en el backend la
  /// recompensa del reto con los valores del catálogo local).
  Future<List<InsigniaResponse>> _otorgarRecompensa(Reto reto) async {
    try {
      var backendId = _idBackendDeReto(reto);
      try {
        final respuesta = await _asignarRetoBackend(reto, 'COMPLETADO');
        _backendCargado = false;
        if (respuesta.retoId != 0) backendId = respuesta.retoId;
      } catch (_) {
        // Sin conexión: el reclamo fallará y se reintentará al reconciliar
        // la próxima aprobación/carga (el servidor es idempotente).
      }
      if (backendId != null) {
        await _monedero.reclamarRecompensa(
          tipo: 'RETO',
          claveIdempotencia: 'RETO:$backendId',
          retoId: backendId,
          categoriaId: reto.categoria.categoriaId,
          descripcion: 'Reto completado: ${reto.titulo}',
        );
        await _marcarRecompensaOk(reto.id);
      }
      await _progreso.incrementarRetos(usuarioId);
    } catch (_) {
      // Un fallo aquí no rompe el completado.
    }
    return _otorgarInsigniasPorRetos();
  }

  /// Insignias de progreso por retos completados.
  ///
  /// Consulta el catálogo real de insignias del backend, deduce cuántos
  /// retos exige cada una (p. ej. "Completar 5 retos") y otorga todas las
  /// que el usuario ya haya cumplido y aún no tenga.
  Future<List<InsigniaResponse>> _otorgarInsigniasPorRetos() async {
    final otorgadas = <InsigniaResponse>[];
    try {
      final progreso = await _progreso.getProgreso(usuarioId);
      final total = progreso.retosCompletados;
      final catalogo = await _insignias.getInsignias();
      final propias = await _insignias.getInsigniasUsuario(usuarioId);
      final yaObtuvo = propias.map((u) => u.insigniaId).toSet();

      for (final ins in catalogo) {
        if (yaObtuvo.contains(ins.insigniaId)) continue;
        final requerido = _requisitoRetos(ins);
        if (requerido == null || total < requerido) continue;
        await _insignias.otorgarInsignia(usuarioId, ins.insigniaId);
        await _progreso.incrementarInsignias(usuarioId);
        // La recompensa de la insignia (Monedas Eco) la acredita el backend
        // una sola vez por insignia.
        try {
          await _monedero.reclamarRecompensa(
            tipo: 'INSIGNIA',
            claveIdempotencia: 'INSIGNIA:${ins.insigniaId}',
            insigniaId: ins.insigniaId,
          );
        } catch (_) {}
        otorgadas.add(ins);
        yaObtuvo.add(ins.insigniaId);
      }
    } catch (_) {
      // Sin conexión o catálogo vacío: los logros se evalúan la próxima vez.
    }
    return otorgadas;
  }

  /// Deduce el número de retos que exige una insignia a partir de su
  /// requisito/nombre/descripción ("Completar 5 retos", "Logra 10 retos"...).
  int? _requisitoRetos(InsigniaResponse ins) {
    final texto = '${ins.requisito} ${ins.nombreInsignia} ${ins.descripcion}'
        .toLowerCase();
    final coincidencia = RegExp(
      r'(\d+)\s*reto',
      caseSensitive: false,
    ).firstMatch(texto);
    if (coincidencia != null) {
      return int.tryParse(coincidencia.group(1)!);
    }
    if (texto.contains('primer reto') ||
        texto.contains('primer eco') ||
        texto.contains('novato') ||
        texto.contains('iniciador')) {
      return 1;
    }
    return null;
  }

  void _sincronizarBackend(Reto reto, RetoProgreso progreso) {
    // Best-effort: jamás bloquea la interacción del usuario.
    _asignarRetoBackend(reto, 'INICIADO').then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  /// Verifica (o crea) el reto en el backend y asegura la participación del
  /// usuario en UNA sola llamada, aplicando el estado solicitado. Reemplaza
  /// la secuencia anterior de 2-4 llamadas (registrar + consultar + participar
  /// + completar) por un solo viaje; el cache de ids se actualiza al vuelo.
  Future<UsuarioRetoResponse> _asignarRetoBackend(
    Reto reto,
    String estado, {
    String? evidencia,
  }) async {
    final respuesta = await _retoService.asignarReto(
      usuarioId: usuarioId,
      codigo: reto.id,
      categoriaId: reto.categoria.categoriaId,
      titulo: reto.titulo,
      descripcion: reto.descripcion,
      instrucciones: reto.instrucciones.isNotEmpty
          ? reto.instrucciones.join('\n')
          : reto.descripcion,
      experienciaRecompensa: reto.xp,
      monedasRecompensa: reto.monedas,
      dificultad: _dificultadBackend(reto.dificultad),
      estado: estado,
      evidencia: evidencia,
      puntosObtenidos: estado == 'COMPLETADO' ? reto.xp : 0,
    );
    if (respuesta.retoId != 0) {
      _backendRetos[respuesta.retoId] = respuesta;
      _backendIdsPorCodigo[reto.id] = respuesta.retoId;
      await _guardarIdsBackend();
    }
    return respuesta;
  }
}

/// Resultado del completado: distingue recompensa otorgada vs duplicado.
sealed class CompletarResultado {
  final RetoProgreso progreso;
  const CompletarResultado(this.progreso);
}

/// Recompensa otorgada correctamente (primera vez).
class CompletadoNuevo extends CompletarResultado {
  /// Insignias/logros desbloqueados al completar este reto.
  final List<InsigniaResponse> logros;

  const CompletadoNuevo(super.progreso, {this.logros = const []});
}

/// El reto ya había sido completado: NO se vuelve a otorgar recompensa.
class CompletoYa extends CompletarResultado {
  const CompletoYa(super.progreso);
}
