import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/mensaje_service.dart';
import '../../data/services/perfil_social_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/social_service.dart';
import '../messages/conversation_screen.dart';
import '../widgets/user_avatar.dart';
import 'cubit/community_cubit.dart';
import 'cubit/public_profile_cubit.dart';
import 'widgets/follow_button.dart';
import 'widgets/post_card.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';

/// Abre el perfil publico de un usuario.
void abrirPerfilUsuario(BuildContext context, int usuarioId) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (ctx) => PublicProfileCubit(
          usuarioId: usuarioId,
          perfilService: ctx.read<PerfilSocialService>(),
          publicacionService: ctx.read<PublicacionService>(),
          seguimientoService: ctx.read<SeguimientoService>(),
        )..load(),
        child: const UserProfileScreen(),
      ),
    ),
  );
}

class UserProfileScreen extends StatefulWidget {
  final int? usuarioId;

  const UserProfileScreen({super.key, this.usuarioId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      context.read<PublicProfileCubit>().cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<PublicProfileCubit, PublicProfileState>(
      listenWhen: (a, b) =>
          a.error != b.error && b.error != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColorsDark.background : AppColors.background,
        appBar: AppBar(title: const Text('Perfil')),
        body: BlocBuilder<PublicProfileCubit, PublicProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.perfil == null) {
              return const PostCardSkeleton();
            }
            if (state.error != null && state.perfil == null) {
              return SocialErrorState(
                mensaje: state.error!,
                onReintentar: () =>
                    context.read<PublicProfileCubit>().load(),
              );
            }
            final perfil = state.perfil;
            if (perfil == null) return const SizedBox.shrink();

            return AnchoLectura(
              child: RefreshIndicator(
              onRefresh: () => context.read<PublicProfileCubit>().load(),
              child: ListView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _cabecera(context, perfil),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      'Publicaciones',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: textColor(context),
                      ),
                    ),
                  ),
                  if (state.publicaciones.isEmpty && !state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: SocialEmptyState(
                        icono: Icons.article_outlined,
                        titulo: 'Sin publicaciones todavía',
                        subtitulo:
                            'Cuando comparta una acción ambiental aparecerá aquí.',
                      ),
                    )
                  else
                    ...state.publicaciones.map(
                      (p) => PostCard(
                        post: p,
                        usuarioId: _usuarioIdPropio(context),
                      ),
                    ),
                  if (state.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _usuarioIdPropio(BuildContext context) {
    try {
      return context.read<CommunityCubit>().usuarioId;
    } catch (_) {
      return 0;
    }
  }

  Widget _cabecera(BuildContext context, PerfilPublicoResponse perfil) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    // Mantiene el boton de seguir alineado con el estado global del muro.
    final siguiendoGlobal = context.select<CommunityCubit, bool>(
      (c) => c.state.siguiendoIds.contains(perfil.usuarioId),
    );
    final delta = siguiendoGlobal == perfil.siguiendo
        ? 0
        : (siguiendoGlobal ? 1 : -1);
    final seguidores = (perfil.cantidadSeguidores + delta).clamp(0, 1 << 31);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor(context).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          UserAvatar(
            nombre: perfil.nombreUsuario,
            fotoUrl: perfil.fotoPerfil,
            radius: 38,
          ),
          const SizedBox(height: 12),
          Text(
            perfil.nombreCompleto ?? perfil.nombreUsuario,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: textColor(context),
            ),
          ),
          if (perfil.nombreCompleto != null)
            Text(
              usernameSlug(perfil.nombreUsuario),
              style: TextStyle(color: sec, fontSize: 13),
            ),
          if (perfil.centroEducativo != null ||
              perfil.grado != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (perfil.grado != null) perfil.grado!,
                if (perfil.centroEducativo != null) perfil.centroEducativo!,
              ].join(' · '),
              textAlign: TextAlign.center,
              style: TextStyle(color: sec, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat(context, '${perfil.cantidadPublicaciones}',
                  'Publicaciones'),
              _stat(context, '$seguidores', 'Seguidores'),
              _stat(context, '${perfil.cantidadSeguidos}', 'Siguiendo'),
            ],
          ),
          if (!perfil.esMiPerfil) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FollowButton(
                    siguiendo: siguiendoGlobal,
                    compacto: false,
                    onToggle: () => _alternarSeguir(perfil),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _abrirConversacion(context, perfil),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Mensaje'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    side: BorderSide(color: primaryOf(context)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _alternarSeguir(PerfilPublicoResponse perfil) async {
    final cubit = context.read<PublicProfileCubit>();
    final community = context.read<CommunityCubit>();
    await cubit.toggleSeguir();
    final actualizado = cubit.state.perfil;
    if (actualizado == null) return;
    community.sincronizarSeguimiento(perfil.usuarioId, actualizado.siguiendo);
  }

  Future<void> _abrirConversacion(
      BuildContext context, PerfilPublicoResponse perfil) async {
    try {
      final conversacion = await context
          .read<MensajeService>()
          .abrirConversacion(perfil.usuarioId);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(
            conversacionId: conversacion.conversacionId,
            usuarioId: context.read<CommunityCubit>().usuarioId,
            titulo: conversacion.otroNombreUsuario,
            fotoUrl: conversacion.otroFotoPerfil ?? perfil.fotoPerfil,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la conversación. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  Widget _stat(BuildContext context, String valor, String label) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: textColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textSecondaryColor(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
