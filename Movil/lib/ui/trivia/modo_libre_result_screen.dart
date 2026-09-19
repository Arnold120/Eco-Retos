import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/confetti_widget.dart';
import 'cubit/modo_libre_cubit.dart';
import 'cubit/modo_libre_state.dart';
import 'widgets/recompensa_celebracion.dart';
import 'widgets/trivia_ui.dart';

/// Pantalla de resultados de Modo Libre con botón RECLAMAR.
class ModoLibreResultScreen extends StatefulWidget {
  const ModoLibreResultScreen({super.key});

  @override
  State<ModoLibreResultScreen> createState() => _ModoLibreResultScreenState();
}

class _ModoLibreResultScreenState extends State<ModoLibreResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fadeAnim;
  bool _reclamado = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ModoLibreCubit>().state;
    final porcentaje = state.porcentajeAciertos;
    final color = colorResultadoTrivia(porcentaje);
    final mensaje = mensajePorcentajeTrivia(porcentaje.toDouble());

    _reclamado = state.recompensaReclamada;
    final puedeReclamar = state.recompensaPendiente && !_reclamado;

    return BlocListener<ModoLibreCubit, ModoLibreState>(
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
              xp: state.xpGanados,
              monedas: state.monedasGanadas,
              puntos: state.puntuacion,
              esDiario: false,
            );
            if (mounted) navigator.pop();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resultado'),
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
                      _circuloResultado(porcentaje, color),
                      const SizedBox(height: 20),
                      Text(
                        mensaje,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${state.respuestasCorrectas} de ${state.totalPreguntas} respuestas correctas',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStats(context, state),
                      const SizedBox(height: 16),
                      if (puedeReclamar)
                        _buildRecompensaPendiente(state)
                      else
                        RecompensasTrivia(
                          xp: state.xpGanados,
                          monedas: state.monedasGanadas,
                        ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.read<ModoLibreCubit>().repetirPartida(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('JUGAR DE NUEVO'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.read<ModoLibreCubit>().irAConfiguracion(),
                          icon: const Icon(Icons.tune),
                          label: const Text('CAMBIAR CATEGORÍA'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ConfettiWidget(
              show: porcentaje >= 50 && _reclamado,
              duration: const Duration(milliseconds: 2500),
              particleCount: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecompensaPendiente(ModoLibreState state) {
    final estaReclamando = state.recompensaReclamando;
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
            '+${state.xpGanados} XP  ·  +${state.monedasGanadas} Monedas Eco',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: estaReclamando
                  ? null
                  : () =>
                      context.read<ModoLibreCubit>().reclamarRecompensas(),
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

  Widget _circuloResultado(int porcentaje, Color color) {
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

  static String _formatoDuracion(Duration duracion) {
    final minutos = duracion.inMinutes.remainder(60);
    final segundos = duracion.inSeconds.remainder(60);
    final ms = duracion.inMilliseconds.remainder(1000) ~/ 10;
    return '$minutos:${segundos.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  Widget _buildStats(BuildContext context, ModoLibreState state) {
    final stats = [
      ('Puntos', '${state.puntuacion}', Icons.stars),
      ('Precisión', '${state.porcentajeAciertos}%', Icons.percent),
      ('Mejor racha', 'x${state.mejorRacha}', Icons.local_fire_department),
      ('Tiempo', _formatoDuracion(state.tiempoTotal), Icons.timer_outlined),
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
}
