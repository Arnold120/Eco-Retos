import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/social/enlace_preview.dart';
import '../../../data/services/enlace_service.dart';
import 'post_helpers.dart';

/// Vista previa de un enlace pegada en una publicacion.
///
/// Intenta obtener metadatos (Open Graph) desde el backend. Si no es posible,
/// muestra una version degradada elegante con el dominio y la URL.
class LinkPreviewCard extends StatefulWidget {
  final String url;
  final bool permitirQuitar;
  final VoidCallback? onQuitar;

  const LinkPreviewCard({
    super.key,
    required this.url,
    this.permitirQuitar = false,
    this.onQuitar,
  });

  @override
  State<LinkPreviewCard> createState() => _LinkPreviewCardState();
}

class _LinkPreviewCardState extends State<LinkPreviewCard> {
  EnlacePreview? _preview;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant LinkPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _preview = null;
      _cargando = true;
      _cargar();
    }
  }

  Future<void> _cargar() async {
    try {
      final preview =
          await context.read<EnlaceService>().obtenerPreview(widget.url);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _preview = EnlacePreview(url: widget.url);
        _cargando = false;
      });
    }
  }

  String get _dominio {
    final dominio = _preview?.dominio;
    if (dominio != null && dominio.isNotEmpty) return dominio;
    final uri = Uri.tryParse(widget.url);
    return uri?.host ?? widget.url;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor(context).withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: _abrir,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_preview?.imagen != null)
                  Image.network(
                    _preview!.imagen!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dominio.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w800,
                          color: textSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_cargando)
                        Text(
                          widget.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor(context),
                          ),
                        )
                      else if (_preview?.disponible == true)
                        Text(
                          _preview!.titulo ?? _dominio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor(context),
                          ),
                        )
                      else
                        Text(
                          'Enlace externo',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor(context),
                          ),
                        ),
                      if (_preview?.descripcion != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          _preview!.descripcion!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor(context),
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.open_in_new,
                            size: 13,
                            color: textSecondaryColor(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondaryColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.permitirQuitar)
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                onPressed: widget.onQuitar,
                tooltip: 'Quitar vista previa',
                icon: const Icon(Icons.close, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(30, 30),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _abrir() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }
}
