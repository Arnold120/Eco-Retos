import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../community/widgets/post_card_skeleton.dart';
import '../community/widgets/post_helpers.dart';
import '../widgets/user_avatar.dart';
import 'conversation_screen.dart';
import 'cubit/messages_cubit.dart';

/// Pantalla de mensajes como ruta independiente. Reutiliza la misma vista
/// incrustable del Muro Eco y el mismo cubit global.
class MessagesScreen extends StatelessWidget {
  final int usuarioId;

  const MessagesScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: MuroMensajesView(usuarioId: usuarioId),
    );
  }
}

/// Lista de conversaciones incrustable (Muro Eco).
class MuroMensajesView extends StatefulWidget {
  final int usuarioId;

  /// Si viene, la conversacion se abre dentro del Muro Eco.
  /// Si no, se abre como pantalla independiente.
  final void Function(ConversacionResumen)? onAbrir;

  const MuroMensajesView({
    super.key,
    required this.usuarioId,
    this.onAbrir,
  });

  @override
  State<MuroMensajesView> createState() => _MuroMensajesViewState();
}

class _MuroMensajesViewState extends State<MuroMensajesView> {
  final _filtro = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MessagesCubit>().load();
    });
  }

  @override
  void dispose() {
    _filtro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<MessagesCubit, MessagesState>(
      builder: (context, state) {
        if (state.isLoading && state.conversaciones.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: const [PostCardSkeleton(), PostCardSkeleton()],
          );
        }
        if (state.error != null && state.conversaciones.isEmpty) {
          return SocialErrorState(
            mensaje: state.error!,
            onReintentar: () => context.read<MessagesCubit>().load(),
          );
        }
        if (state.conversaciones.isEmpty) {
          return const SocialEmptyState(
            icono: Icons.mail_outline,
            titulo: 'No tienes conversaciones',
            subtitulo:
                'Abre el perfil de un usuario y toca "Mensaje" para iniciar una.',
          );
        }

        final filtro = _filtro.text.trim().toLowerCase();
        final conversaciones = filtro.isEmpty
            ? state.conversaciones
            : state.conversaciones
                .where((c) =>
                    c.otroNombreUsuario.toLowerCase().contains(filtro))
                .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _filtro,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar conversación…',
                  hintStyle:
                      const TextStyle(color: AppColors.textHint, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor:
                      isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<MessagesCubit>().load(),
                child: conversaciones.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Sin coincidencias',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textSecondaryColor(context),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        itemCount: conversaciones.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 76,
                          color: dividerColor(context).withValues(alpha: 0.4),
                        ),
                        itemBuilder: (context, i) =>
                            _conversacionTile(context, conversaciones[i]),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _conversacionTile(BuildContext context, ConversacionResumen c) {
    final sec = textSecondaryColor(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(
        nombre: c.otroNombreUsuario,
        fotoUrl: c.otroFotoPerfil,
        radius: 24,
      ),
      title: Text(
        c.otroNombreUsuario,
        style: TextStyle(
          fontWeight: c.noLeidos > 0 ? FontWeight.w800 : FontWeight.w600,
          color: textColor(context),
        ),
      ),
      subtitle: Text(
        c.ultimoMensaje ?? 'Inicia la conversación',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: sec,
          fontSize: 13,
          fontWeight: c.noLeidos > 0 ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (c.fechaUltimoMensaje != null)
            Text(
              timeAgo(c.fechaUltimoMensaje!),
              style: TextStyle(color: sec, fontSize: 11.5),
            ),
          if (c.noLeidos > 0) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${c.noLeidos}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () => _abrirConversacion(context, c),
    );
  }

  Future<void> _abrirConversacion(
      BuildContext context, ConversacionResumen c) async {
    if (widget.onAbrir != null) {
      widget.onAbrir!(c);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          conversacionId: c.conversacionId,
          usuarioId: widget.usuarioId,
          titulo: c.otroNombreUsuario,
          fotoUrl: c.otroFotoPerfil,
        ),
      ),
    );
    if (context.mounted) context.read<MessagesCubit>().load();
  }
}
