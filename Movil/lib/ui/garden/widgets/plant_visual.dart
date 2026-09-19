import 'package:flutter/material.dart';

import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/models/garden/garden_catalog.dart';


enum FormaHoja {
  oval,
  lanceolada,
  acicular,
  serrada,
  palmeada,
  carnosa,
  redondeada,
  espada,
}


enum Porte {
  erecto,
  frondoso,
  ramificado,
  trepador,
  roseta,
  arbol,
  carnivoro,
  flotante,
}



class PlantProfile {
  final Color semilla;
  final Color semillaDetalle;
  final Color raiz;
  final Color tallo;
  final Color hojaClara;
  final Color hojaMedia;
  final Color hojaOscura;
  final Color flor;
  final Color florCentro;
  final Color fruto;
  final FormaHoja formaHoja;
  final Porte porte;
  final double densidad;
  final double anchura;
  final bool floresAdultas;
  final bool frutosAdultos;


  final bool colgante;

  const PlantProfile({
    required this.semilla,
    required this.semillaDetalle,
    required this.raiz,
    required this.tallo,
    required this.hojaClara,
    required this.hojaMedia,
    required this.hojaOscura,
    required this.flor,
    required this.florCentro,
    required this.fruto,
    required this.formaHoja,
    required this.porte,
    required this.densidad,
    required this.anchura,
    this.floresAdultas = false,
    this.frutosAdultos = false,
    this.colgante = false,
  });



  Color marchitar(Color c, double sed) {
    if (sed <= 0) return c;
    final apagado = Color.lerp(c, const Color(0xFFA8A48E), sed.clamp(0.0, 1.0));
    return apagado!.withValues(alpha: c.a * (1.0 - sed * 0.18));
  }
}


class PlantArtProfile {
  const PlantArtProfile._();

  static const PlantProfile basico = PlantProfile(
    semilla: Color(0xFF8D6E63),
    semillaDetalle: Color(0xFFBCAAA4),
    raiz: Color(0xFFB99B6A),
    tallo: Color(0xFF4C7A3C),
    hojaClara: Color(0xFF8BC34A),
    hojaMedia: Color(0xFF5DA85F),
    hojaOscura: Color(0xFF37804C),
    flor: Color(0xFFF26D85),
    florCentro: Color(0xFFF6C85F),
    fruto: Color(0xFFE53935),
    formaHoja: FormaHoja.oval,
    porte: Porte.erecto,
    densidad: 1,
    anchura: 1,
    floresAdultas: true,
  );

