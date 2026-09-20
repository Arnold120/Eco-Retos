import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/imagen_service.dart';
import '../../data/services/mensaje_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/social_service.dart';
import '../community/post_detail_screen.dart';
import '../community/widgets/post_card_skeleton.dart';
import '../community/widgets/post_helpers.dart';
import '../community/widgets/post_media.dart';
import '../widgets/user_avatar.dart';
import 'cubit/conversation_cubit.dart';

class ConversationScreen extends StatelessWidget {
  final int conversacionId;
  final int usuarioId;
  final String titulo;



  final String? fotoUrl;

  const ConversationScreen({
    super.key,
    required this.conversacionId,
    required this.usuarioId,
    required this.titulo,
    this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ConversationCubit(
        conversacionId: conversacionId,
        usuarioId: usuarioId,
        service: ctx.read<MensajeService>(),
      )..load(),
      child: Scaffold(
        body: MuroConversacionView(
          conversacionId: conversacionId,
          usuarioId: usuarioId,
          titulo: titulo,
          fotoUrl: fotoUrl,
          onVolver: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}


class MuroConversacionView extends StatefulWidget {
  final int conversacionId;
  final int usuarioId;
  final String titulo;
  final String? fotoUrl;


  final VoidCallback? onVolver;

  const MuroConversacionView({
    super.key,
    required this.conversacionId,
    required this.usuarioId,
    required this.titulo,
    this.fotoUrl,
    this.onVolver,
  });

  @override
  State<MuroConversacionView> createState() => _MuroConversacionViewState();
}

class _MuroConversacionViewState extends State<MuroConversacionView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  late String _nombre;
  String? _foto;
  MensajeResponse? _respondiendo;
  final Map<int, GlobalKey> _claves = {};
  final _picker = ImagePicker();
  bool _subiendoAdjunto = false;

  @override
  void initState() {
    super.initState();
    _nombre = widget.titulo;
    _foto = widget.fotoUrl;
    _scroll.addListener(() {


      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 80) {
        context.read<ConversationCubit>().cargarMas();
      }
    });
    if (_foto == null) _resolverContacto();
  }


  Future<void> _resolverContacto() async {
    try {
      final conversaciones =
          await context.read<MensajeService>().getConversaciones();
      if (!mounted) return;
      for (final c in conversaciones) {
        if (c.conversacionId == widget.conversacionId) {
          setState(() {
            _nombre = c.otroNombreUsuario;
            _foto = c.otroFotoPerfil;
          });
          return;
        }
      }
    } catch (_) {

    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    final respondiendo = _respondiendo;
    final ok = await context.read<ConversationCubit>().enviar(
          texto,
          respuestaAId: respondiendo?.mensajeId,
        );
    if (!mounted) return;
    if (ok) {
      _controller.clear();
      setState(() => _respondiendo = null);
      _focus.requestFocus();
      _bajarAlUltimoMensaje();
    }
  }

  String _resumenMensaje(MensajeResponse mensaje) {
    switch (mensaje.tipo) {
      case 'IMAGEN':
        return mensaje.contenido.isNotEmpty ? '📷 ${mensaje.contenido}' : '📷 Foto';
      case 'VIDEO':
        return mensaje.contenido.isNotEmpty ? '🎥 ${mensaje.contenido}' : '🎥 Video';
      case 'PUBLICACION':
        return '📰 Publicación compartida';
      default:
        return mensaje.contenido;
    }
  }

  MensajeResponse? _buscarMensaje(int id) {
    for (final m in context.read<ConversationCubit>().state.mensajes) {
      if (m.mensajeId == id) return m;
    }
    return null;
  }

  void _saltarAMensaje(int id) {
    final key = _claves[id];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 250),
      alignment: 0.4,
    );
  }

  void _copiar(MensajeResponse mensaje) {
    Clipboard.setData(ClipboardData(text: mensaje.contenido));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje copiado')),
    );
  }

