import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../../data/services/gamification_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as eco;
import '../widgets/animated_widgets.dart';

class AchievementsScreen extends StatefulWidget {
  final int usuarioId;

  const AchievementsScreen({super.key, required this.usuarioId});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  List<InsigniaResponse> _allAchievements = [];
  List<UsuarioInsigniaResponse> _userAchievements = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadAchievements();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final insigniaService = context.read<InsigniaService>();
      final results = await Future.wait([
        insigniaService.getInsignias(),
        insigniaService.getInsigniasUsuario(widget.usuarioId),
      ]);
      if (!mounted) return;
      setState(() {
        _allAchievements = results[0] as List<InsigniaResponse>;
        _userAchievements = results[1] as List<UsuarioInsigniaResponse>;
        _isLoading = false;
      });
      _animationController.forward();
      developer.log('Logros cargados correctamente', name: 'AchievementsScreen');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar logros',
        name: 'AchievementsScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _getErrorMessage(e);
      });
    }
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return 'Sesión expirada. Inicia sesión de nuevo.';
        case 403:
          return 'No tienes permiso para ver los logros.';
        case 500:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return 'Error: ${error.message.isNotEmpty ? error.message : error.toString()}';
      }
    }
    return 'Error inesperado: $error';
  }

  bool _hasAchievement(int insigniaId) {
    return _userAchievements.any((ua) => ua.insigniaId == insigniaId);
  }

  UsuarioInsigniaResponse? _getUserAchievement(int insigniaId) {
    try {
      return _userAchievements.firstWhere((ua) => ua.insigniaId == insigniaId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Logros'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.xpGold.withValues(alpha: 0.2),
                      AppColors.xpGold,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '${_userAchievements.length} / ${_allAchievements.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildSkeleton(isDark);
    }

    if (_error != null) {
      return eco.ErrorWidget(
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _loadAchievements,
      );
    }

    if (_allAchievements.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.military_tech_outlined,
        title: 'No hay logros disponibles',
        subtitle: 'Pronto se agregarán nuevos logros para desbloquear',
        actionLabel: 'Reintentar',
        onAction: _loadAchievements,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildProgressHeader(isDark),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.separated(
              itemCount: _allAchievements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final insignia = _allAchievements[index];
                final unlocked = _hasAchievement(insignia.insigniaId);
                final userAchievement = _getUserAchievement(insignia.insigniaId);
                return StaggeredAnimation(
                  index: index,
                  controller: _animationController,
                  child: _buildAchievementCard(
                      insignia, unlocked, userAchievement, isDark),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildProgressHeaderSkeleton(isDark),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.separated(
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => SkeletonWidgets.achievementCard(
                isDark: isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(bool isDark) {
    final total = _allAchievements.length;
    final unlocked = _userAchievements.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColorsDark.primary, AppColorsDark.secondary]
              : [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked de $total logros',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% completado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.xpGold),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeaderSkeleton(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonWidgets.shimmerRect(width: 140, height: 26),
                    const SizedBox(height: 4),
                    SkeletonWidgets.shimmerRect(width: 100, height: 16),
                  ],
                ),
              ),
              SkeletonWidgets.shimmerCircle(60),
            ],
          ),
          const SizedBox(height: 20),
          SkeletonWidgets.shimmerRect(
              width: double.infinity, height: 10, radius: 8),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    InsigniaResponse insignia,
    bool unlocked,
    UsuarioInsigniaResponse? userAchievement,
    bool isDark,
  ) {
    final fechaObtencion = userAchievement?.fechaObtencion;
    final progreso = _calculateProgress(insignia);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: unlocked
            ? (isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard)
            : (isDark
                ? AppColorsDark.surfaceDim.withValues(alpha: 0.5)
                : AppColors.surfaceDim.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAchievementDetail(
              context, insignia, unlocked, userAchievement, isDark),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unlocked
                    ? AppColors.xpGold.withValues(alpha: 0.3)
                    : (isDark ? AppColorsDark.border : AppColors.border)
                        .withValues(alpha: 0.5),
                width: unlocked ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildAchievementIcon(insignia, unlocked, isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insignia.nombreInsignia,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: unlocked
                                    ? (isDark
                                        ? AppColorsDark.textPrimary
                                        : AppColors.textPrimary)
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                          if (unlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 12, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Desbloqueado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.textHint.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Bloqueado',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insignia.descripcion,
                        style: TextStyle(
                          fontSize: 13,
                          color: unlocked
                              ? (isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary)
                              : AppColors.textHint,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (!unlocked && progreso != null) ...[
                        _buildProgressBar(progreso, isDark),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.xpGold),
                          const SizedBox(width: 4),
                          Text(
                            '${insignia.monedasRecompensa} Monedas',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.xpGold,
                            ),
                          ),
                          if (unlocked && fechaObtencion != null) ...[
                            const Spacer(),
                            Icon(Icons.calendar_today,
                                size: 12, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(fechaObtencion),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ],
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

  double? _calculateProgress(InsigniaResponse insignia) {


    final requisito = insignia.requisito.toLowerCase();
    if (requisito.contains('reto') || requisito.contains('trivia')) {

      return null;
    }
    return null;
  }

  Widget _buildProgressBar(double progress, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.xpGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: (isDark ? AppColorsDark.border : AppColors.border)
                .withValues(alpha: 0.5),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementIcon(
      InsigniaResponse insignia, bool unlocked, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                colors: [
                  AppColors.xpGold.withValues(alpha: 0.3),
                  AppColors.xpGold,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  (isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim)
                      .withValues(alpha: 0.5),
                  (isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim)
                      .withValues(alpha: 0.3),
                ],
              ),
        shape: BoxShape.circle,
        border: Border.all(
          color: unlocked
              ? AppColors.xpGold.withValues(alpha: 0.5)
              : (isDark ? AppColorsDark.border : AppColors.border)
                  .withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppColors.xpGold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        unlocked ? Icons.military_tech : Icons.lock_outline,
        color: unlocked ? Colors.white : AppColors.textHint,
        size: 28,
      ),
    );
  }

  void _showAchievementDetail(
    BuildContext context,
    InsigniaResponse insignia,
    bool unlocked,
    UsuarioInsigniaResponse? userAchievement,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppColorsDark.border : AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            _buildAchievementIcon(insignia, unlocked, isDark),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                insignia.nombreInsignia,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: unlocked
                      ? (isDark
                          ? AppColorsDark.textPrimary
                          : AppColors.textPrimary)
                      : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                insignia.descripcion,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColorsDark.textSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              indent: 24,
              endIndent: 24,
              color: (isDark ? AppColorsDark.border : AppColors.border),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    'Requisito',
                    insignia.requisito,
                    Icons.assignment_outlined,
                    isDark,
                  ),
                  _buildDetailItem(
                    'Recompensa',
                    '${insignia.monedasRecompensa} Monedas',
                    Icons.star,
                    isDark,
                  ),
                  if (unlocked)
                    _buildDetailItem(
                      'Obtenido',
                      _formatDate(userAchievement!.fechaObtencion),
                      Icons.calendar_today_outlined,
                      isDark,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
