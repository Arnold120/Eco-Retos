import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ProgresoResponse extends Equatable {
  final int progresoId;
  final int usuarioId;

  final int experiencia;
  final int retosCompletados;
  final int triviasCompletadas;
  final int insigniasObtenidas;
  final int publicacionesRealizadas;
  final int materialesObtenidos;
  final int nivelActual;
  final double porcentajeProgreso;

  const ProgresoResponse({
    required this.progresoId,
    required this.usuarioId,
    this.experiencia = 0,
    required this.retosCompletados,
    required this.triviasCompletadas,
    required this.insigniasObtenidas,
    required this.publicacionesRealizadas,
    required this.materialesObtenidos,
    required this.nivelActual,
    required this.porcentajeProgreso,
  });

  factory ProgresoResponse.fromJson(Map<String, dynamic> json) {
    return ProgresoResponse(
      progresoId: json['progresoId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      experiencia: json['experiencia'] ?? 0,
      retosCompletados: json['retosCompletados'] ?? 0,
      triviasCompletadas: json['triviasCompletadas'] ?? 0,
      insigniasObtenidas: json['insigniasObtenidas'] ?? 0,
      publicacionesRealizadas: json['publicacionesRealizadas'] ?? 0,
      materialesObtenidos: json['materialesObtenidos'] ?? 0,
      nivelActual: json['nivelActual'] ?? 1,
      porcentajeProgreso:
          (json['porcentajeProgreso'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        progresoId,
        usuarioId,
        experiencia,
        retosCompletados,
        triviasCompletadas,
        insigniasObtenidas,
        publicacionesRealizadas,
        materialesObtenidos,
        nivelActual,
        porcentajeProgreso,
      ];
}


class SaldoMonederoResponse extends Equatable {
  final int saldo;
  final int experiencia;
  final int nivelActual;
  final int xpEnNivel;
  final int xpMaximoNivel;
  final double porcentajeProgreso;

  const SaldoMonederoResponse({
    this.saldo = 0,
    this.experiencia = 0,
    this.nivelActual = 1,
    this.xpEnNivel = 0,
    this.xpMaximoNivel = 100,
    this.porcentajeProgreso = 0,
  });

  factory SaldoMonederoResponse.fromJson(Map<String, dynamic> json) {
    return SaldoMonederoResponse(
      saldo: json['saldo'] ?? 0,
      experiencia: json['experiencia'] ?? 0,
      nivelActual: json['nivelActual'] ?? 1,
      xpEnNivel: json['xpEnNivel'] ?? 0,
      xpMaximoNivel: json['xpMaximoNivel'] ?? 100,
      porcentajeProgreso: (json['porcentajeProgreso'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        saldo,
        experiencia,
        nivelActual,
        xpEnNivel,
        xpMaximoNivel,
        porcentajeProgreso,
      ];
}


class RecompensaResponse extends Equatable {
  final bool duplicado;
  final int experienciaGanada;
  final int monedasGanadas;
  final int saldo;
  final int experiencia;
  final int nivelActual;
  final double porcentajeProgreso;

  const RecompensaResponse({
    this.duplicado = false,
    this.experienciaGanada = 0,
    this.monedasGanadas = 0,
    this.saldo = 0,
    this.experiencia = 0,
    this.nivelActual = 1,
    this.porcentajeProgreso = 0,
  });

  factory RecompensaResponse.fromJson(Map<String, dynamic> json) {
    return RecompensaResponse(
      duplicado: json['duplicado'] ?? false,
      experienciaGanada: json['experienciaGanada'] ?? 0,
      monedasGanadas: json['monedasGanadas'] ?? 0,
      saldo: json['saldo'] ?? 0,
      experiencia: json['experiencia'] ?? 0,
      nivelActual: json['nivelActual'] ?? 1,
      porcentajeProgreso: (json['porcentajeProgreso'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        duplicado,
        experienciaGanada,
        monedasGanadas,
        saldo,
        experiencia,
        nivelActual,
        porcentajeProgreso,
      ];
}


class GastoMonedasResponse extends Equatable {
  final int saldo;
  final int cantidad;

  const GastoMonedasResponse({this.saldo = 0, this.cantidad = 0});

  factory GastoMonedasResponse.fromJson(Map<String, dynamic> json) {
    return GastoMonedasResponse(
      saldo: json['saldo'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [saldo, cantidad];
}

class JardinResponse extends Equatable {
  final int jardinId;
  final int usuarioId;
  final int nivelJardin;
  final int plantas;
  final int arboles;
  final int flores;
  final int puntosJardin;

  const JardinResponse({
    required this.jardinId,
    required this.usuarioId,
    required this.nivelJardin,
    required this.plantas,
    required this.arboles,
    required this.flores,
    required this.puntosJardin,
  });

  factory JardinResponse.fromJson(Map<String, dynamic> json) {
    return JardinResponse(
      jardinId: json['jardinId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nivelJardin: json['nivelJardin'] ?? 1,
      plantas: json['plantas'] ?? 0,
      arboles: json['arboles'] ?? 0,
      flores: json['flores'] ?? 0,
      puntosJardin: json['puntosJardin'] ?? 0,
    );
  }

  int get totalVegetacion => plantas + arboles + flores;

  @override
  List<Object?> get props => [
        jardinId,
        usuarioId,
        nivelJardin,
        plantas,
        arboles,
        flores,
        puntosJardin,
      ];
}

class InsigniaResponse extends Equatable {
  final int insigniaId;
  final String nombreInsignia;
  final String descripcion;
  final String requisito;
  final String? imagen;

  final int monedasRecompensa;

  const InsigniaResponse({
    required this.insigniaId,
    required this.nombreInsignia,
    required this.descripcion,
    required this.requisito,
    this.imagen,
    required this.monedasRecompensa,
  });

  factory InsigniaResponse.fromJson(Map<String, dynamic> json) {
    return InsigniaResponse(
      insigniaId: json['insigniaId'] ?? 0,
      nombreInsignia: json['nombreInsignia']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      requisito: json['requisito']?.toString() ?? '',
      imagen: json['imagen']?.toString(),
      monedasRecompensa: json['monedasRecompensa'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        insigniaId,
        nombreInsignia,
        descripcion,
        requisito,
        imagen,
        monedasRecompensa,
      ];
}

class UsuarioInsigniaResponse extends Equatable {
  final int usuarioInsigniaId;
  final int usuarioId;
  final int insigniaId;
  final DateTime fechaObtencion;
  final String nombreInsignia;

  const UsuarioInsigniaResponse({
    required this.usuarioInsigniaId,
    required this.usuarioId,
    required this.insigniaId,
    required this.fechaObtencion,
    required this.nombreInsignia,
  });

  factory UsuarioInsigniaResponse.fromJson(Map<String, dynamic> json) {
    return UsuarioInsigniaResponse(
      usuarioInsigniaId: json['usuarioInsigniaId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      insigniaId: json['insigniaId'] ?? 0,
      fechaObtencion:
          DateTime.tryParse(json['fechaObtencion'].toString()) ??
              DateTime.now(),
      nombreInsignia: json['nombreInsignia']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        usuarioInsigniaId,
        usuarioId,
        insigniaId,
        fechaObtencion,
        nombreInsignia,
      ];
}


class MovimientoMonedaResponse extends Equatable {
  final int historialMonedaId;
  final int usuarioId;
  final int? categoriaId;
  final String nombreCategoria;

  final int cantidad;
  final String tipo;
  final String descripcion;
  final int saldoResultante;
  final DateTime fecha;

  const MovimientoMonedaResponse({
    required this.historialMonedaId,
    required this.usuarioId,
    this.categoriaId,
    this.nombreCategoria = '',
    required this.cantidad,
    required this.tipo,
    required this.descripcion,
    this.saldoResultante = 0,
    required this.fecha,
  });

  factory MovimientoMonedaResponse.fromJson(Map<String, dynamic> json) {
    return MovimientoMonedaResponse(
      historialMonedaId:
          (json['historialMonedaId'] ?? json['historialId'] ?? 0) as int,
      usuarioId: json['usuarioId'] ?? 0,
      categoriaId: json['categoriaId'] as int?,
      nombreCategoria: json['nombreCategoria']?.toString() ?? '',
      cantidad: (json['cantidad'] ?? json['puntos'] ?? 0) as int,
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      saldoResultante: json['saldoResultante'] ?? 0,
      fecha: DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now(),
    );
  }

  bool get esPositivo => cantidad > 0;

  @override
  List<Object?> get props => [
        historialMonedaId,
        usuarioId,
        categoriaId,
        nombreCategoria,
        cantidad,
        tipo,
        descripcion,
        saldoResultante,
        fecha,
      ];
}


class CategoriaMonedas extends Equatable {
  final int categoriaId;
  final String nombreCategoria;
  final int total;

  const CategoriaMonedas({
    required this.categoriaId,
    required this.nombreCategoria,
    required this.total,
  });

  factory CategoriaMonedas.fromJson(Map<String, dynamic> json) {
    return CategoriaMonedas(
      categoriaId: json['categoriaId'] ?? 0,
      nombreCategoria: json['nombreCategoria']?.toString() ?? '',
      total: json['total'] ?? json['puntos'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [categoriaId, nombreCategoria, total];
}

class RachaResponse extends Equatable {
  final int rachaId;
  final int usuarioId;
  final DateTime fechaAcceso;
  final int numeroRacha;

  const RachaResponse({
    required this.rachaId,
    required this.usuarioId,
    required this.fechaAcceso,
    required this.numeroRacha,
  });

  factory RachaResponse.fromJson(Map<String, dynamic> json) {
    return RachaResponse(
      rachaId: json['rachaId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      fechaAcceso:
          DateTime.tryParse(json['fechaAcceso'].toString()) ?? DateTime.now(),
      numeroRacha: json['numeroRacha'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [rachaId, usuarioId, fechaAcceso, numeroRacha];
}

class RankingItem extends Equatable {
  final int position;
  final String nombreUsuario;
  final int puntos;
  final int nivel;

  const RankingItem({
    required this.position,
    required this.nombreUsuario,
    required this.puntos,
    required this.nivel,
  });

  @override
  List<Object?> get props => [position, nombreUsuario, puntos, nivel];
}


enum PlantaRareza {
  comun,
  pocoComun,
  rara,
  epica,
  legendaria,
}


extension PlantaRarezaExtension on PlantaRareza {
  Color get rarezaColor {
    switch (this) {
      case PlantaRareza.comun:
        return const Color(0xFF9E9E9E); 
      case PlantaRareza.pocoComun:
        return const Color(0xFF4CAF50); 
      case PlantaRareza.rara:
        return const Color(0xFF2196F3); 
      case PlantaRareza.epica:
        return const Color(0xFF9C27B0); 
      case PlantaRareza.legendaria:
        return const Color(0xFFFFC107); 
    }
  }

  String get rarezaLabel {
    switch (this) {
      case PlantaRareza.comun:
        return 'Común';
      case PlantaRareza.pocoComun:
        return 'Poco común';
      case PlantaRareza.rara:
        return 'Rara';
      case PlantaRareza.epica:
        return 'Épica';
      case PlantaRareza.legendaria:
        return 'Legendaria';
    }
  }
}


enum PlantaEtapa {
  semilla,
  brote,
  plantaJoven,
  plantaAdulta,
  arbol,
}


class PlantaJardin extends Equatable {
  final String id;
  final String nombre;
  final String emoji;
  final PlantaRareza rareza;
  final PlantaEtapa etapa;
  final int precioMonedas;
  final int xpRecompensa;
  final int nivelRequerido;
  final int jardinNivelRequerido;
  final String descripcion;
  final List<String> cuidadosRequeridos; 
  final int tiempoCrecimientoHoras;
  final bool desbloqueada;
  final DateTime? fechaDesbloqueo;
  final int progresoCrecimiento; 

  const PlantaJardin({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.rareza,
    required this.etapa,
    required this.precioMonedas,
    required this.xpRecompensa,
    required this.nivelRequerido,
    required this.jardinNivelRequerido,
    required this.descripcion,
    required this.cuidadosRequeridos,
    required this.tiempoCrecimientoHoras,
    this.desbloqueada = false,
    this.fechaDesbloqueo,
    this.progresoCrecimiento = 0,
  });

  factory PlantaJardin.fromJson(Map<String, dynamic> json) {
    return PlantaJardin(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🌱',
      rareza: PlantaRareza.values.firstWhere(
        (r) => r.name == (json['rareza']?.toString() ?? 'comun'),
        orElse: () => PlantaRareza.comun,
      ),
      etapa: PlantaEtapa.values.firstWhere(
        (e) => e.name == (json['etapa']?.toString() ?? 'semilla'),
        orElse: () => PlantaEtapa.semilla,
      ),
      precioMonedas: json['precioMonedas'] ?? 0,
      xpRecompensa: json['xpRecompensa'] ?? 0,
      nivelRequerido: json['nivelRequerido'] ?? 1,
      jardinNivelRequerido: json['jardinNivelRequerido'] ?? 1,
      descripcion: json['descripcion']?.toString() ?? '',
      cuidadosRequeridos: (json['cuidadosRequeridos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tiempoCrecimientoHoras: json['tiempoCrecimientoHoras'] ?? 24,
      desbloqueada: json['desbloqueada'] ?? false,
      fechaDesbloqueo: json['fechaDesbloqueo'] != null
          ? DateTime.tryParse(json['fechaDesbloqueo'].toString())
          : null,
      progresoCrecimiento: json['progresoCrecimiento'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'emoji': emoji,
      'rareza': rareza.name,
      'etapa': etapa.name,
      'precioMonedas': precioMonedas,
      'xpRecompensa': xpRecompensa,
      'nivelRequerido': nivelRequerido,
      'jardinNivelRequerido': jardinNivelRequerido,
      'descripcion': descripcion,
      'cuidadosRequeridos': cuidadosRequeridos,
      'tiempoCrecimientoHoras': tiempoCrecimientoHoras,
      'desbloqueada': desbloqueada,
      'fechaDesbloqueo': fechaDesbloqueo?.toIso8601String(),
      'progresoCrecimiento': progresoCrecimiento,
    };
  }

  Color get rarezaColor {
    switch (rareza) {
      case PlantaRareza.comun:
        return const Color(0xFF9E9E9E); 
      case PlantaRareza.pocoComun:
        return const Color(0xFF4CAF50); 
      case PlantaRareza.rara:
        return const Color(0xFF2196F3); 
      case PlantaRareza.epica:
        return const Color(0xFF9C27B0); 
      case PlantaRareza.legendaria:
        return const Color(0xFFFFC107); 
    }
  }

  String get rarezaLabel {
    switch (rareza) {
      case PlantaRareza.comun:
        return 'Común';
      case PlantaRareza.pocoComun:
        return 'Poco común';
      case PlantaRareza.rara:
        return 'Rara';
      case PlantaRareza.epica:
        return 'Épica';
      case PlantaRareza.legendaria:
        return 'Legendaria';
    }
  }

  String get etapaLabel {
    switch (etapa) {
      case PlantaEtapa.semilla:
        return 'Semilla';
      case PlantaEtapa.brote:
        return 'Brote';
      case PlantaEtapa.plantaJoven:
        return 'Planta joven';
      case PlantaEtapa.plantaAdulta:
        return 'Planta adulta';
      case PlantaEtapa.arbol:
        return 'Árbol';
    }
  }

  PlantaJardin copyWith({
    String? id,
    String? nombre,
    String? emoji,
    PlantaRareza? rareza,
    PlantaEtapa? etapa,
    int? precioMonedas,
    int? xpRecompensa,
    int? nivelRequerido,
    int? jardinNivelRequerido,
    String? descripcion,
    List<String>? cuidadosRequeridos,
    int? tiempoCrecimientoHoras,
    bool? desbloqueada,
    DateTime? fechaDesbloqueo,
    int? progresoCrecimiento,
  }) {
    return PlantaJardin(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      emoji: emoji ?? this.emoji,
      rareza: rareza ?? this.rareza,
      etapa: etapa ?? this.etapa,
      precioMonedas: precioMonedas ?? this.precioMonedas,
      xpRecompensa: xpRecompensa ?? this.xpRecompensa,
      nivelRequerido: nivelRequerido ?? this.nivelRequerido,
      jardinNivelRequerido: jardinNivelRequerido ?? this.jardinNivelRequerido,
      descripcion: descripcion ?? this.descripcion,
      cuidadosRequeridos: cuidadosRequeridos ?? this.cuidadosRequeridos,
      tiempoCrecimientoHoras: tiempoCrecimientoHoras ?? this.tiempoCrecimientoHoras,
      desbloqueada: desbloqueada ?? this.desbloqueada,
      fechaDesbloqueo: fechaDesbloqueo ?? this.fechaDesbloqueo,
      progresoCrecimiento: progresoCrecimiento ?? this.progresoCrecimiento,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        emoji,
        rareza,
        etapa,
        precioMonedas,
        xpRecompensa,
        nivelRequerido,
        jardinNivelRequerido,
        descripcion,
        cuidadosRequeridos,
        tiempoCrecimientoHoras,
        desbloqueada,
        fechaDesbloqueo,
        progresoCrecimiento,
      ];
}


class CatalogoPlantas {
  static List<PlantaJardin> get catalogoCompleto => [

    PlantaJardin(
      id: 'planta_comun_1',
      nombre: 'Helecho común',
      emoji: '🌿',
      rareza: PlantaRareza.comun,
      etapa: PlantaEtapa.plantaJoven,
      precioMonedas: 5,
      xpRecompensa: 10,
      nivelRequerido: 1,
      jardinNivelRequerido: 1,
      descripcion: 'Un helecho resistente que purifica el aire.',
      cuidadosRequeridos: ['riego', 'sombra'],
      tiempoCrecimientoHoras: 12,
    ),
    PlantaJardin(
      id: 'planta_comun_2',
      nombre: 'Suculenta básica',
      emoji: '🌵',
      rareza: PlantaRareza.comun,
      etapa: PlantaEtapa.plantaAdulta,
      precioMonedas: 8,
      xpRecompensa: 15,
      nivelRequerido: 1,
      jardinNivelRequerido: 1,
      descripcion: 'Requiere poco riego, ideal para principiantes.',
      cuidadosRequeridos: ['sol', 'poco_riego'],
      tiempoCrecimientoHoras: 24,
    ),

    PlantaJardin(
      id: 'planta_poco_comun_1',
      nombre: 'Orquídea morada',
      emoji: '🌸',
      rareza: PlantaRareza.pocoComun,
      etapa: PlantaEtapa.plantaAdulta,
      precioMonedas: 25,
      xpRecompensa: 50,
      nivelRequerido: 3,
      jardinNivelRequerido: 2,
      descripcion: 'Flor exótica que necesita humedad constante.',
      cuidadosRequeridos: ['riego_frecuente', 'sombra', 'humedad'],
      tiempoCrecimientoHoras: 48,
    ),
    PlantaJardin(
      id: 'planta_poco_comun_2',
      nombre: 'Bonsái de pino',
      emoji: '🌲',
      rareza: PlantaRareza.pocoComun,
      etapa: PlantaEtapa.arbol,
      precioMonedas: 35,
      xpRecompensa: 75,
      nivelRequerido: 5,
      jardinNivelRequerido: 3,
      descripcion: 'Árbol miniatura que requiere paciencia y poda.',
      cuidadosRequeridos: ['sol', 'riego_moderado', 'poda'],
      tiempoCrecimientoHoras: 72,
    ),

    PlantaJardin(
      id: 'planta_rara_1',
      nombre: 'Rosa azul',
      emoji: '🌹',
      rareza: PlantaRareza.rara,
      etapa: PlantaEtapa.plantaAdulta,
      precioMonedas: 80,
      xpRecompensa: 200,
      nivelRequerido: 10,
      jardinNivelRequerido: 5,
      descripcion: 'Flor mítica que solo florece bajo la luna llena.',
      cuidadosRequeridos: ['riego_puro', 'luz_lunar', 'abono_especial'],
      tiempoCrecimientoHoras: 120,
    ),

    PlantaJardin(
      id: 'planta_epica_1',
      nombre: 'Árbol de la vida',
      emoji: '🌳',
      rareza: PlantaRareza.epica,
      etapa: PlantaEtapa.arbol,
      precioMonedas: 200,
      xpRecompensa: 500,
      nivelRequerido: 20,
      jardinNivelRequerido: 10,
      descripcion: 'Árbol ancestral que otorga sabiduría a quien lo cuida.',
      cuidadosRequeridos: ['agua_vida', 'luz_solar', 'canto_verde'],
      tiempoCrecimientoHoras: 240,
    ),

    PlantaJardin(
      id: 'planta_legendaria_1',
      nombre: 'Flor del Edén',
      emoji: '🌺',
      rareza: PlantaRareza.legendaria,
      etapa: PlantaEtapa.plantaAdulta,
      precioMonedas: 500,
      xpRecompensa: 1000,
      nivelRequerido: 50,
      jardinNivelRequerido: 20,
      descripcion: 'La flor más hermosa del mundo, concede un deseo al florecer.',
      cuidadosRequeridos: ['amor', 'paciencia', 'devocion', 'pureza'],
      tiempoCrecimientoHoras: 500,
    ),
  ];

  static List<PlantaJardin> getPlantasParaNivel(int nivelUsuario, int nivelJardin) {
    return catalogoCompleto.where((p) =>
        p.nivelRequerido <= nivelUsuario && p.jardinNivelRequerido <= nivelJardin).toList();
  }

  static List<PlantaJardin> getPlantasBloqueadas(int nivelUsuario, int nivelJardin) {
    return catalogoCompleto.where((p) =>
        p.nivelRequerido > nivelUsuario || p.jardinNivelRequerido > nivelJardin).toList();
  }
}
