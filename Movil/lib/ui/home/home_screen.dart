import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalogos/retos/reto_model.dart';
import '../../data/catalogos/retos/retos_catalogo.dart';
import '../../data/models/social/social_models.dart';
import '../../core/utils/media_url.dart';
import '../challenges/challenge_list_screen.dart';
import '../trivia/trivias_screen.dart';
import '../widgets/stat_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as eco;
import '../widgets/global_header_actions.dart';
import '../../data/services/gamification_service.dart';
import '../garden/garden_screen.dart';
import '../garden/cubit/garden_cubit.dart';
import '../shop/shop_screen.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  final int usuarioId;
  final String nombreUsuario;
  final VoidCallback? onMenuTap;
  final VoidCallback? onGotoRetos;

  const HomeScreen({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
    this.onMenuTap,
    this.onGotoRetos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap),
        title: const Text('Eco Retos'),
        actions: const [GlobalHeaderActions()],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget(message: 'Cargando tu dashboard...');
          }
          if (state.error != null) {
            return eco.ErrorWidget(
              message: state.error!,
              actionLabel: 'Reintentar',
              onAction: () => context.read<HomeCubit>().refresh(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(state, context),
                  _buildStatsGrid(state),
                  _buildLevelProgress(state),
                  _buildRetoDelDia(context),
                  _buildQuickActions(context),
                  _buildRetosRecientes(context, state),
                  _buildMuroPreview(context, state),
                  _buildGardenPreview(context, state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(HomeState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColorsDark.tertiary, AppColorsDark.primary]
              : [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            state.nombreUsuario.isNotEmpty ? state.nombreUsuario : 'Estudiante',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (state.progreso != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nivel ${state.progreso!.nivelActual}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelProgress(HomeState state) {
    if (state.progreso == null) return const SizedBox.shrink();
    final progreso = state.progreso!;
    final xpActual = (progreso.porcentajeProgreso * 100).toInt();
    final xpMaximo = 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nivel ${progreso.nivelActual}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '$xpActual / $xpMaximo XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.xpGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progreso.porcentajeProgreso / 100,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.xpGold,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Continúa participando para subir de nivel.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(HomeState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.monetization_on,
                  label: 'Monedas Eco',
                  value: '${state.monedas}',
                  iconColor: AppColors.xpGold,
                  valueColor: AppColors.xpGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Racha',
                  value: '${state.rachaActual} días',
                  iconColor: AppColors.streakFire,
                  valueColor: AppColors.streakFire,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.emoji_events,
                  label: 'Retos',
                  value: '${state.progreso?.retosCompletados ?? 0}',
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.quiz,
                  label: 'Trivias',
                  value: '${state.progreso?.triviasCompletadas ?? 0}',
                  iconColor: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos rápidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickAction(
                context,
                icon: Icons.park,
                label: 'Jardín',
                color: AppColors.gardenGreen,
                foregroundColor: Colors.white,
                onTap: () => _abrirJardin(context),
              ),
              const SizedBox(width: 10),
              _buildQuickAction(
                context,
                icon: Icons.store,
                label: 'Tienda',
                color: AppColors.xpGold,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShopScreen(usuarioId: usuarioId),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildQuickAction(
                context,
                icon: Icons.quiz,
                label: 'Trivia',
                color: AppColors.info,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        TriviasScreen(usuarioId: usuarioId, onMenuTap: null),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildQuickAction(
                context,
                icon: Icons.emoji_events,
                label: 'Retos',
                color: AppColors.coralSoft,
                onTap: () {
                  if (onGotoRetos != null) {
                    onGotoRetos!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChallengeListScreen(
                          usuarioId: usuarioId,
                          onMenuTap: null,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    Color? foregroundColor,
    required VoidCallback onTap,
  }) {
    final fg = foregroundColor ?? color;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirJardin(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GardenCubit(
            usuarioId: usuarioId,
            jardinService: context.read<JardinService>(),
            monederoService: context.read<MonederoService>(),
          )..loadGarden(),
          child: const GardenScreen(),
        ),
      ),
    );
    if (!context.mounted) return;
    context.read<HomeCubit>().refresh();
  }

  Widget _buildRetosRecientes(BuildContext context, HomeState state) {
    if (state.retosRecientes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Retos destacados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...state.retosRecientes
              .take(3)
              .map(
                (reto) {
                  final catalogo = RetoCatalogo.porId(reto.codigo ?? '');
                  return ChallengeCard(
                    titulo: reto.tituloReto,
                    categoria: catalogo?.categoria.nombre ?? 'Reto',
                    dificultad:
                        catalogo?.dificultad.name.toUpperCase() ?? 'FACIL',
                    puntos: reto.puntosReto,
                    estado: reto.estado,
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildGardenPreview(BuildContext context, HomeState state) {
    if (state.jardin == null) return const SizedBox.shrink();
    final jardin = state.jardin!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🌱 Mi Jardín Virtual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gardenGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Nivel ${jardin.nivelJardin}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildGardenStat('🌿', '${jardin.plantas}', 'Plantas'),
                  _buildGardenStat('🌳', '${jardin.arboles}', 'Árboles'),
                  _buildGardenStat('🌸', '${jardin.flores}', 'Flores'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _abrirJardin(context),
                  child: const Text('Entrar al Jardín'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGardenStat(String emoji, String count, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días ☀️';
    if (hour < 18) return 'Buenas tardes 🌤️';
    return 'Buenas noches 🌙';
  }

  Widget _buildRetoDelDia(BuildContext context) {
    final delDia = RetoCatalogo.retoDelDia(DateTime.now());
    if (delDia == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF1F5C44)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.local_fire_department, color: AppColors.xpGold),
                SizedBox(width: 6),
                Text(
                  '🔥 RETO DEL DÍA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              delDia.titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${delDia.categoria.nombre} · ${delDia.dificultad.label}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _chipRecompensa('⭐ ${delDia.xp} XP'),
                const SizedBox(width: 8),
                _chipRecompensa('🪙 ${delDia.monedas} ECO'),
                const Spacer(),
                if (onGotoRetos != null)
                  TextButton(
                    onPressed: onGotoRetos,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Hacer reto',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipRecompensa(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMuroPreview(BuildContext context, HomeState state) {
    if (state.publicacionesRecientes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📢 Actividad en el Muro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...state.publicacionesRecientes
              .take(3)
              .map((p) => _buildMuroTile(context, p)),
        ],
      ),
    );
  }

  Widget _buildMuroTile(BuildContext context, PublicacionResponse post) {
    final hasImage = post.imagen != null && post.imagen!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  resolverUrlMedia(post.imagen!)!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.nombreUsuario,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.contenido,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
