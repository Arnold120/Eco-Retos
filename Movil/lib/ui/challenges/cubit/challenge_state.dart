import 'package:equatable/equatable.dart';

import '../../../data/catalogos/retos/reto_model.dart';

/// Sección/estado visible del listado de retos.
enum RetosSeccion {
  todos('Todos'),
  enProgreso('En progreso'),
  completados('Completados');

  final String label;
  const RetosSeccion(this.label);
}

class ChallengeState extends Equatable {
  final List<RetoProgreso> retos;
  final bool isLoading;
  final String? error;

  // Búsqueda y filtros.
  final String busqueda;
  final RetoDificultad? dificultadSeleccionada;
  final RetoCategoria? categoriaSeleccionada;
  final RetoTipo? tipoSeleccionado;
  final RetosSeccion seccion;

  // Reto del día (🔥).
  final RetoProgreso? retoDelDia;

  /// Retos cuya evidencia fue aprobada por un admin (recompensa ya pagada);
  /// la lista los celebra una sola vez.
  final List<AprobacionReciente> aprobacionesRecientes;

  const ChallengeState({
    this.retos = const [],
    this.isLoading = false,
    this.error,
    this.busqueda = '',
    this.dificultadSeleccionada,
    this.categoriaSeleccionada,
    this.tipoSeleccionado,
    this.seccion = RetosSeccion.todos,
    this.retoDelDia,
    this.aprobacionesRecientes = const [],
  });

  // ─── Datos derivados ────────────────────────────────────────────────────

  /// Lista visible tras aplicar búsqueda, filtros y sección.
  List<RetoProgreso> get retosFiltrados {
    var lista = retos;

    switch (seccion) {
      case RetosSeccion.enProgreso:
        lista = lista.where((r) => r.estado == RetoEstado.enProgreso).toList();
      case RetosSeccion.completados:
        lista = lista.where((r) => r.estado == RetoEstado.completado).toList();
      case RetosSeccion.todos:
        break;
    }

    if (dificultadSeleccionada != null) {
      lista = lista
          .where((r) => r.reto.dificultad == dificultadSeleccionada)
          .toList();
    }
    if (categoriaSeleccionada != null) {
      lista = lista
          .where((r) => r.reto.categoria == categoriaSeleccionada)
          .toList();
    }
    if (tipoSeleccionado != null) {
      lista = lista.where((r) => r.reto.tipo == tipoSeleccionado).toList();
    }

    final q = busqueda.trim().toLowerCase();
    if (q.isNotEmpty) {
      lista = lista.where((r) {
        final reto = r.reto;
        final campos = [
          reto.titulo,
          reto.descripcion,
          reto.subcategoria ?? '',
          reto.categoria.nombre,
          reto.tipo.label,
          reto.dificultad.label,
          ...reto.etiquetas,
        ].join(' ').toLowerCase();
        return campos.contains(q);
      }).toList();
    }

    return lista;
  }

  int get total => retos.length;

  int get totalCompletados =>
      retos.where((r) => r.estado == RetoEstado.completado).length;

  int get totalEnProgreso =>
      retos.where((r) => r.estado == RetoEstado.enProgreso).length;

  int get totalPendientes =>
      retos.where((r) => r.estado != RetoEstado.completado).length;

  /// XP acumulada solo por retos completados (economía transparente).
  int get xpGanado => retos
      .where((r) => r.estado == RetoEstado.completado)
      .fold(0, (acc, r) => acc + r.reto.xp);

  int get monedasGanadas => retos
      .where((r) => r.estado == RetoEstado.completado)
      .fold(0, (acc, r) => acc + r.reto.monedas);

  /// Nivel local estimado (1 XP por punto → 100 por nivel).
  int get nivelEstimado => 1 + (xpGanado ~/ 100);

  ChallengeState copyWith({
    List<RetoProgreso>? retos,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? busqueda,
    RetoDificultad? dificultadSeleccionada,
    bool clearDificultad = false,
    RetoCategoria? categoriaSeleccionada,
    bool clearCategoria = false,
    RetoTipo? tipoSeleccionado,
    bool clearTipo = false,
    RetosSeccion? seccion,
    RetoProgreso? retoDelDia,
    List<AprobacionReciente>? aprobacionesRecientes,
  }) {
    return ChallengeState(
      retos: retos ?? this.retos,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      busqueda: busqueda ?? this.busqueda,
      dificultadSeleccionada: clearDificultad
          ? null
          : (dificultadSeleccionada ?? this.dificultadSeleccionada),
      categoriaSeleccionada: clearCategoria
          ? null
          : (categoriaSeleccionada ?? this.categoriaSeleccionada),
      tipoSeleccionado: clearTipo
          ? null
          : (tipoSeleccionado ?? this.tipoSeleccionado),
      seccion: seccion ?? this.seccion,
      retoDelDia: retoDelDia ?? this.retoDelDia,
      aprobacionesRecientes:
          aprobacionesRecientes ?? this.aprobacionesRecientes,
    );
  }

  @override
  List<Object?> get props => [
    retos,
    isLoading,
    error,
    busqueda,
    dificultadSeleccionada,
    categoriaSeleccionada,
    tipoSeleccionado,
    seccion,
    retoDelDia,
    aprobacionesRecientes,
  ];
}
