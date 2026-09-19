import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/mensaje_service.dart';
import '../community/widgets/post_card_skeleton.dart';
import '../community/widgets/post_helpers.dart';
import '../widgets/user_avatar.dart';
import 'cubit/conversation_cubit.dart';

class ConversationScreen extends StatelessWidget {
  final int conversacionId;
  final int usuarioId;
  final String titulo;

  /// Foto de perfil del otro usuario. Si no se conoce, la pantalla la
  /// resuelve consultando las conversaciones.
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

/// Conversacion incrustable dentro del Muro Eco (mantiene la navegacion).
class MuroConversacionView extends StatefulWidget {
  final int conversacionId;
  final int usuarioId;
  final String titulo;
  final String? fotoUrl;

  /// Si viene, muestra el boton de volver (para la version incrustada).
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

  @override
  void initState() {
    super.initState();
    _nombre = widget.titulo;
    _foto = widget.fotoUrl;
    _scroll.addListener(() {
      // Con la lista invertida, llegar al final del scroll significa llegar
      // a los mensajes mas antiguos: ahi se cargan mas.
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 80) {
        context.read<ConversationCubit>().cargarMas();
      }
    });
    if (_foto == null) _resolverContacto();
  }

  /// Obtiene nombre y foto reales del otro participante.
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
      // Se conserva el titulo recibido.
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
    final ok = await context.read<ConversationCubit>().enviar(texto);
    if (!mounted) return;
    if (ok) {
      _controller.clear();
      _focus.requestFocus();
      _bajarAlUltimoMensaje();
    }
  }

  /// Con la lista invertida, el mensaje mas reciente esta en el offset 0.
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
                  // Lista invertida: el mensaje mas reciente siempre queda
                  // abajo y visible al abrir o al enviar.
                  final mensajes = state.mensajes.reversed.toList();
                  final ultimoMioId = _idUltimoMio(state.mensajes);
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
                        mostrarEstado: mensaje.mensajeId == ultimoMioId,
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

  int? _idUltimoMio(List<MensajeResponse> mensajes) {
    for (var i = mensajes.length - 1; i >= 0; i--) {
      if (mensajes[i].remitenteId == widget.usuarioId) {
        return mensajes[i].mensajeId;
      }
    }
    return null;
  }

  Widget _burbuja(
    BuildContext context,
    MensajeResponse mensaje, {
    required bool esMio,
    required bool mostrarAvatar,
    bool mostrarEstado = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = textSecondaryColor(context);

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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                crossAxisAlignment:
                    esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.contenido,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: esMio ? Colors.white : textColor(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeAgo(mensaje.fecha),
                        style: TextStyle(
                          fontSize: 10,
                          color: esMio ? Colors.white70 : sec,
                        ),
                      ),
                      if (esMio && mostrarEstado) ...[
                        const SizedBox(width: 6),
                        Icon(
                          mensaje.leido ? Icons.done_all : Icons.done,
                          size: 13,
                          color: mensaje.leido
                              ? AppColors.tertiary
                              : Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          mensaje.leido ? 'Leído' : 'Enviado',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compositor(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
        child: BlocBuilder<ConversationCubit, ConversationState>(
          buildWhen: (a, b) => a.isSending != b.isSending,
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                      hintStyle: const TextStyle(color: AppColors.textHint),
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
                  onPressed: state.isSending || _controller.text.trim().isEmpty
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

