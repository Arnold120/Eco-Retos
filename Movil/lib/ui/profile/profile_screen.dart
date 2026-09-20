import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';
import '../../core/utils/nivel_progreso.dart';
import '../widgets/global_header_actions.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as eco;
import '../profile/cubit/profile_cubit.dart';
import '../profile/cubit/profile_state.dart' show ProfileState;
import '../achievements/achievements_screen.dart';
import '../statistics/statistics_screen.dart';
import '../garden/garden_screen.dart';
import '../garden/cubit/garden_cubit.dart';
import '../notifications/notification_screen.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../settings/settings_screen.dart';
import '../../data/services/gamification_service.dart';
import '../../data/services/social_service.dart' show NotificacionService;
import '../auth/cubit/auth_cubit.dart';
import 'edit_profile_screen.dart';
import 'historial_monedas_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int usuarioId;
  final VoidCallback? onMenuTap;

  const ProfileScreen({super.key, required this.usuarioId, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap),
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _goEdit(context),
          ),
          const GlobalHeaderActions(),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.perfil == null) {
            return _buildProfileSkeleton(context);
          }
          if (state.error != null && state.perfil == null) {
            return eco.ErrorWidget(
              message: state.error!,
              actionLabel: 'Reintentar',
              onAction: () => context.read<ProfileCubit>().loadProfile(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 740),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(state, context),
                    const SizedBox(height: 26),
                    _buildNivelSection(state, context),
                    const SizedBox(height: 26),
                    _buildQuickStatsSection(state, context),
                    const SizedBox(height: 26),
                    _buildInsigniasSection(state, context),
                    const SizedBox(height: 26),
                    _buildActionsSection(state, context),
                    const SizedBox(height: 18),
                    _buildLogout(context),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Column(
            children: [
              const SizedBox(height: 8),
              SkeletonWidgets.profileHeader(isDark: isDark),
              const SizedBox(height: 26),
              SkeletonWidgets.nivelCard(isDark: isDark),
              const SizedBox(height: 26),
              _sectionTitle(context, 'En un vistazo'),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columnas = constraints.maxWidth >= 600 ? 4 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 140,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, i) =>
                        SkeletonWidgets.quickStatCard(isDark: isDark),
                  );
                },
              ),
              const SizedBox(height: 26),
              _sectionTitle(context, 'Mis insignias'),
              SizedBox(
                height: 118,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => SizedBox(
                    width: 340,
                    child: SkeletonWidgets.achievementCard(isDark: isDark),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _sectionTitle(context, 'Accesos rápidos'),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 600) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 4.6,
                          ),
                      itemCount: 6,
                      itemBuilder: (_, __) =>
                          SkeletonWidgets.actionTile(isDark: isDark),
                    );
                  }
                  return Column(
                    children: List.generate(
                      6,
                      (i) => SkeletonWidgets.actionTile(isDark: isDark),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _buildLogout(context),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildHeader(ProfileState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final perfil = state.perfil;
    final nombre = (perfil?.nombreCompleto.trim().isNotEmpty ?? false)
        ? perfil!.nombreCompleto
        : state.nombreUsuario;
    final centro = perfil?.centroEducativo;
    final grado = perfil?.grado;
    final nivelInfo = _computeNivelInfo(state);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColorsDark.primary, AppColorsDark.secondary]
                : [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -30,
              child: _blob(170, AppColors.bluePastel),
            ),
            Positioned(
              bottom: -46,
              left: -24,
              child: _blob(150, AppColors.coralSoft),
            ),
            Positioned(
              top: 80,
              left: -18,
              child: _blob(90, AppColors.lavender),
            ),
            Positioned(
              bottom: 34,
              right: 32,
              child: _blob(56, AppColors.xpGold),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  _buildAvatar(state, context),
                  const SizedBox(height: 14),
                  Text(
                    nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.correo,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLevelProgressBar(nivelInfo, context),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        Icons.military_tech_outlined,
                        'Nivel ${nivelInfo.nivel}',
                        AppColors.xpGold,
                      ),
                      _chip(
                        Icons.star_outline,
                        '${state.xpTotal} XP',
                        AppColors.xpGold,
                      ),
                      if (centro != null && centro.isNotEmpty)
                        _chip(
                          Icons.school_outlined,
                          centro,
                          AppColors.bluePastel,
                        ),
                      if (grado != null && grado.isNotEmpty)
                        _chip(
                          Icons.grade_outlined,
                          'Grado $grado',
                          AppColors.lavender,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEditButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  NivelInfo _computeNivelInfo(ProfileState state) {

    final totalXp = state.xpTotal;
    final backendNivel = state.progreso?.nivelActual ?? 1;
    final backendPorcentaje = state.progreso?.porcentajeProgreso ?? 0.0;


    if (totalXp > 0) {
      return NivelInfo.fromTotalXp(totalXp);
    }

    return NivelInfo.fromBackendProgress(
      backendNivel,
      backendPorcentaje,
      totalXp: totalXp > 0 ? totalXp : null,
    );
  }

  Widget _buildLevelProgressBar(NivelInfo info, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel ${info.nivel}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${info.xpEnNivel}/${info.xpMaximoNivel} XP',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.xpGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: info.porcentaje / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.xpGold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                info.listoParaSubir
                    ? '¡Listo para el Nivel ${info.nivel + 1}!'
                    : 'Faltan ${info.xpFaltante} XP para el Nivel ${info.nivel + 1}',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              if (info.listoParaSubir)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '¡SUBIR DE NIVEL!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.xpGold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _goEdit(context),
      icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
      label: const Text(
        'Editar perfil',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildAvatar(ProfileState state, BuildContext context) {
    final fotoUrl = state.perfil?.fotoPerfil;
    final inicial = (state.perfil?.nombre.isNotEmpty ?? false)
        ? state.perfil!.nombre[0].toUpperCase()
        : (state.nombreUsuario.isNotEmpty
              ? state.nombreUsuario[0].toUpperCase()
              : '?');

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            final url = resolverUrlMedia(fotoUrl);
            if (url == null) return;
            showDialog<void>(
              context: context,
              barrierColor: Colors.black,
              builder: (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: Center(
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (c, child, progreso) {
                              if (progreso == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white70,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white54,
                                    size: 56,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imagen no disponible',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SafeArea(
                        child: IconButton(
                          tooltip: 'Cerrar',
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: resolverUrlMedia(fotoUrl) != null
                  ? Image.network(
                      resolverUrlMedia(fotoUrl)!,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 88,
                          height: 88,
                          color: Colors.white.withValues(alpha: 0.2),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        developer.log(
                          'Error loading profile image: $error',
                          name: 'ProfileScreen',
                        );
                        return _defaultAvatar(inicial);
                      },
                    )
                  : _defaultAvatar(inicial),
            ),
          ),
        ),
        if (state.subiendoFoto)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: state.subiendoFoto ? null : () => _cambiarFoto(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.xpGold,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar(String inicial) {
    return Container(
      width: 88,
      height: 88,
      color: Colors.white.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildNivelSection(ProfileState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nivelInfo = _computeNivelInfo(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Progreso de nivel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NIVEL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.xpGold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardBox(context, isDark, accent: AppColors.xpGold),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.xpGold.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.military_tech,
                            color: AppColors.xpGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Nivel ${nivelInfo.nivel}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColorsDark.textPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _pill(
                      '${nivelInfo.porcentaje.toStringAsFixed(0)}%',
                      AppColors.xpGold,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: nivelInfo.porcentaje / 100),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor:
                            (isDark ? AppColorsDark.border : AppColors.border)
                                .withValues(alpha: 0.6),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.xpGold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nivelInfo.listoParaSubir
                            ? '¡Listo para el Nivel ${nivelInfo.nivel + 1}!'
                            : 'Faltan ${nivelInfo.xpFaltante} XP para el Nivel '
                                  '${nivelInfo.nivel + 1}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${nivelInfo.xpEnNivel}/${nivelInfo.xpMaximoNivel} XP',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.xpGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildQuickStatsSection(ProfileState state, BuildContext context) {
    final items = [
      _QuickStat(
        Icons.local_fire_department,
        '${state.rachaActual}',
        'Días de racha',
        AppColors.streakFire,
      ),
      _QuickStat(
        Icons.emoji_events,
        '${state.progreso?.retosCompletados ?? 0}',
        'Retos completados',
        AppColors.primary,
        foregroundColor: Colors.white,
      ),
      _QuickStat(
        Icons.quiz_outlined,
        '${state.progreso?.triviasCompletadas ?? 0}',
        'Trivias completadas',
        AppColors.bluePastel,
      ),
      _QuickStat(
        Icons.park_outlined,
        '${state.jardin?.totalVegetacion ?? 0}',
        'Plantas en jardín',
        AppColors.gardenGreen,
        foregroundColor: Colors.white,
      ),
      _QuickStat(
        Icons.star_outline,
        '${state.xpTotal}',
        'XP acumulado',
        AppColors.xpGold,
      ),
      _QuickStat(
        Icons.monetization_on_outlined,
        '${state.monedas}',
        'Monedas',
        AppColors.coralSoft,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'En un vistazo'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columnas = constraints.maxWidth >= 600 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 140,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _buildQuickStatCard(items[i], context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(_QuickStat stat, BuildContext context) {
    final fg = stat.foregroundColor ?? stat.color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stat.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: fg, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInsigniasSection(ProfileState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insignias = state.insignias.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          'Mis insignias',
          trailing: 'Ver todas',
          onTrailing: () => _goAchievements(context),
        ),
        if (insignias.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBox(context, isDark, accent: AppColors.lavender),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.lavender.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_outlined,
                      color: AppColors.lavender,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aún no has ganado insignias. ¡Completa retos y trivias para desbloquearlas!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _goAchievements(context),
                    child: const Text('Ver logros'),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 118,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: insignias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final color = colores[i % colores.length];
                final fg =
                    (color == AppColors.primary ||
                        color == AppColors.gardenGreen)
                    ? Colors.white
                    : color;
                return Container(
                  width: 104,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: _cardBox(context, isDark, accent: color),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.military_tech_outlined,
                          color: fg,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insignias[i].nombreInsignia,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  static const colores = [
    AppColors.xpGold,
    AppColors.bluePastel,
    AppColors.coralSoft,
    AppColors.lavender,
    AppColors.primary,
    AppColors.gardenGreen,
    AppColors.streakFire,
    AppColors.info,
  ];



  Widget _buildActionsSection(ProfileState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final acciones = [
      _Accion(
        icon: Icons.park_outlined,
        title: 'Mi Jardín Virtual',
        subtitle: '${state.jardin?.totalVegetacion ?? 0} plantas en tu jardín',
        color: AppColors.gardenGreen,
        foregroundColor: Colors.white,
        onTap: () => _goGarden(context),
      ),
      _Accion(
        icon: Icons.military_tech_outlined,
        title: 'Mis Logros',
        subtitle: '${state.insignias.length} insignias ganadas',
        color: AppColors.xpGold,
        onTap: () => _goAchievements(context),
      ),
      _Accion(
        icon: Icons.bar_chart_outlined,
        title: 'Mis Estadísticas',
        subtitle: 'Consulta tu actividad detallada',
        color: AppColors.bluePastel,
        onTap: () => _goStatistics(context),
      ),
      _Accion(
        icon: Icons.receipt_long_outlined,
        title: 'Historial de puntos',
        subtitle: 'Movimientos de XP y monedas',
        color: AppColors.lavender,
        onTap: () => _goHistorial(context),
      ),
      _Accion(
        icon: Icons.notifications_outlined,
        title: 'Notificaciones',
        subtitle: 'Avisos, recompensas y comunidad',
        color: AppColors.coralSoft,
        onTap: () => _goNotifications(context),
      ),
      _Accion(
        icon: Icons.settings_outlined,
        title: 'Configuración',
        subtitle: 'Preferencias de tu cuenta',
        color: AppColors.primary,
        foregroundColor: Colors.white,
        onTap: () => _goSettings(context),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 4.6,
              ),
              itemCount: acciones.length,
              itemBuilder: (context, i) =>
                  _buildAccionTile(context, acciones[i], isDark),
            );
          }
          return Column(
            children: [
              for (final a in acciones) _buildAccionTile(context, a, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccionTile(BuildContext context, _Accion accion, bool isDark) {
    final fg = accion.foregroundColor ?? accion.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: accion.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isDark ? AppColorsDark.border : AppColors.border)
                    .withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accion.color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(accion.icon, color: fg, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        accion.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        accion.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark ? AppColorsDark.textHint : AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tu progreso está guardado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }



  void _goEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: const EditProfileScreen(),
        ),
      ),
    );
  }

  Future<void> _goGarden(BuildContext context) async {
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
    context.read<ProfileCubit>().refresh();
  }

  void _goAchievements(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(usuarioId: usuarioId),
      ),
    );
  }

  void _goStatistics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatisticsScreen(usuarioId: usuarioId)),
    );
  }

  void _goSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(usuarioId: usuarioId)),
    );
  }

  void _goNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => NotificationCubit(
            usuarioId: context.read<ProfileCubit>().usuarioId,
            service: context.read<NotificacionService>(),
          ),
          child: const NotificationScreen(),
        ),
      ),
    );
  }

  void _goHistorial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistorialMonedasScreen(usuarioId: usuarioId),
      ),
    );
  }



  Future<void> _cambiarFoto(BuildContext context) async {
    if (context.read<ProfileCubit>().state.subiendoFoto) return;

    final esEscritorio = !kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    final source = esEscritorio
        ? ImageSource.gallery
        : await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (Theme.of(ctx).brightness == Brightness.dark
                    ? AppColorsDark.border
                    : AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                ),
              ),
              title: const Text('Tomar una foto'),
              subtitle: const Text('Usa la cámara del dispositivo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.lavender,
                ),
              ),
              title: const Text('Elegir de la galería'),
              subtitle: const Text('Selecciona una imagen guardada'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
          ),
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final XFile? archivo;
    try {
      archivo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 82,
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la cámara o galería')),
      );
      return;
    }
    if (archivo == null) return;

    final exito = await cubit.cambiarFoto(File(archivo.path));
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          exito
              ? 'Foto de perfil actualizada 🎉'
              : 'No se pudo actualizar la foto',
        ),
      ),
    );
  }



  Widget _sectionTitle(
    BuildContext context,
    String title, {
    String? trailing,
    VoidCallback? onTrailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (trailing != null && onTrailing != null)
            TextButton(onPressed: onTrailing, child: Text(trailing)),
        ],
      ),
    );
  }

  BoxDecoration _cardBox(BuildContext context, bool isDark, {Color? accent}) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (isDark ? AppColorsDark.border : AppColors.border).withValues(
          alpha: 0.7,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _QuickStat {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color? foregroundColor;

  const _QuickStat(
    this.icon,
    this.value,
    this.label,
    this.color, {
    this.foregroundColor,
  });
}

class _Accion {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color? foregroundColor;
  final VoidCallback onTap;

  const _Accion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.foregroundColor,
    required this.onTap,
  });
}
