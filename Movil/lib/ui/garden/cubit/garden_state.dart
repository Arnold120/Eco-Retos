import 'package:equatable/equatable.dart';

import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/models/garden/plant_growth.dart';
import '../../../data/repositories/garden_repository.dart';

/// Efecto visual que debe reproducir la UI tras una acción de cuidado.
enum EfectoJardin { riego, abono, insecticida }

class GardenState extends Equatable {
  final JardinResponse? jardin;
  final List<PlantGrowth> plantas;
  final InventarioJardin inventario;
  final int monedas;
  final int racha;
  final String? seleccionadaId;
  final bool isLoading;
  final bool comprando;
  final bool comprandoHerramienta;
  final String? error;
  final String? advertencia;
  final String? mensaje;
  final MejoraEtapa? mejora;
  final bool desbloqueoCarnicora;
  final List<PlantaPerdida> plantasPerdidas;
  final EfectoJardin? efecto;
  final String? efectoPlantaId;
  final int efectoToken;

  const GardenState({
    this.jardin,
    this.plantas = const [],
    this.inventario = const InventarioJardin(),
    this.monedas = 0,
    this.racha = 0,
    this.seleccionadaId,
    this.isLoading = false,
    this.comprando = false,
    this.comprandoHerramienta = false,
    this.error,
    this.advertencia,
    this.mensaje,
    this.mejora,
    this.desbloqueoCarnicora = false,
    this.plantasPerdidas = const [],
    this.efecto,
    this.efectoPlantaId,
    this.efectoToken = 0,
  });

  int get totalPlantas => plantas.length;

  int get espaciosLibres {
    final libres = GardenGrowthConfig.maxSlots - plantas.length;
    return libres < 0 ? 0 : libres;
  }

  bool get carnicoraEnJardin => plantas.any((p) => p.catalogoId == 'carnicora');

  int get rachaParaCarnicora {
    final faltan = GardenGrowthConfig.rachaCarnicora - racha;
    return faltan < 0 ? 0 : faltan;
  }

  PlantGrowth? get plantaSeleccionada {
    final id = seleccionadaId;
    if (id == null) return plantas.isEmpty ? null : plantas.first;
    for (final planta in plantas) {
      if (planta.id == id) return planta;
    }
    return plantas.isEmpty ? null : plantas.first;
  }

  GardenState copyWith({
    JardinResponse? jardin,
    List<PlantGrowth>? plantas,
    InventarioJardin? inventario,
    int? monedas,
    int? racha,
    String? seleccionadaId,
    bool? isLoading,
    bool? comprando,
    bool? comprandoHerramienta,
    String? error,
    String? advertencia,
    String? mensaje,
    MejoraEtapa? mejora,
    bool? desbloqueoCarnicora,
    List<PlantaPerdida>? plantasPerdidas,
    EfectoJardin? efecto,
    String? efectoPlantaId,
    int? efectoToken,
    bool limpiarError = false,
    bool limpiarAdvertencia = false,
    bool limpiarMensaje = false,
    bool limpiarMejora = false,
    bool limpiarEfecto = false,
    bool limpiarPerdidas = false,
  }) {
    return GardenState(
      jardin: jardin ?? this.jardin,
      plantas: plantas ?? this.plantas,
      inventario: inventario ?? this.inventario,
      monedas: monedas ?? this.monedas,
      racha: racha ?? this.racha,
      seleccionadaId: seleccionadaId ?? this.seleccionadaId,
      isLoading: isLoading ?? this.isLoading,
      comprando: comprando ?? this.comprando,
      comprandoHerramienta: comprandoHerramienta ?? this.comprandoHerramienta,
      error: limpiarError ? null : (error ?? this.error),
      advertencia: limpiarAdvertencia
          ? null
          : (advertencia ?? this.advertencia),
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      mejora: limpiarMejora ? null : (mejora ?? this.mejora),
      desbloqueoCarnicora: desbloqueoCarnicora ?? this.desbloqueoCarnicora,
      plantasPerdidas: limpiarPerdidas
          ? const []
          : (plantasPerdidas ?? this.plantasPerdidas),
      efecto: limpiarEfecto ? null : (efecto ?? this.efecto),
      efectoPlantaId: limpiarEfecto
          ? null
          : (efectoPlantaId ?? this.efectoPlantaId),
      efectoToken: efectoToken ?? this.efectoToken,
    );
  }

  @override
  List<Object?> get props => [
    jardin,
    plantas,
    inventario,
    monedas,
    racha,
    seleccionadaId,
    isLoading,
    comprando,
    comprandoHerramienta,
    error,
    advertencia,
    mensaje,
    mejora,
    desbloqueoCarnicora,
    plantasPerdidas,
    efecto,
    efectoPlantaId,
    efectoToken,
  ];
}
