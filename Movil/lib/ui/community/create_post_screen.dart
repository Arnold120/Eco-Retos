import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/imagen_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../widgets/user_avatar.dart';
import 'cubit/community_cubit.dart';
import 'widgets/link_preview.dart';
import 'widgets/post_helpers.dart';

/// Compositor de publicaciones (crear y editar).
class CreatePostScreen extends StatefulWidget {
  final int usuarioId;

  /// Si viene, la pantalla funciona en modo edicion.
  final PublicacionResponse? post;

  const CreatePostScreen({
    super.key,
    required this.usuarioId,
    this.post,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _texto = TextEditingController();
  final _ubicacion = TextEditingController();

  final List<MultimediaItem> _multimedia = [];

  /// Ruta local -> progreso (0..1) de los archivos en subida.
  final Map<String, double> _subiendo = {};

  TipoPublicacion _tipo = TipoPublicacion.general;
  String? _categoria;
  String _visibilidad = 'PUBLICO';
  bool _publicando = false;
  String? _error;
  bool _mostrarPreviewEnlace = true;

  bool get _esEdicion => widget.post != null;

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    if (post != null) {
      _texto.text = post.contenido;
      _ubicacion.text = post.ubicacion ?? '';
      _tipo = post.tipoEnum;
      _categoria = post.categoria;
      _visibilidad = post.visibilidad;
      _multimedia.addAll(post.multimedia);
    }
  }

  @override
  void dispose() {
    _texto.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  bool get _puedePublicar =>
      !_publicando &&
      _subiendo.isEmpty &&
      (_texto.text.trim().isNotEmpty || _multimedia.isNotEmpty);

  String? get _urlDetectada {
    if (!_mostrarPreviewEnlace) return null;
    return primerEnlace(_texto.text);
  }

  Future<void> _publicar() async {
    if (_subiendo.isNotEmpty) {
      _aviso('Espera a que terminen de subirse los archivos multimedia.');
      return;
    }
    if (!_puedePublicar) return;
    setState(() {
      _publicando = true;
      _error = null;
    });

    final cubit = context.read<CommunityCubit>();
    final contenido = _texto.text.trim();
    final ubicacion =
        _ubicacion.text.trim().isEmpty ? null : _ubicacion.text.trim();

    PublicacionResponse? resultado;
    if (_esEdicion) {
      resultado = await cubit.editarPublicacion(
        widget.post!,
        contenido: contenido,
        ubicacion: ubicacion,
        categoria: _categoria,
        visibilidad: _visibilidad,
        multimedia: _multimedia,
      );
    } else {
      resultado = await cubit.crearPublicacion(
        contenido: contenido,
        tipo: TipoHelpers.toApi(_tipo),
        ubicacion: ubicacion,
        categoria: _categoria,
        visibilidad: _visibilidad,
        multimedia: _multimedia,
      );
    }

    if (!mounted) return;
    setState(() => _publicando = false);

    if (resultado != null) {
      Navigator.of(context).pop(resultado);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Publicación actualizada correctamente'
                : 'Publicación creada correctamente',
          ),
        ),
      );
    } else {
      setState(() {
        _error = _esEdicion
            ? 'No se pudo actualizar la publicación. Inténtalo nuevamente.'
            : 'No se pudo publicar. Inténtalo nuevamente.';
      });
    }
  }

  // ─── Multimedia ─────────────────────────────────────────────────────────

  Future<void> _elegirFotos() async {
    if (_multimedia.length >= 10) {
      _aviso('Puedes adjuntar hasta 10 elementos.');
      return;
    }

    List<XFile> archivos;
    try {
      archivos = await ImagePicker().pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
    } catch (_) {
      _aviso('No se pudo abrir la galería.');
      return;
    }
    if (archivos.isEmpty) return;

    for (final archivo in archivos.take(10 - _multimedia.length)) {
      await _subirArchivo(archivo, esVideo: false);
    }
  }

  Future<void> _elegirVideo() async {
    if (_multimedia.length >= 10) {
      _aviso('Puedes adjuntar hasta 10 elementos.');
      return;
    }

    XFile? archivo;
    try {
      archivo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
    } catch (_) {
      _aviso('No se pudo abrir la galería.');
      return;
    }
    if (archivo == null || !mounted) return;

    // Vista previa + recorte antes de subir.
    final recorte = await showDialog<_RecorteVideo>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditorVideoDialog(archivo: archivo!),
    );
    if (recorte == null || !mounted) return;

    final resultado = await _optimizarVideo(recorte);
    if (!mounted) return;
    await _subirVideoConProgreso(
      resultado.archivo,
      poster: resultado.poster,
    );
  }

  /// Recorta/optimiza el video para movil. Si la plataforma no soporta la
  /// compresion (por ejemplo escritorio) o el archivo ya es pequeno, se sube
  /// el original sin bloquear el flujo.
  Future<({File archivo, String? poster})> _optimizarVideo(
      _RecorteVideo recorte) async {
    final archivo = recorte.archivo;
    final tamanio = await archivo.length();
    final duracionRecorte = recorte.fin - recorte.inicio;
    final hayRecorte = recorte.inicio > Duration.zero ||
        duracionRecorte < recorte.duracionTotal;

    Future<String?> subirPoster() async {
      if (recorte.poster == null) return null;
      try {
        final subida = await context.read<ImagenService>().subirMedia(
              recorte.poster!,
            );
        return subida.url;
      } catch (_) {
        return null;
      }
    }

    // Archivos livianos sin recorte: solo se sube la portada elegida.
    if (!hayRecorte && tamanio < 4 * 1024 * 1024) {
      return (archivo: archivo, poster: await subirPoster());
    }

    final progreso = ValueNotifier<double>(0);
    if (!mounted) return (archivo: archivo, poster: null);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Optimizando video…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recortando y comprimiendo el video para que cargue más rápido.',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<double>(
                valueListenable: progreso,
                builder: (context, valor, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: valor <= 0 ? null : valor,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(valor * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Subscription? suscripcion;
    try {
      // Limpia cualquier proceso anterior que haya quedado colgado.
      try {
        await VideoCompress.cancelCompression();
      } catch (_) {}
      suscripcion = VideoCompress.compressProgress$.subscribe((p) {
        progreso.value = (p / 100).clamp(0.0, 1.0);
      });
      final info = await VideoCompress.compressVideo(
        archivo.path,
        quality: VideoQuality.MediumQuality,
        startTime: recorte.inicio.inMilliseconds,
        duration: duracionRecorte.inMilliseconds,
        includeAudio: true,
        deleteOrigin: false,
      );
      final resultado = info?.file;
      final poster = await subirPoster();
      if (resultado != null && await resultado.exists()) {
        if (mounted && hayRecorte) {
          final messenger = ScaffoldMessenger.of(context);
          final mb =
              ((await resultado.length()) / (1024 * 1024)).toStringAsFixed(1);
          messenger.showSnackBar(
            SnackBar(
              content: Text('Video recortado y optimizado ($mb MB)'),
            ),
          );
        }
        return (archivo: resultado, poster: poster);
      }
      // No se pudo comprimir/recortar: se avisa y se sube el original.
      if (mounted && hayRecorte) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo recortar el video en este dispositivo; se '
              'publicará completo.',
            ),
          ),
        );
      }
      return (archivo: archivo, poster: poster);
    } catch (_) {
      // Sin soporte de compresion en esta plataforma: se sube el original.
      if (mounted && hayRecorte) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo recortar el video en este dispositivo; se '
              'publicará completo.',
            ),
          ),
        );
      }
      return (archivo: archivo, poster: await subirPoster());
    } finally {
      suscripcion?.unsubscribe();
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      progreso.dispose();
    }
  }

  /// Sube una imagen o video. Las imagenes muestran progreso en la galeria;
  /// los videos muestran una pantalla de carga con porcentaje real y no
  /// pueden publicarse hasta completar la subida.
  Future<void> _subirArchivo(XFile archivo, {required bool esVideo}) async {
    if (esVideo) {
      await _subirVideoConProgreso(File(archivo.path));
      return;
    }

    final ruta = archivo.path;
    setState(() => _subiendo[ruta] = 0);
    try {
      final subida = await context.read<ImagenService>().subirMedia(
            File(ruta),
            onProgress: (p) {
              if (mounted) setState(() => _subiendo[ruta] = p);
            },
          );
      if (!mounted) return;
      setState(() {
        _multimedia.add(
            (url: subida.url, tipo: 'imagen', duracion: null, poster: null));
        _subiendo.remove(ruta);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _subiendo.remove(ruta));
      final mensaje =
          e is ApiException ? e.userMessage : 'No se pudo subir la imagen.';
      _aviso(mensaje);
    }
  }

  Future<void> _subirVideoConProgreso(File archivo, {String? poster}) async {
    final progreso = ValueNotifier<double>(0);
    final tamanio = await archivo.length();
    final pesoMb = (tamanio / (1024 * 1024)).toStringAsFixed(1);

    if (!mounted) return;
    setState(() => _subiendo[archivo.path] = 0);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Subiendo video…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${archivo.uri.pathSegments.last} · $pesoMb MB',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<double>(
                valueListenable: progreso,
                builder: (context, valor, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: valor <= 0 ? null : valor,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(valor * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No cierres esta pantalla hasta que termine la carga.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final subida = await context.read<ImagenService>().subirMedia(
            archivo,
            onProgress: (p) => progreso.value = p,
          );
      progreso.value = 1;
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        _multimedia.add((
          url: subida.url,
          tipo: 'video',
          duracion: null,
          poster: poster,
        ));
        _subiendo.remove(archivo.path);
      });
      _aviso('Video subido. Ya puedes publicar.');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _subiendo.remove(archivo.path));
      final mensaje = e is ApiException
          ? e.userMessage
          : 'No se pudo subir el video.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () => _subirVideoConProgreso(archivo, poster: poster),
          ),
        ),
      );
    } finally {
      progreso.dispose();
    }
  }

  Future<void> _agregarPorUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar por URL'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://…/imagen.jpg o video.mp4',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _aviso('La URL no es válida.');
      return;
    }
    final esVideo = RegExp(r'\.(mp4|mov|webm|avi)(\?.*)?$', caseSensitive: false)
        .hasMatch(url);
    final esImagen =
        RegExp(r'\.(png|jpe?g|webp|gif)(\?.*)?$', caseSensitive: false)
            .hasMatch(url);
    if (!esVideo && !esImagen) {
      _aviso(
        'Esa URL no es una imagen ni un video. Pégala en el texto y se '
        'mostrará como vista previa.',
      );
      return;
    }
    setState(() {
      _multimedia
          .add((
        url: url,
        tipo: esVideo ? 'video' : 'imagen',
        duracion: null,
        poster: null,
      ));
    });
  }

  // ─── Selectores ─────────────────────────────────────────────────────────

  Future<void> _elegirVisibilidad() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                '¿Quién puede ver esta publicación?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            _opcionPrivacidad(
              ctx,
              valor: 'PUBLICO',
              icono: Icons.public,
              titulo: 'Público',
              subtitulo: 'Cualquier persona en el Muro Eco',
            ),
            _opcionPrivacidad(
              ctx,
              valor: 'SEGUIDORES',
              icono: Icons.people_outline,
              titulo: 'Seguidores',
              subtitulo: 'Solo quienes te siguen',
            ),
            _opcionPrivacidad(
              ctx,
              valor: 'SOLO_YO',
              icono: Icons.lock_outline,
              titulo: 'Solo yo',
              subtitulo: 'Nadie más puede verla',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (opcion != null) setState(() => _visibilidad = opcion);
  }

  Widget _opcionPrivacidad(
    BuildContext ctx, {
    required String valor,
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    final seleccionado = _visibilidad == valor;
    return ListTile(
      leading: Icon(icono,
          color: seleccionado ? AppColors.primary : null),
      title: Text(titulo,
          style: TextStyle(
              fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w600)),
      subtitle: Text(subtitulo),
      trailing: seleccionado
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => Navigator.of(ctx).pop(valor),
    );
  }

  Future<void> _editarUbicacion() async {
    final controller = TextEditingController(text: _ubicacion.text);
    final lugar = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubicación'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Ej. Parque Central, Managua'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (lugar != null) {
      setState(() => _ubicacion.text = lugar);
    }
  }

  void _insertarTextoEnCursor(String inserto) {
    final seleccion = _texto.selection;
    final inicio = seleccion.isValid ? seleccion.start : _texto.text.length;
    final fin = seleccion.isValid ? seleccion.end : _texto.text.length;
    final nuevo = _texto.text.replaceRange(inicio, fin, inserto);
    _texto.text = nuevo;
    _texto.selection = TextSelection.collapsed(offset: inicio + inserto.length);
    setState(() {});
  }

  void _insertarHashtag() {
    final texto = _texto.text;
    final prefijo = texto.isEmpty || texto.endsWith(' ') ? '' : ' ';
    _insertarTextoEnCursor('$prefijo#EcoRetos ');
  }

  /// Permite etiquetar a las personas que el usuario sigue.
  Future<void> _insertarMencion() async {
    List<UsuarioResumen> seguidos;
    try {
      seguidos = await context.read<SeguimientoService>().getSiguiendo(
            widget.usuarioId,
          );
    } catch (_) {
      _aviso('No pudimos cargar tus contactos. Inténtalo nuevamente.');
      return;
    }
    if (!mounted) return;
    if (seguidos.isEmpty) {
      _aviso('Aún no sigues a nadie. Sigue a otros usuarios para etiquetarlos.');
      return;
    }

    final elegido = await showModalBottomSheet<UsuarioResumen>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _SelectorMenciones(usuarios: seguidos),
    );
    if (elegido == null || !mounted) return;

    final texto = _texto.text;
    final prefijo = texto.isEmpty || texto.endsWith(' ') ? '' : ' ';
    _insertarTextoEnCursor('$prefijo@${elegido.nombreUsuario} ');
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ─── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceDim =
        isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim;

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.background : AppColors.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar publicación' : 'Nueva publicación'),
        leading: IconButton(
          tooltip: 'Cancelar',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _puedePublicar ? _publicar : null,
              child: _publicando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _esEdicion ? 'Guardar' : 'Publicar',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: AppColors.error.withValues(alpha: 0.15),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  TextButton(
                    onPressed: _puedePublicar ? _publicar : null,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const CurrentUserAvatar(radius: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: _elegirVisibilidad,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: surfaceDim,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_iconoVisibilidad, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _labelVisibilidad,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _texto,
                  minLines: 4,
                  maxLines: 10,
                  autofocus: !_esEdicion,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText:
                        'Cuenta qué acción ambiental hiciste hoy… Usa #hashtags y @menciones.',
                    hintStyle: TextStyle(
                        color: AppColors.textHint, fontSize: 15, height: 1.4),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: textColor(context),
                  ),
                ),
                if (_urlDetectada != null)
                  LinkPreviewCard(
                    url: _urlDetectada!,
                    permitirQuitar: true,
                    onQuitar: () =>
                        setState(() => _mostrarPreviewEnlace = false),
                  ),
                if (_multimedia.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _galeriaEditable(),
                ],
                if (_subiendo.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _subiendo.entries.map((e) {
                      final nombre = e.key.split(RegExp(r'[/\\]')).last;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subiendo $nombre… ${(e.value * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textSecondaryColor(context),
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: e.value <= 0 ? null : e.value,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                _seccion('Añadir a tu publicación'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _accion(Icons.photo_library_outlined, 'Fotos',
                        _elegirFotos),
                    _accion(Icons.videocam_outlined, 'Video',
                        _elegirVideo),
                    _accion(Icons.link, 'URL multimedia', _agregarPorUrl),
                    _accion(Icons.place_outlined, 'Ubicación',
                        _editarUbicacion),
                    _accion(Icons.tag, 'Hashtag', _insertarHashtag),
                    _accion(Icons.alternate_email, 'Mencionar',
                        _insertarMencion),
                  ],
                ),
                if (_ubicacion.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.place,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _ubicacion.text,
                          style: TextStyle(
                            color: textSecondaryColor(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Quitar ubicación',
                        onPressed: () => setState(() => _ubicacion.clear()),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _seccion('Tipo de publicación'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _tipoChip(TipoPublicacion.general, 'General'),
                    _tipoChip(TipoPublicacion.logro, 'Logro'),
                    _tipoChip(TipoPublicacion.actividad, 'Actividad'),
                    _tipoChip(TipoPublicacion.iniciativa, 'Iniciativa'),
                  ],
                ),
                const SizedBox(height: 16),
                _seccion('Categoría ambiental'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AmbientCategories.all.entries.map((e) {
                    final seleccionado = _categoria == e.key;
                    return FilterChip(
                      label: Text(e.value),
                      selected: seleccionado,
                      onSelected: (_) => setState(
                          () => _categoria = seleccionado ? null : e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _iconoVisibilidad => switch (_visibilidad) {
        'SEGUIDORES' => Icons.people_outline,
        'SOLO_YO' => Icons.lock_outline,
        _ => Icons.public,
      };

  String get _labelVisibilidad => switch (_visibilidad) {
        'SEGUIDORES' => 'Seguidores',
        'SOLO_YO' => 'Solo yo',
        _ => 'Público',
      };

  Widget _seccion(String titulo) {
    return Text(
      titulo,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: textColor(context),
      ),
    );
  }

  Widget _tipoChip(TipoPublicacion tipo, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _tipo == tipo,
      onSelected: (_) => setState(() => _tipo = tipo),
    );
  }

  Widget _accion(IconData icono, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icono, size: 16, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _galeriaEditable() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _multimedia.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        final item = _multimedia[i];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.tipo == 'video'
                  ? Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: const Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 34),
                    )
                  : Image.network(
                      resolverUrlMedia(item.url) ?? item.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceDim,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => setState(() => _multimedia.removeAt(i)),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Selector de usuarios seguidos para insertar menciones @.
class _SelectorMenciones extends StatefulWidget {
  final List<UsuarioResumen> usuarios;

  const _SelectorMenciones({required this.usuarios});

  @override
  State<_SelectorMenciones> createState() => _SelectorMencionesState();
}

class _SelectorMencionesState extends State<_SelectorMenciones> {
  String _filtro = '';

  List<UsuarioResumen> get _filtrados {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return widget.usuarios;
    return widget.usuarios
        .where((u) => u.nombreUsuario.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Etiquetar a alguien',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _filtro = v),
                decoration: InputDecoration(
                  hintText: 'Buscar en tus seguidos…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor:
                      isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtrados.isEmpty
                  ? Center(
                      child: Text(
                        'Sin coincidencias',
                        style: TextStyle(
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtrados.length,
                      itemBuilder: (context, i) {
                        final u = _filtrados[i];
                        return ListTile(
                          leading: UserAvatar(
                            nombre: u.nombreUsuario,
                            fotoUrl: u.fotoPerfil,
                            radius: 20,
                          ),
                          title: Text(u.nombreUsuario),
                          subtitle: Text('@${u.nombreUsuario}'),
                          onTap: () => Navigator.of(context).pop(u),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Datos del recorte elegido por el usuario antes de optimizar/subir.
class _RecorteVideo {
  final File archivo;
  final Duration inicio;
  final Duration fin;
  final Duration duracionTotal;

  /// Fotograma elegido como portada del video (puede ser null).
  final File? poster;

  const _RecorteVideo({
    required this.archivo,
    required this.inicio,
    required this.fin,
    required this.duracionTotal,
    this.poster,
  });
}

String _formatoSegundos(double segundos) {
  final total = segundos.round();
  final min = total ~/ 60;
  final seg = (total % 60).toString().padLeft(2, '0');
  return '$min:$seg';
}

/// Vista previa del video con recorte opcional antes de publicarlo.
class _EditorVideoDialog extends StatefulWidget {
  final XFile archivo;

  const _EditorVideoDialog({required this.archivo});

  @override
  State<_EditorVideoDialog> createState() => _EditorVideoDialogState();
}

class _EditorVideoDialogState extends State<_EditorVideoDialog> {
  VideoPlayerController? _controller;
  bool _cargando = true;
  bool _error = false;
  double _duracion = 0;
  RangeValues _rango = const RangeValues(0, 0);
  bool _usarPortada = true;
  double _posicionPortada = 1;
  Uint8List? _portadaBytes;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final controller = VideoPlayerController.file(File(widget.archivo.path));
    try {
      await controller.initialize();
      await controller.seekTo(const Duration(milliseconds: 1));
      final duracion = controller.value.duration.inMilliseconds / 1000;
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _duracion = duracion;
        _rango = RangeValues(0, duracion);
        _cargando = false;
      });
      if (_usarPortada) _actualizarPortada(_posicionPortada);
    } catch (_) {
      await controller.dispose();
      // Respaldo: se obtiene la duracion con el plugin nativo para que el
      // recorte y la portada sigan disponibles sin vista previa.
      double? duracion;
      try {
        final info = await VideoCompress.getMediaInfo(widget.archivo.path);
        final ms = double.tryParse('${info.duration}') ?? 0;
        if (ms > 0) duracion = ms / 1000;
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = true;
        if (duracion != null) {
          _duracion = duracion;
          _rango = RangeValues(0, duracion);
        }
      });
      if (duracion != null && _usarPortada) {
        _actualizarPortada(_posicionPortada);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    File? poster;
    if (_usarPortada) {
      poster = await _generarPortada(_posicionPortada);
      if (poster == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar la portada en este dispositivo; el video '
              'se publicará sin imagen de inicio.',
            ),
          ),
        );
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(_RecorteVideo(
      archivo: File(widget.archivo.path),
      inicio: Duration(milliseconds: (_rango.start * 1000).round()),
      fin: Duration(milliseconds: (_rango.end * 1000).round()),
      duracionTotal: Duration(milliseconds: (_duracion * 1000).round()),
      poster: poster,
    ));
  }

  /// Mueve el video al segundo indicado y lo deja en pausa: asi el fotograma
  /// elegido se ve en la propia vista previa.
  void _irAFotograma(double segundos) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.pause();
    controller.seekTo(Duration(milliseconds: (segundos * 1000).round()));
  }

  Future<void> _actualizarPortada(double segundos) async {
    _irAFotograma(segundos);
    try {
      final bytes = await VideoCompress.getByteThumbnail(
        widget.archivo.path,
        quality: 60,
        position: (segundos * 1000).round(),
      );
      if (!mounted || bytes == null || bytes.isEmpty) return;
      setState(() => _portadaBytes = bytes);
    } catch (_) {
      // La vista previa del video sigue mostrando el fotograma elegido.
    }
  }

  /// Genera el archivo de portada (con respaldo por bytes).
  Future<File?> _generarPortada(double segundos) async {
    final ms = (segundos * 1000).round();
    try {
      final archivo = await VideoCompress.getFileThumbnail(
        widget.archivo.path,
        quality: 75,
        position: ms,
      );
      if (await archivo.exists() && await archivo.length() > 0) return archivo;
    } catch (_) {}
    try {
      final bytes = await VideoCompress.getByteThumbnail(
        widget.archivo.path,
        quality: 75,
        position: ms,
      );
      if (bytes == null || bytes.isEmpty) return null;
      final temp = await getTemporaryDirectory();
      final destino = File(
        '${temp.path}${Platform.pathSeparator}portada_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await destino.writeAsBytes(bytes);
      return destino;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AlertDialog(
      title: const Text('Vista previa del video'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_cargando)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_error || controller == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'La vista previa del video no está disponible en este '
                    'dispositivo, pero puedes recortarlo y elegir la portada.',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(controller),
                          if (!controller.value.isPlaying)
                            const Icon(Icons.play_circle_fill,
                                size: 60, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_duracion > 2) ...[
                const SizedBox(height: 14),
                const Text(
                  'Recorta el video si lo necesitas',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                RangeSlider(
                  values: _rango,
                  min: 0,
                  max: _duracion,
                  labels: RangeLabels(
                    _formatoSegundos(_rango.start),
                    _formatoSegundos(_rango.end),
                  ),
                  onChanged: (valores) {
                    if (valores.end - valores.start < 1) return;
                    setState(() => _rango = valores);
                    _irAFotograma(valores.start);
                  },
                  onChangeEnd: (_) => _irAFotograma(_rango.start),
                ),
                Text(
                  '${_formatoSegundos(_rango.start)} – ${_formatoSegundos(_rango.end)} '
                  '· ${(_rango.end - _rango.start).toStringAsFixed(1)}s de ${_formatoSegundos(_duracion)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (_duracion > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Switch(
                      value: _usarPortada,
                      onChanged: (v) {
                        setState(() => _usarPortada = v);
                        if (v) _actualizarPortada(_posicionPortada);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Elegir portada del video',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    if (_portadaBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          _portadaBytes!,
                          width: 64,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
                if (_usarPortada && _duracion > 2)
                  Slider(
                    value: _posicionPortada.clamp(0, _duracion),
                    min: 0,
                    max: _duracion,
                    label: _formatoSegundos(_posicionPortada),
                    onChangeEnd: _actualizarPortada,
                    onChanged: (v) {
                      setState(() => _posicionPortada = v);
                      _irAFotograma(v);
                    },
                  ),
                const SizedBox(height: 6),
                const Text(
                  'La portada se verá en el muro como imagen de inicio del video.',
                  style: TextStyle(fontSize: 11.5),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => _confirmar(),
          child: const Text('Usar video'),
        ),
      ],
    );
  }
}
