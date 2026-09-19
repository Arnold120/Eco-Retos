import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/admin/admin_models.dart';
import '../../../../data/services/admin_service.dart';
import '../../../../data/services/usuarios_service.dart';
import 'admin_panel_state.dart';



class AdminPanelCubit extends Cubit<AdminPanelState> {
  final UsuariosService _usuariosService;
  final AdminService _adminService;

  AdminPanelCubit({
    required UsuariosService usuariosService,
    required AdminService adminService,
  }) : _usuariosService = usuariosService,
       _adminService = adminService,
       super(const AdminPanelState());


  Future<void> cargarPanel() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final totales = await _usuariosService.obtenerTotales();
      final evidencias = await _adminService.obtenerEvidenciasPendientes();
      emit(
        state.copyWith(
          isLoading: false,
          totales: totales,
          evidenciasPendientes: evidencias.length,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'No se pudo cargar el panel de administración.',
        ),
      );
    }
  }


  Future<void> cargarUsuarios() async {
    if (state.usuarios.isEmpty) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    try {
      final usuarios = await _usuariosService.listarUsuarios();
      emit(state.copyWith(isLoading: false, usuarios: usuarios));
      if (state.totales == null) {
        try {
          final totales = await _usuariosService.obtenerTotales();
          if (isClosed) return;
          emit(state.copyWith(totales: totales));
        } catch (_) {}
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'No se pudo cargar la lista de usuarios.',
        ),
      );
    }
  }


  Future<void> cargarRoles() async {
    if (state.roles.isNotEmpty) return;
    try {
      final roles = await _usuariosService.listarRoles();
      if (isClosed) return;
      emit(state.copyWith(roles: roles));
    } catch (_) {
      emit(state.copyWith(error: 'No se pudo cargar los roles.'));
    }
  }

  Future<void> activarUsuario(UsuarioAdminResponse usuario) async {
    await _cambiarEstadoActivo(usuario, activar: true);
  }

  Future<void> desactivarUsuario(UsuarioAdminResponse usuario) async {
    await _cambiarEstadoActivo(usuario, activar: false);
  }

  Future<void> _cambiarEstadoActivo(
    UsuarioAdminResponse usuario, {
    required bool activar,
  }) async {
    emit(
      state.copyWith(
        clearError: true,
        clearMensaje: true,
        actuandoId: usuario.usuarioId,
      ),
    );
    try {
      if (activar) {
        await _usuariosService.activar(usuario.usuarioId);
      } else {
        await _usuariosService.desactivar(usuario.usuarioId);
      }
      emit(
        state.copyWith(
          limpiarActuando: true,
          mensaje: activar
              ? '${usuario.nombreUsuario} activado.'
              : '${usuario.nombreUsuario} desactivado.',
          usuarios: [
            for (final u in state.usuarios)
              if (u.usuarioId == usuario.usuarioId)
                u.copyWith(activo: activar)
              else
                u,
          ],
          totales: _restarSumarTotales(usuario.activo != activar, activar),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          limpiarActuando: true,
          error: activar
              ? 'No se pudo activar a ${usuario.nombreUsuario}.'
              : 'No se pudo desactivar a ${usuario.nombreUsuario}.',
        ),
      );
    }
  }

  UsuariosTotalesResponse? _restarSumarTotales(bool cambia, bool ahoraActivo) {
    final t = state.totales;
    if (t == null || !cambia) return t;
    final delta = ahoraActivo ? 1 : -1;
    return UsuariosTotalesResponse(
      total: t.total,
      activos: t.activos + delta,
      inactivos: t.inactivos - delta,
    );
  }

  Future<void> asignarRol(UsuarioAdminResponse usuario, RolResponse rol) async {
    if (usuario.roles.any(
      (r) => r.trim().toUpperCase() == rol.nombreRol.trim().toUpperCase(),
    )) {
      emit(
        state.copyWith(mensaje: '${usuario.nombreUsuario} ya tiene ese rol.'),
      );
      return;
    }
    emit(
      state.copyWith(
        clearError: true,
        clearMensaje: true,
        actuandoId: usuario.usuarioId,
      ),
    );
    try {
      await _usuariosService.asignarRol(usuario.usuarioId, rol.rolId);
      emit(
        state.copyWith(
          limpiarActuando: true,
          mensaje: 'Rol ${rol.nombreRol} asignado a ${usuario.nombreUsuario}.',
          usuarios: [
            for (final u in state.usuarios)
              if (u.usuarioId == usuario.usuarioId)
                u.copyWith(roles: [...u.roles, rol.nombreRol])
              else
                u,
          ],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          limpiarActuando: true,
          error: 'No se pudo asignar el rol ${rol.nombreRol}.',
        ),
      );
    }
  }

  Future<void> quitarRol(UsuarioAdminResponse usuario, RolResponse rol) async {
    emit(
      state.copyWith(
        clearError: true,
        clearMensaje: true,
        actuandoId: usuario.usuarioId,
      ),
    );
    try {
      await _usuariosService.quitarRol(usuario.usuarioId, rol.rolId);
      emit(
        state.copyWith(
          limpiarActuando: true,
          mensaje: 'Rol ${rol.nombreRol} quitado a ${usuario.nombreUsuario}.',
          usuarios: [
            for (final u in state.usuarios)
              if (u.usuarioId == usuario.usuarioId)
                u.copyWith(
                  roles: u.roles
                      .where(
                        (r) =>
                            r.trim().toUpperCase() !=
                            rol.nombreRol.trim().toUpperCase(),
                      )
                      .toList(),
                )
              else
                u,
          ],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          limpiarActuando: true,
          error: 'No se pudo quitar el rol ${rol.nombreRol}.',
        ),
      );
    }
  }

  void notificar(String mensaje) =>
      emit(state.copyWith(mensaje: mensaje, clearError: true));

  void limpiarFeedback() =>
      emit(state.copyWith(clearMensaje: true, clearError: true));
}
