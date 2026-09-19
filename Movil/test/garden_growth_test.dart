import 'dart:io';

import 'package:eco_reto/data/models/garden/garden_catalog.dart';
import 'package:eco_reto/data/models/garden/plant_growth.dart';
import 'package:flutter_test/flutter_test.dart';

PlantGrowth _plantar(
  String id, {
  int slot = 0,
  double horas = 0,
  DateTime? ahora,
  DateTime? plantadaEl,
  DateTime? ultimoRiego,
  DateTime? ultimoAbono,
}) {
  final momento = ahora ?? DateTime.now();
  final especie = CatalogoJardin.porId(id)!;
  return PlantGrowth.crearDesdeEspecie(
    especie: especie,
    slot: slot,
    horasIniciales: horas,
    plantadaEl: plantadaEl,
  ).copyWith(
    ultimaActualizacion: momento,
    ultimoRiego: ultimoRiego,
    ultimoAbono: ultimoAbono,
  );
}

void main() {
  test('el crecimiento avanza con tiempo real mientras hay agua y abono', () {
    final ahora = DateTime.now();
    final planta = _plantar(
      'potted_plant',
      ahora: ahora,
      ultimoRiego: ahora,
      ultimoAbono: ahora,
    );

    expect(planta.horasTotales(ahora), 0);
    expect(planta.horasTotales(ahora.add(const Duration(hours: 5))), 5);
    expect(planta.etapa(ahora), EtapaCrecimiento.semilla);
    expect(
      planta.etapa(ahora.add(const Duration(hours: 5))),
      EtapaCrecimiento.germinacion,
    );
  });

  test('sin abono el crecimiento se detiene hasta fertilizar', () {
    final ahora = DateTime.now();
    final planta = _plantar(
      'potted_plant',
      ahora: ahora,
      ultimoRiego: ahora,
      ultimoAbono: ahora.subtract(const Duration(hours: 13)),
    );

    expect(planta.faltaAbono, isTrue);
    expect(planta.horasTotales(ahora.add(const Duration(hours: 3))), 0);

    final abonada = planta.copyWith(ultimoAbono: ahora);
    expect(abonada.faltaAbono, isFalse);
    expect(abonada.horasTotales(ahora.add(const Duration(hours: 3))), 3);
  });

  test('sin agua el crecimiento también se detiene', () {
    final ahora = DateTime.now();
    final planta = _plantar(
      'potted_plant',
      ahora: ahora,
      ultimoRiego: ahora.subtract(const Duration(hours: 13)),
      ultimoAbono: ahora,
    );

    expect(planta.horasTotales(ahora.add(const Duration(hours: 2))), 0);

    final regada = planta.copyWith(ultimoRiego: ahora);
    expect(regada.horasTotales(ahora.add(const Duration(hours: 2))), 2);
  });

  test('la marchitez avanza hora a hora y la planta se pierde a las 5 h',
      () {
    final ahora = DateTime.now();
    PlantGrowth conSed(double horas) => _plantar(
      'potted_plant',
      ahora: ahora,
      plantadaEl: ahora.subtract(
        Duration(minutes: (horas * 60).round()),
      ),
    );

    final recienMarchita = conSed(12);
    expect(recienMarchita.marchita, isTrue);
    expect(recienMarchita.marchitez, closeTo(0, 0.02));
    expect(recienMarchita.perdida, isFalse);
    expect(recienMarchita.necesitaAgua, isTrue);

    final dosHoras = conSed(14);
    expect(dosHoras.marchitez, closeTo(0.4, 0.02));
    expect(dosHoras.perdida, isFalse);

    final perdida = conSed(17);
    expect(perdida.marchitez, 1.0);
    expect(perdida.perdidaPorSed, isTrue);
    expect(perdida.perdida, isTrue);
    expect(perdida.puedeRegar, isFalse);
  });

  test('una plaga sin tratar se lleva la planta en 1 día', () {
    final ahora = DateTime.now();
    final planta = _plantar('monstera', ahora: ahora).copyWith(
      tienePlaga: true,
      plagaDesde: ahora.subtract(const Duration(hours: 23)),
    );

    expect(planta.perdidaPorPlaga, isFalse);
    expect(planta.puedeInsecticida, isTrue);

    final muerta = planta.copyWith(
      plagaDesde: ahora.subtract(const Duration(hours: 24)),
    );
    expect(muerta.perdidaPorPlaga, isTrue);
    expect(muerta.perdida, isTrue);
    expect(muerta.puedeInsecticida, isFalse);
  });

  test('la plaga pausa el crecimiento hasta curarla', () {
    final ahora = DateTime.now();
    final planta =
        _plantar('monstera', horas: 10, ahora: ahora).copyWith(
          ultimaActualizacion: ahora.subtract(const Duration(hours: 24)),
          tienePlaga: true,
          plagaDesde: ahora.subtract(const Duration(hours: 24)),
        );

    expect(planta.horasTotales(ahora), 10);
    expect(planta.etapa(ahora), EtapaCrecimiento.brote);

    final curada = planta.copyWith(quitarPlaga: true);
    expect(curada.horasTotales(ahora), 34);
  });

  test('la floración solo llega en plantas con flores', () {
    final ahora = DateTime.now();
    final conFlor = _plantar('loto', horas: 31, ahora: ahora);
    final sinFlor = _plantar('potted_plant', horas: 31, ahora: ahora);

    expect(conFlor.etapa(ahora), EtapaCrecimiento.floracion);
    expect(sinFlor.etapa(ahora), EtapaCrecimiento.plantaAdulta);
  });

  test('el inventario de herramientas sobrevive el ciclo JSON', () {
    const inventario = InventarioJardin(
      regadera: true,
      abono: 3,
      insecticida: 2,
      carnicoraDesbloqueada: true,
    );
    final reconstruido = InventarioJardin.fromJson(inventario.toJson());
    expect(reconstruido, inventario);
    expect(reconstruido.cantidad(HerramientaJardin.abono), 3);
    expect(reconstruido.tiene(HerramientaJardin.regadera), isTrue);
  });

  test('el tomate usa un modelo 3D distinto por etapa', () {
    final tomate = CatalogoJardin.porId('tomate')!;
    expect(tomate.modeloPara(EtapaCrecimiento.semilla), 'tomato_lv1.glb');
    expect(tomate.modeloPara(EtapaCrecimiento.plantaPequena), 'tomato_lv2.glb');
    expect(tomate.modeloPara(EtapaCrecimiento.floracion), 'tomato_lv3.glb');
  });

  test('la planta carnívora se desbloquea solo por racha', () {
    expect(CatalogoJardin.carnicora.especialRacha, isTrue);
    expect(CatalogoJardin.carnicora.rachaRequerida, 30);
    expect(CatalogoJardin.carnicora.precio, 0);
  });

  test('todas las especies apuntan a modelos GLB locales que existen', () {
    for (final especie in CatalogoJardin.especies) {
      expect(
        especie.modelo.endsWith('.glb'),
        isTrue,
        reason: '${especie.id} debe usar un GLB',
      );
      expect(
        File('${GardenGrowthConfig.carpetaModelos}/${especie.modelo}')
            .existsSync(),
        isTrue,
        reason: 'falta el modelo ${especie.modelo} de ${especie.id}',
      );
      final porEtapa = especie.modelosPorEtapa;
      if (porEtapa != null) {
        for (final modelo in porEtapa) {
          expect(modelo.endsWith('.glb'), isTrue);
          expect(
            File('${GardenGrowthConfig.carpetaModelos}/$modelo').existsSync(),
            isTrue,
            reason: 'falta el modelo $modelo',
          );
        }
      }
    }
  });

  test('las herramientas usan ilustraciones propias existentes', () {
    for (final herramienta in HerramientaJardin.values) {
      expect(
        herramienta.assetIcono.startsWith('assets/objetos_jardin/'),
        isTrue,
      );
      expect(
        File(herramienta.assetIcono).existsSync(),
        isTrue,
        reason: 'falta ${herramienta.assetIcono}',
      );
    }
  });

  test('las herramientas tienen precios equilibrados', () {
    expect(GardenGrowthConfig.precioRegadera, 50);
    expect(GardenGrowthConfig.precioAbono, 25);
    expect(GardenGrowthConfig.precioInsecticida, 30);
  });

  test('el insecticida se aplica de forma preventiva mientras crece', () {
    final ahora = DateTime.now();
    final creciendo = _plantar('potted_plant', horas: 10, ahora: ahora);

    expect(creciendo.enCrecimiento, isTrue);
    expect(creciendo.puedeInsecticida, isTrue);

    final adulta = creciendo.copyWith(horasCrecimiento: 30);
    expect(adulta.esAdulta, isTrue);
    expect(adulta.puedeInsecticida, isFalse,
        reason: 'una adulta sana no necesita insecticida preventivo');

    final adultaConPlaga = adulta.copyWith(tienePlaga: true);
    expect(adultaConPlaga.puedeInsecticida, isTrue,
        reason: 'curar una plaga siempre está permitido');
  });

  test('la protección por insecticida evita plagas durante un rato', () {
    final ahora = DateTime.now();
    final planta = _plantar('monstera', ahora: ahora).copyWith(
      protegidaHasta: ahora.add(const Duration(hours: 8)),
    );

    expect(planta.estaProtegida(ahora.add(const Duration(hours: 1))), isTrue);
    expect(planta.estaProtegida(ahora.add(const Duration(hours: 5))), isTrue);
    expect(
      planta.estaProtegida(ahora.add(const Duration(hours: 9))),
      isFalse,
    );
  });

  test('regar quita el aviso de agua y la marchitez', () {
    final ahora = DateTime.now();
    final planta = _plantar(
      'potted_plant',
      ahora: ahora,
      plantadaEl: ahora.subtract(const Duration(hours: 13)),
    );

    expect(planta.necesitaAgua, isTrue);
    expect(planta.marchita, isTrue);
    expect(planta.humedad, 'Seca');

    final regada = planta.copyWith(ultimoRiego: DateTime.now());
    expect(regada.necesitaAgua, isFalse);
    expect(regada.marchita, isFalse);
    expect(regada.humedad, 'Hidratada');
  });

  test('la escala del modelo crece de forma continua y solo llega a 1.0 al '
      'terminar', () {
    final ahora = DateTime.now();
    final valores = [
      0.0,
      3.0,
      8.0,
      13.0,
      17.0,
      22.0,
      25.0,
      30.0,
    ].map((h) => _plantar('potted_plant', horas: h, ahora: ahora).escalaModelo)
        .toList();

    for (var i = 1; i < valores.length; i++) {
      expect(
        valores[i],
        greaterThanOrEqualTo(valores[i - 1]),
        reason: 'la escala no debe retroceder',
      );
    }
    expect(valores.last, 1.0);
    expect(
      _plantar('potted_plant', horas: 20, ahora: ahora).escalaModelo,
      lessThan(1.0),
      reason: 'antes de ser adulta la planta aún no alcanza su tamaño final',
    );
  });

  test('la protección por insecticida sobrevive el ciclo JSON', () {
    final ahora = DateTime.now();
    final planta = _plantar('tomate', ahora: ahora).copyWith(
      protegidaHasta: ahora.add(const Duration(hours: 8)),
    );
    final reconstruida = PlantGrowth.fromJson(planta.toJson());
    expect(reconstruida.protegidaHasta, planta.protegidaHasta);
  });
}
