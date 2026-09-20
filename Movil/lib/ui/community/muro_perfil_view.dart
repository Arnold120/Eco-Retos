import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/calificacion_service.dart';
import '../../data/services/perfil_social_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/social_service.dart';
import 'cubit/public_profile_cubit.dart';
import 'user_profile_screen.dart';

/// Perfil personal dentro del muro eco.
///
/// Reutiliza [UserProfileScreen] (la misma interfaz del perfil de
/// usuarios: pestañas Inicio / Fotos / Videos / Menciones /
/// Compartido, grilla multimedia y visor con hora, me gusta,
/// comentar y compartir), proveyendo su [PublicProfileCubit].
class MuroPerfilView extends StatefulWidget {
  final int usuarioId;

  const MuroPerfilView({super.key, required this.usuarioId});

  @override
  State<MuroPerfilView> createState() => _MuroPerfilViewState();
}

class _MuroPerfilViewState extends State<MuroPerfilView> {
  late PublicProfileCubit _cubit;

  PublicProfileCubit _crearCubit() {
    return PublicProfileCubit(
      usuarioId: widget.usuarioId,
      perfilService: context.read<PerfilSocialService>(),
      publicacionService: context.read<PublicacionService>(),
      seguimientoService: context.read<SeguimientoService>(),
      calificacionService: context.read<CalificacionService>(),
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = _crearCubit()..load();
  }

  @override
  void didUpdateWidget(covariant MuroPerfilView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usuarioId != widget.usuarioId) {
      _cubit.close();
      _cubit = _crearCubit()..load();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const UserProfileScreen(embebido: true),
    );
  }
}
