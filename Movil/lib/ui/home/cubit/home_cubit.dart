import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/models/social/social_models.dart';
import '../../../data/models/trivia/diario_models.dart';
import '../../../data/repositories/trivias_diario_local.dart';
import '../../../data/repositories/reto_repository.dart';
import '../../../data/services/categoria_service.dart';
import '../../../data/services/gamification_service.dart';
import '../../../data/services/reto_service.dart';
import '../../../data/services/social_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final int usuarioId;
  final String nombreUsuario;
  final CategoriaService _categoriaService;
  final RetoService _retoService;
  final ProgresoService _progresoService;
  final JardinService _jardinService;
  final DiarioStore _diarioStore;
  final MonederoService _monederoService;
  final NotificacionService _notificacionService;
  final PublicacionService _publicacionService;

  HomeCubit({
    required this.usuarioId,
    required this.nombreUsuario,
    required CategoriaService categoriaService,
    required RetoService retoService,
    required ProgresoService progresoService,
    required JardinService jardinService,
    required DiarioStore diarioStore,
    required MonederoService monederoService,
    required NotificacionService notificacionService,
    required PublicacionService publicacionService,
  })  : _categoriaService = categoriaService,
        _retoService = retoService,
        _progresoService = progresoService,
        _jardinService = jardinService,
        _diarioStore = diarioStore,
        _monederoService = monederoService,
        _notificacionService = notificacionService,
        _publicacionService = publicacionService,
        super(HomeState(usuarioId: usuarioId, nombreUsuario: nombreUsuario));

  Future<void> loadDashboard() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // El catálogo de retos ahora vive en el backend: se carga aquí (y en
      // el ChallengeCubit) compartiendo un único viaje a GET /api/Retos.
      await RetoRepository.cargarCatalogo(_retoService);
      final results = await Future.wait([
        _categoriaService.getCategorias(),
        _retoService.getRetosActivosUsuario(usuarioId),
        _progresoService.getProgreso(usuarioId),
        _jardinService.getJardin(usuarioId),
        _diarioStore.cargar(),
        // Saldo único de Monedas Eco + XP/nivel (fuente de verdad: backend).
        _monederoService.getSaldo(),
        _notificacionService.getConteoNoLeidas(usuarioId),
        _publicacionService.getRecientes(5),
      ]);

      final progreso = results[2] as ProgresoResponse;
      final saldo = results[5] as SaldoMonederoResponse;

      emit(state.copyWith(
        isLoading: false,
        categorias: results[0] as List<CategoriaResponse>,
        retosRecientes: (results[1] as List<UsuarioRetoResponse>).take(5).toList(),
        progreso: progreso,
        jardin: results[3] as JardinResponse,
        totalPuntos: saldo.saldo,
        xpTotal: saldo.experiencia,
        monedas: saldo.saldo,
        rachaActual: rachaEfectivaDiaria(results[4] as ProgresoDiario, DateTime.now()),
        notificacionesSinLeer: results[6] as int,
        publicacionesRecientes: results[7] as List<PublicacionResponse>,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar el dashboard',
      ));
    }
  }

  Future<void> refresh() => loadDashboard();
}
