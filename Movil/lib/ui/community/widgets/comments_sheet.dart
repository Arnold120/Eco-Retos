import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/social/social_models.dart';
import '../../widgets/user_avatar.dart';
import '../cubit/community_cubit.dart';
import '../user_profile_screen.dart';
import 'post_card_skeleton.dart';
import 'post_helpers.dart';

Future<void> showCommentsSheet(
  BuildContext context, {
  required int publicacionId,
  required int usuarioId,
}) {
  final cubit = context.read<CommunityCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _CommentsSheet(
        publicacionId: publicacionId,
        usuarioId: usuarioId,
      ),
    ),
  );
}

class _CommentsSheet extends StatelessWidget {
  final int publicacionId;
  final int usuarioId;

  const _CommentsSheet({
    required this.publicacionId,
    required this.usuarioId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    final insets = MediaQuery.of(context).viewInsets.bottom;
    final altura =
        (MediaQuery.of(context).size.height * 0.82 - insets).clamp(240.0, 1200.0);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: insets),
      child: Container(
      height: altura,
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.divider : AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          CommentsView(
            publicacionId: publicacionId,
            usuarioId: usuarioId,
          ),
        ],
      ),
      ),
    );
  }
}


class CommentsView extends StatefulWidget {
  final int publicacionId;
  final int usuarioId;

