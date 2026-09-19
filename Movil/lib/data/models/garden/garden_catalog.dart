import 'package:equatable/equatable.dart';

import '../gamification/gamification_models.dart';
import 'plant_growth.dart';


enum PlantaTipo { planta, arbol, flor, suculenta, hierba, decorativa, especial }

extension PlantaTipoX on PlantaTipo {
  String get label {
    switch (this) {
      case PlantaTipo.planta:
        return 'Planta';
      case PlantaTipo.arbol:
        return 'Árbol';
      case PlantaTipo.flor:
        return 'Flor';
      case PlantaTipo.suculenta:
        return 'Suculenta';
      case PlantaTipo.hierba:
        return 'Hierba';
      case PlantaTipo.decorativa:
        return 'Decorativa';
      case PlantaTipo.especial:
        return 'Especial';
    }
  }

  static PlantaTipo desdeNombre(String nombre) {
    for (final tipo in PlantaTipo.values) {
      if (tipo.name == nombre) return tipo;
    }
    return PlantaTipo.planta;
  }
}



class EspecieJardin extends Equatable {
  final String id;
  final String nombre;
  final String emoji;
  final String modelo;
  final List<String>? modelosPorEtapa;
  final PlantaTipo tipo;
  final PlantaRareza rareza;
  final int precio;
  final bool tieneFloracion;
  final bool especialRacha;
  final int rachaRequerida;
  final bool escalaPorEtapa;
  final String? animacion;
  final String descripcion;

  const EspecieJardin({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.modelo,
    required this.tipo,
    required this.rareza,
    required this.precio,
    required this.descripcion,
    this.modelosPorEtapa,
    this.tieneFloracion = false,
    this.especialRacha = false,
    this.rachaRequerida = 0,
    this.escalaPorEtapa = true,
    this.animacion,
  });

  String modeloPara(EtapaCrecimiento etapa) {
    final lista = modelosPorEtapa;
    if (lista == null || lista.isEmpty) return modelo;
    final indice = etapa.index < lista.length ? etapa.index : lista.length - 1;
    return lista[indice];
  }

  String get rarezaLabel => rareza.rarezaLabel;

  String get tipoLabel => tipo.label;

  @override
  List<Object?> get props => [id, nombre, modelo, tipo, rareza, precio];
}




class CatalogoJardin {
  const CatalogoJardin._();

  static const EspecieJardin carnicora = EspecieJardin(
    id: 'carnicora',
    nombre: 'Planta carnívora',
    emoji: '🪴',
    modelo: 'planta_carnivora.glb',
    tipo: PlantaTipo.especial,
    rareza: PlantaRareza.legendaria,
    precio: 0,
    especialRacha: true,
    rachaRequerida: 30,
    animacion: 'CINEMA_4D_Principal',
    descripcion:
        'Exclusiva del jardín: se desbloquea con una racha de 30 días. '
        'Su modelo tiene una animación propia de apertura.',
  );

