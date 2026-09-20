import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../catalogos/retos/reto_model.dart';
import '../catalogos/retos/retos_catalogo.dart';
import '../models/challenge/challenge_models.dart';
import '../models/gamification/gamification_models.dart';
import '../services/gamification_service.dart';
import '../services/reto_service.dart';
import 'reto_progreso_local.dart';







class RetoRepository {
  final int usuarioId;
  final RetoService _retoService;
  final RetoProgresoLocal _local;
  final MonederoService _monedero;
  final InsigniaService _insignias;

  RetoRepository({
    required this.usuarioId,
    required RetoService retoService,
    required MonederoService monederoService,
    required InsigniaService insigniaService,
    RetoProgresoLocal? local,
  }) : _retoService = retoService,
       _monedero = monederoService,
       _insignias = insigniaService,
       _local = local ?? RetoProgresoLocal();




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



  Map<int, UsuarioRetoResponse> _backendRetos = {};
  bool _backendCargado = false;

  static const _idsBackendKey = 'reto_backend_ids_v1';
  static const _recompensasOkKey = 'reto_recompensa_ok_v1';




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



  final List<AprobacionReciente> aprobacionesRecientes = [];

  Future<void> _cargarBackend() async {
    if (_backendCargado) return;
    try {
      final misRetos = await _retoService.getRetosUsuario(usuarioId);
      _backendRetos = {
        for (final ur in misRetos)
          if (ur.retoId != 0) ur.retoId: ur,
      };



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

    } finally {
      _backendCargado = true;
    }
  }


  Future<void> resincronizarBackend() async {
    _backendCargado = false;
    _backendRetos = {};
    await _cargarBackend();
  }






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




      if (_backendCargado && _requiereSincronizacion(reto, reconciliado)) {
        porSincronizar.add(reconciliado);
      }
    }
    if (porSincronizar.isNotEmpty) {
      await _sincronizarLoteBackend(porSincronizar);
    }
    return lista;
  }




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

    }
  }

  Future<RetoProgreso> _reconciliar(Reto reto, RetoProgreso local) async {
    final backendId = _idBackendDeReto(reto);
    final backend = backendId == null ? null : _backendRetos[backendId];
    if (backend == null) return local;



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


        final logros = await _otorgarRecompensa(reto);
        aprobacionesRecientes.add(AprobacionReciente(completo, logros));
      }
      return completo;
    }



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





  Future<CompletarResultado> completar(Reto reto) async {
    final previo = await _local.progresoDe(reto);
    if (previo?.estado == RetoEstado.completado) {
      return CompletoYa(previo!);
    }
    if (previo?.estado == RetoEstado.pendienteRevision) {
      return EnRevisionNuevo(previo!);
    }

    final objetivo = reto.cantidadObjetivo ?? reto.instrucciones.length;
    final pendiente = RetoProgreso(
      reto: reto,
      estado: RetoEstado.pendienteRevision,
      progresoActual: objetivo,
      pasosCompletadas: reto.instrucciones.isNotEmpty
          ? reto.instrucciones.length
          : null,
      fechaInicio: previo?.fechaInicio,
    );

    await _local.guardar(pendiente);

    if (_backendCargado) {
      try {
        await _asignarRetoBackend(reto, 'EN_REVISION');
        _backendCargado = false;
      } catch (_) {}
    }

    return EnRevisionNuevo(pendiente);
  }








  Future<List<InsigniaResponse>> _otorgarRecompensa(Reto reto) async {
    try {
      final backendId = _idBackendDeReto(reto);
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
    } catch (_) {

    }
    return _logrosRecientes();
  }






  /// Logros otorgados por el backend en los últimos minutos (ej. al aprobarse
  /// el reto el evaluador backend otorga las insignias correspondientes).
  /// Solo se consultan para celebrarlos; el otorgamiento ya lo hizo el servidor.
  Future<List<InsigniaResponse>> _logrosRecientes({
    Duration ventana = const Duration(minutes: 10),
  }) async {
    try {
      final propias = await _insignias.getInsigniasUsuario(usuarioId);
      final limite = DateTime.now().subtract(ventana);
      final ids = propias
          .where((u) => u.fechaObtencion.isAfter(limite))
          .map((u) => u.insigniaId)
          .toSet();
      if (ids.isEmpty) return const [];
      final catalogo = await _insignias.getInsignias();
      return catalogo.where((i) => ids.contains(i.insigniaId)).toList();
    } catch (_) {
      return const [];
    }
  }

  void _sincronizarBackend(Reto reto, RetoProgreso progreso) {

    _asignarRetoBackend(reto, 'INICIADO').then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }





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


sealed class CompletarResultado {
  final RetoProgreso progreso;
  const CompletarResultado(this.progreso);
}


class CompletadoNuevo extends CompletarResultado {

  final List<InsigniaResponse> logros;

  const CompletadoNuevo(super.progreso, {this.logros = const []});
}


class EnRevisionNuevo extends CompletarResultado {
  const EnRevisionNuevo(super.progreso);
}


class CompletoYa extends CompletarResultado {
  const CompletoYa(super.progreso);
}
