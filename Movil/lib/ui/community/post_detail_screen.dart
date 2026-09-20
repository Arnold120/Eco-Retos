import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/social_service.dart';
import 'cubit/community_cubit.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/post_card.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';

/// Abre el detalle de una publicación asegurando que [CommunityCubit]
/// esté disponible en la ruta (las rutas empujadas al Navigator raíz
/// no heredan los providers del home de MaterialApp).
void abrirDetallePublicacion(
  BuildContext context,
  int publicacionId, {
  int? usuarioId,
}) {
  CommunityCubit? existente;
  try {
    existente = context.read<CommunityCubit>();
  } catch (_) {
    existente = null;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) {
        final cubit = existente;
        if (cubit != null) {
          return BlocProvider.value(
            value: cubit,
            child: PostDetailScreen(publicacionId: publicacionId),
          );
        }
        return BlocProvider(
          create: (_) => CommunityCubit(
            usuarioId: usuarioId ?? 0,
            publicacionService: ctx.read<PublicacionService>(),
            reaccionService: ctx.read<ReaccionService>(),
            seguimientoService: ctx.read<SeguimientoService>(),
            guardadoService: ctx.read<GuardadoService>(),
          ),
          child: PostDetailScreen(publicacionId: publicacionId),
        );
      },
    ),
  );
}



class PostDetailScreen extends StatefulWidget {
  final int publicacionId;

  const PostDetailScreen({super.key, required this.publicacionId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PublicacionResponse? _post;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final post = await context
          .read<PublicacionService>()
          .getPublicacion(widget.publicacionId);
      if (!mounted) return;
      setState(() {
        _post = post;
        _cargando = false;
      });
      try {
        context.read<CommunityCubit>().sembrarPublicacion(post);
      } catch (_) {}
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No pudimos cargar esta publicación. Inténtalo nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usuarioId = context.read<CommunityCubit>().usuarioId;
    final publicaciones = context.watch<CommunityCubit>().state.publicaciones;
    PublicacionResponse? post = _post;
    for (final p in publicaciones) {
      if (p.publicacionId == widget.publicacionId) {
        post = p;
        break;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.background : AppColors.background,
      appBar: AppBar(title: const Text('Publicación')),
      body: _cargando
          ? const PostCardSkeleton()
          : _error != null
              ? SocialErrorState(mensaje: _error!, onReintentar: _cargar)
              : post == null
                  ? const SocialEmptyState(
                      icono: Icons.hide_source_outlined,
                      titulo: 'Publicación no disponible',
                      subtitulo:
                          'Es posible que haya sido eliminada por su autor.',
                    )
                  : AnchoLectura(
                      child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        PostCard(post: post, usuarioId: usuarioId),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Divider(),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: CommentsView(
                            publicacionId: widget.publicacionId,
                            usuarioId: usuarioId,
                          ),
                        ),
                      ],
                      ),
                    ),
    );
  }
}
