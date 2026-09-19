


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
  bool get esNivelMaximo => false; 



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



  factory NivelInfo.fromBackendProgress(
    int nivelActual,
    double porcentajeProgreso, {
    int xpPorNivel = 100,
    int? totalXp, 
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


  @Deprecated('Usar fromTotalXp o fromBackendProgress')
  factory NivelInfo.computar(
    int nivelActual,
    double porcentajeProgreso, {
    int xpPorNivel = 100,
  }) {
    return NivelInfo.fromBackendProgress(nivelActual, porcentajeProgreso, xpPorNivel: xpPorNivel);
  }
}