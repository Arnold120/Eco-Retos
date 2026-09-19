import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/admin/admin_models.dart';
import '../design/eco_widgets.dart';
import 'cubit/admin_panel_cubit.dart';
import 'cubit/admin_panel_state.dart';

/// Gestión de usuarios: activar/desactivar cuentas y asignar/quitar roles.
class AdminUsersScreen extends StatefulWidget {
  final int usuarioIdActual;

  const AdminUsersScreen({super.key, required this.usuarioIdActual});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AdminPanelCubit>();
      cubit.limpiarFeedback();
      cubit.cargarUsuarios();
      cubit.cargarRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () => context.read<AdminPanelCubit>().cargarUsuarios(),
          ),
        ],
      ),
      body: BlocConsumer<AdminPanelCubit, AdminPanelState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                ),
              );
          } else if (state.mensaje != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.mensaje!),
                  backgroundColor: AppColors.success,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.usuarios.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.error != null && state.usuarios.isEmpty) {
            return EcoErrorState(
              mensaje: state.error!,
              onReintentar: () =>
                  context.read<AdminPanelCubit>().cargarUsuarios(),
            );
          }

          final filtrados = state.usuarios.where((u) {
            final q = _busqueda.trim().toLowerCase();
            if (q.isEmpty) return true;
            return u.nombreUsuario.toLowerCase().contains(q) ||
                u.correo.toLowerCase().contains(q);
          }).toList();

          return RefreshIndicator(
            onRefresh: () => context.read<AdminPanelCubit>().cargarUsuarios(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                EcoSectionTitle(
                  titulo:
                      '${state.usuarios.length} usuarios · '
                      '${state.usuarios.where((u) => u.activo).length} activos',
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _busqueda = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o correo...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (filtrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EcoEmptyState(
                      icono: Icons.person_search_outlined,
                      titulo: 'Sin resultados',
                      mensaje: 'No hay usuarios que coincidan con la búsqueda.',
                    ),
                  )
                else
                  for (final usuario in filtrados) ...[
                    _UsuarioCard(
                      usuario: usuario,
                      esYoMismo: usuario.usuarioId == widget.usuarioIdActual,
                      ocupado: state.actuandoId == usuario.usuarioId,
                      rolesDisponibles: state.roles,
                      onActivar: () => context
                          .read<AdminPanelCubit>()
                          .activarUsuario(usuario),
                      onDesactivar: () => context
                          .read<AdminPanelCubit>()
                          .desactivarUsuario(usuario),
                      onEditarRoles: () =>
                          _editarRoles(context, usuario, state.roles),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _editarRoles(
    BuildContext context,
    UsuarioAdminResponse usuario,
    List<RolResponse> rolesDisponibles,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final cubit = ctx.read<AdminPanelCubit>();
        return BlocBuilder<AdminPanelCubit, AdminPanelState>(
          builder: (context, state) {
            final usuarioActual = state.usuarios.firstWhere(
              (u) => u.usuarioId == usuario.usuarioId,
              orElse: () => usuario,
            );
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const EcoSectionTitle(titulo: 'Roles del usuario'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            usuarioActual.nombreUsuario.isNotEmpty
                                ? usuarioActual.nombreUsuario[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuarioActual.nombreUsuario,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                usuarioActual.correo,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Roles actuales',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (usuarioActual.roles.isEmpty)
                      const Text(
                        'Sin roles asignados.',
                        style: TextStyle(color: AppColors.textHint),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final rol in usuarioActual.roles)
                            Chip(
                              avatar: const Icon(
                                Icons.badge_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(rol),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: usuarioActual.esAdmin
                                  ? AppColors.levelPurple
                                  : AppColors.primary,
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                              onDeleted: () {
                                final rolDefinido = _rolPorNombre(
                                  rolesDisponibles,
                                  rol,
                                );
                                if (rolDefinido != null &&
                                    !usuarioActual.esAdmin) {
                                  cubit.quitarRol(usuarioActual, rolDefinido);
                                }
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Asignar rol',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (rolesDisponibles.isEmpty)
                      const Text(
                        'No hay roles disponibles.',
                        style: TextStyle(color: AppColors.textHint),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final rol in rolesDisponibles)
                            ActionChip(
                              avatar: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(rol.nombreRol),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: AppColors.info,
                              onPressed: () =>
                                  cubit.asignarRol(usuarioActual, rol),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  RolResponse? _rolPorNombre(List<RolResponse> roles, String nombre) {
    for (final r in roles) {
      if (r.nombreRol.trim().toUpperCase() == nombre.trim().toUpperCase()) {
        return r;
      }
    }
    return null;
  }
}

class _UsuarioCard extends StatelessWidget {
  final UsuarioAdminResponse usuario;
  final bool esYoMismo;
  final bool ocupado;
  final List<RolResponse> rolesDisponibles;
  final VoidCallback onActivar;
  final VoidCallback onDesactivar;
  final VoidCallback onEditarRoles;

  const _UsuarioCard({
    required this.usuario,
    required this.esYoMismo,
    required this.ocupado,
    required this.rolesDisponibles,
    required this.onActivar,
    required this.onDesactivar,
    required this.onEditarRoles,
  });

  @override
  Widget build(BuildContext context) {
    return EcoCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: usuario.activo
                ? AppColors.primary
                : AppColors.textHint,
            child: Text(
              usuario.nombreUsuario.isNotEmpty
                  ? usuario.nombreUsuario[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        usuario.nombreUsuario,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (esYoMismo)
                      const _ChipTexto(
                        texto: 'Tú',
                        color: AppColors.levelPurple,
                      ),
                    if (!usuario.activo)
                      const _ChipTexto(
                        texto: 'Inactivo',
                        color: AppColors.error,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  usuario.correo,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final rol in usuario.roles)
                      _ChipTexto(
                        texto: rol,
                        color: usuario.esAdmin
                            ? AppColors.levelPurple
                            : AppColors.primary,
                        icono: Icons.badge_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: ocupado ? null : onEditarRoles,
                      icon: const Icon(Icons.groups_outlined, size: 18),
                      label: const Text('Roles'),
                    ),
                    if (ocupado)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: esYoMismo || !usuario.activo
                            ? null
                            : onDesactivar,
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Desactivar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: ocupado
                          ? null
                          : (usuario.activo ? null : onActivar),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Activar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTexto extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icono;

  const _ChipTexto({required this.texto, required this.color, this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(
              icono,
              size: 13,
              color: color == AppColors.primary ? Colors.white : color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color == AppColors.primary ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
