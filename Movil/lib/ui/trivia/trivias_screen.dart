import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/trivia_recompensa_local.dart';
import '../../data/repositories/trivias_diario_local.dart';
import '../../data/services/categoria_service.dart';
import '../../data/services/gamification_service.dart';
import '../../data/services/trivia_service.dart' show TriviaService;
import '../home/cubit/home_cubit.dart';
import '../profile/cubit/profile_cubit.dart';
import '../widgets/global_header_actions.dart';
import '../widgets/loading_widget.dart';
import 'cubit/trivias_cubit.dart';
import 'cubit/trivias_state.dart';
import 'diario_screen.dart';
import 'modo_libre_screen.dart';
import 'widgets/recompensa_celebracion.dart';
import 'widgets/trivia_ui.dart';

/// Pantalla principal de trivias: acceso a Modo Libre y Modo Diario, junto con
/// el progreso semanal de la trivia diaria.
///
/// Es un [StatefulWidget] que POSEE el [TriviasCubit]: lo crea, lo provee con
/// [BlocProvider.value] y lo cierra al salir. Idéntico patrón autocontenido
/// que el resto de las pantallas de trivia.
class TriviasScreen extends StatefulWidget {
  final int usuarioId;
  final VoidCallback? onMenuTap;

  const TriviasScreen({super.key, required this.usuarioId, this.onMenuTap});

  @override
  State<TriviasScreen> createState() => _TriviasScreenState();
}

class _TriviasScreenState extends State<TriviasScreen> {
  late final TriviasCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TriviasCubit(
      usuarioId: widget.usuarioId,
      store: DiarioStore(usuarioId: widget.usuarioId),
      categoriaService: context.read<CategoriaService>(),
      monederoService: context.read<MonederoService>(),
      progresoService: context.read<ProgresoService>(),
      recompensaStore: RecompensaLibreStore(usuarioId: widget.usuarioId),
    )..cargar();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _recargarAlVolver() async {
    if (!mounted) return;
    _cubit.cargar();
    context.read<ProfileCubit>().refresh();
    context.read<HomeCubit>().refresh();
  }

  void _refrescarInicioYPerfil() {
    if (mounted) context.read<ProfileCubit>().refresh();
    if (mounted) context.read<HomeCubit>().refresh();
  }

