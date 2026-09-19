import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../gamification/gamification_models.dart';
import 'garden_catalog.dart';







class GardenGrowthConfig {
  const GardenGrowthConfig._();




  static const List<double> horasPorEtapa = [5, 5, 5, 4, 6];


  static const double horasHastaAdulta = 25;


  static const double horasHastaFloracion = 31;


  static const int maxSlots = 12;


  static const double horasPorRiego = 1.0;
  static const double horasPorAbono = 2.0;
  static const Duration cooldownRiego = Duration(hours: 3);
  static const Duration cooldownAbono = Duration(hours: 6);



  static const double horasPorInsecticida = 0.5;
  static const Duration cooldownInsecticida = Duration(hours: 4);
  static const Duration ventanaProteccionPlaga = Duration(hours: 8);


  static const Duration ventanaHumedad = Duration(hours: 12);


  static const Duration umbralNecesitaAgua = Duration(hours: 6);


  static const Duration ventanaAbono = Duration(hours: 12);



  static const Duration horasHastaPerderPorSed = Duration(hours: 5);


  static const Duration horasHastaPerderPorPlaga = Duration(hours: 24);

  static const String carpetaModelos = 'assets/plants';


  static const int precioRegadera = 50;
  static const int precioAbono = 25;
  static const int precioInsecticida = 30;


  static const int rachaCarnicora = 30;
}


enum EtapaCrecimiento {
  semilla(0, 'Semilla', 'La semilla descansa bajo la tierra.'),
  germinacion(5, 'Germinando', 'Una raíz y un pequeño tallo asoman.'),
  brote(10, 'Brote', 'Ya tiene sus primeras hojas.'),
  plantaPequena(15, 'Planta pequeña', 'Crece fuerte y necesita cuidados.'),
  plantaMediana(19, 'Planta mediana', 'Su follaje se vuelve frondoso.'),
  plantaAdulta(25, 'Planta adulta', '¡Alcanzó su máximo crecimiento!'),
  floracion(31, 'Floración', '¡Tu planta floreció o dio frutos!');

  const EtapaCrecimiento(this.umbralHoras, this.label, this.descripcion);

  final double umbralHoras;
  final String label;
  final String descripcion;

  static EtapaCrecimiento porHoras(
    double horas, {
    required bool tieneFloracion,
  }) {
    var etapa = EtapaCrecimiento.semilla;
    for (final candidata in values) {
      if (horas >= candidata.umbralHoras) etapa = candidata;
    }
    if (!tieneFloracion && etapa == EtapaCrecimiento.floracion) {
      return EtapaCrecimiento.plantaAdulta;
    }
    return etapa;
  }

  EtapaCrecimiento? get siguiente {
    final indice = index + 1;
    return indice < values.length ? values[indice] : null;
  }

  bool get esFinal =>
      this == EtapaCrecimiento.plantaAdulta ||
      this == EtapaCrecimiento.floracion;
}


enum HerramientaJardin { regadera, abono, insecticida }

extension HerramientaJardinX on HerramientaJardin {
  String get nombre {
    switch (this) {
      case HerramientaJardin.regadera:
        return 'Regadera básica';
      case HerramientaJardin.abono:
        return 'Abono básico';
      case HerramientaJardin.insecticida:
        return 'Insecticida';
    }
  }

  String get emoji {
    switch (this) {
      case HerramientaJardin.regadera:
        return '🚿';
      case HerramientaJardin.abono:
        return '🌱';
      case HerramientaJardin.insecticida:
        return '🪲';
    }
  }


  String get assetIcono {
    switch (this) {
      case HerramientaJardin.regadera:
        return 'assets/objetos_jardin/eco_regadera.png';
      case HerramientaJardin.abono:
        return 'assets/objetos_jardin/eco_abono.png';
      case HerramientaJardin.insecticida:
        return 'assets/objetos_jardin/eco_insecticida.png';
    }
  }

  int get precio {
    switch (this) {
      case HerramientaJardin.regadera:
        return GardenGrowthConfig.precioRegadera;
      case HerramientaJardin.abono:
        return GardenGrowthConfig.precioAbono;
      case HerramientaJardin.insecticida:
        return GardenGrowthConfig.precioInsecticida;
    }
  }

  String get descripcion {
    switch (this) {
      case HerramientaJardin.regadera:
        return 'Necesaria para regar. Se compra una sola vez.';
      case HerramientaJardin.abono:
        return 'Acelera el crecimiento 2 horas. Se consume al usar.';
      case HerramientaJardin.insecticida:
        return 'Elimina plagas. Se consume al usar.';
    }
  }
}


