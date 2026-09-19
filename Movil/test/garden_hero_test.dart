import 'package:eco_reto/data/models/garden/garden_catalog.dart';
import 'package:eco_reto/data/models/garden/plant_growth.dart';
import 'package:eco_reto/ui/garden/widgets/garden_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PlantGrowth _planta(
  String id, {
  double horas = 0,
  DateTime? ultimoRiego,
  DateTime? ultimoAbono,
  bool conPlaga = false,
}) {
  final ahora = DateTime.now();
  final especie = CatalogoJardin.porId(id)!;
  return PlantGrowth.crearDesdeEspecie(
    especie: especie,
    slot: 0,
    horasIniciales: horas,
  ).copyWith(
    ultimaActualizacion: ahora,
    plantadaEl: ahora,
    ultimoRiego: ultimoRiego ?? ahora,
    ultimoAbono: ultimoAbono ?? ahora,
    tienePlaga: conPlaga,
  );
}

Future<void> _montar(WidgetTester tester, PlantGrowth planta) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: GardenHero(
            planta: planta,
            inventario: const InventarioJardin(
              regadera: true,
              abono: 2,
              insecticida: 2,
            ),
            onRegar: () {},
            onAbonar: () {},
            onFumigar: () {},
            onVerDetalle: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('el hero bloquea el modelo 3D hasta la etapa adulta',
      (tester) async {
    await _montar(tester, _planta('potted_plant', horas: 10));

    expect(find.text('Modelo 3D bloqueado'), findsOneWidget);
    expect(
      find.textContaining('Se desbloquea en la etapa adulta'),
      findsOneWidget,
    );
    expect(find.textContaining('¡Cuida tu planta!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el hero avisa cuando falta abono y el crecimiento se detiene',
      (tester) async {
    final ahora = DateTime.now();
    await _montar(
      tester,
      _planta(
        'potted_plant',
        horas: 10,
        ultimoAbono: ahora.subtract(const Duration(hours: 20)),
      ),
    );

    expect(find.textContaining('Le falta abono'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el hero avisa del riesgo de perder la planta por plaga',
      (tester) async {
    await _montar(
      tester,
      _planta('monstera', horas: 12, conPlaga: true),
    );

    expect(find.textContaining('Plaga sin tratar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el hero muestra la línea de seguimiento de etapas',
      (tester) async {
    await _montar(tester, _planta('potted_plant', horas: 10));

    expect(find.text('Seguimiento de crecimiento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
