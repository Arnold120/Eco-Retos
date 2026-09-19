/// Modela el progreso de nivel a partir de datos reales del backend.
/// Soporta cálculo basado en XP total real o en porcentaje del backend.
/// La base de XP por nivel es fija (100 XP) para consistencia visual.
class NivelInfo {
  final int nivel;
  final double porcentaje;
  final int xpPorNivel;
  final int xpEnNivel;
  final int xpMaximoNivel;
  final int xpFaltante;
  final int xpTotales;
  final int xpSiguienteNivel;

  const NivelInfo({
    required this.nivel,
    required this.porcentaje,
    required this.xpPorNivel,
    required this.xpEnNivel,
    required this.xpMaximoNivel,
    required this.xpFaltante,
    required this.xpTotales,
    required this.xpSiguienteNivel,
  });

  bool get listoParaSubir => xpFaltante <= 0;
  bool get esNivelMaximo => false; // Se puede extender si hay nivel máximo

  /// Calcula el progreso usando el XP total real del usuario.
  /// Este es el método preferido cuando tenemos el XP total real.
  factory NivelInfo.fromTotalXp(
    int totalXp, {
    int xpPorNivel = 100,
    int nivelMaximo = 100,
  }) {
    final nivel = (totalXp / xpPorNivel).floor() + 1;
    final nivelClamped = nivel.clamp(1, nivelMaximo);
    final xpEnNivel = totalXp % xpPorNivel;
    final porcentaje = (xpEnNivel / xpPorNivel * 100).clamp(0.0, 100.0);
    final xpFaltante = (xpPorNivel - xpEnNivel).clamp(0, xpPorNivel);
    final xpSiguienteNivel = nivelClamped * xpPorNivel;

    return NivelInfo(
      nivel: nivelClamped,
      porcentaje: porcentaje,
      xpPorNivel: xpPorNivel,
      xpEnNivel: xpEnNivel,
      xpMaximoNivel: xpPorNivel,
      xpFaltante: xpFaltante,
      xpTotales: totalXp,
      xpSiguienteNivel: xpSiguienteNivel,
    );
  }

  /// Calcula el progreso usando nivel actual y porcentaje del backend.
  /// Útil cuando el backend ya proporciona estos valores calculados.
  factory NivelInfo.fromBackendProgress(
    int nivelActual,
    double porcentajeProgreso, {
    int xpPorNivel = 100,
    int? totalXp, // Opcional: si tenemos el XP total real, lo usamos para validar
  }) {
    final nivel = nivelActual < 1 ? 1 : nivelActual;
    final porcentaje = porcentajeProgreso.clamp(0.0, 100.0);
    final xpEnNivel = (porcentaje / 100 * xpPorNivel).round();
    final xpFaltante = (xpPorNivel - xpEnNivel).clamp(0, xpPorNivel);
    final xpTotalesCalculado = (nivel - 1) * xpPorNivel + xpEnNivel;
    final xpTotales = totalXp ?? xpTotalesCalculado;
    final xpSiguienteNivel = nivel * xpPorNivel;

    return NivelInfo(
      nivel: nivel,
      porcentaje: porcentaje,
      xpPorNivel: xpPorNivel,
      xpEnNivel: xpEnNivel,
      xpMaximoNivel: xpPorNivel,
      xpFaltante: xpFaltante,
      xpTotales: xpTotales,
      xpSiguienteNivel: xpSiguienteNivel,
    );
  }

  /// Método legacy para compatibilidad - redirige a fromBackendProgress
  @Deprecated('Usar fromTotalXp o fromBackendProgress')
  factory NivelInfo.computar(
    int nivelActual,
    double porcentajeProgreso, {
    int xpPorNivel = 100,
  }) {
    return NivelInfo.fromBackendProgress(nivelActual, porcentajeProgreso, xpPorNivel: xpPorNivel);
  }
}