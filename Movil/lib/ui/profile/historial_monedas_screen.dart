import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../core/theme/app_theme.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../../data/services/gamification_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as eco;
import '../widgets/animated_widgets.dart';

class HistorialMonedasScreen extends StatefulWidget {
  final int usuarioId;

  const HistorialMonedasScreen({super.key, required this.usuarioId});

  @override
  State<HistorialMonedasScreen> createState() => _HistorialMonedasScreenState();
}

class _HistorialMonedasScreenState extends State<HistorialMonedasScreen>
    with SingleTickerProviderStateMixin {
  List<MovimientoMonedaResponse> _historial = [];
  int _monedasTotales = 0;
  bool _isLoading = true;
  String? _error;
  String _filtroTipo = 'todos';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadHistorial();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistorial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final monederoService = context.read<MonederoService>();
      final results = await Future.wait([
        monederoService.getHistorial(),
        monederoService.getSaldo(),
      ]);
      if (!mounted) return;
      setState(() {
        _historial = results[0] as List<MovimientoMonedaResponse>;
        _monedasTotales = (results[1] as SaldoMonederoResponse).saldo;
        _isLoading = false;
      });
      _animationController.forward();
      developer.log('Historial cargado: ${_historial.length} items', name: 'HistorialMonedasScreen');
    } catch (e, stackTrace) {
      developer.log(
        'Error al cargar historial',
        name: 'HistorialMonedasScreen',
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
          return 'No tienes permiso para ver el historial.';
        case 500:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return 'Error: ${error.message.isNotEmpty ? error.message : error.toString()}';
      }
    }
    return 'Error inesperado: $error';
  }

  List<MovimientoMonedaResponse> get _historialFiltrado {
    return _historial.where((item) {
      final matchTipo = _filtroTipo == 'todos' || item.tipo == _filtroTipo.toUpperCase();
      final matchFecha = (_fechaInicio == null || !item.fecha.isBefore(_fechaInicio!)) &&
          (_fechaFin == null || !item.fecha.isAfter(_fechaFin!.add(const Duration(days: 1))));
      return matchTipo && matchFecha;
    }).toList();
  }

  Map<String, int> get _resumenPorTipo {
    final mapa = <String, int>{};
    for (final item in _historial) {
      mapa[item.tipo] = (mapa[item.tipo] ?? 0) + item.cantidad;
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Monedas'),
        actions: [
          IconButton(
            tooltip: 'Filtrar',
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _historial.isEmpty) {
      return _buildSkeleton(isDark);
    }

    if (_error != null && _historial.isEmpty) {
      return eco.ErrorWidget(
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _loadHistorial,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistorial,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderCard(isDark),
          ),
          SliverToBoxAdapter(
            child: _buildResumenCard(isDark),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildFilterChips(isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: _historialFiltrado.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: _historial.isEmpty
                          ? 'No hay movimientos'
                          : 'Sin resultados con los filtros actuales',
                      subtitle: _historial.isEmpty
                          ? 'Tus movimientos de XP y monedas aparecerán aquí'
                          : 'Intenta cambiar los filtros',
                      actionLabel: _historial.isEmpty ? null : 'Limpiar filtros',
                      onAction: _historial.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _filtroTipo = 'todos';
                                _fechaInicio = null;
                                _fechaFin = null;
                              });
                            },
                    ),
                  )
                : SliverList.separated(
                    itemCount: _historialFiltrado.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _historialFiltrado[index];
                      return StaggeredAnimation(
                        index: index,
                        controller: _animationController,
                        child: _buildHistorialItem(item, isDark),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SkeletonWidgets.shimmerRect(
                width: double.infinity, height: 100, radius: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SkeletonWidgets.shimmerRect(
                width: double.infinity, height: 80, radius: 16),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.separated(
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, __) => _buildHistorialSkeleton(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialSkeleton(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColorsDark.border : AppColors.border)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          SkeletonWidgets.shimmerCircle(40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidgets.shimmerRect(width: 140, height: 18),
                const SizedBox(height: 4),
                SkeletonWidgets.shimmerRect(width: 200, height: 14),
                const SizedBox(height: 4),
                SkeletonWidgets.shimmerRect(width: 100, height: 12),
              ],
            ),
          ),
          SkeletonWidgets.shimmerRect(width: 60, height: 20, radius: 8),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColorsDark.primary, AppColorsDark.secondary]
              : [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial de movimientos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_historialFiltrado.length} de ${_historial.length} movimientos',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.xpGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$_monedasTotales Monedas',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(bool isDark) {
    final tipos = _resumenPorTipo.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? AppColorsDark.border : AppColors.border)
                .withValues(alpha: 0.5),
        ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen por tipo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tipos.map((entry) {
                final isPositive = entry.value > 0;
                final color = isPositive ? AppColors.success : AppColors.error;
                final icon = _getTipoIcon(entry.key);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isPositive ? '+' : ''}${entry.value}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filtros = [
      {'key': 'todos', 'label': 'Todos'},
      {'key': 'RETO', 'label': 'Retos'},
      {'key': 'TRIVIA', 'label': 'Trivias'},
      {'key': 'COMPRA', 'label': 'Compras'},
      {'key': 'RECOMPENSA', 'label': 'Recompensas'},
      {'key': 'LOGRO', 'label': 'Logros'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filtros.map((filtro) {
          final isSelected = _filtroTipo == filtro['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filtro['label']!),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _filtroTipo = filtro['key']!);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColorsDark.textSecondary : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? AppColorsDark.surfaceCard
                  : AppColors.surfaceCard,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColorsDark.border : AppColors.border),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistorialItem(MovimientoMonedaResponse item, bool isDark) {
    final isPositive = item.esPositivo;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = _getTipoIcon(item.tipo);
    final tipoLabel = _getTipoLabel(item.tipo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tipoLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.tipo == 'COMPRA' ? 'Compra en el jardín' : _getTipoDescription(item.tipo),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 11,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(item.fecha),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${item.cantidad}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.cantidad > 0 ? 'Monedas ganadas' : 'Monedas gastadas',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColorsDark.border : AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filtrar historial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Tipo de movimiento', Icons.category_outlined),
            const SizedBox(height: 16),
            _buildFilterOption('Fecha inicio', Icons.calendar_today_outlined,
                subtitle: _fechaInicio != null
                    ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'
                    : 'Seleccionar fecha'),
            const SizedBox(height: 12),
            _buildFilterOption('Fecha fin', Icons.calendar_today_outlined,
                subtitle: _fechaFin != null
                    ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                    : 'Seleccionar fecha'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filtroTipo = 'todos';
                        _fechaInicio = null;
                        _fechaFin = null;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Limpiar filtros'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon,
      {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ??
          () {

          },
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Hace ${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RETO':
        return Icons.emoji_events;
      case 'TRIVIA':
        return Icons.quiz;
      case 'COMPRA':
        return Icons.shopping_cart_outlined;
      case 'RECOMPENSA':
        return Icons.card_giftcard_outlined;
      case 'LOGRO':
        return Icons.workspace_premium;
      case 'NIVEL':
        return Icons.military_tech;
      case 'JARDIN':
        return Icons.park;
      default:
        return Icons.star;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RETO':
        return 'Reto';
      case 'TRIVIA':
        return 'Trivia';
      case 'COMPRA':
        return 'Compra';
      case 'RECOMPENSA':
        return 'Recompensa';
      case 'LOGRO':
        return 'Logro';
      case 'NIVEL':
        return 'Nivel';
      case 'JARDIN':
        return 'Jardín';
      default:
        return 'General';
    }
  }

  String _getTipoDescription(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RETO':
        return 'Completaste un reto ambiental';
      case 'TRIVIA':
        return 'Respondiste una trivia correctamente';
      case 'COMPRA':
        return 'Compraste una planta para tu jardín';
      case 'RECOMPENSA':
        return 'Recibiste una recompensa';
      case 'LOGRO':
        return 'Desbloqueaste un logro';
      case 'NIVEL':
        return 'Subiste de nivel';
      case 'JARDIN':
        return 'Actividad en tu jardín';
      default:
        return 'Movimiento de puntos';
    }
  }
}
