import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/confetti_widget.dart';
import 'cubit/diario_cubit.dart';
import 'cubit/diario_state.dart';
import 'widgets/recompensa_celebracion.dart';
import 'widgets/trivia_ui.dart';

/// Pantalla de resultados del Modo Diario con botón RECLAMAR.
class DiarioResultScreen extends StatefulWidget {
  final DiarioState state;

  const DiarioResultScreen({super.key, required this.state});

  @override
  State<DiarioResultScreen> createState() => _DiarioResultScreenState();
}

class _DiarioResultScreenState extends State<DiarioResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fadeAnim;
  bool _reclamado = false;

  @override
  void initState() {
    super.initState();
    _reclamado = widget.state.recompensaReclamada;
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _reclamar() {
    context.read<DiarioCubit>().reclamarRecompensas();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = widget.state.resultado;
    if (resultado == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final color = colorResultadoTrivia(resultado.porcentaje);
    final puedeReclamar =
        widget.state.recompensaPendiente && !_reclamado;

    return BlocListener<DiarioCubit, DiarioState>(
      listenWhen: (prev, curr) =>
          prev.recompensaReclamada != curr.recompensaReclamada,
      listener: (context, state) {
        if (state.recompensaReclamada && !_reclamado) {
          setState(() => _reclamado = true);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final navigator = Navigator.of(context);
            await RecompensaCelebracionSheet.mostrar(
              context,
              xp: resultado.xpGanados,
              monedas: resultado.monedasGanadas,
              rachaNueva: resultado.rachaNueva,
              xpSemana: resultado.xpSemana,
              monedasSemana: resultado.monedasSemana,
              esDiario: true,
            );
            if (mounted) navigator.pop();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resultado diario'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _circulo(
                        porcentaje: resultado.porcentaje,
                        color: color,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        resultado.mensaje,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${resultado.aciertos} de ${resultado.totalPreguntas} respuestas correctas',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStats(context),
                      const SizedBox(height: 16),
                      if (puedeReclamar)
                        _buildRecompensaPendiente(resultado)
                      else
                        RecompensasTrivia(
                          xp: resultado.xpGanados,
                          monedas: resultado.monedasGanadas,
                        ),
                      if (resultado.semanaCompletada) ...[
                        const SizedBox(height: 16),
                        _buildBannerSemana(context, resultado),
                      ],
                      if (resultado.subioDificultad) ...[
                        const SizedBox(height: 12),
                        _buildBannerDificultad(context),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ConfettiWidget(
              show: resultado.porcentaje >= 50 && _reclamado,
              duration: const Duration(milliseconds: 2500),
              particleCount: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecompensaPendiente(ResultadoDiario resultado) {
    final estaReclamando = widget.state.recompensaReclamando;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ecoGreen, AppColors.ecoGreen2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.ecoGreen.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  '¡Recompensa disponible!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '+${resultado.xpGanados} XP  ·  +${resultado.monedasGanadas} Monedas Eco',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (resultado.semanaCompletada) ...[
            const SizedBox(height: 6),
            Text(
              '+${resultado.xpSemana} bonus semana',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: estaReclamando ? null : _reclamar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ecoGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: estaReclamando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.ecoGreen,
                      ),
                    )
                  : const Text(
                      'RECLAMAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circulo({required int porcentaje, required Color color}) {
    final icono = porcentaje >= 80
        ? Icons.emoji_events
        : (porcentaje >= 50 ? Icons.thumb_up : Icons.sentiment_neutral);

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.6), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 44, color: color),
          const SizedBox(height: 4),
          Text(
            '$porcentaje%',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final resultado = widget.state.resultado!;
    final stats = [
      ('Puntos', '${resultado.puntos}', Icons.stars),
      ('Racha', '${resultado.rachaNueva}', Icons.local_fire_department),
      ('Mejor racha', 'x${resultado.mejorRacha}', Icons.emoji_events),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorMintFondo(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 48,
                color: colorMintFuerte(context).withValues(alpha: 0.35),
              ),
            Expanded(
              child: _statCell(
                context,
                icono: stats[i].$3,
                valor: stats[i].$2,
                etiqueta: stats[i].$1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCell(
    BuildContext context, {
    required IconData icono,
    required String valor,
    required String etiqueta,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 20, color: colorMintFuerte(context)),
          const SizedBox(height: 6),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSemana(BuildContext context, ResultadoDiario resultado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.xpGoldLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, color: AppColors.xpGold, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Semana completada!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  '+${resultado.xpSemana} XP y +${resultado.monedasSemana} monedas',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerDificultad(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mintLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.mintStrong.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, color: AppColors.mintStrong, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Subiste de dificultad!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Ahora jugarás ${widget.state.dificultad.etiqueta} en ${widget.state.categoriaNombre}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
