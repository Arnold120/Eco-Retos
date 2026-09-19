import 'package:equatable/equatable.dart';

import '../../../data/models/user/user_models.dart';
import '../../../data/models/gamification/gamification_models.dart';

class ProfileState extends Equatable {
  final int usuarioId;
  final String nombreUsuario;
  final String correo;
  final PerfilResponse? perfil;
  final ProgresoResponse? progreso;
  final JardinResponse? jardin;
  final List<UsuarioInsigniaResponse> insignias;
  final List<MovimientoMonedaResponse> historial;
  final int totalPuntos;
  final int xpTotal;
  final int rachaActual;
  final int monedas;
  final bool isLoading;
  final bool subiendoFoto;
  final String? error;

  const ProfileState({
    this.usuarioId = 0,
    this.nombreUsuario = '',
    this.correo = '',
    this.perfil,
    this.progreso,
    this.jardin,
    this.insignias = const [],
    this.historial = const [],
    this.totalPuntos = 0,
    this.xpTotal = 0,
    this.rachaActual = 0,
    this.monedas = 0,
    this.isLoading = false,
    this.subiendoFoto = false,
    this.error,
  });

  ProfileState copyWith({
    int? usuarioId,
    String? nombreUsuario,
    String? correo,
    PerfilResponse? perfil,
    ProgresoResponse? progreso,
    JardinResponse? jardin,
    List<UsuarioInsigniaResponse>? insignias,
    List<MovimientoMonedaResponse>? historial,
    int? totalPuntos,
    int? xpTotal,
    int? rachaActual,
    int? monedas,
    bool? isLoading,
    bool? subiendoFoto,
    String? error,
  }) {
    return ProfileState(
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      correo: correo ?? this.correo,
      perfil: perfil ?? this.perfil,
      progreso: progreso ?? this.progreso,
      jardin: jardin ?? this.jardin,
      insignias: insignias ?? this.insignias,
      historial: historial ?? this.historial,
      totalPuntos: totalPuntos ?? this.totalPuntos,
      xpTotal: xpTotal ?? this.xpTotal,
      rachaActual: rachaActual ?? this.rachaActual,
      monedas: monedas ?? this.monedas,
      isLoading: isLoading ?? this.isLoading,
      subiendoFoto: subiendoFoto ?? this.subiendoFoto,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        usuarioId,
        nombreUsuario,
        correo,
        perfil,
        progreso,
        jardin,
        insignias,
        historial,
        totalPuntos,
        xpTotal,
        rachaActual,
        monedas,
        isLoading,
        subiendoFoto,
        error,
      ];
}
