import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/community_cubit.dart';


class FollowButton extends StatelessWidget {
  final bool siguiendo;
  final bool cargando;
  final VoidCallback onToggle;
  final bool compacto;

  const FollowButton({
    super.key,
    required this.siguiendo,
    required this.onToggle,
    this.cargando = false,
    this.compacto = true,
  });

  @override
  Widget build(BuildContext context) {
    final prim = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.primary
        : AppColors.primary;

    final estilo = compacto
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return Semantics(
      button: true,
      label: siguiendo ? 'Dejar de seguir' : 'Seguir',
      child: FilledButton(
        onPressed: cargando ? null : onToggle,
        style: FilledButton.styleFrom(
          backgroundColor: siguiendo ? Colors.transparent : prim,
          foregroundColor: siguiendo ? AppColors.primary : Colors.white,
          padding: estilo,
          minimumSize: Size(0, compacto ? 32 : 46),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: siguiendo
              ? BorderSide(color: prim, width: 1.2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: cargando
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                siguiendo ? 'Dejar de seguir' : 'Seguir',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: compacto ? 12.5 : 14.5,
                ),
              ),
      ),
    );
  }
}


class CommunityFollowButton extends StatelessWidget {
  final int usuarioId;
  final bool compacto;

  const CommunityFollowButton({
    super.key,
    required this.usuarioId,
    this.compacto = true,
  });

  @override
  Widget build(BuildContext context) {
    final siguiendo = context.select<CommunityCubit, bool>(
      (c) => c.state.siguiendoIds.contains(usuarioId),
    );
    return FollowButton(
      siguiendo: siguiendo,
      compacto: compacto,
      onToggle: () => context.read<CommunityCubit>().toggleSeguir(usuarioId),
    );
  }
}