  void _abrirModoLibre(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModoLibreScreen(
          usuarioId: widget.usuarioId,
          triviaService: context.read<TriviaService>(),
          categoriaService: context.read<CategoriaService>(),
          monederoService: context.read<MonederoService>(),
          progresoService: context.read<ProgresoService>(),
          onTriviaCompleted: _refrescarInicioYPerfil,
        ),
      ),
    );
    await _recargarAlVolver();
  }

  void _abrirModoDiario(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiarioScreen(
          usuarioId: widget.usuarioId,
          triviaService: context.read<TriviaService>(),
          categoriaService: context.read<CategoriaService>(),
          monederoService: context.read<MonederoService>(),
          progresoService: context.read<ProgresoService>(),
          onTriviaCompleted: _refrescarInicioYPerfil,
        ),
      ),
    );
    await _recargarAlVolver();
  }

  Future<void> _reclamarRecompensaLibre(BuildContext context) async {
    final cubit = context.read<TriviasCubit>();
    final recompensa = cubit.state.recompensaLibre;
    if (recompensa == null || !recompensa.pendiente) return;
    final ok = await cubit.reclamarRecompensaLibre();
    if (!ok || !context.mounted) return;
    _refrescarInicioYPerfil();
    await RecompensaCelebracionSheet.mostrar(
      context,
      xp: recompensa.xp,
      monedas: recompensa.monedas,
      puntos: recompensa.puntos,
      esDiario: false,
      titulo: '¡Recompensa reclamada!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TriviasCubit>.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.onMenuTap,
          ),
          title: const Text('Trivia Eco'),
          actions: const [GlobalHeaderActions()],
        ),
        body: BlocBuilder<TriviasCubit, TriviasState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget(message: 'Cargando trivias...');
            }
            if (state.status == TriviasStatus.error && state.error != null) {
              return _PantallaError(
                mensaje: state.error!,
                onReintentar: () => context.read<TriviasCubit>().cargar(),
              );
            }
            if (state.status != TriviasStatus.listo) {
              return const LoadingWidget(message: 'Cargando trivias...');
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.cargar(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsRow(state),
                  const SizedBox(height: 20),
                  if (state.hayRecompensaLibrePendiente) ...[
                    _buildRecompensaPendienteBanner(context, state),
                    const SizedBox(height: 16),
                  ],
                  _buildSemana(state),
                  const SizedBox(height: 24),
                  _buildModoLibreCard(context),
                  const SizedBox(height: 16),
                  _buildModoDiarioCard(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(TriviasState state) {
    return Row(
      children: [
        _statTile(
          icono: Icons.local_fire_department,
          color: AppColors.streakFire,
          valor: '${state.racha}',
          etiqueta: 'Racha',
        ),
        const SizedBox(width: 10),
        _statTile(
          icono: Icons.emoji_events,
          color: AppColors.levelPurple,
          valor: '${state.mejorRacha}',
          etiqueta: 'Mejor racha',
        ),
        const SizedBox(width: 10),
        _statTile(
          icono: Icons.monetization_on,
          color: AppColors.coinGold,
          valor: '${state.monedasDisponibles}',
          etiqueta: 'Monedas',
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icono,
    required Color color,
    required String valor,
    required String etiqueta,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icono, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecompensaPendienteBanner(
    BuildContext context,
    TriviasState state,
  ) {
    final recompensa = state.recompensaLibre!;
    final reclamando = state.recompensaReclamando;
    return _entradaAnimada(
      index: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.ecoGold, Color(0xFFFF9E3D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.ecoGold.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.redeem,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Recompensa sin reclamar!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${recompensa.xp} XP · +${recompensa.monedas} 🪙 '
                    'de tu última partida.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ecoGold,
              ),
              onPressed: reclamando
                  ? null
                  : () => _reclamarRecompensaLibre(context),
              child: Text(reclamando ? '...' : 'RECLAMAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemana(TriviasState state) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    // En modo claro la tarjeta se pinta blanca con letras negras, al estilo
    // de la tarjeta de Modo Libre; en oscuro conserva el verde actual.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esOscuro
            ? const Color.fromARGB(255, 46, 125, 91)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esOscuro
              ? const Color.fromARGB(255, 22, 64, 0)
              : AppColors.border,
        ),
        boxShadow: esOscuro
            ? null
            : const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: esOscuro
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trivia diaria de la semana',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: esOscuro ? null : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                state.progresoSemanaTexto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: esOscuro
                      ? const Color.fromARGB(255, 250, 249, 249)
                      : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final dia in state.semana)
                Expanded(
                  child: _diaSemana(dia, state.semanaCompletada),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _diaSemana(DiaSemanaTrivia dia, bool semanaCompletada) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final completado = dia.completado || (semanaCompletada && dia.esHoy);
    final esHoy = dia.esHoy;

    final Color color = completado
        ? AppColors.success
        : (esHoy
              ? (esOscuro
                    ? const Color.fromARGB(255, 255, 208, 1)
                    : AppColors.primary)
              : const Color.fromARGB(255, 229, 220, 220));

    // En modo claro el día de hoy se pinta blanco con letras negras; en
    // oscuro conserva el gris con acento amarillo.
    final Color colorFondo = completado
        ? const Color.fromARGB(255, 0, 0, 0)
        : (esHoy
              ? (esOscuro
                    ? const Color.fromARGB(255, 184, 184, 184)
                    : Colors.white)
              : AppColors.surfaceDim);

    final Color colorTexto = esHoy
        ? (esOscuro ? AppColors.primary : AppColors.textPrimary)
        : AppColors.textSecondary;

    final resaltarHoy = esHoy && !completado;

    return Tooltip(
      message: '${dia.categoriaNombre}${completado ? ' · completado' : ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorFondo,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: completado ? 2 : (esHoy ? 2.5 : 1),
              ),
              boxShadow: resaltarHoy
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: esOscuro ? 0.65 : 0.45),
                        blurRadius: esOscuro ? 14 : 10,
                        spreadRadius: esOscuro ? 1.5 : 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: completado
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      dia.inicial,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colorTexto,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dia.inicial,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModoLibreCard(BuildContext context) {
    return _entradaAnimada(
      index: 2,
      child: _modoCard(
        context,
        icono: Icons.quiz_outlined,
        colorPrincipal: colorTriviaPrincipal(context),
        colorSecundario: colorTriviaSecundario(context),
        titulo: 'MODO LIBRE',
        descripcion:
            'Elige categoría y dificultad y juega las veces que quieras.\n'
            'Gana XP y Monedas Eco por tus respuestas.',
        etiquetas: const ['+XP', '+Monedas', '🌿 Recompensas'],
        botonTexto: 'Jugar ahora',
        onIniciar: () => _abrirModoLibre(context),
        varianteClara: true,
      ),
    );
  }

  Widget _buildModoDiarioCard(BuildContext context, TriviasState state) {
    DiaSemanaTrivia? diaHoy;
    var hoyCompletado = false;
    for (final dia in state.semana) {
      if (dia.esHoy) {
        diaHoy = dia;
        hoyCompletado = dia.completado;
      }
    }
    final categoriaHoy = diaHoy?.categoriaNombre ?? 'Categoría de hoy';
    final diasCompletados = state.diasCompletados;
    final progresoSemana = (diasCompletados / 7).clamp(0.0, 1.0);

    return _entradaAnimada(
      index: 3,
      child: _modoCard(
        context,
        icono: Icons.edit_calendar_outlined,
        colorPrincipal: colorTriviaSecundario(context),
        colorSecundario: colorTriviaPrincipal(context),
        titulo: 'RETO DE HOY',
        descripcion: 'Hoy: $categoriaHoy\n'
            '3 preguntas · Sube de dificultad cada 3 semanas.',
        etiquetas: const ['Racha 🔥', '+100 XP semana'],
        botonTexto: hoyCompletado ? 'Completado ✓' : 'Jugar hoy',
        botonDeshabilitado: hoyCompletado,
        onIniciar: hoyCompletado ? null : () => _abrirModoDiario(context),
        barraProgreso: progresoSemana,
        etiquetaBarra: '$diasCompletados/7 días esta semana',
        varianteClara: true,
      ),
    );
  }

  Widget _modoCard(
    BuildContext context, {
    required IconData icono,
    required Color colorPrincipal,
    required Color colorSecundario,
    required String titulo,
    required String descripcion,
    required List<String> etiquetas,
    required String botonTexto,
    VoidCallback? onIniciar,
    bool botonDeshabilitado = false,
    double barraProgreso = 0.0,
    String? etiquetaBarra,
    bool varianteClara = false,
  }) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondoClaro = varianteClara && !esOscuro;

    final Color colorTitulo =
        fondoClaro ? AppColors.textPrimary : Colors.white;
    final Color colorDescripcion =
        fondoClaro ? AppColors.textSecondary : Colors.white;
    final Color colorAcento = fondoClaro ? AppColors.primary : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: fondoClaro
            ? null
            : LinearGradient(
                colors: [colorPrincipal, colorSecundario],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: fondoClaro ? AppColors.surface : null,
        border: fondoClaro ? Border.all(color: AppColors.border) : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: fondoClaro
                ? AppColors.cardShadow
                : colorPrincipal.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorAcento.withValues(
                    alpha: fondoClaro ? 0.12 : 0.18,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: colorAcento, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: colorTitulo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colorDescripcion,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final etiqueta in etiquetas)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorAcento.withValues(
                      alpha: fondoClaro ? 0.10 : 0.16,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fondoClaro ? AppColors.primaryDark : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (barraProgreso > 0 && !botonDeshabilitado) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: barraProgreso,
                backgroundColor: colorAcento.withValues(
                  alpha: fondoClaro ? 0.15 : 0.22,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  fondoClaro ? AppColors.primary : Colors.white,
                ),
                minHeight: 8,
              ),
            ),
            if (etiquetaBarra != null) ...[
              const SizedBox(height: 6),
              Text(
                etiquetaBarra,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fondoClaro
                      ? AppColors.textSecondary
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                    fondoClaro ? AppColors.primary : Colors.white,
                foregroundColor: fondoClaro ? Colors.white : colorPrincipal,
                disabledBackgroundColor: fondoClaro
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.5),
                disabledForegroundColor: fondoClaro
                    ? Colors.white.withValues(alpha: 0.9)
                    : colorPrincipal.withValues(alpha: 0.6),
              ),
              onPressed: botonDeshabilitado ? null : onIniciar,
              icon: Icon(
                botonDeshabilitado ? Icons.check : Icons.play_arrow,
                size: 20,
              ),
              label: Text(botonTexto,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  /// Envuelve a cada tarjeta con una animación de entrada tipo slide+fade
  /// escalonada.
  Widget _entradaAnimada({
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: child,
          ),
        );
      },
    );
  }
}

class _PantallaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _PantallaError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'Ups, algo salió mal',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}