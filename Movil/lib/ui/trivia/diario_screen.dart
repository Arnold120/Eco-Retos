import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/trivia/diario_models.dart'
    show kSemanasParaSubirDificultad, inicioSemana, esMismoDia;
import '../../data/repositories/trivias_diario_local.dart';
import '../../data/services/categoria_service.dart';
import '../../data/services/gamification_service.dart';
import '../../data/services/trivia_service.dart' show TriviaService;
import 'cubit/diario_cubit.dart';
import 'cubit/diario_state.dart';
import 'diario_play_screen.dart';
import 'diario_result_screen.dart';
import 'widgets/recompensa_celebracion.dart';
import 'widgets/trivia_ui.dart';

const _nombresDia = [
  '',
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];






class DiarioScreen extends StatefulWidget {
  final int usuarioId;
  final TriviaService triviaService;
  final CategoriaService categoriaService;
  final MonederoService monederoService;
  final ProgresoService progresoService;
  final VoidCallback? onTriviaCompleted;

  const DiarioScreen({
    super.key,
    required this.usuarioId,
    required this.triviaService,
    required this.categoriaService,
    required this.monederoService,
    required this.progresoService,
    this.onTriviaCompleted,
  });

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  late final DiarioCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DiarioCubit(
      usuarioId: widget.usuarioId,
      store: DiarioStore(usuarioId: widget.usuarioId),
      categoriaService: widget.categoriaService,
      triviaService: widget.triviaService,
      monederoService: widget.monederoService,
      progresoService: widget.progresoService,
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
    return BlocProvider<DiarioCubit>.value(
      value: _cubit,
      child: BlocConsumer<DiarioCubit, DiarioState>(
        listener: (context, state) {
          if (state.error != null && state.status != DiarioStatus.error) {
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
            case DiarioStatus.initial:
            case DiarioStatus.loading:
              return const _PantallaCarga();
            case DiarioStatus.ready:
              return _PantallaIntro(state: state);
            case DiarioStatus.questionActive:
            case DiarioStatus.answerSelected:
            case DiarioStatus.answerCorrect:
            case DiarioStatus.answerIncorrect:
            case DiarioStatus.timeExpired:
              return DiarioPlayScreen(state: state);
            case DiarioStatus.completed:
              return DiarioResultScreen(state: state);
            case DiarioStatus.todayDone:
              return _PantallaHoyCompletado(state: state);
            case DiarioStatus.sinPreguntas:
              return _PantallaSinPreguntas(
                onCerrar: () => Navigator.of(context).pop(),
              );
            case DiarioStatus.error:
              return _PantallaError(
                onReintentar: () => context.read<DiarioCubit>().reintentar(),
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
      appBar: AppBar(title: const Text('Trivia diaria')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparando la trivia de hoy...'),
          ],
        ),
      ),
    );
  }
}

class _PantallaIntro extends StatelessWidget {
  final DiarioState state;

  const _PantallaIntro({required this.state});

  @override
  Widget build(BuildContext context) {
    final nombreDia = _nombresDia[state.hoy.weekday];
    final semanasRestantes =
        kSemanasParaSubirDificultad - state.semanasCompletadasConsecutivas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia diaria'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, valor, child) => Opacity(
          opacity: valor,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - valor)),
            child: child,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tarjetaDia(context),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _chipRacha(
                      context,
                      icono: Icons.local_fire_department,
                      color: AppColors.streakFire,
                      texto: 'Racha ${state.rachaEfectiva}🔥',
                    ),
                    const SizedBox(width: 8),
                    _chipRacha(
                      context,
                      icono: Icons.calendar_today_outlined,
                      color: AppColors.mintStrong,
                      texto: '${state.diasCompletadosSemana}/7 de la semana',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _progresoSemanal(context),
                const SizedBox(height: 20),
                _tarjetaDificultad(context, semanasRestantes),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.read<DiarioCubit>().comenzarPartida(),
                    icon: Icon(
                      state.reanudando ? Icons.play_arrow : Icons.eco,
                    ),
                    label: Text(
                      state.reanudando ? 'CONTINUAR' : 'EMPIEZA EL RETO',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '3 preguntas · 30 segundos cada una · $nombreDia',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaDia(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorTriviaPrincipal(context),
            colorTriviaSecundario(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorTriviaPrincipal(context).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.today, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'LA TRIVIA DE HOY ES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.categoriaNombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _nombresDia[state.hoy.weekday],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progresoSemanal(BuildContext context) {
    const iniciales = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final inicio = inicioSemana(state.hoy);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorMintFondo(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de la semana',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              Text(
                '${state.diasCompletadosSemana}/7',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colorTriviaPrincipal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++) ...[
                _diaSemana(
                  context,
                  inicial: iniciales[i],
                  completado:
                      state.progreso.sesionDeDia(inicio.add(Duration(days: i)))
                              ?.completada ??
                          false,
                  esHoy: esMismoDia(inicio.add(Duration(days: i)), state.hoy),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: state.diasCompletadosSemana / 7,
              minHeight: 8,
              backgroundColor:
                  colorTriviaPrincipal(context).withValues(alpha: 0.18),
              valueColor:
                  AlwaysStoppedAnimation<Color>(colorTriviaPrincipal(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _diaSemana(
    BuildContext context, {
    required String inicial,
    required bool completado,
    required bool esHoy,
  }) {


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completado
                    ? colorTriviaPrincipal(context)
                    : AppColors.textHint.withValues(alpha: 0.12),
                border: Border.all(
                  color: esHoy
                      ? colorTriviaSecundario(context)
                      : Colors.transparent,
                  width: 2.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                inicial,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: completado ? Colors.white : AppColors.textHint,
                ),
              ),
            ),
            if (completado)
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorTriviaPrincipal(context),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tarjetaDificultad(BuildContext context, int semanasRestantes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up,
                  size: 18, color: AppColors.mintStrong),
              const SizedBox(width: 6),
              Text(
                'Dificultad: ${state.dificultad.etiqueta}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            semanasRestantes > 0
                ? 'Completa $semanasRestantes semana(s) seguidas para subir'
                : '¡Listo para subir de dificultad!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipRacha(
    BuildContext context, {
    required IconData icono,
    required Color color,
    required String texto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PantallaHoyCompletado extends StatefulWidget {
  final DiarioState state;

  const _PantallaHoyCompletado({required this.state});

  @override
  State<_PantallaHoyCompletado> createState() => _PantallaHoyCompletadoState();
}

class _PantallaHoyCompletadoState extends State<_PantallaHoyCompletado> {
  bool _reclamado = false;

  @override
  void initState() {
    super.initState();
    _reclamado = widget.state.recompensaReclamada;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final puedeReclamar = state.recompensaPendiente && !_reclamado;
    final xp = state.resultado?.xpGanados;
    final monedas = state.resultado?.monedasGanadas;

    return BlocListener<DiarioCubit, DiarioState>(
      listenWhen: (prev, curr) =>
          prev.recompensaReclamada != curr.recompensaReclamada,
      listener: (context, cuState) {
        if (cuState.recompensaReclamada && !_reclamado) {
          setState(() => _reclamado = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && xp != null && monedas != null) {
              RecompensaCelebracionSheet.mostrar(
                context,
                xp: xp,
                monedas: monedas,
                rachaNueva: cuState.rachaEfectiva,
                xpSemana: cuState.resultado?.xpSemana,
                monedasSemana: cuState.resultado?.monedasSemana,
                esDiario: true,
              );
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trivia diaria'),
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
                Icon(Icons.verified,
                    size: 80, color: colorTriviaPrincipal(context)),
                const SizedBox(height: 16),
                const Text(
                  '¡Hoy ya la completaste!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Racha actual: ${state.rachaEfectiva} 🔥\n${state.diasCompletadosSemana} de 7 días esta semana',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (puedeReclamar) ...[
                  const SizedBox(height: 24),
                  _recompensaPendiente(context),
                ] else if (_reclamado) ...[
                  const SizedBox(height: 24),
                  _recompensaReclamada(),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('VOLVER'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recompensaPendiente(BuildContext context) {
    final estaReclamando = widget.state.recompensaReclamando;
    final resultado = widget.state.resultado;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorTriviaPrincipal(context),
            colorTriviaSecundario(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorTriviaPrincipal(context).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎁 ¡Tienes una recompensa por reclamar!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '+${resultado?.xpGanados ?? 0} XP  ·  +${resultado?.monedasGanadas ?? 0} Monedas Eco',
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
                      context.read<DiarioCubit>().reclamarRecompensas(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorTriviaPrincipal(context),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: estaReclamando
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorTriviaPrincipal(context),
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

  Widget _recompensaReclamada() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorTriviaSecundario(context).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorTriviaSecundario(context).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle,
              color: colorTriviaPrincipal(context), size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Recompensa reclamada',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorTriviaPrincipal(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PantallaSinPreguntas extends StatelessWidget {
  final VoidCallback onCerrar;

  const _PantallaSinPreguntas({required this.onCerrar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia diaria')),
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
                'Hoy no hay preguntas disponibles',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vuelve más tarde o prueba el Modo Libre.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCerrar,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
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
        title: const Text('Trivia diaria'),
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
                'No pudimos cargar la trivia diaria. Revisa tu conexión e inténtalo de nuevo.',
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