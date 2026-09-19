import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/garden/garden_catalog.dart';
import '../../../data/models/garden/plant_growth.dart';
import '../../../data/repositories/garden_repository.dart';
import '../../../data/services/gamification_service.dart';
import 'garden_state.dart';




class GardenCubit extends Cubit<GardenState> {
  final int usuarioId;
  final GardenRepository _repository;
  Timer? _mejoraTimer;
  Timer? _efectoTimer;

  GardenCubit({
    required this.usuarioId,
    required JardinService jardinService,
    required MonederoService monederoService,
  }) : _repository = GardenRepository(
         usuarioId: usuarioId,
         jardinService: jardinService,
         monederoService: monederoService,
       ),
       super(const GardenState());

  Future<void> loadGarden() async {
    emit(state.copyWith(isLoading: true, limpiarError: true));
    try {
      final snapshot = await _repository.cargar();
      emit(
        state.copyWith(
          isLoading: false,
          jardin: snapshot.jardin,
          plantas: snapshot.plantas,
          inventario: snapshot.inventario,
          monedas: snapshot.monedas,
          racha: snapshot.racha,
          seleccionadaId: _mantenerSeleccion(snapshot.plantas),
          advertencia: snapshot.advertencia,
          limpiarAdvertencia: snapshot.advertencia == null,
          desbloqueoCarnicora: snapshot.desbloqueoCarnicora,
          plantasPerdidas: snapshot.perdidas,
          limpiarError: true,
        ),
      );
      if (snapshot.mejoras.isNotEmpty) {
        final mejor = snapshot.mejoras.reduce(
          (a, b) => a.nueva.index >= b.nueva.index ? a : b,
        );
        _emitirMejora(mejor);
      }
      developer.log('Jardín cargado correctamente', name: 'GardenCubit');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar jardín',
        name: 'GardenCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(isLoading: false, error: _getErrorMessage(e)));
    }
  }

  Future<void> refresh() => loadGarden();


