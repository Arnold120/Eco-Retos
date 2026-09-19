import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_reto/core/network/api_client.dart';
import 'package:eco_reto/data/models/challenge/challenge_models.dart';
import 'package:eco_reto/data/models/gamification/gamification_models.dart';
import 'package:eco_reto/data/models/social/social_models.dart';
import 'package:eco_reto/data/repositories/trivias_diario_local.dart';
import 'package:eco_reto/data/services/categoria_service.dart';
import 'package:eco_reto/data/services/gamification_service.dart';
import 'package:eco_reto/data/services/reto_service.dart';
import 'package:eco_reto/data/services/social_service.dart';
import 'package:eco_reto/ui/home/cubit/home_cubit.dart';

class _FakeCategoriaService extends CategoriaService {
  _FakeCategoriaService(super.client);

  @override
  Future<List<CategoriaResponse>> getCategorias() async => const [];
}

class _FakeRetoService extends RetoService {
  _FakeRetoService(super.client);

  @override
  Future<List<UsuarioRetoResponse>> getRetosActivosUsuario(int usuarioId) async {
    return [
      UsuarioRetoResponse(
        usuarioRetoId: 1,
        usuarioId: usuarioId,
        retoId: 10,
        codigo: 'reto-0001',
        tituloReto: 'Reto de prueba',
        estado: 'INICIADO',
        puntosObtenidos: 0,
        puntosReto: 40,
        fechaInicio: DateTime(2026, 1, 1),
      ),
    ];
  }
}

class _FakeProgresoService extends ProgresoService {
  _FakeProgresoService(super.client);

  @override
  Future<ProgresoResponse> getProgreso(int usuarioId) async {
    return ProgresoResponse(
      progresoId: 1,
      usuarioId: usuarioId,
      retosCompletados: 9,
      triviasCompletadas: 0,
      insigniasObtenidas: 0,
      publicacionesRealizadas: 0,
      materialesObtenidos: 0,
      nivelActual: 1,
      porcentajeProgreso: 0,
    );
  }
}

class _FakeJardinService extends JardinService {
  _FakeJardinService(super.client);

  @override
  Future<JardinResponse> getJardin(int usuarioId) async {
    return JardinResponse(
      jardinId: 1,
      usuarioId: usuarioId,
      nivelJardin: 1,
      plantas: 0,
      arboles: 0,
      flores: 0,
      puntosJardin: 0,
    );
  }
}

class _FakeMonederoService extends MonederoService {
  _FakeMonederoService(super.client);

  @override
  Future<SaldoMonederoResponse> getSaldo() async =>
      const SaldoMonederoResponse(saldo: 0, experiencia: 0);
}

class _FakeNotificacionService extends NotificacionService {
  _FakeNotificacionService(super.client);

  @override
  Future<int> getConteoNoLeidas(int usuarioId) async => 0;
}

class _FakePublicacionService extends PublicacionService {
  _FakePublicacionService(super.client);

  @override
  Future<List<PublicacionResponse>> getRecientes(int cantidad) async =>
      const [];
}

void main() {
  test(
    'loadDashboard guarda los retos activos como UsuarioRetoResponse',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = ApiClient();
      final cubit = HomeCubit(
        usuarioId: 2,
        nombreUsuario: 'Dan',
        categoriaService: _FakeCategoriaService(client),
        retoService: _FakeRetoService(client),
        progresoService: _FakeProgresoService(client),
        jardinService: _FakeJardinService(client),
        diarioStore: DiarioStore(usuarioId: 2),
        monederoService: _FakeMonederoService(client),
        notificacionService: _FakeNotificacionService(client),
        publicacionService: _FakePublicacionService(client),
      );

      await cubit.loadDashboard();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, isNull);
      expect(cubit.state.retosRecientes, hasLength(1));
      expect(cubit.state.retosRecientes.first.tituloReto, 'Reto de prueba');
      expect(cubit.state.progreso?.retosCompletados, 9);
    },
  );
}