class InventarioJardin extends Equatable {
  final bool regadera;
  final int abono;
  final int insecticida;
  final bool carnicoraDesbloqueada;

  const InventarioJardin({
    this.regadera = false,
    this.abono = 0,
    this.insecticida = 0,
    this.carnicoraDesbloqueada = false,
  });

  int cantidad(HerramientaJardin herramienta) {
    switch (herramienta) {
      case HerramientaJardin.regadera:
        return regadera ? 1 : 0;
      case HerramientaJardin.abono:
        return abono;
      case HerramientaJardin.insecticida:
        return insecticida;
    }
  }

  bool tiene(HerramientaJardin herramienta) => cantidad(herramienta) > 0;

  factory InventarioJardin.fromJson(Map<String, dynamic> json) {
    return InventarioJardin(
      regadera: json['regadera'] ?? false,
      abono: (json['abono'] as num?)?.toInt() ?? 0,
      insecticida: (json['insecticida'] as num?)?.toInt() ?? 0,
      carnicoraDesbloqueada: json['carnicoraDesbloqueada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'regadera': regadera,
    'abono': abono,
    'insecticida': insecticida,
    'carnicoraDesbloqueada': carnicoraDesbloqueada,
  };

  InventarioJardin copyWith({
    bool? regadera,
    int? abono,
    int? insecticida,
    bool? carnicoraDesbloqueada,
  }) {
    return InventarioJardin(
      regadera: regadera ?? this.regadera,
      abono: abono ?? this.abono,
      insecticida: insecticida ?? this.insecticida,
      carnicoraDesbloqueada:
          carnicoraDesbloqueada ?? this.carnicoraDesbloqueada,
    );
  }

  @override
  List<Object?> get props => [
    regadera,
    abono,
    insecticida,
    carnicoraDesbloqueada,
  ];
}


class PlantGrowth extends Equatable {
  final String id;
  final String catalogoId;
  final String nombre;
  final String emoji;
  final String tipo;
  final String modeloBase;
  final PlantaRareza rareza;
  final int slot;


  final double horasCrecimiento;


  final DateTime ultimaActualizacion;
  final DateTime plantadaEl;

  final DateTime? ultimoRiego;
  final DateTime? ultimoAbono;
  final DateTime? ultimoInsecticida;

  final bool tienePlaga;
  final DateTime? plagaDesde;
  final DateTime? proximaRevisionPlaga;


  final DateTime? protegidaHasta;

  final bool desbloqueada;

  const PlantGrowth({
    required this.id,
    required this.catalogoId,
    required this.nombre,
    required this.emoji,
    required this.tipo,
    required this.modeloBase,
    required this.rareza,
    required this.slot,
    required this.horasCrecimiento,
    required this.ultimaActualizacion,
    required this.plantadaEl,
    this.ultimoRiego,
    this.ultimoAbono,
    this.ultimoInsecticida,
    this.tienePlaga = false,
    this.plagaDesde,
    this.proximaRevisionPlaga,
    this.protegidaHasta,
    this.desbloqueada = true,
  });

  factory PlantGrowth.crearDesdeEspecie({
    required EspecieJardin especie,
    required int slot,
    double horasIniciales = 0,
    DateTime? plantadaEl,
    String? id,
  }) {
    final ahora = DateTime.now();
    return PlantGrowth(
      id: id ?? '${especie.id}_${ahora.microsecondsSinceEpoch}',
      catalogoId: especie.id,
      nombre: especie.nombre,
      emoji: especie.emoji,
      tipo: especie.tipo.name,
      modeloBase: especie.modelo,
      rareza: especie.rareza,
      slot: slot,
      horasCrecimiento: horasIniciales,
      ultimaActualizacion: ahora,
      plantadaEl: plantadaEl ?? ahora,
    );
  }

  factory PlantGrowth.fromJson(Map<String, dynamic> json) {
    final ahora = DateTime.now();
    return PlantGrowth(
      id: json['id']?.toString() ?? '',
      catalogoId: json['catalogoId']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? 'Planta',
      emoji: json['emoji']?.toString() ?? '🌱',
      tipo: json['tipo']?.toString() ?? 'planta',
      modeloBase:
          json['modelo']?.toString() ?? json['modeloBase']?.toString() ?? '',
      rareza: _rarezaDe(json['rareza']),
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      horasCrecimiento:
          (json['horas'] as num?)?.toDouble() ??
          ((json['progreso'] as num?)?.toDouble() ?? 0) /
              100 *
              GardenGrowthConfig.horasHastaAdulta,
      ultimaActualizacion: _fechaDe(json['ultimaActualizacion']) ?? ahora,
      plantadaEl: _fechaDe(json['plantadaEl']) ?? ahora,
      ultimoRiego: _fechaDe(json['ultimoRiego']),
      ultimoAbono: _fechaDe(json['ultimoAbono']),
      ultimoInsecticida: _fechaDe(json['ultimoInsecticida']),
      tienePlaga: json['tienePlaga'] ?? false,
      plagaDesde: _fechaDe(json['plagaDesde']),
      proximaRevisionPlaga: _fechaDe(json['proximaRevisionPlaga']),
      protegidaHasta: _fechaDe(json['protegidaHasta']),
      desbloqueada: json['desbloqueada'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catalogoId': catalogoId,
      'nombre': nombre,
      'emoji': emoji,
      'tipo': tipo,
      'modelo': modeloBase,
      'rareza': rareza.name,
      'slot': slot,
      'horas': horasCrecimiento,
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
      'plantadaEl': plantadaEl.toIso8601String(),
      'ultimoRiego': ultimoRiego?.toIso8601String(),
      'ultimoAbono': ultimoAbono?.toIso8601String(),
      'ultimoInsecticida': ultimoInsecticida?.toIso8601String(),
      'tienePlaga': tienePlaga,
      'plagaDesde': plagaDesde?.toIso8601String(),
      'proximaRevisionPlaga': proximaRevisionPlaga?.toIso8601String(),
      'protegidaHasta': protegidaHasta?.toIso8601String(),
      'desbloqueada': desbloqueada,
    };
  }





  EspecieJardin? get catalogo => CatalogoJardin.porId(catalogoId);

  bool get tieneFloracion => catalogo?.tieneFloracion ?? false;

  bool get esArbol => tipo == PlantaTipo.arbol.name;

  DateTime _referencia(DateTime? valor) => valor ?? plantadaEl;




  double horasTotales([DateTime? ahora]) {
    final momento = ahora ?? DateTime.now();
    var transcurridas =
        momento.difference(ultimaActualizacion).inMinutes / 60.0;
    if (transcurridas < 0) transcurridas = 0;

    if (tienePlaga) {
      transcurridas = 0;
    } else {

      final finAgua = _referencia(
        ultimoRiego,
      ).add(GardenGrowthConfig.ventanaHumedad);
      final finAbono = _referencia(
        ultimoAbono,
      ).add(GardenGrowthConfig.ventanaAbono);
      final finActivo = finAgua.isBefore(finAbono) ? finAgua : finAbono;
      if (!ultimaActualizacion.isBefore(finActivo)) {
        transcurridas = 0;
      } else if (momento.isAfter(finActivo)) {
        final hasta =
            finActivo.difference(ultimaActualizacion).inMinutes / 60.0;
        if (hasta < transcurridas) transcurridas = hasta;
      }
    }
    return horasCrecimiento + transcurridas;
  }

  EtapaCrecimiento etapa([DateTime? ahora]) => EtapaCrecimiento.porHoras(
    horasTotales(ahora),
    tieneFloracion: tieneFloracion,
  );

  double progreso([DateTime? ahora]) {
    final horas = horasTotales(ahora);
    final valor = horas / GardenGrowthConfig.horasHastaAdulta * 100;
    return valor.clamp(0.0, 100.0);
  }

  bool get esAdulta =>
      etapa() == EtapaCrecimiento.plantaAdulta ||
      etapa() == EtapaCrecimiento.floracion;

  bool get especial => catalogo?.especialRacha ?? false;

  String get assetModelo {
    final especie = catalogo;
    final archivo = especie != null ? especie.modeloPara(etapa()) : modeloBase;
    return '${GardenGrowthConfig.carpetaModelos}/$archivo';
  }

  double get escalaModelo {
    final especie = catalogo;
    if (especie != null && !especie.escalaPorEtapa) return 1.0;


    const umbrales = [0.0, 5, 10, 15, 19, 25, 31];
    const escalas = [0.30, 0.45, 0.60, 0.75, 0.88, 1.00, 1.00];
    final horas = horasTotales();
    if (horas <= umbrales.first) return escalas.first;
    for (var i = 0; i < umbrales.length - 1; i++) {
      if (horas <= umbrales[i + 1]) {
        final tt = ((horas - umbrales[i]) / (umbrales[i + 1] - umbrales[i]))
            .clamp(0.0, 1.0);
        final suave = tt * tt * (3 - 2 * tt);
        return escalas[i] + (escalas[i + 1] - escalas[i]) * suave;
      }
    }
    return escalas.last;
  }

  String? get animacion => catalogo?.animacion;

  double get horasSinRiego {
    final ultimo = ultimoRiego ?? plantadaEl;
    return DateTime.now().difference(ultimo).inMinutes / 60.0;
  }

  double get horasSinAbono {
    final ultimo = ultimoAbono ?? plantadaEl;
    return DateTime.now().difference(ultimo).inMinutes / 60.0;
  }


  bool get faltaAbono =>
      enCrecimiento &&
      horasSinAbono >= GardenGrowthConfig.ventanaAbono.inHours;


  double get marchitez {
    final exceso = horasSinRiego - GardenGrowthConfig.ventanaHumedad.inHours;
    if (exceso <= 0) return 0;
    final total = GardenGrowthConfig.horasHastaPerderPorSed.inHours;
    return (exceso / total).clamp(0.0, 1.0);
  }

  bool get perdidaPorSed =>
      horasSinRiego >=
      (GardenGrowthConfig.ventanaHumedad +
              GardenGrowthConfig.horasHastaPerderPorSed)
          .inHours;

  bool get perdidaPorPlaga {
    final desde = plagaDesde;
    if (!tienePlaga || desde == null) return false;
    return DateTime.now().difference(desde) >=
        GardenGrowthConfig.horasHastaPerderPorPlaga;
  }


  bool get perdida => perdidaPorSed || perdidaPorPlaga;

  String? get motivoPerdida {
    if (perdidaPorSed) return 'se secó por falta de agua';
    if (perdidaPorPlaga) return 'no pudo vencer la plaga';
    return null;
  }


  double get horasParaPerderse {
    var restante =
        (GardenGrowthConfig.ventanaHumedad +
                    GardenGrowthConfig.horasHastaPerderPorSed)
                .inHours -
            horasSinRiego;
    final desde = plagaDesde;
    if (tienePlaga && desde != null) {
      final porPlaga =
          GardenGrowthConfig.horasHastaPerderPorPlaga.inHours -
          DateTime.now().difference(desde).inMinutes / 60.0;
      if (porPlaga < restante) restante = porPlaga;
    }
    return restante < 0 ? 0 : restante;
  }


  bool get enCrecimiento => !esAdulta;


  bool get necesitaAgua =>
      horasSinRiego >= GardenGrowthConfig.umbralNecesitaAgua.inHours;


  bool get marchita =>
      horasSinRiego >= GardenGrowthConfig.ventanaHumedad.inHours;

  String get humedad {
    final horas = horasSinRiego;
    if (horas < GardenGrowthConfig.umbralNecesitaAgua.inHours) {
      return 'Hidratada';
    }
    if (horas < GardenGrowthConfig.ventanaHumedad.inHours) return 'Normal';
    return 'Seca';
  }

  bool get puedeRegar {
    if (perdida) return false;
    final ultimo = ultimoRiego;
    if (ultimo == null) return true;
    return DateTime.now().difference(ultimo) >=
        GardenGrowthConfig.cooldownRiego;
  }

  Duration get tiempoRestanteRiego {
    final ultimo = ultimoRiego;
    if (ultimo == null) return Duration.zero;
    final restante =
        GardenGrowthConfig.cooldownRiego - DateTime.now().difference(ultimo);
    return restante.isNegative ? Duration.zero : restante;
  }

  bool get puedeAbonar {
    if (perdida) return false;
    final ultimo = ultimoAbono;
    if (ultimo == null) return true;
    return DateTime.now().difference(ultimo) >=
        GardenGrowthConfig.cooldownAbono;
  }

  Duration get tiempoRestanteAbono {
    final ultimo = ultimoAbono;
    if (ultimo == null) return Duration.zero;
    final restante =
        GardenGrowthConfig.cooldownAbono - DateTime.now().difference(ultimo);
    return restante.isNegative ? Duration.zero : restante;
  }



  bool get puedeInsecticida {
    if (perdida) return false;
    if (tienePlaga) return true;
    if (!enCrecimiento) return false;
    final ultimo = ultimoInsecticida;
    if (ultimo == null) return true;
    return DateTime.now().difference(ultimo) >=
        GardenGrowthConfig.cooldownInsecticida;
  }

  Duration get tiempoRestanteInsecticida {
    final ultimo = ultimoInsecticida;
    if (ultimo == null) return Duration.zero;
    final restante =
        GardenGrowthConfig.cooldownInsecticida -
        DateTime.now().difference(ultimo);
    return restante.isNegative ? Duration.zero : restante;
  }

  bool estaProtegida([DateTime? momento]) {
    final hasta = protegidaHasta;
    if (hasta == null) return false;
    return (momento ?? DateTime.now()).isBefore(hasta);
  }

  String get estadoSalud {
    if (tienePlaga) return 'Enferma';
    if (marchita) return 'Necesita agua';
    if (progreso() >= 80) return 'Excelente';
    if (progreso() >= 35) return 'Saludable';
    return 'En crecimiento';
  }

  EtapaCrecimiento? get proximaEtapa {
    final actual = etapa();
    if (actual == EtapaCrecimiento.floracion) return null;
    if (actual == EtapaCrecimiento.plantaAdulta && !tieneFloracion) return null;
    return actual.siguiente;
  }

  double get horasParaSiguienteEtapa {
    final proxima = proximaEtapa;
    if (proxima == null) return 0;
    final faltante = proxima.umbralHoras - horasTotales();
    return faltante < 0 ? 0 : faltante;
  }

  PlantGrowth copyWith({
    String? id,
    String? catalogoId,
    String? nombre,
    String? emoji,
    String? tipo,
    String? modeloBase,
    PlantaRareza? rareza,
    int? slot,
    double? horasCrecimiento,
    DateTime? ultimaActualizacion,
    DateTime? plantadaEl,
    DateTime? ultimoRiego,
    DateTime? ultimoAbono,
    DateTime? ultimoInsecticida,
    bool? tienePlaga,
    DateTime? plagaDesde,
    DateTime? proximaRevisionPlaga,
    DateTime? protegidaHasta,
    bool? desbloqueada,
    bool quitarPlaga = false,
    bool limpiarProteccion = false,
  }) {
    return PlantGrowth(
      id: id ?? this.id,
      catalogoId: catalogoId ?? this.catalogoId,
      nombre: nombre ?? this.nombre,
      emoji: emoji ?? this.emoji,
      tipo: tipo ?? this.tipo,
      modeloBase: modeloBase ?? this.modeloBase,
      rareza: rareza ?? this.rareza,
      slot: slot ?? this.slot,
      horasCrecimiento: horasCrecimiento ?? this.horasCrecimiento,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      plantadaEl: plantadaEl ?? this.plantadaEl,
      ultimoRiego: ultimoRiego ?? this.ultimoRiego,
      ultimoAbono: ultimoAbono ?? this.ultimoAbono,
      ultimoInsecticida: ultimoInsecticida ?? this.ultimoInsecticida,
      tienePlaga: quitarPlaga ? false : (tienePlaga ?? this.tienePlaga),
      plagaDesde: quitarPlaga ? null : (plagaDesde ?? this.plagaDesde),
      proximaRevisionPlaga: proximaRevisionPlaga ?? this.proximaRevisionPlaga,
      protegidaHasta: limpiarProteccion
          ? null
          : (protegidaHasta ?? this.protegidaHasta),
      desbloqueada: desbloqueada ?? this.desbloqueada,
    );
  }

  static PlantaRareza _rarezaDe(Object? valor) {
    final nombre = valor?.toString() ?? '';
    for (final rareza in PlantaRareza.values) {
      if (rareza.name == nombre) return rareza;
    }
    return PlantaRareza.comun;
  }

  static DateTime? _fechaDe(Object? valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  Color get rarezaColor => rareza.rarezaColor;

  String get rarezaLabel => rareza.rarezaLabel;

  @override
  List<Object?> get props => [
    id,
    catalogoId,
    nombre,
    emoji,
    tipo,
    modeloBase,
    rareza,
    slot,
    horasCrecimiento,
    ultimaActualizacion,
    plantadaEl,
    ultimoRiego,
    ultimoAbono,
    ultimoInsecticida,
    tienePlaga,
    plagaDesde,
    proximaRevisionPlaga,
    protegidaHasta,
    desbloqueada,
  ];
}
