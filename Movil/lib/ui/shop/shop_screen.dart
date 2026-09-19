import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/content/content_models.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../../data/services/recurso_service.dart';
import '../../data/services/gamification_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';

class ShopScreen extends StatefulWidget {
  final int usuarioId;

  const ShopScreen({super.key, required this.usuarioId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<MaterialResponse> _materiales = [];
  int _monedasDisponibles = 0;
  bool _isLoading = true;
  String? _error;
  String _filtroTipo = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final materialService = context.read<MaterialService>();
      final monederoService = context.read<MonederoService>();
      final results = await Future.wait([
        materialService.getMaterialesDisponibles(),

        monederoService.getSaldo(),
      ]);
      setState(() {
        _materiales = results[0] as List<MaterialResponse>;
        _monedasDisponibles = (results[1] as SaldoMonederoResponse).saldo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar la tienda';
        _isLoading = false;
      });
    }
  }

  List<MaterialResponse> get _filteredMateriales {
    if (_filtroTipo == 'Todos') return _materiales;
    return _materiales
        .where((m) => m.tipo.toUpperCase() == _filtroTipo.toUpperCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda Eco'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.xpGoldLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.xpGold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_monedasDisponibles Monedas Eco',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.xpGold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando tienda...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: Column(
                    children: [
                      _buildCategoryFilter(isDark),
                      Expanded(
                        child: _filteredMateriales.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.store_outlined,
                                title: 'No hay materiales disponibles',
                                subtitle:
                                    'Pronto habrá nuevos materiales en la tienda',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredMateriales.length,
                                itemBuilder: (context, index) {
                                  final material = _filteredMateriales[index];
                                  return _buildProductCard(material, isDark);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    final tipos = ['Todos', 'Plástico', 'Madera', 'Papel', 'Herramientas', 'Otros'];
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tipos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tipo = tipos[index];
          final isSelected = _filtroTipo == tipo;
          return FilterChip(
            label: Text(tipo),
            selected: isSelected,
            onSelected: (_) => setState(() => _filtroTipo = tipo),
            selectedColor: AppColors.primaryDark,
            checkmarkColor: Colors.white,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(MaterialResponse material, bool isDark) {
    final canAfford = _monedasDisponibles >= material.precioMonedas;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getMaterialColor(material.tipo).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMaterialIcon(material.tipo),
                color: _getMaterialColor(material.tipo),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.nombreMaterial,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (material.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      material.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.monetization_on,
                          size: 14, color: AppColors.xpGold),
                      const SizedBox(width: 4),
                      Text(
                        '${material.precioMonedas} Monedas Eco',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.xpGold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Disponible: ${material.cantidadDisponible}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: canAfford
                  ? () => _showPurchaseConfirmation(material)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canAfford ? AppColors.primary : AppColors.textHint,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                canAfford ? 'Comprar' : 'Insuficiente',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(MaterialResponse material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Comprar material?'),
        content: Text(
          'Se descontarán ${material.precioMonedas} Monedas Eco de tu saldo.\n\nMaterial: ${material.nombreMaterial}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _purchaseMaterial(material);
            },
            child: const Text('Confirmar compra'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseMaterial(MaterialResponse material) async {
    try {
      final compraService = context.read<CompraService>();



      final compra = await compraService.createCompra(
        detalles: [
          DetalleCompraItem(materialId: material.materialId, cantidad: 1),
        ],
      );

      if (mounted && compra.saldoRestante >= 0) {
        setState(() => _monedasDisponibles = compra.saldoRestante);
      }
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡${material.nombreMaterial} adquirido!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al comprar. Intenta de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getMaterialColor(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'PLASTICO':
        return AppColors.info;
      case 'MADERA':
        return const Color(0xFF8D6E63);
      case 'PAPEL':
        return const Color(0xFFFFB74D);
      case 'HERRAMIENTAS':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getMaterialIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'PLASTICO':
        return Icons.water_drop_outlined;
      case 'MADERA':
        return Icons.forest_outlined;
      case 'PAPEL':
        return Icons.description_outlined;
      case 'HERRAMIENTAS':
        return Icons.build_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
