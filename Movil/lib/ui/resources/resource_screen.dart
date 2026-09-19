import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/content/content_models.dart';
import '../../data/services/recurso_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as eco;

class ResourceScreen extends StatefulWidget {
  final RecursoService recursoService;

  const ResourceScreen({super.key, required this.recursoService});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  List<RecursoResponse>? _recursos;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecursos();
  }

  void _loadRecursos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final recursos = await widget.recursoService.getRecursosActivos();
      setState(() {
        _recursos = recursos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar recursos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos Educativos'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando recursos...')
          : _error != null
              ? eco.ErrorWidget(
                  message: _error!,
                  actionLabel: 'Reintentar',
                  onAction: _loadRecursos,
                )
              : _recursos == null || _recursos!.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.menu_book_outlined,
                      title: 'No hay recursos disponibles',
                      subtitle:
                          'Pronto habrá materiales educativos para ti',
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _loadRecursos(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _recursos!.length,
                        itemBuilder: (context, index) {
                          final recurso = _recursos![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.article,
                                  color: AppColors.info,
                                ),
                              ),
                              title: Text(
                                recurso.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    recurso.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        recurso.nombreCategoria,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        recurso.tipo,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: recurso.url != null
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => _openUrl(recurso.url!),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
