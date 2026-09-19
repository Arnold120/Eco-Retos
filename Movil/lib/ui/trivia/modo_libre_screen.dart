import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/trivia_recompensa_local.dart';
import '../../data/services/categoria_service.dart';
import '../../data/services/gamification_service.dart';
import '../../data/services/trivia_service.dart' show TriviaService;
import 'cubit/modo_libre_cubit.dart';
import 'cubit/modo_libre_state.dart';
import 'modo_libre_config_screen.dart';
import 'modo_libre_play_screen.dart';
import 'modo_libre_result_screen.dart';









class ModoLibreScreen extends StatefulWidget {
  final int usuarioId;
  final TriviaService triviaService;
  final CategoriaService categoriaService;
  final MonederoService monederoService;
  final ProgresoService progresoService;
  final VoidCallback? onTriviaCompleted;

  const ModoLibreScreen({
    super.key,
    required this.usuarioId,
    required this.triviaService,
    required this.categoriaService,
    required this.monederoService,
    required this.progresoService,
    this.onTriviaCompleted,
  });

  @override
  State<ModoLibreScreen> createState() => _ModoLibreScreenState();
}

class _ModoLibreScreenState extends State<ModoLibreScreen> {
  late final ModoLibreCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ModoLibreCubit(
      usuarioId: widget.usuarioId,
      categoriaService: widget.categoriaService,
      triviaService: widget.triviaService,
      monederoService: widget.monederoService,
      progresoService: widget.progresoService,
      recompensaStore: RecompensaLibreStore(usuarioId: widget.usuarioId),
      onTriviaCompleted: widget.onTriviaCompleted,
    )..iniciar();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ModoLibreCubit>.value(
      value: _cubit,
      child: BlocConsumer<ModoLibreCubit, ModoLibreState>(
        listener: (context, state) {
          if (state.error != null && state.status != ModoLibreStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case ModoLibreStatus.cargando:
              return const _PantallaCarga();
            case ModoLibreStatus.configurando:
              return const ModoLibreConfigScreen();
            case ModoLibreStatus.jugando:
            case ModoLibreStatus.retroalimentacion:
              return const ModoLibrePlayScreen();
            case ModoLibreStatus.resultados:
              return const ModoLibreResultScreen();
            case ModoLibreStatus.sinPreguntas:
              return _PantallaSinPreguntas(
                onReintentar: () {
                  context.read<ModoLibreCubit>().irAConfiguracion();
                },
              );
            case ModoLibreStatus.error:
              return _PantallaError(
                onReintentar: () {
                  context.read<ModoLibreCubit>().reintentar();
                },
              );
          }
        },
      ),
    );
  }
}

class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo libre')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparando tus preguntas...'),
          ],
        ),
      ),
    );
  }
}

class _PantallaSinPreguntas extends StatelessWidget {
  final VoidCallback onReintentar;

  const _PantallaSinPreguntas({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo libre'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
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
              const Text(
                'Prueba cambiando la configuración o vuelve más tarde',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.tune),
                label: const Text('Cambiar configuración'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantallaError extends StatelessWidget {
  final VoidCallback onReintentar;

  const _PantallaError({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo libre'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 72,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ups, algo salió mal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'No pudimos cargar la trivia. Revisa tu conexión e inténtalo de nuevo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