  const CommentsView({
    super.key,
    required this.publicacionId,
    required this.usuarioId,
  });

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  List<ComentarioResponse> _comentarios = [];
  bool _cargando = true;
  bool _enviando = false;
  String? _error;
  int? _editandoId;
  ComentarioResponse? _respondiendoA;
  final Set<int> _respuestasExpandidas = {};
  int _visibles = 15;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  CommunityCubit get _cubit => context.read<CommunityCubit>();

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    final lista = await _cubit.getComentarios(widget.publicacionId);
    if (!mounted) return;
    setState(() {
      _comentarios = lista;
      _cargando = false;
      if (lista.isEmpty && _cubit.state.error != null) {
        _error = 'No pudimos cargar los comentarios.';
      }
    });
    _cubit.limpiarMensajes();
  }

  List<ComentarioResponse> get _raices =>
      _comentarios.where((c) => c.comentarioPadreId == null).toList();

  List<ComentarioResponse> _respuestas(int padreId) =>
      _comentarios.where((c) => c.comentarioPadreId == padreId).toList();

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    final editandoId = _editandoId;
    final padreId = _respondiendoA?.comentarioId;

    if (editandoId != null) {
      final actualizado = await _cubit.editarComentario(editandoId, texto);
      if (!mounted) return;
      setState(() {
        _enviando = false;
        if (actualizado != null) {
          _comentarios = _comentarios
              .map((c) => c.comentarioId == editandoId ? actualizado : c)
              .toList();
          _editandoId = null;
          _controller.clear();
        }
      });
      if (actualizado == null && mounted) {
        _aviso('No se pudo editar el comentario.');
      }
      return;
    }

    final creado = await _cubit.agregarComentario(
      widget.publicacionId,
      texto,
      comentarioPadreId: padreId,
    );
    if (!mounted) return;
    setState(() {
      _enviando = false;
      if (creado != null) {
        _comentarios = [..._comentarios, creado];
        _controller.clear();
        if (padreId != null) _respuestasExpandidas.add(padreId);
        _respondiendoA = null;
      }
    });
    if (creado == null && mounted) {
      _aviso('No se pudo publicar el comentario.');
    } else if (mounted) {
      FocusScope.of(context).unfocus();
      _focus.requestFocus();
    }
  }

  Future<void> _toggleLike(ComentarioResponse comentario) async {
    final anterior = comentario;
    setState(() {
      _comentarios = _comentarios.map((c) {
        if (c.comentarioId != comentario.comentarioId) return c;
        final meGusta = !c.meGusta;
        return c.copyWith(
          meGusta: meGusta,
          cantidadLikes:
              (c.cantidadLikes + (meGusta ? 1 : -1)).clamp(0, 1 << 31),
        );
      }).toList();
    });

    final resultado = await _cubit.toggleMeGustaComentario(comentario);
    if (!mounted) return;
    setState(() {
      _comentarios = _comentarios.map((c) {
        if (c.comentarioId != anterior.comentarioId) return c;
        if (resultado == null) return anterior;
        return c.copyWith(
          meGusta: resultado.activa,
          cantidadLikes: resultado.total,
        );
      }).toList();
    });
    if (resultado == null && mounted) {
      _aviso('No se pudo registrar tu reacción.');
    }
  }

  Future<void> _eliminar(ComentarioResponse comentario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar comentario?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    final ok = await _cubit.eliminarComentario(
      widget.publicacionId,
      comentario.comentarioId,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _comentarios = _comentarios
            .where((c) =>
                c.comentarioId != comentario.comentarioId &&
                c.comentarioPadreId != comentario.comentarioId)
            .toList();
      });
    } else {
      _aviso('No se pudo eliminar el comentario.');
    }
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Row(
              children: [
                Text(
                  'Comentarios',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_comentarios.length}',
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Recargar comentarios',
                  onPressed: _cargando ? null : _cargar,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColorsDark.divider : AppColors.divider,
          ),
          Expanded(child: _cuerpo(isDark)),
          _barraEntrada(isDark),
        ],
      ),
    );
  }

  Widget _cuerpo(bool isDark) {
    if (_cargando) return const CommentsSkeleton();
    if (_error != null) {
      return SocialErrorState(mensaje: _error!, onReintentar: _cargar);
    }
    final raices = _raices;
    if (raices.isEmpty) {
      return const SocialEmptyState(
        icono: Icons.chat_bubble_outline,
        titulo: 'Sé el primero en comentar',
        subtitulo: 'Comparte tu opinión y motiva a más personas.',
      );
    }

    final visibles = raices.take(_visibles).toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: visibles.length + (raices.length > _visibles ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= visibles.length) {
          return TextButton(
            onPressed: () => setState(() => _visibles += 15),
            child: Text('Ver ${raices.length - _visibles} comentarios más'),
          );
        }
        return _comentarioConRespuestas(context, visibles[i], isDark);
      },
    );
  }

  Widget _comentarioConRespuestas(
      BuildContext context, ComentarioResponse comentario, bool isDark) {
    final respuestas = _respuestas(comentario.comentarioId);
    final expandidas = _respuestasExpandidas.contains(comentario.comentarioId);
    final mostradas = expandidas ? respuestas : respuestas.take(2).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filaComentario(context, comentario, isDark),
          if (respuestas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...mostradas.map((r) => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _filaComentario(context, r, isDark,
                            esRespuesta: true),
                      )),
                  if (respuestas.length > 2)
                    TextButton(
                      onPressed: () => setState(() {
                        if (expandidas) {
                          _respuestasExpandidas.remove(comentario.comentarioId);
                        } else {
                          _respuestasExpandidas.add(comentario.comentarioId);
                        }
                      }),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        expandidas
                            ? 'Ocultar respuestas'
                            : 'Ver las ${respuestas.length} respuestas',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filaComentario(
    BuildContext context,
    ComentarioResponse comentario,
    bool isDark, {
    bool esRespuesta = false,
  }) {
    final sec = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final esMio = comentario.usuarioId == widget.usuarioId;
    final editando = _editandoId == comentario.comentarioId;

    if (editando) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CurrentUserAvatar(radius: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColorsDark.surfaceDim
                        : AppColors.surfaceDim,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        _editandoId = null;
                        _controller.clear();
                      }),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: _enviando ? null : _enviar,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          nombre: comentario.nombreUsuario,
          fotoUrl: comentario.fotoPerfil,
          radius: esRespuesta ? 14 : 16,
          onTap: () => abrirPerfilUsuario(context, comentario.usuarioId),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () =>
                          abrirPerfilUsuario(context, comentario.usuarioId),
                      child: Text(
                        comentario.nombreUsuario,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (esMio) ...[
                    const SizedBox(width: 5),
                    Text('· tú', style: TextStyle(color: sec, fontSize: 11.5)),
                  ],
                  if (comentario.editado) ...[
                    const SizedBox(width: 5),
                    Text('· editado',
                        style: TextStyle(color: sec, fontSize: 11.5)),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comentario.comentarioTexto,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    timeAgo(comentario.fechaComentario),
                    style: TextStyle(color: sec, fontSize: 11.5),
                  ),
                  _accionTexto(
                    context: context,
                    label: comentario.meGusta
                        ? 'Te gusta (${comentario.cantidadLikes})'
                        : 'Me gusta',
                    activo: comentario.meGusta,
                    onTap: () => _toggleLike(comentario),
                  ),
                  if (!esRespuesta)
                    _accionTexto(
                      context: context,
                      label: 'Responder',
                      onTap: () {
                        setState(() {
                          _respondiendoA = comentario;
                          _editandoId = null;
                          _controller.clear();
                        });
                        _focus.requestFocus();
                      },
                    ),
                  if (esMio) ...[
                    _accionTexto(
                      context: context,
                      label: 'Editar',
                      onTap: () => setState(() {
                        _editandoId = comentario.comentarioId;
                        _respondiendoA = null;
                        _controller.text = comentario.comentarioTexto;
                      }),
                    ),
                    _accionTexto(
                      context: context,
                      label: 'Eliminar',
                      onTap: () => _eliminar(comentario),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accionTexto({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    bool activo = false,
  }) {
    final sec = textSecondaryColor(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
            color: activo ? AppColors.error : sec,
          ),
        ),
      ),
    );
  }

  Widget _barraEntrada(bool isDark) {
    final surfaceDim =
        isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.divider : AppColors.divider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_respondiendoA != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Respondiendo a ${_respondiendoA!.nombreUsuario}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          setState(() => _respondiendoA = null),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const CurrentUserAvatar(radius: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _editandoId != null
                          ? 'Edita tu comentario…'
                          : 'Escribe un comentario…',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: surfaceDim,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Enviar comentario',
                  onPressed: _enviando ||
                          _controller.text.trim().isEmpty
                      ? null
                      : _enviar,
                  icon: _enviando
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
            ),
          ],
        ),
      ),
    );
  }
}
