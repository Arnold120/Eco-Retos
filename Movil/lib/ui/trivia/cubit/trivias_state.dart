import 'package:equatable/equatable.dart';

import '../../../data/repositories/trivia_recompensa_local.dart';


enum TriviasStatus {
  cargando,
  listo,
  error,
}


class DiaSemanaTrivia extends Equatable {

  final int weekday;
  final String inicial;
  final int categoriaId;
  final String categoriaNombre;
  final bool completado;
  final bool esHoy;

  const DiaSemanaTrivia({
    required this.weekday,
    required this.inicial,
    required this.categoriaId,
    required this.categoriaNombre,
    this.completado = false,
    this.esHoy = false,
  });

  @override
  List<Object?> get props => [
        weekday,
        inicial,
        categoriaId,
        categoriaNombre,
        completado,
        esHoy,
      ];
}


class TriviasState extends Equatable {
  final TriviasStatus status;
  final bool isLoading;
  final String? error;
  final DateTime hoy;
  final int racha;
  final int mejorRacha;
  final int monedasDisponibles;
  final List<DiaSemanaTrivia> semana;


  final RecompensaLibre? recompensaLibre;


  final bool recompensaReclamando;

  const TriviasState({
    this.status = TriviasStatus.cargando,
    this.isLoading = false,
    this.error,
    required this.hoy,
    this.racha = 0,
    this.mejorRacha = 0,
    this.monedasDisponibles = 0,
    this.semana = const [],
    this.recompensaLibre,
    this.recompensaReclamando = false,
  });

  factory TriviasState.inicial({DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    return TriviasState(hoy: DateTime(ahora.year, ahora.month, ahora.day));
  }

  int get diasCompletados => semana.where((d) => d.completado).length;

  bool get semanaCompletada => diasCompletados >= 7;

  bool get hayRecompensaLibrePendiente =>
      recompensaLibre != null &&
      recompensaLibre!.pendiente &&
      !recompensaReclamando;

  String get progresoSemanaTexto => semanaCompletada
      ? '🎉 ¡Semana completada!'
      : '$diasCompletados / 7 días completados';

  TriviasState copyWith({
    TriviasStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
    DateTime? hoy,
    int? racha,
    int? mejorRacha,
    int? monedasDisponibles,
    List<DiaSemanaTrivia>? semana,
    RecompensaLibre? recompensaLibre,
    bool? recompensaReclamando,
  }) {
    return TriviasState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hoy: hoy ?? this.hoy,
      racha: racha ?? this.racha,
      mejorRacha: mejorRacha ?? this.mejorRacha,
      monedasDisponibles: monedasDisponibles ?? this.monedasDisponibles,
      semana: semana ?? this.semana,
      recompensaLibre: recompensaLibre ?? this.recompensaLibre,
      recompensaReclamando: recompensaReclamando ?? this.recompensaReclamando,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoading,
        error,
        hoy,
        racha,
        mejorRacha,
        monedasDisponibles,
        semana,
        recompensaLibre,
        recompensaReclamando,
      ];
}