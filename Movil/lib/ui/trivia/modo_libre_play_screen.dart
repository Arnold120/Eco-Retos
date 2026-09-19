import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import 'cubit/modo_libre_cubit.dart';
import 'cubit/modo_libre_state.dart';
import 'widgets/trivia_ui.dart';



class ModoLibrePlayScreen extends StatelessWidget {
  const ModoLibrePlayScreen({super.key});

  static const _letras = ['A', 'B', 'C', 'D'];

  TriviaOpcionEstado _estadoDe(String letra, ModoLibreState state) {
    if (state.status == ModoLibreStatus.retroalimentacion) {
      if (state.preguntaActual?.esLetraCorrecta(letra) ?? false) {
        return TriviaOpcionEstado.correcta;
      }
      if (state.opcionSeleccionada == letra) return TriviaOpcionEstado.incorrecta;
      return TriviaOpcionEstado.normal;
    }
    if (state.opcionesEliminadas.contains(letra)) {
      return TriviaOpcionEstado.eliminada;
    }
    return TriviaOpcionEstado.normal;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ModoLibreCubit>().state;
    final pregunta = state.preguntaActual;

    if (pregunta == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showFeedback = state.status == ModoLibreStatus.retroalimentacion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmarSalida(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modo libre'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmarSalida(context),
          ),
        ),
        body: Column(
          children: [
            _buildBarraSuperior(state),
            LinearProgressIndicator(
              value: state.progreso,
              backgroundColor: AppColors.border.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChips(context, state),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey('pregunta_${pregunta.triviaId}'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pregunta.pregunta,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 22),
                          for (final letra in _letras)
                            TriviaOpcionButton(
                              letra: letra,
                              texto: pregunta.opciones[letra] ?? '',
                              estado: _estadoDe(letra, state),
                              onTap: showFeedback
                                  ? null
                                  : () => context
                                      .read<ModoLibreCubit>()
                                      .seleccionarOpcion(letra),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!showFeedback) _buildAyudas(context, state),
            if (showFeedback) _buildPanelFeedback(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildAyudas(BuildContext context, ModoLibreState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AyudasTriviaBar(
          monedasDisponibles: state.monedasDisponibles,
          permitirSaltar: true,
          habilitadas: state.status == ModoLibreStatus.jugando,
          onSeleccionada: (ayuda) =>
              context.read<ModoLibreCubit>().usarAyuda(ayuda),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildBarraSuperior(ModoLibreState state) {
    final tieneTiempo =
        state.status == ModoLibreStatus.jugando &&
        state.config.tiempoPorPregunta != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            'Pregunta ${state.preguntaActualIndex + 1} de ${state.totalPreguntas}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          const _ScoreTexto(),
          const SizedBox(width: 8),
          const _MonedasTexto(),
          if (tieneTiempo) ...[
            const SizedBox(width: 8),
            TemporizadorTrivia(
              restante: state.tiempoRestante ?? Duration.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChips(BuildContext context, ModoLibreState state) {
    final pregunta = state.preguntaActual;
    if (pregunta == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChipTrivia(
          icono: Icons.category_outlined,
          texto: state.nombreCategoriaActual,
        ),
        ChipTrivia(icono: Icons.speed, texto: state.nombreDificultadActual),
        ChipTrivia(
          icono: Icons.star_outline,
          texto: '+${pregunta.puntos} XP',
        ),
        if (state.rachaActual >= 2)
          ChipTrivia(
            icono: Icons.local_fire_department,
            texto: 'Racha x${state.rachaActual}',
            color: AppColors.streakFire,
          ),
      ],
    );
  }

  Widget _buildPanelFeedback(BuildContext context, ModoLibreState state) {
    void terminar() => context.read<ModoLibreCubit>().siguienteRespuesta();

    if (state.saltada) {
      return PanelFeedbackTrivia(
        esCorrecta: false,
        tiempoAgotado: false,
        titulo: 'Pregunta saltada',
        icono: Icons.skip_next,
        respuestaCorrectaTexto: state.respuestaCorrectaTexto,
        etiquetaPuntos: 'Puntos: ${state.puntuacion}',
        onContinuar: terminar,
      );
    }

    final chips = <Widget>[];
    if (state.esCorrecta) {
      chips.add(
        ChipTrivia(
          icono: Icons.eco,
          texto: '+${state.puntosGanadosPregunta} XP',
        ),
      );
      if (state.bonusRapidez > 0) {
        chips.add(
          ChipTrivia(
            icono: Icons.bolt,
            texto: '+${state.bonusRapidez} velocidad',
            color: AppColors.info,
          ),
        );
      }
      if (state.rachaActual >= 2) {
        chips.add(
          ChipTrivia(
            icono: Icons.local_fire_department,
            texto: 'Racha x${state.rachaActual}',
            color: AppColors.streakFire,
          ),
        );
      }
    }

    return PanelFeedbackTrivia(
      esCorrecta: state.esCorrecta,
      tiempoAgotado: state.tiempoAgotado,
      respuestaCorrectaTexto: state.respuestaCorrectaTexto,
      etiquetaPuntos: 'Puntos: ${state.puntuacion}',
      chips: chips.isEmpty ? null : chips,
      onContinuar: terminar,
    );
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del modo libre?'),
        content: const Text('Perderás tu progreso actual en esta partida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (salir == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}


class _ScoreTexto extends StatelessWidget {
  const _ScoreTexto();

  @override
  Widget build(BuildContext context) {
    final puntos = context.select(
      (ModoLibreCubit cubit) => cubit.state.puntuacion,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mintStrong.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco, size: 16, color: AppColors.mintStrong),
          const SizedBox(width: 4),
          Text(
            '$puntos',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.mintStrong,
            ),
          ),
        ],
      ),
    );
  }
}


class _MonedasTexto extends StatelessWidget {
  const _MonedasTexto();

  @override
  Widget build(BuildContext context) {
    final monedas = context.select(
      (ModoLibreCubit cubit) => cubit.state.monedasDisponibles,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.coinGoldLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            size: 16,
            color: AppColors.coinGold,
          ),
          const SizedBox(width: 4),
          Text(
            '$monedas',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.coinGold,
            ),
          ),
        ],
      ),
    );
  }
}