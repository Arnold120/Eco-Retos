import 'package:flutter_test/flutter_test.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/core/utils/media_url.dart';
import 'package:eco_reto/data/models/social/social_models.dart';
import 'package:eco_reto/ui/community/cubit/community_state.dart';
import 'package:eco_reto/ui/community/widgets/post_helpers.dart';

PublicacionResponse _post({
  required int id,
  int usuarioId = 1,
  int likes = 0,
  int comentarios = 0,
  bool guardada = false,
  String contenido = 'Acción ambiental',
  DateTime? fecha,
  String? ubicacion,
  String tipo = 'GENERAL',
}) {
  return PublicacionResponse(
    publicacionId: id,
    usuarioId: usuarioId,
    nombreUsuario: 'Usuario $usuarioId',
    contenido: contenido,
    tipo: tipo,
    fechaPublicacion: fecha ?? DateTime(2026, 1, id),
    estado: 'PUBLICADA',
    cantidadComentarios: comentarios,
    cantidadLikes: likes,
    guardada: guardada,
    ubicacion: ubicacion,
  );
}

void main() {
  group('CommunityState.feed', () {
    test('paraTi ordena por relevancia (likes + comentarios) y fecha', () {
      final state = CommunityState(
        publicaciones: [
          _post(id: 1, likes: 1, comentarios: 0),
          _post(id: 2, likes: 0, comentarios: 1),
          _post(id: 3, likes: 5, comentarios: 0),
        ],
      );

      final ids = state.feed.map((p) => p.publicacionId).toList();
      expect(ids.first, 3);
      expect(ids[1], 2);
    });

    test('populares ordena por interacciones', () {
      final state = CommunityState(
        filtro: MuroFiltro.populares,
        publicaciones: [
          _post(id: 1, likes: 1),
          _post(id: 2, likes: 9, comentarios: 3),
        ],
      );
      expect(state.feed.first.publicacionId, 2);
    });

    test('siguiendo solo muestra publicaciones de usuarios seguidos', () {
      final state = CommunityState(
        filtro: MuroFiltro.siguiendo,
        publicaciones: [
          _post(id: 1, usuarioId: 10),
          _post(id: 2, usuarioId: 20),
        ],
        siguiendoIds: {20},
      );
      expect(state.feed.length, 1);
      expect(state.feed.first.usuarioId, 20);
    });

    test('guardadas filtra por estado guardada', () {
      final state = CommunityState(
        filtro: MuroFiltro.guardadas,
        publicaciones: [
          _post(id: 1, guardada: true),
          _post(id: 2),
        ],
      );
      expect(state.feed.map((p) => p.publicacionId), [1]);
    });

    test('las publicaciones ocultas no aparecen en el feed', () {
      final state = CommunityState(
        publicaciones: [_post(id: 1), _post(id: 2)],
        ocultadasIds: {1},
      );
      expect(state.feed.map((p) => p.publicacionId), [2]);
    });

    test('cercaDeTi exige ubicación o tipo iniciativa', () {
      final state = CommunityState(
        filtro: MuroFiltro.cercaDeTi,
        publicaciones: [
          _post(id: 1, ubicacion: 'Managua'),
          _post(id: 2),
          _post(id: 3, tipo: 'INICIATIVA'),
        ],
      );
      final ids = state.feed.map((p) => p.publicacionId).toSet();
      expect(ids, {1, 3});
    });

    test('la búsqueda local filtra por contenido y autor', () {
      final state = CommunityState(
        publicaciones: [
          _post(id: 1, contenido: 'Reciclamos plástico'),
          _post(id: 2, contenido: 'Sembramos árboles'),
        ],
        busqueda: 'reciclamos',
        esBusqueda: true,
      );
      expect(state.feed.map((p) => p.publicacionId), [1]);
    });
  });

  group('resolverUrlMedia', () {
    test('reescribe archivos de la API al host actual', () {
      const url =
          'http://accuracy-hypnotize-gawk.ngrok-free.dev/api/Imagenes/archivo/202609/video.mp4';
      final resuelta = resolverUrlMedia(url);
      expect(resuelta, isNotNull);
      expect(resuelta, contains('/api/Imagenes/archivo/202609/video.mp4'));
      expect(resuelta, contains(Uri.parse(EnvConfig.baseUrl).host));
    });

    test('deja intactas las imagenes externas', () {
      const url = 'https://images.example.com/foto.jpg';
      expect(resolverUrlMedia(url), url);
    });

    test('devuelve null para vacios', () {
      expect(resolverUrlMedia(null), isNull);
      expect(resolverUrlMedia('  '), isNull);
    });
  });

  group('primerEnlace', () {
    test('detecta la primera URL y limpia signos finales', () {
      const texto = 'Mira esto https://ejemplo.com/nota, y luego más texto';
      expect(primerEnlace(texto), 'https://ejemplo.com/nota');
    });

    test('devuelve null cuando no hay enlace', () {
      expect(primerEnlace('sin enlaces aquí'), isNull);
    });
  });

  group('PublicacionResponse', () {
    test('mapea visibilidad, compartidos y multimedia del backend', () {
      final post = PublicacionResponse.fromJson({
        'publicacionId': 7,
        'usuarioId': 3,
        'nombreUsuario': 'Ana',
        'contenido': 'Hola',
        'tipo': 'GENERAL',
        'fechaPublicacion': '2026-02-01T10:00:00',
        'estado': 'PUBLICADA',
        'cantidadComentarios': 2,
        'cantidadLikes': 4,
        'meGusta': true,
        'guardada': true,
        'cantidadCompartidos': 1,
        'visibilidad': 'SEGUIDORES',
        'compartidoDeId': 5,
        'compartidoEliminado': false,
        'multimedia': [
          {'url': 'https://cdn/x.jpg', 'tipo': 'imagen'},
          {'url': 'https://cdn/y.mp4', 'tipo': 'video'},
        ],
      });

      expect(post.visibilidad, 'SEGUIDORES');
      expect(post.cantidadCompartidos, 1);
      expect(post.esCompartido, isTrue);
      expect(post.multimedia.length, 2);
      expect(post.multimedia.last.tipo, 'video');
    });
  });
}