  static const List<EspecieJardin> especies = [
    EspecieJardin(
      id: 'low_poly_style_plant',
      nombre: 'Planta low poly',
      emoji: '🌿',
      modelo: 'low_poly_style_plant.glb',
      tipo: PlantaTipo.decorativa,
      rareza: PlantaRareza.comun,
      precio: 25,
      descripcion: 'Estilo minimalista que da vida a cualquier rincón.',
    ),
    EspecieJardin(
      id: 'flowering_plant_free',
      nombre: 'Planta florecida',
      emoji: '🌸',
      modelo: 'flowering_plant_free.glb',
      tipo: PlantaTipo.flor,
      rareza: PlantaRareza.comun,
      precio: 30,
      tieneFloracion: true,
      descripcion: 'Crece rápido y termina regalando flores.',
    ),
    EspecieJardin(
      id: 'potted_plant',
      nombre: 'Planta de interior',
      emoji: '🪴',
      modelo: 'potted_plant.glb',
      tipo: PlantaTipo.planta,
      rareza: PlantaRareza.comun,
      precio: 35,
      descripcion: 'Follaje compacto, muy fácil de cuidar.',
    ),
    EspecieJardin(
      id: 'tomate',
      nombre: 'Tomate cherry',
      emoji: '🍅',
      modelo: 'tomato_lv1.glb',
      modelosPorEtapa: [
        'tomato_lv1.glb',
        'tomato_lv1.glb',
        'tomato_lv2.glb',
        'tomato_lv2.glb',
        'tomato_lv3.glb',
        'tomato_lv3.glb',
        'tomato_lv3.glb',
      ],
      tipo: PlantaTipo.flor,
      rareza: PlantaRareza.comun,
      precio: 40,
      tieneFloracion: true,
      escalaPorEtapa: false,
      descripcion: 'Cada etapa tiene su propio modelo 3D. ¡Hasta da tomates!',
    ),
    EspecieJardin(
      id: 'ivy',
      nombre: 'Hiedra trepadora',
      emoji: '🌿',
      modelo: 'ivy.glb',
      tipo: PlantaTipo.hierba,
      rareza: PlantaRareza.pocoComun,
      precio: 50,
      descripcion: 'Crece con elegancia y cubre tu jardín de verde.',
    ),
    EspecieJardin(
      id: 'plant_pot_ivy',
      nombre: 'Hiedra en maceta',
      emoji: '🌿',
      modelo: 'plant_pot_ivy.glb',
      tipo: PlantaTipo.hierba,
      rareza: PlantaRareza.pocoComun,
      precio: 55,
      descripcion: 'Hiedra detallada con maceta de barro.',
    ),
    EspecieJardin(
      id: 'monstera',
      nombre: 'Monstera',
      emoji: '🌿',
      modelo: 'monstera_b02.glb',
      tipo: PlantaTipo.planta,
      rareza: PlantaRareza.pocoComun,
      precio: 60,
      descripcion: 'Hojas grandes y tropicales, muy decorativa.',
    ),
    EspecieJardin(
      id: 'planta_2',
      nombre: 'Planta frondosa',
      emoji: '🌿',
      modelo: 'planta_2.glb',
      tipo: PlantaTipo.planta,
      rareza: PlantaRareza.pocoComun,
      precio: 65,
      descripcion: 'Follaje abundante que llena cualquier espacio.',
    ),
    EspecieJardin(
      id: 'i_kea_fejka_helecho',
      nombre: 'Helecho de Boston',
      emoji: '🌿',
      modelo: 'i_kea_fejka_helecho.glb',
      tipo: PlantaTipo.hierba,
      rareza: PlantaRareza.pocoComun,
      precio: 70,
      descripcion: 'Helecho colgante de hojas finas y elegantes.',
    ),
    EspecieJardin(
      id: 'i_kea_dypsis_lutescens_planta',
      nombre: 'Palma areca',
      emoji: '🌴',
      modelo: 'i_kea_dypsis_lutescens_planta.glb',
      tipo: PlantaTipo.arbol,
      rareza: PlantaRareza.pocoComun,
      precio: 80,
      descripcion: 'Palma tropical que aporta frescura al jardín.',
    ),
    EspecieJardin(
      id: 'flower',
      nombre: 'Flor dorada',
      emoji: '🌼',
      modelo: 'flower.glb',
      tipo: PlantaTipo.flor,
      rareza: PlantaRareza.rara,
      precio: 100,
      tieneFloracion: true,
      descripcion: 'Una flor radiante que corona tu jardín.',
    ),
    EspecieJardin(
      id: 'lupino',
      nombre: 'Lupino florido',
      emoji: '💜',
      modelo: 'realistic_hd_large-leaved_lupine_918.glb',
      tipo: PlantaTipo.flor,
      rareza: PlantaRareza.rara,
      precio: 110,
      tieneFloracion: true,
      descripcion: 'Espigas de flores moradas muy llamativas.',
    ),
    EspecieJardin(
      id: 'opuntia',
      nombre: 'Cactus Opuntia',
      emoji: '🌵',
      modelo: 'opuntia_cacti.glb',
      tipo: PlantaTipo.suculenta,
      rareza: PlantaRareza.rara,
      precio: 120,
      descripcion: 'Cactus con palas, flores y frutos. Muy resistente.',
    ),
    EspecieJardin(
      id: 'i_kea_yucca_elephantipes_planta',
      nombre: 'Yuca pie de elefante',
      emoji: '🌳',
      modelo: 'i_kea_yucca_elephantipes_planta.glb',
      tipo: PlantaTipo.arbol,
      rareza: PlantaRareza.rara,
      precio: 130,
      descripcion: 'Tronco robusto y hojas en roseta. Muy resistente.',
    ),
    EspecieJardin(
      id: 'indoor_plant',
      nombre: 'Planta de salón',
      emoji: '🪴',
      modelo: 'indoor_plant.glb',
      tipo: PlantaTipo.planta,
      rareza: PlantaRareza.rara,
      precio: 140,
      descripcion: 'Follaje premium con maceta decorativa.',
    ),
    EspecieJardin(
      id: 'planta_decorativa',
      nombre: 'Planta decorativa',
      emoji: '🌿',
      modelo: 'stylish_green_plant_3d_model__modern_home_decor.glb',
      tipo: PlantaTipo.planta,
      rareza: PlantaRareza.rara,
      precio: 150,
      descripcion: 'Follaje frondoso de alta calidad para un jardín premium.',
    ),
    EspecieJardin(
      id: 'bonsai',
      nombre: 'Bonsái',
      emoji: '🌳',
      modelo: 'bonsai.glb',
      tipo: PlantaTipo.arbol,
      rareza: PlantaRareza.rara,
      precio: 160,
      descripcion: 'Árbol miniatura que requiere paciencia y cuidado.',
    ),
    EspecieJardin(
      id: 'planta_macetero_colgante',
      nombre: 'Macetero colgante',
      emoji: '🏺',
      modelo: 'planta_macetero_colgante.glb',
      tipo: PlantaTipo.decorativa,
      rareza: PlantaRareza.epica,
      precio: 180,
      descripcion: 'Planta colgante con macetero artesanal.',
    ),
    EspecieJardin(
      id: 'manzano_ornamental',
      nombre: 'Manzano ornamental',
      emoji: '🌳',
      modelo: 'crab_apple_royal_beauty_-_garden.glb',
      tipo: PlantaTipo.arbol,
      rareza: PlantaRareza.epica,
      precio: 200,
      tieneFloracion: true,
      descripcion: 'Árbol en maceta que florece con fuerza en primavera.',
    ),
    EspecieJardin(
      id: 'loto',
      nombre: 'Loto rosado',
      emoji: '🪷',
      modelo: 'pink_lotus_flower_cluster.glb',
      tipo: PlantaTipo.flor,
      rareza: PlantaRareza.epica,
      precio: 220,
      tieneFloracion: true,
      descripcion: 'Conjunto de flores de loto, símbolo de pureza.',
    ),
    EspecieJardin(
      id: 'baobab',
      nombre: 'Baobab',
      emoji: '🌳',
      modelo: 'realistic_hd_african_continental_baobab_120.glb',
      tipo: PlantaTipo.arbol,
      rareza: PlantaRareza.legendaria,
      precio: 300,
      descripcion: 'El árbol africano más emblemático. Todo un logro.',
    ),
    carnicora,
  ];

  static EspecieJardin? porId(String id) {
    for (final especie in especies) {
      if (especie.id == id) return especie;
    }
    return null;
  }

  static List<EspecieJardin> get comprables =>
      especies.where((e) => !e.especialRacha).toList();
}
