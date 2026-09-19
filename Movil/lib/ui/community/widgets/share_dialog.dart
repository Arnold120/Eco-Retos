import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/social/social_models.dart';
import '../../../data/services/mensaje_service.dart';
import '../../messages/conversation_screen.dart';
import '../cubit/community_cubit.dart';
import 'post_helpers.dart';



Future<void> showShareDialog(
  BuildContext context, {
  required PublicacionResponse post,
  required int usuarioId,
}) {
  final cubit = context.read<CommunityCubit>();
  final mensajeService = context.read<MensajeService>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.surface
        : AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ShareSheet(
      post: post,
      usuarioId: usuarioId,
      cubit: cubit,
      mensajeService: mensajeService,
    ),
  );
}

class _ShareSheet extends StatefulWidget {
  final PublicacionResponse post;
  final int usuarioId;
  final CommunityCubit cubit;
  final MensajeService mensajeService;

  const _ShareSheet({
    required this.post,
    required this.usuarioId,
    required this.cubit,
    required this.mensajeService,
  });

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _comentario = TextEditingController();
  bool _publicando = false;
  bool _enviandoEnlace = false;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  String get _enlace => 'https://ecoretos.app/muro/${widget.post.publicacionId}';

  Future<void> _compartirEnMuro() async {
    if (_publicando) return;
    setState(() => _publicando = true);
    final creado = await widget.cubit.crearPublicacion(
      contenido: _comentario.text.trim(),
      compartidoDeId: widget.post.publicacionId,
      tipo: 'GENERAL',
    );
    if (!mounted) return;
    setState(() => _publicando = false);
    if (creado != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compartido en tu muro')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo compartir. Inténtalo de nuevo.')),
      );
    }
  }

  Future<void> _copiarEnlace() async {
    await Clipboard.setData(ClipboardData(text: _enlace));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace copiado al portapapeles')),
    );
  }

  Future<void> _enviarPorMensaje() async {
    if (_enviandoEnlace) return;
    setState(() => _enviandoEnlace = true);
    try {
      final conversaciones = await widget.mensajeService.getConversaciones();
      if (!mounted) return;
      setState(() => _enviandoEnlace = false);
      final elegida = await showModalBottomSheet<ConversacionResumen>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.surface
            : AppColors.surface,
        builder: (ctx) => _ConversationPicker(conversaciones: conversaciones),
      );
      if (elegida == null || !mounted) return;

      final texto = _comentario.text.trim().isEmpty
          ? _enlace
          : '${_comentario.text.trim()}\n$_enlace';
      await widget.mensajeService.enviarMensaje(
        elegida.conversacionId,
        texto,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviado a ${elegida.otroNombreUsuario}')),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(
            conversacionId: elegida.conversacionId,
            usuarioId: widget.usuarioId,
            titulo: elegida.otroNombreUsuario,
            fotoUrl: elegida.otroFotoPerfil,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviandoEnlace = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compartir publicación',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Opcion(
                  icon: Icons.dynamic_feed_outlined,
                  label: 'En mi muro',
                  onTap: _publicando ? null : _compartirEnMuro,
                  cargando: _publicando,
                ),
                const SizedBox(width: 12),
                _Opcion(
                  icon: Icons.link,
                  label: 'Copiar enlace',
                  onTap: _copiarEnlace,
                ),
                const SizedBox(width: 12),
                _Opcion(
                  icon: Icons.send_outlined,
                  label: 'Por mensaje',
                  onTap: _enviandoEnlace ? null : _enviarPorMensaje,
                  cargando: _enviandoEnlace,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentario,
              minLines: 2,
              maxLines: 4,
              maxLength: 280,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Agrega un comentario (opcional)',
                hintStyle: TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor:
                    isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Text(
              'El enlace apunta a la publicación original: $enlace',
              style: TextStyle(color: sec, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  String get enlace => _enlace;
}

class _Opcion extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool cargando;

  const _Opcion({
    required this.icon,
    required this.label,
    this.onTap,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final prim = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.primary
        : AppColors.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: prim.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              if (cargando)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, size: 26, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationPicker extends StatelessWidget {
  final List<ConversacionResumen> conversaciones;

  const _ConversationPicker({required this.conversaciones});

  @override
  Widget build(BuildContext context) {
    final sec = textSecondaryColor(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Enviar a una conversación',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            Expanded(
              child: conversaciones.isEmpty
                  ? Center(
                      child: Text(
                        'Aún no tienes conversaciones. Inicia una desde el '
                        'perfil de un usuario.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: sec),
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversaciones.length,
                      itemBuilder: (context, i) {
                        final c = conversaciones[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              initialOf(c.otroNombreUsuario),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(c.otroNombreUsuario),
                          subtitle: c.ultimoMensaje == null
                              ? null
                              : Text(
                                  c.ultimoMensaje!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          onTap: () => Navigator.of(context).pop(c),
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
