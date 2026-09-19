import 'package:eco_reto/data/models/garden/garden_catalog.dart';
import 'package:eco_reto/data/models/garden/plant_growth.dart';
import 'package:eco_reto/ui/garden/widgets/garden_bed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PlantGrowth _planta(String id, int slot, double horas) {
  final especie = CatalogoJardin.porId(id)!;
  final ahora = DateTime.now();
  return PlantGrowth.crearDesdeEspecie(
    especie: especie,
    slot: slot,
    horasIniciales: horas,
  ).copyWith(
    ultimaActualizacion: ahora,
    plantadaEl: ahora.subtract(Duration(hours: horas.round())),
  );
}

Future<void> _montar(WidgetTester tester, List<PlantGrowth> plantas) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 360,
            child: GardenBed(
              plantas: plantas,
              maxSlots: GardenGrowthConfig.maxSlots,
              onVerPlanta: (_) {},
              onPlantarNueva: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  testWidgets('el cantero dibuja todas las etapas y portes sin errores',
      (tester) async {
    final plantas = <PlantGrowth>[
      _planta('low_poly_style_plant', 0, 0),
      _planta('potted_plant', 1, 5),
      _planta('flowering_plant_free', 2, 10),
      _planta('planta_2', 3, 15),
      _planta('tomate', 4, 19),
      _planta('monstera', 5, 25),
      _planta('opuntia', 6, 30),
      _planta('bonsai', 7, 31),
      _planta('loto', 8, 31),
      _planta('ivy', 9, 12),
      _planta('planta_macetero_colgante', 10, 27),
      _planta('carnicora', 11, 28),
    ];

    await _montar(tester, plantas);

    expect(find.byType(GardenBed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el cantero dibuja plantas marchitas, con plaga y regadas',
      (tester) async {
    final ahora = DateTime.now();
    final plantas = <PlantGrowth>[
      _planta('bonsai', 0, 24).copyWith(
        plantadaEl: ahora.subtract(const Duration(hours: 13)),
      ),
      _planta('baobab', 1, 20).copyWith(tienePlaga: true),
      _planta('carnicora', 2, 28).copyWith(ultimoRiego: ahora),
      _planta('i_kea_yucca_elephantipes_planta', 3, 31),
      _planta('i_kea_fejka_helecho', 4, 16).copyWith(
        ultimoAbono: ahora.subtract(const Duration(hours: 20)),
      ),
    ];

    await _montar(tester, plantas);

    expect(tester.takeException(), isNull);
  });

  testWidgets('el cantero vacío muestra los espacios para sembrar',
      (tester) async {
    await _montar(tester, const []);

    expect(tester.takeException(), isNull);
    expect(find.text('Sembrar'), findsNWidgets(GardenGrowthConfig.maxSlots));
  });
}