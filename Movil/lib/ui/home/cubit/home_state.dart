import 'package:equatable/equatable.dart';

import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/models/gamification/gamification_models.dart';
import '../../../data/models/social/social_models.dart';

class HomeState extends Equatable {
  final int usuarioId;
  final String nombreUsuario;
  final int totalPuntos;
  final int xpTotal;
  final int monedas;
  final int rachaActual;
  final ProgresoResponse? progreso;
  final JardinResponse? jardin;
  final List<CategoriaResponse> categorias;
  final List<UsuarioRetoResponse> retosRecientes;
  final List<PublicacionResponse> publicacionesRecientes;
  final int notificacionesSinLeer;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.usuarioId = 0,
    this.nombreUsuario = '',
    this.totalPuntos = 0,
    this.xpTotal = 0,
    this.monedas = 0,
    this.rachaActual = 0,
    this.progreso,
    this.jardin,
    this.categorias = const [],
    this.retosRecientes = const [],
    this.publicacionesRecientes = const [],
    this.notificacionesSinLeer = 0,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    int? usuarioId,
    String? nombreUsuario,
    int? totalPuntos,
    int? xpTotal,
    int? monedas,
    int? rachaActual,
    ProgresoResponse? progreso,
    JardinResponse? jardin,
    List<CategoriaResponse>? categorias,
    List<UsuarioRetoResponse>? retosRecientes,
    List<PublicacionResponse>? publicacionesRecientes,
    int? notificacionesSinLeer,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      totalPuntos: totalPuntos ?? this.totalPuntos,
      xpTotal: xpTotal ?? this.xpTotal,
      monedas: monedas ?? this.monedas,
      rachaActual: rachaActual ?? this.rachaActual,
      progreso: progreso ?? this.progreso,
      jardin: jardin ?? this.jardin,
      categorias: categorias ?? this.categorias,
      retosRecientes: retosRecientes ?? this.retosRecientes,
      publicacionesRecientes:
          publicacionesRecientes ?? this.publicacionesRecientes,
      notificacionesSinLeer:
          notificacionesSinLeer ?? this.notificacionesSinLeer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        usuarioId,
        nombreUsuario,
        totalPuntos,
        xpTotal,
        monedas,
        rachaActual,
        progreso,
        jardin,
        categorias,
        retosRecientes,
        publicacionesRecientes,
        notificacionesSinLeer,
        isLoading,
        error,
      ];
}