  static PlantProfile perfil(EspecieJardin es) {
    switch (es.id) {
      case 'planta_2':
        return const PlantProfile(
          semilla: Color(0xFF4E5A3A),
          semillaDetalle: Color(0xFF93B06B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF3E6B3C),
          hojaClara: Color(0xFF7CC48A),
          hojaMedia: Color(0xFF4E9A5E),
          hojaOscura: Color(0xFF2E7444),
          flor: Color(0xFFF2A7B3),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF2E7444),
          formaHoja: FormaHoja.oval,
          porte: Porte.frondoso,
          densidad: 1.3,
          anchura: 1.15,
          floresAdultas: true,
        );
      case 'i_kea_fejka_helecho':
        return const PlantProfile(
          semilla: Color(0xFF4A5A3A),
          semillaDetalle: Color(0xFF9CB86F),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4E7A3C),
          hojaClara: Color(0xFF8FD48A),
          hojaMedia: Color(0xFF5DAD68),
          hojaOscura: Color(0xFF3E8A52),
          flor: Color(0xFFB4A6D8),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF3E8A52),
          formaHoja: FormaHoja.lanceolada,
          porte: Porte.frondoso,
          densidad: 1.5,
          anchura: 1.2,
        );
      case 'i_kea_dypsis_lutescens_planta':
        return const PlantProfile(
          semilla: Color(0xFF4A3A2E),
          semillaDetalle: Color(0xFF8A7868),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF8A6A48),
          hojaClara: Color(0xFF8FD48A),
          hojaMedia: Color(0xFF5DB06A),
          hojaOscura: Color(0xFF3A8A52),
          flor: Color(0xFFEFF3E6),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF3A8A52),
          formaHoja: FormaHoja.palmeada,
          porte: Porte.arbol,
          densidad: 1.15,
          anchura: 1.1,
        );
      case 'flower':
        return const PlantProfile(
          semilla: Color(0xFF6B5A2E),
          semillaDetalle: Color(0xFFC9B86F),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4E7A3C),
          hojaClara: Color(0xFF8FD48A),
          hojaMedia: Color(0xFF5DA85F),
          hojaOscura: Color(0xFF37804C),
          flor: Color(0xFFF6C445),
          florCentro: Color(0xFFF59E0B),
          fruto: Color(0xFFD9A227),
          formaHoja: FormaHoja.oval,
          porte: Porte.frondoso,
          densidad: 1.05,
          anchura: 1,
          floresAdultas: true,
        );
      case 'i_kea_yucca_elephantipes_planta':
        return const PlantProfile(
          semilla: Color(0xFF4A3A2E),
          semillaDetalle: Color(0xFF8A7868),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF7A5A3E),
          hojaClara: Color(0xFFA8C07A),
          hojaMedia: Color(0xFF6C9350),
          hojaOscura: Color(0xFF4A7538),
          flor: Color(0xFFEFF3E6),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF4A7538),
          formaHoja: FormaHoja.espada,
          porte: Porte.erecto,
          densidad: 1.2,
          anchura: 1.05,
        );
      case 'indoor_plant':
        return const PlantProfile(
          semilla: Color(0xFF3A4E3A),
          semillaDetalle: Color(0xFF7BA87B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF3E6B48),
          hojaClara: Color(0xFF71C07E),
          hojaMedia: Color(0xFF4C9A5C),
          hojaOscura: Color(0xFF2E7A46),
          flor: Color(0xFFEFF3EE),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF2E7A46),
          formaHoja: FormaHoja.palmeada,
          porte: Porte.frondoso,
          densidad: 1.2,
          anchura: 1.15,
        );
      case 'planta_macetero_colgante':
        return const PlantProfile(
          semilla: Color(0xFF4A4A3A),
          semillaDetalle: Color(0xFF95B06B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF6B7A3C),
          hojaClara: Color(0xFFA8D587),
          hojaMedia: Color(0xFF6FAE63),
          hojaOscura: Color(0xFF45824C),
          flor: Color(0xFFC9D88F),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF4A8A52),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.trepador,
          densidad: 1.3,
          anchura: 1.2,
          colgante: true,
        );
      case 'low_poly_style_plant':
        return const PlantProfile(
          semilla: Color(0xFF3E7A55),
          semillaDetalle: Color(0xFF8FD4AD),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4C8A5A),
          hojaClara: Color(0xFF9FDCB6),
          hojaMedia: Color(0xFF66C98C),
          hojaOscura: Color(0xFF3BAE77),
          flor: Color(0xFF66C98C),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF3BAE77),
          formaHoja: FormaHoja.carnosa,
          porte: Porte.erecto,
          densidad: 0.9,
          anchura: 0.9,
        );
      case 'flowering_plant_free':
        return const PlantProfile(
          semilla: Color(0xFF4A4E6B),
          semillaDetalle: Color(0xFF9C9EB8),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF3E6B4A),
          hojaClara: Color(0xFF6FC174),
          hojaMedia: Color(0xFF4C9A5C),
          hojaOscura: Color(0xFF2F7A48),
          flor: Color(0xFFF26D85),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFFD94A6B),
          formaHoja: FormaHoja.oval,
          porte: Porte.frondoso,
          densidad: 1,
          anchura: 1,
          floresAdultas: true,
        );
      case 'potted_plant':
        return const PlantProfile(
          semilla: Color(0xFF4E5A3A),
          semillaDetalle: Color(0xFF93B06B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF3E6B3C),
          hojaClara: Color(0xFF66B56F),
          hojaMedia: Color(0xFF3E9150),
          hojaOscura: Color(0xFF2C7540),
          flor: Color(0xFF8FC9A0),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF2C7540),
          formaHoja: FormaHoja.oval,
          porte: Porte.frondoso,
          densidad: 1.2,
          anchura: 1.1,
        );
      case 'tomate':
        return const PlantProfile(
          semilla: Color(0xFFC9A227),
          semillaDetalle: Color(0xFFF0D98F),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4C8A4C),
          hojaClara: Color(0xFF7FB85F),
          hojaMedia: Color(0xFF5AA04E),
          hojaOscura: Color(0xFF3C7A3E),
          flor: Color(0xFFFFD54F),
          florCentro: Color(0xFFF59E0B),
          fruto: Color(0xFFE53935),
          formaHoja: FormaHoja.serrada,
          porte: Porte.ramificado,
          densidad: 0.95,
          anchura: 0.95,
          floresAdultas: true,
          frutosAdultos: true,
        );
      case 'ivy':
        return const PlantProfile(
          semilla: Color(0xFF4A4A3A),
          semillaDetalle: Color(0xFF95B06B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF6B7A3C),
          hojaClara: Color(0xFFA8D587),
          hojaMedia: Color(0xFF6FAE63),
          hojaOscura: Color(0xFF45824C),
          flor: Color(0xFFC9D88F),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF4A8A52),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.trepador,
          densidad: 1.25,
          anchura: 1.2,
        );
      case 'plant_pot_ivy':
        return const PlantProfile(
          semilla: Color(0xFF4A4A3A),
          semillaDetalle: Color(0xFF9CB06B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF6B7A3C),
          hojaClara: Color(0xFFB5D587),
          hojaMedia: Color(0xFF74A063),
          hojaOscura: Color(0xFF4A7A4E),
          flor: Color(0xFFC9D88F),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF4A8A52),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.trepador,
          densidad: 1.1,
          anchura: 1.1,
        );
      case 'monstera':
        return const PlantProfile(
          semilla: Color(0xFF4E5A4E),
          semillaDetalle: Color(0xFF8FA88F),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF3E6B48),
          hojaClara: Color(0xFF71C07E),
          hojaMedia: Color(0xFF4C9A5C),
          hojaOscura: Color(0xFF2E7A46),
          flor: Color(0xFFEFF3EE),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF4A8A52),
          formaHoja: FormaHoja.palmeada,
          porte: Porte.frondoso,
          densidad: 1,
          anchura: 1.2,
        );
      case 'lupino':
        return const PlantProfile(
          semilla: Color(0xFF4E3A5A),
          semillaDetalle: Color(0xFF9C86B8),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4C7A5A),
          hojaClara: Color(0xFF6FC174),
          hojaMedia: Color(0xFF4C9A5C),
          hojaOscura: Color(0xFF2F7A48),
          flor: Color(0xFF9C6EF2),
          florCentro: Color(0xFFF6F0FF),
          fruto: Color(0xFF6E4A9C),
          formaHoja: FormaHoja.palmeada,
          porte: Porte.erecto,
          densidad: 0.95,
          anchura: 0.85,
          floresAdultas: true,
        );
      case 'opuntia':
        return const PlantProfile(
          semilla: Color(0xFF6B7A3A),
          semillaDetalle: Color(0xFFA5C97E),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF7AAB5E),
          hojaClara: Color(0xFFA5C97E),
          hojaMedia: Color(0xFF7FAF5C),
          hojaOscura: Color(0xFF5A8F42),
          flor: Color(0xFFFFB35C),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF7B4A9C),
          formaHoja: FormaHoja.carnosa,
          porte: Porte.roseta,
          densidad: 1,
          anchura: 1,
          floresAdultas: true,
          frutosAdultos: true,
        );
      case 'planta_decorativa':
        return const PlantProfile(
          semilla: Color(0xFF4A5A3E),
          semillaDetalle: Color(0xFF8FB088),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF3E6B48),
          hojaClara: Color(0xFF7CC087),
          hojaMedia: Color(0xFF53A06A),
          hojaOscura: Color(0xFF3A7E52),
          flor: Color(0xFFA0C89C),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF3A7E52),
          formaHoja: FormaHoja.oval,
          porte: Porte.frondoso,
          densidad: 1.3,
          anchura: 1.25,
        );
      case 'bonsai':
        return const PlantProfile(
          semilla: Color(0xFF4A3A2E),
          semillaDetalle: Color(0xFF8A7868),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF6B4A32),
          hojaClara: Color(0xFF6FAE63),
          hojaMedia: Color(0xFF4C8A52),
          hojaOscura: Color(0xFF32603C),
          flor: Color(0xFFE8C8B0),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF6A6A3A),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.arbol,
          densidad: 0.9,
          anchura: 0.9,
        );
      case 'manzano_ornamental':
        return const PlantProfile(
          semilla: Color(0xFF4A3A2E),
          semillaDetalle: Color(0xFF8A7868),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF7A5A3E),
          hojaClara: Color(0xFF7FB86F),
          hojaMedia: Color(0xFF5AA04E),
          hojaOscura: Color(0xFF3C7A46),
          flor: Color(0xFFF29EC6),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFFE0392E),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.arbol,
          densidad: 1,
          anchura: 1.1,
          floresAdultas: true,
          frutosAdultos: true,
        );
      case 'loto':
        return const PlantProfile(
          semilla: Color(0xFF4A3A32),
          semillaDetalle: Color(0xFF8A7868),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4C7A5A),
          hojaClara: Color(0xFF7FD4A8),
          hojaMedia: Color(0xFF3FA078),
          hojaOscura: Color(0xFF2E7A5C),
          flor: Color(0xFFF2A7C9),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF3FA078),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.flotante,
          densidad: 1,
          anchura: 1.15,
          floresAdultas: true,
        );
      case 'baobab':
        return const PlantProfile(
          semilla: Color(0xFF4E3A32),
          semillaDetalle: Color(0xFF8A7468),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF8A6A48),
          hojaClara: Color(0xFF7FB86F),
          hojaMedia: Color(0xFF5AA04E),
          hojaOscura: Color(0xFF3C7A46),
          flor: Color(0xFFE8D8C0),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF6E503A),
          formaHoja: FormaHoja.redondeada,
          porte: Porte.arbol,
          densidad: 1.25,
          anchura: 1.3,
        );
      case 'carnicora':
        return const PlantProfile(
          semilla: Color(0xFF3A4E3A),
          semillaDetalle: Color(0xFF7BA87B),
          raiz: Color(0xFFB99B6A),
          tallo: Color(0xFF4E7A4C),
          hojaClara: Color(0xFF7AB85E),
          hojaMedia: Color(0xFF4E9A52),
          hojaOscura: Color(0xFF2E7A3C),
          flor: Color(0xFFE0396B),
          florCentro: Color(0xFFF6C85F),
          fruto: Color(0xFF3A5E4A),
          formaHoja: FormaHoja.carnosa,
          porte: Porte.carnivoro,
          densidad: 0.9,
          anchura: 1,
          floresAdultas: true,
        );
      default:
        return _derivado(es);
    }
  }

  static PlantProfile _derivado(EspecieJardin es) {
    final h = es.id.hashCode.abs();
    final nombres = [
      const Color(0xFF6A4A32),
      const Color(0xFF4E5A3A),
      const Color(0xFF4A4E6B),
      const Color(0xFF3A5E4A),
    ];
    final hojas = [
      const Color(0xFF8BC34A),
      const Color(0xFF6FAE63),
      const Color(0xFF66C98C),
      const Color(0xFF7FB86F),
    ];
    final forma = FormaHoja.values[h % FormaHoja.values.length];
    final porte = switch (es.tipo) {
      PlantaTipo.arbol => Porte.arbol,
      PlantaTipo.suculenta => Porte.roseta,
      PlantaTipo.flor => Porte.frondoso,
      PlantaTipo.hierba => Porte.erecto,
      _ => Porte.erecto,
    };
    final semilla = nombres[h % nombres.length];
    final hoja = hojas[(h >> 3) % hojas.length];
    return PlantProfile(
      semilla: semilla,
      semillaDetalle: Color.lerp(semilla, Colors.white, 0.35)!,
      raiz: const Color(0xFFB99B6A),
      tallo: Color.lerp(hoja, Colors.black, 0.45)!,
      hojaClara: Color.lerp(hoja, Colors.white, 0.2)!,
      hojaMedia: hoja,
      hojaOscura: Color.lerp(hoja, Colors.black, 0.3)!,
      flor: es.rareza.rarezaColor,
      florCentro: const Color(0xFFF6C85F),
      fruto: Color.lerp(hoja, const Color(0xFFE53935), 0.4)!,
      formaHoja: forma,
      porte: porte,
      densidad: 0.8 + (h % 10) / 10,
      anchura: 0.8 + ((h >> 4) % 8) / 10,
      floresAdultas: es.tieneFloracion,
    );
  }
}