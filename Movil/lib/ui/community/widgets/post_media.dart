import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/media_url.dart';
import '../../../data/models/social/social_models.dart';
import '../../widgets/download_helper.dart';











class PostMedia extends StatelessWidget {
  final List<MultimediaItem> items;

  const PostMedia({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    if (items.length == 1) {
      return _MediaTile(
        item: items.first,
        height: 260,
        onTap: () => _abrirVisor(context, 0),
      );
    }

    if (items.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _MediaTile(
              item: items[0],
              height: 200,
              onTap: () => _abrirVisor(context, 0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _MediaTile(
              item: items[1],
              height: 200,
              onTap: () => _abrirVisor(context, 1),
            ),
          ),
        ],
      );
    }

    final visibles = items.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, i) {
        final restantes = items.length - visibles.length;
        return Stack(
          fit: StackFit.expand,
          children: [
            _MediaTile(
              item: visibles[i],
              onTap: () => _abrirVisor(context, i),
            ),
            if (i == visibles.length - 1 && restantes > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      '+$restantes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _abrirVisor(BuildContext context, int indice) {
    abrirVisorMultimedia(context, items, indice);
  }
}


void abrirVisorMultimedia(
  BuildContext context,
  List<MultimediaItem> items,
  int indice, {
  String nombreSugerido = 'muro',
}) {
  if (items.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (_) => VisorMultimedia(
      items: items,
      indiceInicial: indice,
      nombreSugerido: nombreSugerido,
    ),
  );
}


class VisorMultimedia extends StatefulWidget {
  final List<MultimediaItem> items;
  final int indiceInicial;
  final String nombreSugerido;

  const VisorMultimedia({
    super.key,
    required this.items,
    required this.indiceInicial,
    this.nombreSugerido = 'muro',
  });

  @override
  State<VisorMultimedia> createState() => _VisorMultimediaState();
}

class _VisorMultimediaState extends State<VisorMultimedia> {
  late final PageController _controller;
  late int _indice;

  @override
  void initState() {
    super.initState();
    _indice = widget.indiceInicial;
    _controller = PageController(initialPage: _indice);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actual = widget.items[_indice];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _indice = i),
              itemBuilder: (context, i) {
                final item = widget.items[i];
                if (item.tipo == 'video') {
                  return _ReproductorVideo(item: item);
                }
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      resolverUrlMedia(item.url) ?? item.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progreso) {
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
                            Icon(Icons.broken_image_outlined,
                                color: Colors.white54, size: 56),
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
                );
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (widget.items.length > 1)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_indice + 1} / ${widget.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    tooltip: 'Más opciones',
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                    onSelected: (opcion) {
                      if (opcion == 'descargar') {
                        descargarMultimedia(
                          context,
                          archivos: [(url: actual.url, tipo: actual.tipo)],
                          nombreSugerido: widget.nombreSugerido,
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'descargar',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.download_outlined, size: 20),
                          title: Text('Descargar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.items.length > 1)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.items.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _indice ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _indice ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}




class _ReproductorVideo extends StatefulWidget {
  final MultimediaItem item;

  const _ReproductorVideo({required this.item});

  @override
  State<_ReproductorVideo> createState() => _ReproductorVideoState();
}

class _ReproductorVideoState extends State<_ReproductorVideo> {
  VideoPlayerController? _controller;
  bool _inicializando = true;
  bool _error = false;

  String get _url => resolverUrlMedia(widget.item.url) ?? widget.item.url;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(_url));
    try {
      await controller.initialize();
      await controller.setLooping(true);


      await controller.seekTo(const Duration(milliseconds: 1));
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _inicializando = false;
      });
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _inicializando = false;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _abrirExterno() async {
    final uri = Uri.tryParse(_url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inicializando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white70),
      );
    }

    final controller = _controller;
    if (_error || controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                size: 64, color: Colors.white54),
            const SizedBox(height: 10),
            const Text(
              'No se pudo reproducir aquí',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _abrirExterno,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir video'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) => GestureDetector(
          onTap: () {
            value.isPlaying ? controller.pause() : controller.play();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: value.aspectRatio,
                child: VideoPlayer(controller),
              ),


              if (value.position == Duration.zero && !value.isPlaying)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    if (resolverUrlMedia(widget.item.poster) != null)
                      Image.network(
                        resolverUrlMedia(widget.item.poster)!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Colors.black45),
                      ),
                    Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white70),
                          SizedBox(height: 10),
                          Text(
                            'Preparando vista previa…',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else if (!value.isPlaying)
                const Icon(Icons.play_circle_fill,
                    size: 72, color: Colors.white70),
              Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primary,
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: controller.value.volume > 0
                            ? 'Silenciar'
                            : 'Activar sonido',
                        onPressed: () {
                          setState(() {
                            controller.setVolume(
                              controller.value.volume > 0 ? 0 : 1,
                            );
                          });
                        },
                        icon: Icon(
                          controller.value.volume > 0
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
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
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final MultimediaItem item;


  final double? height;
  final VoidCallback? onTap;

  const _MediaTile({required this.item, this.height, this.onTap});

  bool get _esVideo => item.tipo == 'video';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _contenido(context),
              if (_esVideo)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    final superficie = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.surfaceDim
        : AppColors.surfaceDim;

    if (_esVideo) {
      final poster = resolverUrlMedia(item.poster);

      if (poster != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              poster,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.play_circle_fill,
                  size: 56,
                  color: Colors.white70,
                ),
              ),
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_circle_fill,
                size: 56,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_circle_fill,
          size: 56,
          color: Colors.white70,
        ),
      );
    }

    return Image.network(
      resolverUrlMedia(item.url) ?? item.url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        return Container(
          color: superficie,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: superficie,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