  Future<void> _mostrarOpciones(MensajeResponse mensaje) async {
    final esMio = mensaje.remitenteId == widget.usuarioId;
    final esReciente = DateTime.now().difference(mensaje.fecha) <=
        const Duration(hours: 2);
    final puedeEditarOEliminarTodos = esMio && esReciente;

    final accion = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.surface
          : AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copiar'),
              onTap: () => Navigator.of(ctx).pop('copiar'),
            ),
            if (puedeEditarOEliminarTodos)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar mensaje'),
                onTap: () => Navigator.of(ctx).pop('editar'),
              ),
            if (puedeEditarOEliminarTodos)
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined),
                title: const Text('Eliminar para todos'),
                onTap: () => Navigator.of(ctx).pop('todos'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar para mí'),
              onTap: () => Navigator.of(ctx).pop('mi'),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );

    if (!mounted || accion == null) return;
    if (accion == 'copiar') {
      _copiar(mensaje);
    } else if (accion == 'editar') {
      await _editarMensaje(mensaje);
    } else if (accion == 'todos') {
      await context
          .read<ConversationCubit>()
          .eliminar(mensaje.mensajeId, paraTodos: true);
    } else if (accion == 'mi') {
      await context
          .read<ConversationCubit>()
          .eliminar(mensaje.mensajeId, paraTodos: false);
    }
  }

  Future<void> _editarMensaje(MensajeResponse mensaje) async {
    final controller = TextEditingController(text: mensaje.contenido);
    final nuevo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar mensaje'),
        content: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Mensaje'),
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
    if (!mounted ||
        nuevo == null ||
        nuevo.isEmpty ||
        nuevo == mensaje.contenido) {
      return;
    }
    await context.read<ConversationCubit>().editar(mensaje.mensajeId, nuevo);
  }

  Future<void> _adjuntar({required bool video}) async {
    if (_subiendoAdjunto) return;
    final archivo = video
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
    if (archivo == null || !mounted) return;
    setState(() => _subiendoAdjunto = true);
    try {
      final subida =
          await context.read<ImagenService>().subirMedia(File(archivo.path));
      if (!mounted) return;
      final respondiendo = _respondiendo;
      final ok = await context.read<ConversationCubit>().enviar(
            '',
            tipo: video ? 'VIDEO' : 'IMAGEN',
            archivoUrl: subida.url,
            respuestaAId: respondiendo?.mensajeId,
          );
      if (!mounted) return;
      if (ok) {
        setState(() => _respondiendo = null);
        _bajarAlUltimoMensaje();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el archivo.')),
      );
    } finally {
      if (mounted) setState(() => _subiendoAdjunto = false);
    }
  }


  void _bajarAlUltimoMensaje() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ConversationCubit, ConversationState>(
      listenWhen: (a, b) => a.error != b.error && b.error != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      },
      child: Column(
        children: [
          _cabecera(context, isDark),
          Expanded(
              child: BlocBuilder<ConversationCubit, ConversationState>(
                builder: (context, state) {
                  if (state.isLoading && state.mensajes.isEmpty) {
                    return const PostCardSkeleton();
                  }
                  if (state.error != null && state.mensajes.isEmpty) {
                    return SocialErrorState(
                      mensaje: state.error!,
                      onReintentar: () =>
                          context.read<ConversationCubit>().load(),
                    );
                  }
                  if (state.mensajes.isEmpty) {
                    return const SocialEmptyState(
                      icono: Icons.chat_outlined,
                      titulo: 'Sin mensajes todavía',
                      subtitulo: 'Escribe el primero para iniciar la conversación.',
                    );
                  }


                  final mensajes = state.mensajes.reversed.toList();
                  return ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount:
                        mensajes.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= mensajes.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final mensaje = mensajes[i];
                      final esMio = mensaje.remitenteId == widget.usuarioId;
                      final mostrarAvatar = i == mensajes.length - 1 ||
                          mensajes[i + 1].remitenteId != mensaje.remitenteId;
                      return _burbuja(
                        context,
                        mensaje,
                        esMio: esMio,
                        mostrarAvatar: mostrarAvatar,
                      );
                    },
                  );
                },
              ),
            ),
          _compositor(isDark),
        ],
      ),
    );
  }

  Widget _cabecera(BuildContext context, bool isDark) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surface : AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: dividerColor(context).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            if (widget.onVolver != null)
              IconButton(
                tooltip: 'Volver a mensajes',
                onPressed: widget.onVolver,
                icon: const Icon(Icons.arrow_back),
              )
            else
              const SizedBox(width: 4),
            UserAvatar(nombre: _nombre, fotoUrl: _foto, radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _burbuja(
    BuildContext context,
    MensajeResponse mensaje, {
    required bool esMio,
    required bool mostrarAvatar,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = textSecondaryColor(context);
    final textoColor = esMio ? Colors.white : textColor(context);
    final esAdjunto = mensaje.tipo == 'IMAGEN' || mensaje.tipo == 'VIDEO';

    return Padding(
      padding: EdgeInsets.only(top: mostrarAvatar ? 10 : 3),
      child: Row(
        mainAxisAlignment:
            esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esMio)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: mostrarAvatar
                  ? UserAvatar(nombre: _nombre, fotoUrl: _foto, radius: 14)
                  : const SizedBox(width: 28),
            ),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _mostrarOpciones(mensaje),
              onHorizontalDragEnd: (detalles) {
                final velocidad = detalles.primaryVelocity ?? 0;
                if (velocidad.abs() > 200) {
                  setState(() => _respondiendo = mensaje);
                }
              },
              child: Container(
                key: _claves.putIfAbsent(
                  mensaje.mensajeId,
                  () => GlobalKey(),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: esMio
                      ? AppColors.primary
                      : (isDark
                          ? AppColorsDark.surfaceCard
                          : AppColors.surfaceCard),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(esMio ? 14 : 4),
                    bottomRight: Radius.circular(esMio ? 4 : 14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: esMio
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (mensaje.respuestaAId != null)
                      _citaRespuesta(context, mensaje, esMio),
                    if (mensaje.tipo == 'IMAGEN' &&
                        mensaje.archivoUrl != null)
                      _adjuntoImagen(context, mensaje),
                    if (mensaje.tipo == 'VIDEO' &&
                        mensaje.archivoUrl != null)
                      _adjuntoVideo(context, mensaje),
                    if (mensaje.tipo == 'PUBLICACION' &&
                        mensaje.publicacionId != null)
                      _TarjetaPublicacion(
                        publicacionId: mensaje.publicacionId!,
                        esMio: esMio,
                        usuarioId: widget.usuarioId,
                      ),
                    if (!esAdjunto && mensaje.contenido.isNotEmpty)
                      Text(
                        mensaje.contenido,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: textoColor,
                        ),
                      ),
                    if (esAdjunto && mensaje.contenido.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        mensaje.contenido,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: textoColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mensaje.editado) ...[
                          Text(
                            'editado',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontStyle: FontStyle.italic,
                              color: esMio ? Colors.white70 : sec,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          horaMensaje(mensaje.fecha),
                          style: TextStyle(
                            fontSize: 10,
                            color: esMio ? Colors.white70 : sec,
                          ),
                        ),
                        if (esMio) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done_all,
                            size: 14,
                            color: mensaje.leido
                                ? const Color(0xFF34B7F1)
                                : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _citaRespuesta(
    BuildContext context,
    MensajeResponse mensaje,
    bool esMio,
  ) {
    final original = _buscarMensaje(mensaje.respuestaAId!);
    final color = esMio ? Colors.white : primaryOf(context);
    final nombre = original == null
        ? 'Mensaje'
        : (original.remitenteId == widget.usuarioId ? 'Tú' : _nombre);
    final resumen =
        original == null ? 'Mensaje' : _resumenMensaje(original);
    final miniatura = original?.tipo == 'IMAGEN' && original?.archivoUrl != null
        ? resolverUrlMedia(original!.archivoUrl)
        : null;

    return GestureDetector(
      onTap: original == null
          ? null
          : () => _saltarAMensaje(original.mensajeId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: esMio
              ? Colors.black.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: color.withValues(alpha: 0.9), width: 3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: color,
                    ),
                  ),
                  Text(
                    resumen,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: esMio ? Colors.white70 : textSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (miniatura != null) ...[
              const SizedBox(width: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  miniatura,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _adjuntoImagen(BuildContext context, MensajeResponse mensaje) {
    final url = resolverUrlMedia(mensaje.archivoUrl);
    if (url == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => abrirVisorMultimedia(
        context,
        [(url: url, tipo: 'imagen', duracion: null, poster: null)],
        0,
        nombreSugerido: 'mensaje',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              size: 42,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _adjuntoVideo(BuildContext context, MensajeResponse mensaje) {
    final url = resolverUrlMedia(mensaje.archivoUrl);
    if (url == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => abrirVisorMultimedia(
        context,
        [(url: url, tipo: 'video', duracion: null, poster: null)],
        0,
        nombreSugerido: 'mensaje',
      ),
      child: Container(
        width: 200,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 46, color: Colors.white),
        ),
      ),
    );
  }

  Widget _compositor(bool isDark) {
    final respondiendo = _respondiendo;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.divider : AppColors.divider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (respondiendo != null) _vistaResponder(respondiendo, isDark),
            BlocBuilder<ConversationCubit, ConversationState>(
              buildWhen: (a, b) => a.isSending != b.isSending,
              builder: (context, state) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      tooltip: 'Adjuntar archivo',
                      enabled: !_subiendoAdjunto,
                      onSelected: (valor) =>
                          _adjuntar(video: valor == 'video'),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'foto', child: Text('Foto')),
                        PopupMenuItem(value: 'video', child: Text('Video')),
                      ],
                      icon: _subiendoAdjunto
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_photo_alternate_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _enviar(),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje…',
                          hintStyle:
                              const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: isDark
                              ? AppColorsDark.surfaceDim
                              : AppColors.surfaceDim,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Enviar mensaje',
                      onPressed:
                          state.isSending || _controller.text.trim().isEmpty
                              ? null
                              : _enviar,
                      icon: state.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaResponder(MensajeResponse mensaje, bool isDark) {
    final miniatura = mensaje.tipo == 'IMAGEN' && mensaje.archivoUrl != null
        ? resolverUrlMedia(mensaje.archivoUrl)
        : null;
    final esVideo = mensaje.tipo == 'VIDEO' && mensaje.archivoUrl != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: primaryOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje.remitenteId == widget.usuarioId ? 'Tú' : _nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: primaryOf(context),
                  ),
                ),
                Text(
                  _resumenMensaje(mensaje),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          if (miniatura != null) ...[
            const SizedBox(width: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                miniatura,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          if (esVideo) ...[
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.play_circle_fill,
                size: 22,
                color: Colors.white,
              ),
            ),
          ],
          IconButton(
            tooltip: 'Cancelar respuesta',
            onPressed: () => setState(() => _respondiendo = null),
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPublicacion extends StatefulWidget {
  final int publicacionId;
  final bool esMio;
  final int usuarioId;

  const _TarjetaPublicacion({
    required this.publicacionId,
    required this.esMio,
    required this.usuarioId,
  });

  @override
  State<_TarjetaPublicacion> createState() => _TarjetaPublicacionState();
}

class _TarjetaPublicacionState extends State<_TarjetaPublicacion> {
  PublicacionResponse? _post;
  bool _cargando = true;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final post = await context
          .read<PublicacionService>()
          .getPublicacion(widget.publicacionId);
      if (!mounted) return;
      setState(() {
        _post = post;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  Future<void> _alternarLike() async {
    final post = _post;
    if (post == null || _procesando) return;
    setState(() => _procesando = true);
    try {
      final resultado = await context.read<ReaccionService>().alternar(
            publicacionId: post.publicacionId,
            tipo: 'ME_GUSTA',
          );
      if (!mounted) return;
      setState(() {
        _post = post.copyWith(
          meGusta: resultado.activa,
          cantidadLikes: resultado.total,
        );
        _procesando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esMio = widget.esMio;
    final colorTexto = esMio ? Colors.white : textColor(context);
    final colorSecundario =
        esMio ? Colors.white70 : textSecondaryColor(context);
    final fondo = esMio
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.05);

    if (_cargando) {
      return Container(
        width: 220,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final post = _post;
    if (post == null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Publicación no disponible',
          style: TextStyle(fontSize: 12.5, color: colorSecundario),
        ),
      );
    }

    MultimediaItem? primera;
    for (final item in post.multimedia) {
      if (item.tipo == 'imagen' || item.poster != null) {
        primera = item;
        break;
      }
    }

    return GestureDetector(
      onTap: () => abrirDetallePublicacion(
        context,
        post.publicacionId,
        usuarioId: widget.usuarioId,
      ),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.nombreUsuario,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: colorTexto,
              ),
            ),
            if (post.contenido.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                post.contenido,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  color: colorTexto,
                ),
              ),
            ],
            if (primera != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  resolverUrlMedia(
                        primera.tipo == 'video' ? primera.poster : primera.url,
                      ) ??
                      '',
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                GestureDetector(
                  onTap: _procesando ? null : _alternarLike,
                  child: Row(
                    children: [
                      Icon(
                        post.meGusta ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.meGusta ? AppColors.error : colorTexto,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.cantidadLikes}',
                        style: TextStyle(fontSize: 12, color: colorTexto),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: colorSecundario,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.cantidadComentarios}',
                  style: TextStyle(fontSize: 12, color: colorSecundario),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

