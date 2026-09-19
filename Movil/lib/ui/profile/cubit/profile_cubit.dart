import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/user/user_models.dart';
import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/models/trivia/diario_models.dart';
import '../../../data/repositories/trivias_diario_local.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/gamification_service.dart';
import '../../../data/services/imagen_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final int usuarioId;
  final String nombreUsuario;
  final String correo;
  final UserService _userService;
  final ProgresoService _progresoService;
  final JardinService _jardinService;
  final InsigniaService _insigniaService;
  final MonederoService _monederoService;
  final DiarioStore _diarioStore;
  final ImagenService _imagenService;

  ProfileCubit({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.correo,
    required UserService userService,
    required ProgresoService progresoService,
    required JardinService jardinService,
    required InsigniaService insigniaService,
    required MonederoService monederoService,
    required DiarioStore diarioStore,
    required ImagenService imagenService,
  })  : _userService = userService,
        _progresoService = progresoService,
        _jardinService = jardinService,
        _insigniaService = insigniaService,
        _monederoService = monederoService,
        _diarioStore = diarioStore,
        _imagenService = imagenService,
        super(ProfileState(
          usuarioId: usuarioId,
          nombreUsuario: nombreUsuario,
          correo: correo,
        ));

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _userService.getPerfil(usuarioId),
        _progresoService.getProgreso(usuarioId),
        _jardinService.getJardin(usuarioId),
        _insigniaService.getInsigniasUsuario(usuarioId),
        _monederoService.getHistorial(),

        _monederoService.getSaldo(),
        _diarioStore.cargar(),
      ]);

      final historial = results[4] as List<MovimientoMonedaResponse>;
      final saldo = results[5] as SaldoMonederoResponse;
      final progresoDiario = results[6] as ProgresoDiario;

      emit(state.copyWith(
        isLoading: false,
        perfil: results[0] as PerfilResponse,
        progreso: results[1] as ProgresoResponse,
        jardin: results[2] as JardinResponse,
        insignias: results[3] as List<UsuarioInsigniaResponse>,
        historial: historial,
        totalPuntos: saldo.saldo,
        xpTotal: saldo.experiencia,
        monedas: saldo.saldo,
        rachaActual:
            rachaEfectivaDiaria(progresoDiario, DateTime.now()),
      ));
      developer.log('Perfil cargado correctamente', name: 'ProfileCubit');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar perfil',
        name: 'ProfileCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      ));
    }
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Datos inválidos: ${error.message}';
        case 401:
          return 'Sesión expirada. Inicia sesión de nuevo.';
        case 403:
          return 'No tienes permiso para esta acción.';
        case 404:
          return 'No se encontró el perfil.';
        case 500:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return 'Error: ${error.message.isNotEmpty ? error.message : error.toString()}';
      }
    }
    return 'Error inesperado: $error';
  }



  Future<int> _perfilId() async {
    final actual = state.perfil?.perfilId;
    if (actual != null && actual > 0) return actual;
    final perfil = await _userService.getPerfil(usuarioId);
    return perfil.perfilId;
  }

  Future<void> actualizarPerfil(ActualizarPerfilRequest request) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _userService.actualizarPerfil(await _perfilId(), request);
      final perfil = await _userService.getPerfil(usuarioId);
      emit(state.copyWith(isLoading: false, perfil: perfil));
    } catch (e, stackTrace) {
      developer.log(
        'Error al actualizar perfil',
        name: 'ProfileCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      ));
    }
  }

  Future<void> refresh() => loadProfile();


  Future<bool> cambiarFoto(File archivo) async {
    if (state.subiendoFoto) return false;
    emit(state.copyWith(subiendoFoto: true, error: null));
    try {
      final url = await _imagenService.subirImagen(archivo);
      var perfilActual = state.perfil;
      perfilActual ??= await _userService.getPerfil(usuarioId);
      await _userService.actualizarPerfil(
        perfilActual.perfilId,
        ActualizarPerfilRequest(
          nombre: perfilActual.nombre,
          apellido: perfilActual.apellido,
          carnet: perfilActual.carnet,
          centroEducativo: perfilActual.centroEducativo,
          grado: perfilActual.grado,
          fotoPerfil: url,
        ),
      );
      final perfil = await _userService.getPerfil(usuarioId);
      emit(state.copyWith(subiendoFoto: false, perfil: perfil));
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error al cambiar foto',
        name: 'ProfileCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        subiendoFoto: false,
        error: _getErrorMessage(e),
      ));
      return false;
    }
  }



  Future<bool> comprarPlanta(String tipo, int precio) async {
    final jardin = state.jardin;
    if (jardin == null || state.monedas < precio) return false;

    final jardinActualizado = JardinResponse(
      jardinId: jardin.jardinId,
      usuarioId: jardin.usuarioId,
      nivelJardin: jardin.nivelJardin,
      plantas: jardin.plantas + (tipo == 'planta' ? 1 : 0),
      arboles: jardin.arboles + (tipo == 'arbol' ? 1 : 0),
      flores: jardin.flores + (tipo == 'flor' ? 1 : 0),
      puntosJardin: jardin.puntosJardin + 1,
    );

    try {

      await _monederoService.gastar(
        cantidad: precio,
        tipo: 'COMPRA',
        descripcion: 'Compra de planta en el jardín ($precio Monedas Eco)',
      );
      await _jardinService.actualizarJardin(usuarioId, jardinActualizado);
      final saldo = await _monederoService.getSaldo();
      final historial = await _monederoService.getHistorial();
      emit(state.copyWith(
        jardin: jardinActualizado,
        totalPuntos: saldo.saldo,
        xpTotal: saldo.experiencia,
        monedas: saldo.saldo,
        historial: historial,
        error: null,
      ));
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error al comprar planta',
        name: 'ProfileCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(error: _getErrorMessage(e)));
      return false;
    }
  }
}