  Future<void> revisarPerdidas() async {
    try {
      final perdidas = await _repository.removerPerdidas();
      if (perdidas.isEmpty || isClosed) return;
      final plantas = _repository.plantas;
      emit(
        state.copyWith(
          plantas: plantas,
          seleccionadaId: _mantenerSeleccion(plantas),
          plantasPerdidas: perdidas,
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error al revisar plantas perdidas',
        name: 'GardenCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void limpiarPerdidas() {
    if (state.plantasPerdidas.isNotEmpty) {
      emit(state.copyWith(limpiarPerdidas: true));
    }
  }

  String? _mantenerSeleccion(List<PlantGrowth> plantas) {
    final actual = state.seleccionadaId;
    if (actual != null && plantas.any((p) => p.id == actual)) return actual;
    return plantas.isEmpty ? null : plantas.first.id;
  }

  void seleccionarPlanta(String plantaId) {
    emit(state.copyWith(seleccionadaId: plantaId));
  }

  Future<bool> comprarPlanta(EspecieJardin especie) async {
    if (state.comprando) return false;
    emit(
      state.copyWith(comprando: true, limpiarError: true, limpiarMensaje: true),
    );
    try {
      final resultado = await _repository.sembrar(
        especie,
        jardinActual: state.jardin,
        monedasActuales: state.monedas,
      );
      if (!resultado.exito) {
        emit(
          state.copyWith(
            comprando: false,
            error: resultado.mensaje ?? 'No se pudo sembrar la planta.',
          ),
        );
        return false;
      }
      emit(
        state.copyWith(
          comprando: false,
          jardin: resultado.jardin,
          plantas: resultado.plantas,
          monedas: resultado.monedas,
          seleccionadaId: resultado.planta?.id,
          mensaje: resultado.mensaje,
          limpiarError: true,
        ),
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error al comprar planta',
        name: 'GardenCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(comprando: false, error: _getErrorMessage(e)));
      return false;
    }
  }

  Future<bool> comprarHerramienta(HerramientaJardin herramienta) async {
    if (state.comprandoHerramienta) return false;
    emit(
      state.copyWith(
        comprandoHerramienta: true,
        limpiarError: true,
        limpiarMensaje: true,
      ),
    );
    final resultado = await _repository.comprarHerramienta(
      herramienta,
      state.monedas,
    );
    if (!resultado.exito) {
      emit(
        state.copyWith(
          comprandoHerramienta: false,
          error: resultado.mensaje ?? 'No se pudo completar la compra.',
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        comprandoHerramienta: false,
        monedas: resultado.monedas,
        inventario: resultado.inventario,
        mensaje: resultado.mensaje,
        limpiarError: true,
      ),
    );
    return true;
  }

  Future<bool> regar(String plantaId) =>
      _cuidar(plantaId, () => _repository.regar(plantaId), EfectoJardin.riego);

  Future<bool> abonar(String plantaId) =>
      _cuidar(plantaId, () => _repository.abonar(plantaId), EfectoJardin.abono);

  Future<bool> fumigar(String plantaId) => _cuidar(
    plantaId,
    () => _repository.fumigar(plantaId),
    EfectoJardin.insecticida,
  );

  Future<bool> _cuidar(
    String plantaId,
    Future<ResultadoJardin?> Function() accion,
    EfectoJardin efecto,
  ) async {
    try {
      final resultado = await accion();
      if (resultado == null) {
        emit(
          state.copyWith(
            error: 'No encontramos esa planta en tu jardín.',
            limpiarMensaje: true,
          ),
        );
        return false;
      }
      if (!resultado.exito) {
        emit(
          state.copyWith(
            error: resultado.mensaje,
            inventario: resultado.inventario,
            limpiarMensaje: true,
          ),
        );
        return false;
      }
      emit(
        state.copyWith(
          plantas: _repository.plantas,
          inventario: resultado.inventario,
          monedas: resultado.monedas > 0 ? resultado.monedas : state.monedas,
          seleccionadaId: plantaId,
          efecto: efecto,
          efectoPlantaId: plantaId,
          efectoToken: state.efectoToken + 1,
          limpiarError: true,
          limpiarMensaje: true,
        ),
      );
      _programarLimpiezaEfecto();
      if (resultado.mejora != null) {
        _emitirMejora(resultado.mejora!);
      }
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error al cuidar planta',
        name: 'GardenCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(error: _getErrorMessage(e)));
      return false;
    }
  }

  Future<bool> reclamarCarnicora() async {
    final resultado = await _repository.reclamarCarnicora(
      jardinActual: state.jardin,
      monedasActuales: state.monedas,
    );
    if (!resultado.exito) {
      emit(state.copyWith(error: resultado.mensaje));
      return false;
    }
    emit(
      state.copyWith(
        plantas: resultado.plantas,
        seleccionadaId: resultado.planta?.id,
        mensaje: resultado.mensaje,
        limpiarError: true,
      ),
    );
    return true;
  }

  void limpiarDesbloqueo() {
    if (state.desbloqueoCarnicora) {
      emit(state.copyWith(desbloqueoCarnicora: false));
    }
  }

  void limpiarMensaje() {
    if (state.mensaje != null) {
      emit(state.copyWith(limpiarMensaje: true));
    }
  }

  void limpiarMejora() {
    if (state.mejora != null) {
      emit(state.copyWith(limpiarMejora: true));
    }
  }

  void _emitirMejora(MejoraEtapa mejora) {
    emit(
      state.copyWith(
        mejora: mejora,
        seleccionadaId: mejora.planta.id,
        limpiarError: true,
      ),
    );
    _mejoraTimer?.cancel();
    _mejoraTimer = Timer(const Duration(seconds: 6), () {
      if (!isClosed) {
        emit(state.copyWith(limpiarMejora: true));
      }
    });
  }

  void _programarLimpiezaEfecto() {
    _efectoTimer?.cancel();
    _efectoTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!isClosed) {
        emit(state.copyWith(limpiarEfecto: true));
      }
    });
  }

  @override
  Future<void> close() {
    _mejoraTimer?.cancel();
    _efectoTimer?.cancel();
    return super.close();
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
          return 'No se encontró el recurso solicitado.';
        case 500:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return 'Error: ${error.message.isNotEmpty ? error.message : error.toString()}';
      }
    }
    return 'Error inesperado: $error';
  }
}
