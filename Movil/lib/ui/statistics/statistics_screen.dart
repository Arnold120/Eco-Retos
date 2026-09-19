import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../core/theme/app_theme.dart';
import '../../core/network/api_exception.dart';
import '../../data/catalogos/retos/reto_model.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../../data/services/gamification_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as eco;
import '../widgets/animated_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  final int usuarioId;

  const StatisticsScreen({super.key, required this.usuarioId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  ProgresoResponse? _progreso;
  int _experiencia = 0;
  List<CategoriaMonedas> _monedasPorCategoria = [];
  int _rachaActual = 0;
  int _mejorRacha = 0;
  int _plantasObtenidas = 0;
  int _monedasTotales = 0;
  double _impactoEcologico = 0.0;
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
    _loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final progresoService = context.read<ProgresoService>();
      final rachaService = context.read<RachaService>();
      final monederoService = context.read<MonederoService>();
      final jardinService = context.read<JardinService>();

      final results = await Future.wait([
        progresoService.getProgreso(widget.usuarioId),
        rachaService.getRachaActual(widget.usuarioId),
        monederoService.getSaldo(),
        monederoService.getPorCategoria(),
        rachaService.getHistorialRachas(widget.usuarioId),
        jardinService.getJardin(widget.usuarioId),
      ]);

      final rachas = results[4] as List<RachaResponse>;
      final jardin = results[5] as JardinResponse;

      if (!mounted) return;
      setState(() {
        _progreso = results[0] as ProgresoResponse;
        _rachaActual = results[1] as int;
        _experiencia = (results[2] as SaldoMonederoResponse).experiencia;
        _monedasPorCategoria = results[3] as List<CategoriaMonedas>;
        _mejorRacha = rachas.isNotEmpty
            ? rachas.map((r) => r.numeroRacha).reduce((a, b) => a > b ? a : b)
            : 0;
        _monedasTotales = (results[2] as SaldoMonederoResponse).saldo;
        _plantasObtenidas = jardin.totalVegetacion;
        _impactoEcologico = _calculateEcologicalImpact();
        _isLoading = false;
      });
      _animationController.forward();
      developer.log('Estadísticas cargadas correctamente', name: 'StatisticsScreen');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar estadísticas',
        name: 'StatisticsScreen',
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
          return 'No tienes permiso para ver las estadísticas.';
        case 500:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return 'Error: ${error.message.isNotEmpty ? error.message : error.toString()}';
      }
    }
    return 'Error inesperado: $error';
  }

  double _calculateEcologicalImpact() {

    double impacto = 0;
    if (_progreso != null) {
      impacto += _progreso!.retosCompletados * 2.5; 
      impacto += _progreso!.triviasCompletadas * 0.5; 
      impacto += (_plantasObtenidas) * 10; 
    }
    return impacto;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Estadísticas')),
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
        onAction: _loadStats,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildStatsGrid(isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildEcologicalImpactCard(isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildWeeklyChart(isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildCategoryStats(isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _buildDetailedStats(isDark),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: List.generate(
                8,
                (i) => SkeletonWidgets.statGridItem(isDark: isDark),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonWidgets.shimmerRect(
                width: double.infinity, height: 120, radius: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SkeletonWidgets.shimmerRect(
                width: double.infinity, height: 180, radius: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SkeletonWidgets.shimmerRect(
                width: double.infinity, height: 300, radius: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SkeletonWidgets.shimmerRect(
                width: double.infinity, height: 250, radius: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    final stats = [
      _StatData(
        Icons.emoji_events,
        '${_progreso?.retosCompletados ?? 0}',
        'Retos completados',
        AppColors.primary,
        foregroundColor: Colors.white,
      ),
      _StatData(
        Icons.star,
        '$_experiencia',
        'XP acumulado',
        AppColors.xpGold,
      ),
      _StatData(
        Icons.quiz,
        '${_progreso?.triviasCompletadas ?? 0}',
        'Trivias completadas',
        AppColors.info,
      ),
      _StatData(
        Icons.military_tech,
        '${_progreso?.insigniasObtenidas ?? 0}',
        'Logros desbloqueados',
        AppColors.xpGold,
      ),
      _StatData(
        Icons.local_fire_department,
        '$_rachaActual',
        'Racha actual (días)',
        AppColors.streakFire,
        foregroundColor: Colors.white,
      ),
      _StatData(
        Icons.trending_up,
        '$_mejorRacha',
        'Mejor racha',
        AppColors.warning,
        foregroundColor: Colors.white,
      ),
      _StatData(
        Icons.monetization_on,
        '$_monedasTotales',
        'Monedas Eco',
        AppColors.coralSoft,
      ),
      _StatData(
        Icons.park,
        '$_plantasObtenidas',
        'Plantas en jardín',
        AppColors.gardenGreen,
        foregroundColor: Colors.white,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: List.generate(stats.length, (index) {
            return StaggeredAnimation(
              index: index,
              controller: _animationController,
              child: _buildStatItem(stats[index], isDark),
            );
          }),
        );
      },
    );
  }

  Widget _buildStatItem(_StatData stat, bool isDark) {
    final fg = stat.foregroundColor ?? stat.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stat.color.withValues(alpha: 0.15),
            stat.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stat.color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: stat.color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: fg, size: 22),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(stat.value) ?? 0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              value.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEcologicalImpactCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gardenGreen.withValues(alpha: 0.2),
            AppColors.gardenGrass.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gardenGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gardenGreen.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gardenGreen, AppColors.gardenGrass],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.eco, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impacto Ecológico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu contribución al planeta',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildImpactItem(
                        '${_impactoEcologico.toStringAsFixed(1)} kg',
                        'CO₂ evitado',
                        isDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.gardenGreen.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildImpactItem(
                        '${(_progreso?.retosCompletados ?? 0) + (_progreso?.triviasCompletadas ?? 0)}',
                        'Acciones verdes',
                        isDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.gardenGreen.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildImpactItem(
                        '$_plantasObtenidas',
                        'Plantas sembradas',
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: isDark
                ? AppColorsDark.textSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(bool isDark) {

    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final values = _generateWeeklyData();

    return _buildChartCard(
      title: 'Actividad semanal',
      subtitle: 'XP ganados por día',
      isDark: isDark,
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: values[index]),
                          duration: Duration(milliseconds: 600 + index * 100),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => Container(
                            width: double.infinity,
                            height: value * 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.6),
                                  AppColors.secondary,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<double> _generateWeeklyData() {


    final base = (_experiencia > 0 ? (_experiencia / 100).clamp(0.1, 1.0) : 0.3);
    return [
      (base * 0.8).clamp(0.0, 1.0),
      (base * 0.5).clamp(0.0, 1.0),
      (base * 1.0).clamp(0.0, 1.0),
      (base * 0.7).clamp(0.0, 1.0),
      (base * 1.1).clamp(0.0, 1.0),
      (base * 0.4).clamp(0.0, 1.0),
      (base * 0.6).clamp(0.0, 1.0),
    ];
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColorsDark.border : AppColors.border)
              .withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryStats(bool isDark) {
    final puntosMap = {
      for (final p in _monedasPorCategoria) p.categoriaId: p.total,
    };
    final maxPuntos = _monedasPorCategoria.fold<int>(
      0,
      (max, p) => p.total > max ? p.total : max,
    );

    return _buildChartCard(
      title: 'Puntos por categoría',
      subtitle: 'Las 7 categorías oficiales del proyecto',
      isDark: isDark,
      child: Column(
        children: [
          for (int i = 0; i < RetoCategoria.values.length; i++) ...[
            _buildCategoryRow(
              RetoCategoria.values[i],
              puntosMap[RetoCategoria.values[i].categoriaId] ?? 0,
              maxPuntos,
              isDark,
            ),
            if (i != RetoCategoria.values.length - 1)
              const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    RetoCategoria categoria,
    int puntos,
    int maxPuntos,
    bool isDark,
  ) {
    final color = Color(categoria.lightColor);
    final fraccion = maxPuntos <= 0 ? 0.0 : (puntos / maxPuntos).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categoria.nombre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$puntos XP',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: fraccion),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(bool isDark) {
    return _buildChartCard(
      title: 'Resumen completo',
      subtitle: 'Detalle de todas tus métricas',
      isDark: isDark,
      child: Column(
        children: [
          _buildDetailRow(
              'Nivel actual', 'Nivel ${_progreso?.nivelActual ?? 1}', isDark),
          _buildDetailRow(
            'Progreso de nivel',
            '${(_progreso?.porcentajeProgreso ?? 0).toStringAsFixed(1)}%',
            isDark,
          ),
          _buildDetailRow(
              'Retos completados', '${_progreso?.retosCompletados ?? 0}', isDark),
          _buildDetailRow('Trivias completadas',
              '${_progreso?.triviasCompletadas ?? 0}', isDark),
          _buildDetailRow(
              'Insignias obtenidas', '${_progreso?.insigniasObtenidas ?? 0}', isDark),
          _buildDetailRow('Publicaciones realizadas',
              '${_progreso?.publicacionesRealizadas ?? 0}', isDark),
          _buildDetailRow('Materiales obtenidos',
              '${_progreso?.materialesObtenidos ?? 0}', isDark),
          _buildDetailRow('Racha actual', '$_rachaActual días', isDark),
          _buildDetailRow('Mejor racha', '$_mejorRacha días', isDark),
          _buildDetailRow('Plantas en jardín', '$_plantasObtenidas', isDark),
          _buildDetailRow('Monedas Eco', '$_monedasTotales', isDark),
          _buildDetailRow('Impacto ecológico',
              '${_impactoEcologico.toStringAsFixed(1)} kg CO₂', isDark),
          _buildDetailRow('Experiencia total', '$_experiencia XP', isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color? foregroundColor;

  const _StatData(this.icon, this.value, this.label, this.color,
      {this.foregroundColor});
}
