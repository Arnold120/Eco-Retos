import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/admin_service.dart';
import '../../data/services/usuarios_service.dart';
import '../app/main_shell.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import 'admin_home_screen.dart';
import 'cubit/admin_panel_cubit.dart';




class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    if (auth is! Authenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => AdminPanelCubit(
        usuariosService: context.read<UsuariosService>(),
        adminService: context.read<AdminService>(),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text('Panel de administración'),
        ),
        drawer: _AdminDrawer(
          nombreUsuario: auth.nombreUsuario,
          correo: auth.correo,
          onVerAppEstudiante: () {
            _scaffoldKey.currentState?.closeDrawer();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MainShell()));
          },
          onCerrarSesion: () => context.read<AuthCubit>().logout(),
        ),
        body: AdminHomeScreen(
          usuarioIdActual: auth.usuarioId,
          nombreAdmin: auth.nombreUsuario,
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String nombreUsuario;
  final String correo;
  final VoidCallback onVerAppEstudiante;
  final VoidCallback onCerrarSesion;

  const _AdminDrawer({
    required this.nombreUsuario,
    required this.correo,
    required this.onVerAppEstudiante,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.levelPurple, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      nombreUsuario.isNotEmpty
                          ? nombreUsuario[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreUsuario,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          correo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _item(
                    context,
                    icono: Icons.dashboard_outlined,
                    etiqueta: 'Panel principal',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _item(
                    context,
                    icono: Icons.verified_outlined,
                    etiqueta: 'Ver panel de estudiante',
                    color: esOscuro ? Colors.white : AppColors.textPrimary,
                    onTap: onVerAppEstudiante,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _item(
                    context,
                    icono: Icons.logout,
                    etiqueta: 'Cerrar sesión',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      onCerrarSesion();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icono,
    required String etiqueta,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icono, color: color, size: 22),
      title: Text(etiqueta, style: TextStyle(color: color)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
