import 'dart:developer' as developer;
import 'dart:math' as math;

import '../models/gamification/gamification_models.dart';
import '../models/garden/garden_catalog.dart';
import '../models/garden/plant_growth.dart';
import '../models/trivia/diario_models.dart';
import '../services/gamification_service.dart';
import 'garden_local_store.dart';
import 'trivias_diario_local.dart';


class MejoraEtapa {
  final PlantGrowth planta;
  final EtapaCrecimiento anterior;
  final EtapaCrecimiento nueva;
  final DateTime momento;

  const MejoraEtapa({
    required this.planta,
    required this.anterior,
    required this.nueva,
    required this.momento,
  });
}


class PlantaPerdida {
  final PlantGrowth planta;
  final String motivo;

  const PlantaPerdida({required this.planta, required this.motivo});
}


class GardenSnapshot {
  final JardinResponse? jardin;
  final List<PlantGrowth> plantas;
  final InventarioJardin inventario;
  final int monedas;
  final int racha;
  final List<MejoraEtapa> mejoras;
  final List<PlantaPerdida> perdidas;
  final bool desbloqueoCarnicora;
  final String? advertencia;
  final bool conectado;

  const GardenSnapshot({
    required this.jardin,
    required this.plantas,
    required this.inventario,
    required this.monedas,
    required this.racha,
    required this.mejoras,
    required this.perdidas,
    required this.desbloqueoCarnicora,
    required this.advertencia,
    required this.conectado,
  });
}


class ResultadoJardin {
  final bool exito;
  final String? mensaje;
  final PlantGrowth? planta;
  final MejoraEtapa? mejora;
  final int monedas;
  final InventarioJardin inventario;

  const ResultadoJardin({
    required this.exito,
    required this.monedas,
    required this.inventario,
    this.mensaje,
    this.planta,
    this.mejora,
  });
}


class ResultadoSiembra {
  final bool exito;
  final String? mensaje;
  final PlantGrowth? planta;
  final List<PlantGrowth> plantas;
  final int monedas;
  final JardinResponse? jardin;

  const ResultadoSiembra({
    required this.exito,
    required this.plantas,
    required this.monedas,
    this.mensaje,
    this.planta,
    this.jardin,
  });
}







class GardenRepository {
  final int usuarioId;
  final JardinService _jardinService;
  final MonederoService _monederoService;
  final GardenLocalStore _local;
  final DiarioStore _diario;
  final math.Random _random;

  List<PlantGrowth> _plantas = [];
  InventarioJardin _inventario = const InventarioJardin();
  bool _cargado = false;

  GardenRepository({
    required this.usuarioId,
    required JardinService jardinService,
    required MonederoService monederoService,
    GardenLocalStore? localStore,
    DiarioStore? diarioStore,
    math.Random? random,
  }) : _jardinService = jardinService,
       _monederoService = monederoService,
       _local = localStore ?? GardenLocalStore(usuarioId: usuarioId),
       _diario = diarioStore ?? DiarioStore(usuarioId: usuarioId),
       _random = random ?? math.Random();

  List<PlantGrowth> get plantas => List<PlantGrowth>.from(_plantas);

  InventarioJardin get inventario => _inventario;

  bool get cargado => _cargado;

  Future<GardenSnapshot> cargar() async {
    JardinResponse? jardin;
    String? advertencia;
    var conectado = false;

    try {
      jardin = await _jardinService.getJardin(usuarioId);
      conectado = true;
    } catch (e, stackTrace) {
      advertencia = 'Sin conexión: mostrando tu jardín guardado.';
      developer.log(
        'No se pudo cargar el jardín remoto',
        name: 'GardenRepository',
        error: e,
        stackTrace: stackTrace,
      );
    }


    var monedas = 0;
    try {
      final saldo = await _monederoService.getSaldo();
      monedas = saldo.saldo;
    } catch (e) {
      if (conectado) {
        advertencia ??= 'No se pudieron actualizar tus Monedas Eco.';
      }
      developer.log(
        'No se pudieron cargar las monedas',
        name: 'GardenRepository',
        error: e,
      );
    }

    var racha = 0;
    try {
      final progresoDiario = await _diario.cargar();
      racha = rachaEfectivaDiaria(progresoDiario, DateTime.now());
    } catch (_) {}

    _plantas = await _local.cargarPlantas();
    _inventario = await _local.cargarInventario();

    if (_plantas.isEmpty && jardin != null && jardin.totalVegetacion > 0) {
      _plantas = _sembrarDesdeBackend(jardin);
    }

    final ahora = DateTime.now();
    final mejoras = _acumularTiempo(ahora);
    final desbloqueo = _revisarDesbloqueo(racha);
    _revisarPlagas(ahora);
    final perdidas = await removerPerdidas();
    _cargado = true;
    await _persistir();

    return GardenSnapshot(
      jardin: jardin,
      plantas: plantas,
      inventario: _inventario,
      monedas: monedas,
      racha: racha,
      mejoras: mejoras,
      perdidas: perdidas,
      desbloqueoCarnicora: desbloqueo,
      advertencia: advertencia,
      conectado: conectado,
    );
  }




