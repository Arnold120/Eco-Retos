import 'package:eco_reto/data/models/gamification/gamification_models.dart';
import 'package:eco_reto/data/models/garden/garden_catalog.dart';
import 'package:eco_reto/ui/garden/widgets/plant_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el perfil visual es determinista por especie', () {
    for (final especie in CatalogoJardin.especies) {
      final primera = PlantArtProfile.perfil(especie);
      final segunda = PlantArtProfile.perfil(especie);
      expect(primera, same(segunda),
          reason: '${especie.id} debería resolver al mismo perfil');
      expect(primera.formaHoja, isNotNull);
      expect(primera.porte, isNotNull);
      expect(primera.densidad, greaterThan(0));
      expect(primera.anchura, greaterThan(0));
    }
  });

  test('especies distintas tienen identidad visual propia', () {
    final baseEspecie = CatalogoJardin.especies.first;
    final especies = CatalogoJardin.especies
        .where((e) => e.id != baseEspecie.id)
        .map((e) => PlantArtProfile.perfil(e))
        .toList();
    final base = PlantArtProfile.perfil(baseEspecie);

    final hojas = especies.map((p) => p.hojaMedia).toSet();
    final portes = especies.map((p) => p.porte).toSet();
    final formas = especies.map((p) => p.formaHoja).toSet();

    expect(hojas.contains(base.hojaMedia), isFalse,
        reason: 'esperaba más de un perfil de color de hoja entre especies');
    expect(
      hojas.length + portes.length + formas.length,
      greaterThanOrEqualTo(5),
    );
  });

  test('el perfil derivado (especie futura) es determinista y coherente', () {
    const desconocida = EspecieJardin(
      id: 'especie_futura',
      nombre: 'Especie prueba',
      emoji: '',
      modelo: 'futura.glb',
      tipo: PlantaTipo.especial,
      rareza: PlantaRareza.pocoComun,
      precio: 99,
      descripcion: 'Prueba de respaldo visual.',
    );
    final a = PlantArtProfile.perfil(desconocida);
    final b = PlantArtProfile.perfil(desconocida);
    expect(a.hojaMedia, b.hojaMedia);
    expect(a.formaHoja, b.formaHoja);
    expect(a.porte, isNotNull);
    expect(a.flor, isNotNull);
  });

  test('el golpe de sed apaga los colores', () {
    const perfiles = PlantProfile(
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
    );
    final marchito = perfiles.marchitar(perfiles.hojaClara, 1.0);
    expect(marchito, isNot(perfiles.hojaClara));
    expect(
      marchito.computeLuminance(),
      lessThan(perfiles.hojaClara.computeLuminance()),
    );
  });

  test('el perfil básico de respaldo es constante', () {
    expect(PlantArtProfile.basico.porte, Porte.erecto);
    expect(PlantArtProfile.basico.formaHoja, FormaHoja.oval);
  });
}