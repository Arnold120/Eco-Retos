import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/content/content_models.dart';
import '../../data/services/recurso_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../shop/shop_screen.dart';

class InventoryScreen extends StatefulWidget {
  final int usuarioId;

  const InventoryScreen({super.key, required this.usuarioId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventarioResponse> _inventory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final inventarioService = context.read<InventarioService>();
      final items = await inventarioService.getInventarioUsuario(widget.usuarioId);
      setState(() {
        _inventory = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el inventario';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando inventario...')
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
                        onPressed: _loadInventory,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _inventory.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'Todavía no tienes materiales',
                      subtitle:
                          'Compra materiales en la Tienda Eco usando tus Monedas Eco.',
                      actionLabel: 'Ir a Tienda',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ShopScreen(usuarioId: widget.usuarioId),
                          ),
                        );
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: _loadInventory,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '${_inventory.length} material${_inventory.length != 1 ? 'es' : ''} en tu inventario',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColorsDark.textSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _inventory.length,
                              itemBuilder: (context, index) {
                                final item = _inventory[index];
                                return _buildInventoryItem(item, isDark);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInventoryItem(InventarioResponse item, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.nombreMaterial,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '×${item.cantidad}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
