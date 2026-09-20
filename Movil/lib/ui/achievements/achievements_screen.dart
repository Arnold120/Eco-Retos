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
import 'achievements_category_screen.dart';
import 'insignia_categoria.dart';

class AchievementsScreen extends StatefulWidget {
  final int usuarioId;

  const AchievementsScreen({super.key, required this.usuarioId});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<InsigniaResponse> _allAchievements = [];
  List<UsuarioInsigniaResponse> _userAchievements = [];
  ProgresoResponse? _progreso;
  int _rachaActual = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final insigniaService = context.read<InsigniaService>();
      final progresoService = context.read<ProgresoService>();
      final rachaService = context.read<RachaService>();

      final results = await Future.wait([
        insigniaService.getInsignias(),
        insigniaService.getInsigniasUsuario(widget.usuarioId),
        _cargarProgreso(progresoService),
        _cargarRacha(rachaService),
      ]);
      if (!mounted) return;
      setState(() {
        _allAchievements = results[0] as List<InsigniaResponse>;
        _userAchievements = results[1] as List<UsuarioInsigniaResponse>;
        _progreso = results[2] as ProgresoResponse?;
        _rachaActual = results[3] as int;
        _isLoading = false;
      });
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

  Future<ProgresoResponse?> _cargarProgreso(ProgresoService service) async {
    try {
      return await service.getProgreso(widget.usuarioId);
    } catch (_) {
      return null;
    }
  }

  Future<int> _cargarRacha(RachaService service) async {
    try {
      return await service.getRachaActual(widget.usuarioId);
    } catch (_) {
      return 0;
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

  Map<int, UsuarioInsigniaResponse> get _obtenidasPorId => {
        for (final ua in _userAchievements) ua.insigniaId: ua,
      };

  MetricasLogros get _metricas => MetricasLogros(
        retosCompletados: _progreso?.retosCompletados ?? 0,
        triviasCompletadas: _progreso?.triviasCompletadas ?? 0,
        experiencia: _progreso?.experiencia ?? 0,
        rachaActual: _rachaActual,
      );

  Map<InsigniaCategoria, List<InsigniaResponse>> get _porCategoria {
    final mapa = {
      for (final categoria in InsigniaCategoria.values)
        categoria: <InsigniaResponse>[],
    };
    for (final insignia in _allAchievements) {
      mapa[insignia.categoria]!.add(insignia);
    }
    return mapa;
  }

  List<InsigniaResponse> _recientes() {
    final porId = {for (final i in _allAchievements) i.insigniaId: i};
    final ordenadas = [..._userAchievements]
      ..sort((a, b) => b.fechaObtencion.compareTo(a.fechaObtencion));
    return ordenadas
        .map((ua) => porId[ua.insigniaId])
        .whereType<InsigniaResponse>()
        .take(8)
        .toList();
  }

  void _abrirCategoria(InsigniaCategoria categoria) {
    final insignias = _porCategoria[categoria] ?? const <InsigniaResponse>[];
    if (insignias.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AchievementsCategoryScreen(
          categoria: categoria,
          insignias: insignias,
          obtenidasPorId: _obtenidasPorId,
          metricas: _metricas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final obtenidas = _userAchievements.length;
    final total = _allAchievements.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Logros'),
        actions: [
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildContadorPill(obtenidas, total),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildContadorPill(int obtenidas, int total) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.xpGold.withValues(alpha: 0.20),
            AppColors.xpGold.withValues(alpha: 0.38),
          ]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.xpGold,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '$obtenidas / $total',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.xpGold,
              ),
            ),
          ],
        ),
      ),
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
      return const EmptyStateWidget(
        icon: Icons.emoji_events_outlined,
        title: 'Aún no hay logros disponibles',
        subtitle: 'Vuelve más tarde para descubrir nuevos retos y logros.',
      );
    }

    final categorias = _porCategoria;
    final categoriasVisibles = InsigniaCategoria.values
        .where((c) => (categorias[c]?.isNotEmpty ?? false))
        .toList();
    final recientes = _recientes();

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDark)),
          SliverToBoxAdapter(
            child: _buildSeccionTitulo(
              'Explora por categoría',
              'Toca una categoría para ver todos sus logros',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoriaCard(
                  categoriasVisibles[index],
                  categorias,
                ),
                childCount: categoriasVisibles.length,
              ),
            ),
          ),
          if (recientes.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSeccionTitulo(
                'Recién desbloqueados',
                'Tus últimos logros obtenidos',
              ),
            ),
            SliverToBoxAdapter(child: _buildRecientes(recientes, isDark)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final obtenidas = _userAchievements.length;
    final total = _allAchievements.length;
    final porcentaje = total == 0 ? 0.0 : obtenidas / total;
    final metricas = _metricas;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColorsDark.primary, AppColorsDark.secondary]
              : [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                      '$obtenidas de $total logros',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(porcentaje * 100).toStringAsFixed(1)}% completado',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAnilloProgreso(porcentaje),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat(
                Icons.flag_rounded,
                '${metricas.retosCompletados}',
                'Retos',
              ),
              const SizedBox(width: 10),
              _buildMiniStat(
                Icons.psychology_rounded,
                '${metricas.triviasCompletadas}',
                'Trivias',
              ),
              const SizedBox(width: 10),
              _buildMiniStat(
                Icons.local_fire_department_rounded,
                '${metricas.rachaActual}',
                'Racha',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.xpGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnilloProgreso(double progreso) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: progreso,
              strokeWidth: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.xpGold,
              ),
            ),
          ),
          Text(
            '${(progreso * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icono, String valor, String etiqueta) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icono, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valor,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    etiqueta,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      height: 1.2,
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

  Widget _buildSeccionTitulo(String titulo, String subtitulo) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: 12.5,
              color: onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaCard(
    InsigniaCategoria categoria,
    Map<InsigniaCategoria, List<InsigniaResponse>> categorias,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insignias = categorias[categoria] ?? const <InsigniaResponse>[];
    final total = insignias.length;
    final obtenidas =
        insignias.where((i) => _obtenidasPorId.containsKey(i.insigniaId)).length;
    final progreso = total == 0 ? 0.0 : obtenidas / total;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _abrirCategoria(categoria),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: categoria.color.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: categoria.color.withValues(alpha: isDark ? 0.10 : 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: categoria.gradiente),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: categoria.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(categoria.icono, color: Colors.white, size: 26),
              ),
              const Spacer(),
              Text(
                categoria.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$obtenidas / $total logros',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progreso,
                  minHeight: 6,
                  backgroundColor: categoria.color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(categoria.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecientes(List<InsigniaResponse> recientes, bool isDark) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: recientes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final insignia = recientes[index];
          final categoria = insignia.categoria;
          final fecha = _obtenidasPorId[insignia.insigniaId]?.fechaObtencion;
          return SizedBox(
            width: 124,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _abrirCategoria(categoria),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColorsDark.surfaceCard
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.xpGold.withValues(alpha: 0.45),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: categoria.gradiente),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.military_tech_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        insignia.nombreInsignia,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fecha == null ? '' : _formatDate(fecha),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          6,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonWidgets.achievementCard(isDark: isDark),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}
