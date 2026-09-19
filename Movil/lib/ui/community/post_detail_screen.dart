import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/social_service.dart';
import 'cubit/community_cubit.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/post_card.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';

/// Pantalla de detalle de una publicacion (destino de notificaciones y
/// enlaces internos). Carga la publicacion por id y muestra comentarios.
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

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.background : AppColors.background,
      appBar: AppBar(title: const Text('Publicación')),
      body: _cargando
          ? const PostCardSkeleton()
          : _error != null
              ? SocialErrorState(mensaje: _error!, onReintentar: _cargar)
              : _post == null
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
                        PostCard(post: _post!, usuarioId: usuarioId),
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
