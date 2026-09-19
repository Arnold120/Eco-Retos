import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/media_url.dart';
import '../../../data/models/social/social_models.dart';
import '../../../data/services/social_interaction_service.dart';
import '../../../data/services/social_service.dart';
import '../../widgets/download_helper.dart';
import '../../widgets/user_avatar.dart';
import '../create_post_screen.dart';
import '../cubit/community_cubit.dart';
import '../user_profile_screen.dart';
import 'comments_sheet.dart';
import 'follow_button.dart';
import 'link_preview.dart';
import 'post_helpers.dart';
import 'post_media.dart';
import 'share_dialog.dart';

/// Tarjeta de publicacion reutilizable.
///
/// Soporta publicaciones normales, con multimedia, con enlace, compartidas,
/// editadas y con el contenido original eliminado.
class PostCard extends StatelessWidget {
  final PublicacionResponse post;
  final int usuarioId;

  /// Oculta el bloque de autor cuando la tarjeta se muestra dentro de una
  /// publicacion compartida (contenido citado).
  final bool esCitada;

  const PostCard({
    super.key,
    required this.post,
    required this.usuarioId,
    this.esCitada = false,
  });

  bool get _esPropia => post.usuarioId == usuarioId;

  /// Version compacta y sin acciones para citar el contenido original.
  Widget _buildCitada(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor(context).withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, size: 14, color: textSecondaryColor(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  post.nombreUsuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textColor(context),
                  ),
                ),
              ),
            ],
          ),
          if (post.contenido.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              post.contenido,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: textColor(context),
              ),
            ),
          ],
          if (post.multimedia.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                resolverUrlMedia(post.multimedia.first.url) ??
                    post.multimedia.first.url,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final procesando =
        context.select<CommunityCubit, bool>((c) => c.state.procesando.contains(post.publicacionId));

    if (esCitada) {
      return _buildCitada(context);
    }

    return PostCardContainer(
      destacada: post.esDestacada,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecera(context),
          const SizedBox(height: 10),
          if (post.esCompartido) ...[
            if (post.contenido.trim().isNotEmpty) ...[
              _contenidoTexto(context, post.contenido),
              const SizedBox(height: 10),
            ],
            _bloqueCompartido(context),
            const SizedBox(height: 10),
          ] else ...[
            if (post.contenido.trim().isNotEmpty)
              _contenidoTexto(context, post.contenido),
            _etiquetas(context),
            if (post.multimedia.isNotEmpty) ...[
              const SizedBox(height: 12),
              PostMedia(items: post.multimedia),
            ],
          ],
          const SizedBox(height: 12),
          _resumenSocial(context),
          Divider(height: 18, color: dividerColor(context).withValues(alpha: 0.5)),
          _barraAcciones(context, procesando),
        ],
      ),
    );
  }

  // ─── Cabecera ───────────────────────────────────────────────────────────

  Widget _cabecera(BuildContext context) {
    final sec = textSecondaryColor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          nombre: post.nombreUsuario,
          fotoUrl: post.fotoPerfil,
          radius: 20,
          onTap: () => abrirPerfilUsuario(context, post.usuarioId),
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
                          abrirPerfilUsuario(context, post.usuarioId),
                      child: Text(
                        post.nombreUsuario,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: textColor(context),
                        ),
                      ),
                    ),
                  ),
                  if (post.esDestacada) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.star, size: 15, color: AppColors.xpGold),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    usernameSlug(post.nombreUsuario),
                    style: TextStyle(color: sec, fontSize: 12),
                  ),
                  Text('· ${timeAgo(post.fechaPublicacion)}',
                      style: TextStyle(color: sec, fontSize: 12)),
                  if (post.editada)
                    Text('· Editada', style: TextStyle(color: sec, fontSize: 12)),
                  _indicadorPrivacidad(context, sec),
                ],
              ),
              if (post.ubicacion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(Icons.place_outlined, size: 12, color: sec),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          post.ubicacion!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: sec, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (!_esPropia) ...[
          CommunityFollowButton(usuarioId: post.usuarioId),
          const SizedBox(width: 4),
        ],
        _MenuBoton(
          onOpcion: (accion) => _ejecutarMenu(context, accion),
          esPropia: _esPropia,
          guardada: post.guardada,
          tieneMultimedia:
              post.multimedia.isNotEmpty || (post.imagen?.isNotEmpty ?? false),
        ),
      ],
    );
  }

  Widget _indicadorPrivacidad(BuildContext context, Color sec) {
    if (!_esPropia && post.visibilidad == 'PUBLICO') {
      return const SizedBox.shrink();
    }
    final (icono, label) = switch (post.visibilidad) {
      'SEGUIDORES' => (Icons.people_outline, 'Seguidores'),
      'SOLO_YO' => (Icons.lock_outline, 'Solo yo'),
      _ => (Icons.public, 'Público'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 12, color: sec),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: sec, fontSize: 12)),
      ],
    );
  }

  // ─── Contenido ──────────────────────────────────────────────────────────

  Widget _contenidoTexto(BuildContext context, String texto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableRichText(
          texto: texto,
          baseStyle: TextStyle(
            fontSize: 14.5,
            height: 1.4,
            color: textColor(context),
          ),
        ),
        Builder(builder: (context) {
          final url = primerEnlace(texto);
          if (url == null) return const SizedBox.shrink();
          return LinkPreviewCard(url: url);
        }),
      ],
    );
  }

  Widget _etiquetas(BuildContext context) {
    final chips = <Widget>[];
    if (post.categoria != null && post.categoria!.isNotEmpty) {
      chips.add(_chip(context,
          '${AmbientCategories.emoji(post.categoria!)} ${AmbientCategories.nombre(post.categoria!)}'));
    }
    if (post.tipoEnum == TipoPublicacion.logro) {
      chips.add(_chip(context, 'Logro ambiental', color: AppColors.xpGold));
    }
    if (post.tipoEnum == TipoPublicacion.iniciativa) {
      chips.add(_chip(context, 'Iniciativa comunitaria',
          color: AppColors.gardenGreen));
    }
    if (post.tipoEnum == TipoPublicacion.actividad) {
      chips.add(_chip(context, 'Actividad', color: AppColors.info));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(spacing: 6, runSpacing: 6, children: chips),
    );
  }

  Widget _chip(BuildContext context, String texto, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ─── Publicacion compartida ─────────────────────────────────────────────

  Widget _bloqueCompartido(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = textSecondaryColor(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor(context).withValues(alpha: 0.6),
        ),
      ),
      child: post.compartidoEliminado
          ? Row(
              children: [
                Icon(Icons.hide_source_outlined, size: 18, color: sec),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'La publicación original ya no está disponible.',
                    style: TextStyle(color: sec, fontSize: 13),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: post.compartidoDeId == null
                      ? null
                      : () => _abrirOriginal(context, post.compartidoDeId!),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, size: 15, color: sec),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Publicación de ${post.compartidoDeNombreUsuario ?? 'otro usuario'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: textColor(context),
                          ),
                        ),
                      ),
                      if (post.compartidoDeId != null)
                        Icon(Icons.chevron_right, size: 18, color: sec),
                    ],
                  ),
                ),
                if (post.compartidoDeContenido != null &&
                    post.compartidoDeContenido!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.compartidoDeContenido!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: textColor(context),
                    ),
                  ),
                ],
                if (post.compartidoDeImagen != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      resolverUrlMedia(post.compartidoDeImagen!) ??
                          post.compartidoDeImagen!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  // ─── Resumen y acciones ─────────────────────────────────────────────────

  Widget _resumenSocial(BuildContext context) {
    final sec = textSecondaryColor(context);
    final hayLikes = post.cantidadLikes > 0;

    return Row(
      children: [
        if (hayLikes) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite,
                size: 12, color: AppColors.error),
          ),
          const SizedBox(width: 6),
          Text(
            post.meGusta
                ? 'Tú y ${formatCount(post.cantidadLikes - 1)} más'
                : formatCount(post.cantidadLikes),
            style: TextStyle(color: sec, fontSize: 12.5),
          ),
        ],
        const Spacer(),
        if (post.cantidadComentarios > 0)
          Text(
            '${post.cantidadComentarios} ${post.cantidadComentarios == 1 ? 'comentario' : 'comentarios'}',
            style: TextStyle(color: sec, fontSize: 12.5),
          ),
        if (post.cantidadCompartidos > 0) ...[
          const SizedBox(width: 12),
          Text(
            '${post.cantidadCompartidos} ${post.cantidadCompartidos == 1 ? 'compartido' : 'compartidos'}',
            style: TextStyle(color: sec, fontSize: 12.5),
          ),
        ],
      ],
    );
  }

  Widget _barraAcciones(BuildContext context, bool procesando) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _BotonAccion(
          icono: post.meGusta ? Icons.favorite : Icons.favorite_border,
          label: 'Me gusta',
          activo: post.meGusta,
          colorActivo: AppColors.error,
          cargando: procesando,
          onTap: () => context.read<CommunityCubit>().toggleMeGusta(post),
        ),
        _BotonAccion(
          icono: Icons.chat_bubble_outline,
          label: 'Comentar',
          onTap: () => showCommentsSheet(
            context,
            publicacionId: post.publicacionId,
            usuarioId: usuarioId,
          ),
        ),
        _BotonAccion(
          icono: Icons.share_outlined,
          label: 'Compartir',
          onTap: () =>
              showShareDialog(context, post: post, usuarioId: usuarioId),
        ),
        _BotonAccion(
          icono: post.guardada
              ? Icons.bookmark_rounded
              : Icons.bookmark_outline,
          label: post.guardada ? 'Guardado' : 'Guardar',
          activo: post.guardada,
          cargando: procesando,
          onTap: () => context.read<CommunityCubit>().toggleGuardada(post),
        ),
      ],
    );
  }

  // ─── Navegacion ─────────────────────────────────────────────────────────

  void _abrirOriginal(BuildContext context, int publicacionId) async {
    final cubit = context.read<CommunityCubit>();
    try {
      final original =
          await context.read<PublicacionService>().getPublicacion(publicacionId);
      if (context.mounted) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColorsDark.surface
              : AppColors.surface,
          builder: (_) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: PostCard(post: original, usuarioId: usuarioId),
          ),
        );
      }
    } catch (_) {
      cubit.avisoSoporte('La publicación original ya no está disponible');
    }
  }

  // ─── Menu contextual ────────────────────────────────────────────────────

  Future<void> _ejecutarMenu(
      BuildContext context, _AccionMenu accion) async {
    final cubit = context.read<CommunityCubit>();
    switch (accion) {
      case _AccionMenu.editar:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: CreatePostScreen(usuarioId: usuarioId, post: post),
            ),
          ),
        );
        break;
      case _AccionMenu.eliminar:
        final confirmado = await _confirmarEliminar(context);
        if (confirmado) await cubit.eliminarPublicacion(post.publicacionId);
        break;
      case _AccionMenu.ocultar:
        await cubit.ocultarPublicacion(post);
        break;
      case _AccionMenu.guardar:
        await cubit.toggleGuardada(post);
        break;
      case _AccionMenu.copiarEnlace:
        await Clipboard.setData(
          ClipboardData(
            text: 'https://ecoretos.app/muro/${post.publicacionId}',
          ),
        );
        if (context.mounted) {
          cubit.avisoSoporte('Enlace copiado al portapapeles');
        }
        break;
      case _AccionMenu.reportar:
        await _reportar(context);
        break;
      case _AccionMenu.descargar:
        await _descargarMultimedia(context);
        break;
    }
  }

  Future<void> _descargarMultimedia(BuildContext context) async {
    final archivos = post.multimedia.isNotEmpty
        ? post.multimedia
            .map((m) => (url: m.url, tipo: m.tipo))
            .toList()
        : (post.imagen != null
            ? [(url: post.imagen!, tipo: 'imagen')]
            : const <ArchivoDescarga>[]);
    if (archivos.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta publicación no tiene archivos para descargar.'),
          ),
        );
      }
      return;
    }
    await descargarMultimedia(
      context,
      archivos: archivos,
      nombreSugerido: 'muro_${post.publicacionId}',
    );
  }

  Future<void> _reportar(BuildContext context) async {
    final motivo = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Reportar publicación',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            for (final razon in const [
              'Contenido inapropiado',
              'Información falsa',
              'Publicidad no deseada',
              'Acoso o bullying',
              'Otro motivo',
            ])
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(razon),
                onTap: () => Navigator.of(ctx).pop(razon),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (motivo == null || !context.mounted) return;

    try {
      await context
          .read<DenunciaService>()
          .crear(publicacionId: post.publicacionId, motivo: motivo);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado. Gracias por cuidar la comunidad.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el reporte.')),
      );
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar publicación?'),
        content: const Text(
          'Esta acción no se puede deshacer. La publicación desaparecerá del Muro Eco.',
        ),
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
    return resultado ?? false;
  }
}

