import 'package:equatable/equatable.dart';

import '../../../../data/models/admin/admin_models.dart';

class AdminPanelState extends Equatable {
  final List<UsuarioAdminResponse> usuarios;
  final List<RolResponse> roles;
  final UsuariosTotalesResponse? totales;
  final int evidenciasPendientes;
  final bool isLoading;
  final String? error;
  final String? mensaje;
  final int? actuandoId;

  const AdminPanelState({
    this.usuarios = const [],
    this.roles = const [],
    this.totales,
    this.evidenciasPendientes = 0,
    this.isLoading = false,
    this.error,
    this.mensaje,
    this.actuandoId,
  });

  AdminPanelState copyWith({
    List<UsuarioAdminResponse>? usuarios,
    List<RolResponse>? roles,
    UsuariosTotalesResponse? totales,
    int? evidenciasPendientes,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? mensaje,
    bool clearMensaje = false,
    int? actuandoId,
    bool limpiarActuando = false,
  }) {
    return AdminPanelState(
      usuarios: usuarios ?? this.usuarios,
      roles: roles ?? this.roles,
      totales: totales ?? this.totales,
      evidenciasPendientes: evidenciasPendientes ?? this.evidenciasPendientes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      mensaje: clearMensaje ? null : (mensaje ?? this.mensaje),
      actuandoId: limpiarActuando ? null : (actuandoId ?? this.actuandoId),
    );
  }

  @override
  List<Object?> get props => [
    usuarios,
    roles,
    totales,
    evidenciasPendientes,
    isLoading,
    error,
    mensaje,
    actuandoId,
  ];
}
