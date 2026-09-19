import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../profile/cubit/profile_cubit.dart';

/// Avatar unico y consistente para toda la aplicacion.
///
/// - Si el usuario tiene fotografia real, siempre se muestra esa imagen.
/// - Si no la tiene, se usa un placeholder determinista basado en su nombre
///   (nunca cambia aleatoriamente entre pantallas).
class UserAvatar extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.nombre,
    this.fotoUrl,
    this.radius = 20,
    this.onTap,
  });

  static const _gradientes = [
    [Color(0xFF2E7D5B), Color(0xFF4CAF7D)],
    [Color(0xFF1B5E43), Color(0xFF3FAE78)],
    [Color(0xFF2E7D5B), Color(0xFF8ED9B4)],
    [Color(0xFF35704F), Color(0xFF4CAF7D)],
    [Color(0xFF2E7D5B), Color(0xFF4CB8A0)],
  ];

  List<Color> get _gradiente {
    final limpio = nombre.trim();
    if (limpio.isEmpty) return _gradientes.first;
    final hash = limpio.codeUnits.fold<int>(0, (a, c) => a + c);
    return _gradientes[hash % _gradientes.length];
  }

  String get _inicial {
    final limpio = nombre.trim();
    if (limpio.isEmpty) return '?';
    return limpio[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final resuelta = resolverUrlMedia(fotoUrl);
    final tieneFoto = resuelta != null && resuelta.trim().isNotEmpty;

    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: tieneFoto
            ? null
            : LinearGradient(
                colors: _gradiente,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: tieneFoto
          ? Image.network(
              resuelta,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (context, child, progreso) {
                if (progreso == null) return child;
                return _placeholder();
              },
            )
          : _placeholder(),
    );

    if (onTap == null) return avatar;
    return Semantics(
      button: true,
      label: 'Ver perfil de $nombre',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Text(
        _inicial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}

/// Avatar del usuario autenticado. Lee la foto real desde ProfileCubit
/// (y cae al nombre de AuthCubit) para que sea identica en toda la app.
class CurrentUserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const CurrentUserAvatar({super.key, this.radius = 20, this.onTap});

  @override
  Widget build(BuildContext context) {
    String nombre = '';
    String? foto;

    final auth = context.read<AuthCubit>().state;
    if (auth is Authenticated) nombre = auth.nombreUsuario;

    try {
      final perfil = context.watch<ProfileCubit>().state.perfil;
      if (perfil != null) {
        foto = perfil.fotoPerfil;
        if (perfil.nombreCompleto.trim().isNotEmpty) {
          nombre = perfil.nombreCompleto.trim();
        }
      }
    } catch (_) {
      // ProfileCubit no esta disponible en este contexto (p. ej. dialogos).
    }

    if (nombre.isEmpty) nombre = 'Eco Héroe';

    return UserAvatar(
      nombre: nombre,
      fotoUrl: foto,
      radius: radius,
      onTap: onTap,
    );
  }
}

/// Utilidad de estilo para el chip de estado (insignia verificada).
class VerifiedDot extends StatelessWidget {
  final double size;

  const VerifiedDot({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check_rounded,
        size: size * 0.7,
        color: AppColors.textOnPrimary,
      ),
    );
  }
}
