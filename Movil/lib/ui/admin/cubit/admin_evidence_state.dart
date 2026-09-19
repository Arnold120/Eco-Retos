import 'package:equatable/equatable.dart';

import '../../../data/models/challenge/challenge_models.dart';

/// Filtros del panel de revisión de evidencias.
enum EvidenceFiltro { todas, pendientes, aprobadas, rechazadas }

extension EvidenceFiltroInfo on EvidenceFiltro {
  String get etiqueta {
    switch (this) {
      case EvidenceFiltro.todas:
        return 'Todas';
      case EvidenceFiltro.pendientes:
        return 'Pendientes';
      case EvidenceFiltro.aprobadas:
        return 'Aprobadas';
      case EvidenceFiltro.rechazadas:
        return 'Rechazadas';
    }
  }
}

class AdminEvidenceState extends Equatable {
  final bool isLoading;
  final List<UsuarioRetoResponse> evidencias;
  final EvidenceFiltro filtro;
  final String? error;
  final int? aprobandoId;
  final int? rechazandoId;

  const AdminEvidenceState({
    required this.isLoading,
    required this.evidencias,
    this.filtro = EvidenceFiltro.todas,
    this.error,
    this.aprobandoId,
    this.rechazandoId,
  });

  const AdminEvidenceState.initial()
    : isLoading = false,
      evidencias = const [],
      filtro = EvidenceFiltro.todas,
      error = null,
      aprobandoId = null,
      rechazandoId = null;

  static bool _estaPendiente(UsuarioRetoResponse e) =>
      e.estado != 'COMPLETADO' && e.estado != 'RECHAZADO';

  /// Evidencias por aprobar/rechazar (no resueltas aún).
  int get pendientes => evidencias.where(_estaPendiente).length;

  /// Evidencias visibles según el filtro activo.
  List<UsuarioRetoResponse> get evidenciasFiltradas {
    switch (filtro) {
      case EvidenceFiltro.todas:
        return evidencias;
      case EvidenceFiltro.pendientes:
        return evidencias.where(_estaPendiente).toList();
      case EvidenceFiltro.aprobadas:
        return evidencias.where((e) => e.estado == 'COMPLETADO').toList();
      case EvidenceFiltro.rechazadas:
        return evidencias.where((e) => e.estado == 'RECHAZADO').toList();
    }
  }

  AdminEvidenceState copyWith({
    bool? isLoading,
    List<UsuarioRetoResponse>? evidencias,
    EvidenceFiltro? filtro,
    String? error,
    int? aprobandoId,
    int? rechazandoId,
  }) {
    return AdminEvidenceState(
      isLoading: isLoading ?? this.isLoading,
      evidencias: evidencias ?? this.evidencias,
      filtro: filtro ?? this.filtro,
      error: error ?? this.error,
      aprobandoId: aprobandoId ?? this.aprobandoId,
      rechazandoId: rechazandoId ?? this.rechazandoId,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    evidencias,
    filtro,
    error,
    aprobandoId,
    rechazandoId,
  ];
}
