import 'package:flutter_test/flutter_test.dart';

import 'package:eco_reto/data/catalogos/retos/reto_model.dart';
import 'package:eco_reto/data/models/challenge/challenge_models.dart';

void main() {
  final jsonReto0001 = {
    'retoId': 12,
    'codigo': 'reto-0001',
    'categoriaId': 1,
    'nombreCategoria': 'Reciclaje',
    'titulo': 'Clasifica 5 envases de aluminio',
    'descripcion': 'Separa y clasifica al menos 5 envases de aluminio.',
    'instrucciones':
        'Recolecta envases usados.\nRetira restos de comida.\nAplasta los envases.',
    'experienciaRecompensa': 40,
    'monedasRecompensa': 1,
    'dificultad': 'FACIL',
    'fechaInicio': '2026-09-14T23:33:12.1533333',
    'fechaFin': null,
    'estado': 'ACTIVO',
    'subcategoria': 'Aluminio',
    'tipo': 'CANTIDAD',
    'tiempoMin': 15,
    'materiales': '[{"nombre":"Envase de aluminio","cantidad":5}]',
    'cantidadObjetivo': 5,
    'consejos': '["Latas aplastadas ocupan menos espacio."]',
    'advertencias': '[]',
    'requisitos': '["Acceso a contenedor de reciclaje"]',
    'evidencia': 'FOTO',
    'etiquetas': '["aluminio","clasificacion","reciclaje"]',
    'destacado': false,
    'esDiario': false,
    'esSemanal': false,
    'esEspecial': false,
  };

  test('RetoResponse.fromJson mapea el JSON del backend sin perdidas', () {
    final response = RetoResponse.fromJson(jsonReto0001);

    expect(response.retoId, 12);
    expect(response.codigo, 'reto-0001');
    expect(response.categoriaId, 1);
    expect(response.experienciaRecompensa, 40);
    expect(response.monedasRecompensa, 1);
    expect(response.dificultad, 'FACIL');
    expect(response.subcategoria, 'Aluminio');
    expect(response.tipo, 'CANTIDAD');
    expect(response.tiempoMin, 15);
    expect(response.materiales, '[{"nombre":"Envase de aluminio","cantidad":5}]');
    expect(response.cantidadObjetivo, 5);
    expect(response.consejos, '["Latas aplastadas ocupan menos espacio."]');
    expect(response.evidencia, 'FOTO');
    expect(response.etiquetas, '["aluminio","clasificacion","reciclaje"]');
  });

  test('toReto() traduce el RetoResponse al modelo de dominio del catálogo', () {
    final reto = RetoResponse.fromJson(jsonReto0001).toReto();

    expect(reto.id, 'reto-0001');
    expect(reto.retoBackendId, 12);
    expect(reto.categoria, RetoCategoria.reciclaje);
    expect(reto.subcategoria, 'Aluminio');
    expect(reto.dificultad, RetoDificultad.facil);
    expect(reto.tipo, RetoTipo.cantidad);
    expect(reto.tiempoMin, 15);
    expect(reto.xp, 40);
    expect(reto.monedas, 1);
    expect(reto.cantidadObjetivo, 5);
    expect(reto.evidencia, RetoTipoEvidencia.foto);
    expect(reto.materiales, [const RetoMaterial('Envase de aluminio', 5)]);
    expect(reto.instrucciones, [
      'Recolecta envases usados.',
      'Retira restos de comida.',
      'Aplasta los envases.',
    ]);
    expect(reto.consejos, ['Latas aplastadas ocupan menos espacio.']);
    expect(reto.advertencias, isEmpty);
    expect(reto.requisitos, ['Acceso a contenedor de reciclaje']);
    expect(reto.etiquetas, ['aluminio', 'clasificacion', 'reciclaje']);
    expect(reto.destacado, isFalse);
    expect(reto.diario, isFalse);
    expect(reto.semanal, isFalse);
    expect(reto.especial, isFalse);
  });

  test('toReto() tolera campos nulos y enums desconocidos', () {
    final reto = RetoResponse.fromJson({...jsonReto0001, 'materiales': null})
        .toReto();
    expect(reto.materiales, isEmpty);
    expect(reto.instrucciones, hasLength(3));
    expect(reto.dificultad, RetoDificultad.facil);
  });
}