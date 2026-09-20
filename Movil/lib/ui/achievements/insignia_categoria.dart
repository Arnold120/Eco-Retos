import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/gamification/gamification_models.dart';

enum InsigniaCategoria {
  retos(
    nombre: 'Retos',
    descripcion: 'Valida retos y suma logros',
    icono: Icons.flag_rounded,
    color: AppColors.primary,
    colorSecundario: AppColors.secondary,
  ),
  trivias(
    nombre: 'Trivias',
    descripcion: 'Demuestra todo lo que sabes',
    icono: Icons.psychology_rounded,
    color: AppColors.info,
    colorSecundario: AppColors.bluePastel,
  ),
  rachas(
    nombre: 'Rachas',
    descripcion: 'Mantén tu constancia diaria',
    icono: Icons.local_fire_department_rounded,
    color: AppColors.streakFire,
    colorSecundario: AppColors.coralSoft,
  ),
  experiencia(
    nombre: 'Experiencia',
    descripcion: 'Acumula puntos de experiencia',
    icono: Icons.bolt_rounded,
    color: AppColors.xpGold,
    colorSecundario: AppColors.warning,
  ),
  otros(
    nombre: 'Especiales',
    descripcion: 'Logros únicos y sorpresas',
    icono: Icons.auto_awesome_rounded,
    color: AppColors.lavender,
    colorSecundario: AppColors.levelPurple,
  );

  const InsigniaCategoria({
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.colorSecundario,
  });

  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final Color colorSecundario;

  List<Color> get gradiente => [color, colorSecundario];
}

extension InsigniaCategoriaExtension on InsigniaResponse {
  InsigniaCategoria get categoria {
    final requisito = this.requisito.toLowerCase();
    if (requisito.contains('racha')) return InsigniaCategoria.rachas;
    if (requisito.contains('experiencia') ||
        requisito.contains('puntos') ||
        requisito.contains('xp')) {
      return InsigniaCategoria.experiencia;
    }
    if (requisito.contains('trivia')) return InsigniaCategoria.trivias;
    if (requisito.contains('reto')) return InsigniaCategoria.retos;

    final respaldo = '$descripcion $nombreInsignia'.toLowerCase();
    if (respaldo.contains('racha')) return InsigniaCategoria.rachas;
    if (respaldo.contains('trivia')) return InsigniaCategoria.trivias;
    if (respaldo.contains('reto')) return InsigniaCategoria.retos;
    return InsigniaCategoria.otros;
  }

  int? get objetivo {
    final match = RegExp(
      r'(\d+)\s*(?:retos?|trivias?|d[ií]as?|puntos?|xp)',
      caseSensitive: false,
    ).firstMatch(requisito);
    final valor = match == null ? null : int.tryParse(match.group(1)!);
    return (valor == null || valor <= 0) ? null : valor;
  }
}

class MetricasLogros {
  final int retosCompletados;
  final int triviasCompletadas;
  final int experiencia;
  final int rachaActual;

  const MetricasLogros({
    this.retosCompletados = 0,
    this.triviasCompletadas = 0,
    this.experiencia = 0,
    this.rachaActual = 0,
  });

  int valorPara(InsigniaCategoria categoria) {
    switch (categoria) {
      case InsigniaCategoria.retos:
        return retosCompletados;
      case InsigniaCategoria.trivias:
        return triviasCompletadas;
      case InsigniaCategoria.rachas:
        return rachaActual;
      case InsigniaCategoria.experiencia:
        return experiencia;
      case InsigniaCategoria.otros:
        return 0;
    }
  }

  double? progresoDe(InsigniaResponse insignia) {
    final objetivo = insignia.objetivo;
    if (objetivo == null) return null;
    final actual = valorPara(insignia.categoria);
    return (actual / objetivo).clamp(0.0, 1.0).toDouble();
  }
}

String normalizarTexto(String texto) {
  const conAcento = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const sinAcento = 'aaaaaeeeeiiiiooooouuuunc';
  var resultado = texto.toLowerCase();
  for (var i = 0; i < conAcento.length; i++) {
    resultado = resultado.replaceAll(conAcento[i], sinAcento[i]);
  }
  return resultado;
}
