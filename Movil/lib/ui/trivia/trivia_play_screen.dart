import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/trivia/trivia_models.dart';
import '../widgets/confetti_widget.dart';
import 'cubit/trivia_cubit.dart';
import 'cubit/trivia_state.dart';

class TriviaPlayScreen extends StatelessWidget {



  final TriviaCubit? cubit;

  const TriviaPlayScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    final contenido = BlocConsumer<TriviaCubit, TriviaState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.mode == TriviaScreenMode.results) {
          return _buildResults(context, state);
        }
        if (state.showingFeedback) {
          return _buildFeedback(context, state);
        }
        return _buildQuestion(context, state);
      },
    );
    final cubit = this.cubit;
    if (cubit == null) return contenido;
    return BlocProvider<TriviaCubit>.value(value: cubit, child: contenido);
  }

  Widget _buildQuestion(BuildContext context, TriviaState state) {
    final pregunta = state.preguntaActual;
    if (pregunta == null) {
      if (state.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return _buildSinPreguntas(context, state);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.triviaActual?.titulo ?? 'Trivia'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(state),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pregunta ${state.preguntaActualIndex + 1} de ${state.totalPreguntas}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _mintFuerte(context).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${pregunta.puntos} XP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _mintFuerte(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    pregunta.preguntaTexto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...pregunta.opciones.map(
                    (opcion) => _buildOpcion(
                      context,
                      opcion.opcionId,
                      opcion.textoOpcion,
                      state.opcionSeleccionada == opcion.opcionId,
                      pregunta,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildConfirmButton(context, state),
        ],
      ),
    );
  }

  Widget _buildSinPreguntas(BuildContext context, TriviaState state) {
    final mensaje =
        state.error ?? 'Esta trivia no tiene preguntas disponibles.';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _volverALista(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 72,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay preguntas disponibles',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (state.triviaActual != null) ...[
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.read<TriviaCubit>().iniciarTrivia(
                      state.triviaActual!,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.tonalIcon(
                onPressed: () => _volverALista(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a Trivia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _volverALista(BuildContext context) {
    context.read<TriviaCubit>().volverALista();
    Navigator.of(context).pop();
  }

  Widget _buildProgressBar(TriviaState state) {
    final progress = (state.preguntaActualIndex + 1) / state.totalPreguntas;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildOpcion(
    BuildContext context,
    int opcionId,
    String texto,
    bool isSelected,
    PreguntaResponse pregunta,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          context.read<TriviaCubit>().seleccionarOpcion(
            opcionId,
            pregunta.opciones
                .firstWhere((o) => o.opcionId == opcionId)
                .esCorrecta,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryDark.withValues(alpha: 0.6)
                : Theme.of(context).brightness == Brightness.dark
                ? AppColorsDark.surfaceCard
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.tertiary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiary : AppColors.surfaceDim,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primaryDark,
                          size: 18,
                        )
                      : Text(
                          String.fromCharCode(
                            65 +
                                pregunta.opciones.indexOf(
                                  pregunta.opciones.firstWhere(
                                    (o) => o.opcionId == opcionId,
                                  ),
                                ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, TriviaState state) {
    final hasSelection = state.opcionSeleccionada != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSelection
                ? () => context.read<TriviaCubit>().confirmarRespuesta()
                : null,
            child: Text(state.esUltimaPregunta ? 'Finalizar' : 'Siguiente'),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(BuildContext context, TriviaState state) {
    final isCorrect = state.ultimaRespuestaCorrecta ?? false;
    final pregunta = state.preguntaActual;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isCorrect ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 64,
                  color: isCorrect ? Colors.white : AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isCorrect ? '¡Respuesta correcta!' : 'Respuesta incorrecta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isCorrect ? Colors.white : AppColors.error,
                ),
              ),
              if (isCorrect) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _mintFuerte(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${pregunta?.puntos ?? 0} XP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _mintFuerte(context),
                    ),
                  ),
                ),
              ],
              if (!isCorrect) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'La respuesta correcta era:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.respuestaCorrectaTexto ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                isCorrect
                    ? '¡Excelente trabajo! Sigue así.'
                    : 'No te preocupes, aprendiste algo nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColorsDark.textSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<TriviaCubit>().siguientePregunta();
                  },
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, TriviaState state) {
    final porcentaje = state.totalPreguntas > 0
        ? (state.respuestasCorrectas / state.totalPreguntas * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<TriviaCubit>().volverALista();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getResultColor(porcentaje).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getResultIcon(porcentaje),
                            size: 48,
                            color: porcentaje >= 80
                                ? Colors.white
                                : _getResultColor(porcentaje),
                          ),
                          Text(
                            '$porcentaje%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: porcentaje >= 80
                                  ? Colors.white
                                  : _getResultColor(porcentaje),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getResultMessage(porcentaje),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${state.respuestasCorrectas} de ${state.totalPreguntas} respuestas correctas',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _mintFondo(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.eco,
                              color: _mintFuerte(context),
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.xpGanados}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _mintFuerte(context),
                              ),
                            ),
                            Text(
                              'XP',
                              style: TextStyle(
                                fontSize: 13,
                                color: _mintTexto(context),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: _mintFuerte(context).withValues(alpha: 0.4),
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 28,
                              color: AppColors.coinGold,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.monedasGanadas}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _mintFuerte(context),
                              ),
                            ),
                            Text(
                              'Monedas',
                              style: TextStyle(
                                fontSize: 13,
                                color: _mintTexto(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TriviaCubit>().volverALista();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Volver a Trivia'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            show: porcentaje >= 50,
            duration: const Duration(milliseconds: 2500),
          ),
        ],
      ),
    );
  }

  Color _getResultColor(int porcentaje) {
    if (porcentaje >= 80) return AppColors.success;
    if (porcentaje >= 50) return AppColors.mintStrong;
    return AppColors.error;
  }

  static Color _mintFondo(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColorsDark.mintSoft
      : AppColors.mintSoft;

  static Color _mintFuerte(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColorsDark.mintStrong
      : AppColors.mintStrong;

  static Color _mintTexto(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColorsDark.textPrimary
      : AppColors.primaryDark;

  IconData _getResultIcon(int porcentaje) {
    if (porcentaje >= 80) return Icons.emoji_events;
    if (porcentaje >= 50) return Icons.thumb_up;
    return Icons.sentiment_neutral;
  }

  String _getResultMessage(int porcentaje) {
    if (porcentaje >= 80) return '¡Excelente!';
    if (porcentaje >= 50) return '¡Bien hecho!';
    return 'Sigue practicando';
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la trivia?'),
        content: const Text('Perderás tu progreso actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TriviaCubit>().volverALista();
              Navigator.of(context).pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