enum _AccionMenu {
  editar,
  eliminar,
  ocultar,
  guardar,
  copiarEnlace,
  reportar,
  descargar,
}

class _MenuBoton extends StatelessWidget {
  final void Function(_AccionMenu) onOpcion;
  final bool esPropia;
  final bool guardada;
  final bool tieneMultimedia;

  const _MenuBoton({
    required this.onOpcion,
    required this.esPropia,
    required this.guardada,
    this.tieneMultimedia = false,
  });

  @override
  Widget build(BuildContext context) {
    final sec = textSecondaryColor(context);
    return PopupMenuButton<_AccionMenu>(
      tooltip: 'Más opciones',
      icon: Icon(Icons.more_horiz, size: 20, color: sec),
      onSelected: onOpcion,
      itemBuilder: (context) => [
        if (esPropia) ...[
          const PopupMenuItem(
            value: _AccionMenu.editar,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined, size: 20),
              title: Text('Editar publicación'),
            ),
          ),
          const PopupMenuItem(
            value: _AccionMenu.eliminar,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline,
                  size: 20, color: AppColors.error),
              title: Text('Eliminar publicación',
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
        ] else
          const PopupMenuItem(
            value: _AccionMenu.ocultar,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.visibility_off_outlined, size: 20),
              title: Text('Ocultar publicación'),
            ),
          ),
        PopupMenuItem(
          value: _AccionMenu.guardar,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              guardada ? Icons.bookmark_remove_outlined : Icons.bookmark_outline,
              size: 20,
            ),
            title: Text(guardada ? 'Quitar de guardadas' : 'Guardar publicación'),
          ),
        ),
        const PopupMenuItem(
          value: _AccionMenu.copiarEnlace,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.link, size: 20),
            title: Text('Copiar enlace'),
          ),
        ),
        if (tieneMultimedia)
          const PopupMenuItem(
            value: _AccionMenu.descargar,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.download_outlined, size: 20),
              title: Text('Descargar'),
            ),
          ),
        if (!esPropia)
          const PopupMenuItem(
            value: _AccionMenu.reportar,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.flag_outlined,
                  size: 20, color: AppColors.error),
              title: Text('Reportar',
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
      ],
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final bool activo;
  final bool cargando;
  final Color? colorActivo;

  const _BotonAccion({
    required this.icono,
    required this.label,
    required this.onTap,
    this.activo = false,
    this.cargando = false,
    this.colorActivo,
  });

  @override
  Widget build(BuildContext context) {
    final sec = textSecondaryColor(context);
    final color = activo ? (colorActivo ?? AppColors.primary) : sec;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: cargando ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              if (cargando)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icono, size: 19, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: color,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