  Future<List<PlantaPerdida>> removerPerdidas() async {
    final perdidas = <PlantaPerdida>[];
    final vivas = <PlantGrowth>[];
    for (final planta in _plantas) {
      if (planta.perdida) {
        perdidas.add(
          PlantaPerdida(
            planta: planta,
            motivo: planta.motivoPerdida ?? 'no recibió los cuidados a tiempo',
          ),
        );
      } else if (planta.catalogo == null) {
        perdidas.add(
          PlantaPerdida(
            planta: planta,
            motivo: 'su especie ya no está disponible en el catálogo',
          ),
        );
      } else {
        vivas.add(planta);
      }
    }
    if (perdidas.isEmpty) return perdidas;
    _plantas = vivas;
    await _persistir();
    return perdidas;
  }





  Future<ResultadoJardin?> regar(String plantaId) async {
    if (!_inventario.regadera) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'Necesitas comprar una regadera para regar.',
        monedas: 0,
        inventario: _inventario,
      );
    }
    return _aplicarCuidado(
      plantaId,
      puede: (p) => p.puedeRegar,
      aplicar: (p, ahora) => p.copyWith(
        horasCrecimiento: p.horasCrecimiento + GardenGrowthConfig.horasPorRiego,
        ultimoRiego: ahora,
      ),
      mensajeEspera: 'La tierra aún está húmeda. Espera un poco para regar.',
    );
  }

  Future<ResultadoJardin?> abonar(String plantaId) async {
    if (_inventario.abono <= 0) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'No tienes abono. Cómpralo en la tienda del jardín.',
        monedas: 0,
        inventario: _inventario,
      );
    }
    final resultado = await _aplicarCuidado(
      plantaId,
      puede: (p) => p.puedeAbonar,
      aplicar: (p, ahora) => p.copyWith(
        horasCrecimiento: p.horasCrecimiento + GardenGrowthConfig.horasPorAbono,
        ultimoAbono: ahora,
      ),
      mensajeEspera: 'Esta planta ya fue abonada hace poco.',
    );
    if (resultado != null && resultado.exito) {
      _inventario = _inventario.copyWith(abono: _inventario.abono - 1);
      await _persistir();
      return ResultadoJardin(
        exito: true,
        planta: resultado.planta,
        mejora: resultado.mejora,
        monedas: 0,
        inventario: _inventario,
      );
    }
    return resultado;
  }

  Future<ResultadoJardin?> fumigar(String plantaId) async {
    if (_inventario.insecticida <= 0) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'No tienes insecticida. Cómpralo en la tienda del jardín.',
        monedas: 0,
        inventario: _inventario,
      );
    }
    final indice = _indice(plantaId);
    if (indice < 0) return null;
    final planta = _plantas[indice];
    final ahora = DateTime.now();
    if (planta.perdida) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'Esta planta ya no puede recuperarse: retírala del jardín.',
        monedas: 0,
        inventario: _inventario,
      );
    }


    if (!planta.tienePlaga) {
      if (!planta.enCrecimiento) {
        return ResultadoJardin(
          exito: false,
          mensaje:
              'Tu planta ya es adulta y está sana: no necesita insecticida.',
          monedas: 0,
          inventario: _inventario,
        );
      }
      if (!planta.puedeInsecticida) {
        return ResultadoJardin(
          exito: false,
          mensaje: 'Aplica insecticida de nuevo en un rato.',
          monedas: 0,
          inventario: _inventario,
        );
      }
    }

    final consolidada = _consolidar(planta, ahora);
    final actualizada = consolidada.copyWith(
      quitarPlaga: true,
      ultimoInsecticida: ahora,
      protegidaHasta: ahora.add(GardenGrowthConfig.ventanaProteccionPlaga),
      proximaRevisionPlaga: ahora.add(
        GardenGrowthConfig.ventanaProteccionPlaga,
      ),

      horasCrecimiento: planta.tienePlaga
          ? consolidada.horasCrecimiento
          : consolidada.horasCrecimiento +
                GardenGrowthConfig.horasPorInsecticida,
    );
    _plantas[indice] = actualizada;
    _inventario = _inventario.copyWith(
      insecticida: _inventario.insecticida - 1,
    );
    await _persistir();
    return ResultadoJardin(
      exito: true,
      planta: actualizada,
      monedas: 0,
      inventario: _inventario,
    );
  }

  Future<ResultadoJardin?> _aplicarCuidado(
    String plantaId, {
    required bool Function(PlantGrowth) puede,
    required PlantGrowth Function(PlantGrowth, DateTime) aplicar,
    required String mensajeEspera,
  }) async {
    final indice = _indice(plantaId);
    if (indice < 0) return null;
    final planta = _plantas[indice];
    if (planta.perdida) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'Esta planta ya no puede recuperarse: retírala del jardín.',
        monedas: 0,
        inventario: _inventario,
      );
    }
    if (!puede(planta)) {
      return ResultadoJardin(
        exito: false,
        mensaje: mensajeEspera,
        monedas: 0,
        inventario: _inventario,
      );
    }
    final ahora = DateTime.now();
    final etapaAntes = planta.etapa(ahora);
    final actualizada = aplicar(_consolidar(planta, ahora), ahora);
    _plantas[indice] = actualizada;
    await _persistir();
    return ResultadoJardin(
      exito: true,
      planta: actualizada,
      mejora: etapaAntes != actualizada.etapa(ahora)
          ? MejoraEtapa(
              planta: actualizada,
              anterior: etapaAntes,
              nueva: actualizada.etapa(ahora),
              momento: ahora,
            )
          : null,
      monedas: 0,
      inventario: _inventario,
    );
  }





  Future<ResultadoJardin> comprarHerramienta(
    HerramientaJardin herramienta,
    int monedasActuales,
  ) async {
    if (herramienta == HerramientaJardin.regadera && _inventario.regadera) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'Ya tienes una regadera.',
        monedas: monedasActuales,
        inventario: _inventario,
      );
    }
    if (monedasActuales < herramienta.precio) {
      return ResultadoJardin(
        exito: false,
        mensaje: 'Te faltan Monedas Eco para comprar ${herramienta.nombre}.',
        monedas: monedasActuales,
        inventario: _inventario,
      );
    }
    GastoMonedasResponse gasto;
    try {
      gasto = await _monederoService.gastar(
        cantidad: herramienta.precio,
        tipo: 'COMPRA',
        descripcion: 'Herramienta de jardín: ${herramienta.nombre}',
      );
    } catch (e, stackTrace) {
      developer.log(
        'No se pudo registrar la compra de herramienta',
        name: 'GardenRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return ResultadoJardin(
        exito: false,
        mensaje: 'No se pudo conectar con el servidor. Intenta de nuevo.',
        monedas: monedasActuales,
        inventario: _inventario,
      );
    }

    switch (herramienta) {
      case HerramientaJardin.regadera:
        _inventario = _inventario.copyWith(regadera: true);
      case HerramientaJardin.abono:
        _inventario = _inventario.copyWith(abono: _inventario.abono + 1);
      case HerramientaJardin.insecticida:
        _inventario = _inventario.copyWith(
          insecticida: _inventario.insecticida + 1,
        );
    }
    await _persistir();
    return ResultadoJardin(
      exito: true,
      mensaje: '¡Compraste ${herramienta.nombre}!',
      monedas: gasto.saldo,
      inventario: _inventario,
    );
  }

  Future<ResultadoSiembra> sembrar(
    EspecieJardin especie, {
    JardinResponse? jardinActual,
    required int monedasActuales,
  }) async {
    if (especie.especialRacha) {
      return ResultadoSiembra(
        exito: false,
        mensaje: 'Esta planta solo se desbloquea con una racha de 30 días.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }
    if (_plantas.length >= GardenGrowthConfig.maxSlots) {
      return ResultadoSiembra(
        exito: false,
        mensaje: 'No hay espacios libres en tu jardín.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }
    if (monedasActuales < especie.precio) {
      return ResultadoSiembra(
        exito: false,
        mensaje: 'No tienes suficientes Monedas Eco.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }

    final tipoBackend = switch (especie.tipo) {
      PlantaTipo.arbol => 'arbol',
      PlantaTipo.flor => 'flor',
      _ => 'planta',
    };



    final planta = PlantGrowth.crearDesdeEspecie(
      especie: especie,
      slot: _primerSlotLibre(),
    );

    JardinResponse base;
    try {
      base = jardinActual ?? await _jardinService.getJardin(usuarioId);
    } catch (e, stackTrace) {
      developer.log(
        'No se pudo cargar el jardín antes de sembrar',
        name: 'GardenRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return ResultadoSiembra(
        exito: false,
        mensaje: 'No se pudo conectar con el servidor. Intenta de nuevo.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }

    final actualizado = JardinResponse(
      jardinId: base.jardinId,
      usuarioId: base.usuarioId,
      nivelJardin: base.nivelJardin,
      plantas: base.plantas + (tipoBackend == 'planta' ? 1 : 0),
      arboles: base.arboles + (tipoBackend == 'arbol' ? 1 : 0),
      flores: base.flores + (tipoBackend == 'flor' ? 1 : 0),
      puntosJardin: base.puntosJardin + 1,
    );

    try {
      await _jardinService.actualizarJardin(usuarioId, actualizado);
    } catch (e, stackTrace) {
      developer.log(
        'No se pudo registrar la siembra en el backend',
        name: 'GardenRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return ResultadoSiembra(
        exito: false,
        mensaje: 'No se pudo conectar con el servidor. Intenta de nuevo.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }

    GastoMonedasResponse gasto;
    try {
      gasto = await _monederoService.gastar(
        cantidad: especie.precio,
        tipo: 'COMPRA',
        descripcion: 'Compra de planta: ${especie.nombre}',
        claveIdempotencia: 'PLANTA:${planta.id}',
      );
    } catch (e, stackTrace) {
      developer.log(
        'No se pudo cobrar la siembra; se revierten los contadores',
        name: 'GardenRepository',
        error: e,
        stackTrace: stackTrace,
      );

      try {
        await _jardinService.actualizarJardin(usuarioId, base);
      } catch (_) {}
      return ResultadoSiembra(
        exito: false,
        mensaje: 'No se pudo completar el pago. Intenta de nuevo.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: base,
      );
    }

    _plantas.add(planta);
    await _persistir();

    return ResultadoSiembra(
      exito: true,
      planta: planta,
      plantas: plantas,
      monedas: gasto.saldo,
      jardin: actualizado,
      mensaje: '¡${especie.nombre} fue sembrada en tu jardín!',
    );
  }



  Future<ResultadoSiembra> reclamarCarnicora({
    JardinResponse? jardinActual,
    required int monedasActuales,
  }) async {
    if (!_inventario.carnicoraDesbloqueada) {
      return ResultadoSiembra(
        exito: false,
        mensaje: 'Consigue una racha de 30 días para desbloquearla.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }
    final yaPlantada = _plantas.any(
      (p) => p.catalogoId == CatalogoJardin.carnicora.id,
    );
    if (yaPlantada) {
      return ResultadoSiembra(
        exito: false,
        mensaje: 'Ya tienes la planta carnívora en tu jardín.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }
    if (_plantas.length >= GardenGrowthConfig.maxSlots) {
      return ResultadoSiembra(
        exito: false,
        mensaje: 'No hay espacios libres para plantarla.',
        plantas: plantas,
        monedas: monedasActuales,
        jardin: jardinActual,
      );
    }
    final planta = PlantGrowth.crearDesdeEspecie(
      especie: CatalogoJardin.carnicora,
      slot: _primerSlotLibre(),
      horasIniciales: 5,
    );
    _plantas.add(planta);
    await _persistir();
    return ResultadoSiembra(
      exito: true,
      planta: planta,
      plantas: plantas,
      monedas: monedasActuales,
      jardin: jardinActual,
      mensaje: '¡La planta carnívora ya está en tu jardín!',
    );
  }





  List<MejoraEtapa> _acumularTiempo(DateTime ahora) {
    final mejoras = <MejoraEtapa>[];
    for (var i = 0; i < _plantas.length; i++) {
      final planta = _plantas[i];
      final etapaAntes = planta.etapa(ahora);
      final horas = planta.horasTotales(ahora);
      final actualizada = planta.copyWith(
        horasCrecimiento: horas,
        ultimaActualizacion: ahora,
      );
      _plantas[i] = actualizada;
      if (etapaAntes != actualizada.etapa(ahora)) {
        mejoras.add(
          MejoraEtapa(
            planta: actualizada,
            anterior: etapaAntes,
            nueva: actualizada.etapa(ahora),
            momento: ahora,
          ),
        );
      }
    }
    return mejoras;
  }

  bool _revisarDesbloqueo(int racha) {
    if (racha < GardenGrowthConfig.rachaCarnicora) return false;
    if (_inventario.carnicoraDesbloqueada) return false;
    _inventario = _inventario.copyWith(carnicoraDesbloqueada: true);
    final yaPlantada = _plantas.any(
      (p) => p.catalogoId == CatalogoJardin.carnicora.id,
    );
    if (!yaPlantada && _plantas.length < GardenGrowthConfig.maxSlots) {
      _plantas.add(
        PlantGrowth.crearDesdeEspecie(
          especie: CatalogoJardin.carnicora,
          slot: _primerSlotLibre(),
        ),
      );
    }
    return true;
  }

  void _revisarPlagas(DateTime ahora) {
    for (var i = 0; i < _plantas.length; i++) {
      final planta = _plantas[i];
      if (planta.tienePlaga) continue;
      if (planta.perdida) continue;
      if (planta.estaProtegida(ahora)) continue;
      if (planta.etapa(ahora).index < EtapaCrecimiento.brote.index) continue;
      final revision = planta.proximaRevisionPlaga;
      if (revision != null && ahora.isBefore(revision)) continue;

      var actualizada = planta;
      if (_random.nextDouble() < 0.18) {
        actualizada = planta.copyWith(tienePlaga: true, plagaDesde: ahora);
      }
      _plantas[i] = actualizada.copyWith(
        proximaRevisionPlaga: ahora.add(
          Duration(hours: 8 + _random.nextInt(16)),
        ),
      );
    }
  }

  PlantGrowth _consolidar(PlantGrowth planta, DateTime ahora) {
    return planta.copyWith(
      horasCrecimiento: planta.horasTotales(ahora),
      ultimaActualizacion: ahora,
    );
  }

  int _indice(String plantaId) {
    for (var i = 0; i < _plantas.length; i++) {
      if (_plantas[i].id == plantaId) return i;
    }
    return -1;
  }

  int _primerSlotLibre() {
    final ocupados = _plantas.map((p) => p.slot).toSet();
    for (var i = 0; i < GardenGrowthConfig.maxSlots; i++) {
      if (!ocupados.contains(i)) return i;
    }
    return _plantas.length;
  }

  List<PlantGrowth> _sembrarDesdeBackend(JardinResponse jardin) {
    final plantas = <PlantGrowth>[];
    final especies = CatalogoJardin.comprables;

    void agregar(String tipo, int cantidad, int offset) {
      for (var i = 0; i < cantidad; i++) {
        if (plantas.length >= GardenGrowthConfig.maxSlots) return;
        final especie = especies[(offset + i) % especies.length];
        plantas.add(
          PlantGrowth.crearDesdeEspecie(
            especie: especie,
            slot: plantas.length,
            plantadaEl: DateTime.now().subtract(Duration(days: cantidad - i)),
            id: 'backend_${tipo}_$i',
          ),
        );
      }
    }

    agregar('planta', jardin.plantas, 0);
    agregar('arbol', jardin.arboles, 4);
    agregar('flor', jardin.flores, 8);
    return plantas;
  }

  Future<void> _persistir() async {
    await _local.guardar(plantas: _plantas, inventario: _inventario);
  }
}
