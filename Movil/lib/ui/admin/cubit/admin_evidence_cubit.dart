import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/challenge/challenge_models.dart';
import '../../../data/services/admin_service.dart';
import 'admin_evidence_state.dart';

class AdminEvidenceCubit extends Cubit<AdminEvidenceState> {
  final AdminService _adminService;

  AdminEvidenceCubit(this._adminService)
    : super(const AdminEvidenceState.initial());


  Future<void> cargar() async {
    emit(const AdminEvidenceState(isLoading: true, evidencias: []));
    try {
      final lista = await _adminService.obtenerEvidencias();
      emit(AdminEvidenceState(isLoading: false, evidencias: lista));
    } catch (e) {
      emit(
        AdminEvidenceState(
          isLoading: false,
          evidencias: const [],
          error: _mensajeError(e, 'No se pudieron cargar las evidencias.'),
        ),
      );
    }
  }


  void cambiarFiltro(EvidenceFiltro filtro) {
    if (state.filtro == filtro) return;
    emit(state.copyWith(filtro: filtro));
  }


  Future<bool> aprobar(UsuarioRetoResponse evidencia, int puntos) async {
    emit(state.copyWith(aprobandoId: evidencia.usuarioRetoId, error: null));
    try {
      await _adminService.aprobarEvidencia(evidencia.usuarioRetoId, puntos);
      _marcarDecidida(evidencia, 'COMPLETADO');
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          aprobandoId: null,
          error: _mensajeError(
            e,
            'La evidencia no pudo aprobarse. Revisa tu conexión.',
          ),
        ),
      );
      return false;
    }
  }


  Future<bool> rechazar(UsuarioRetoResponse evidencia, String motivo) async {
    emit(state.copyWith(rechazandoId: evidencia.usuarioRetoId, error: null));
    try {
      await _adminService.rechazarEvidencia(evidencia.usuarioRetoId, motivo);
      _marcarDecidida(evidencia, 'RECHAZADO');
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          rechazandoId: null,
          error: _mensajeError(
            e,
            'La evidencia no pudo rechazarse. Revisa tu conexión.',
          ),
        ),
      );
      return false;
    }
  }

  String _mensajeError(Object e, String generico) {
    if (e is ApiException) {
      if (e.statusCode == 404) {
        return 'El servidor aún no tiene el módulo de evidencias. '
            'Reinicia el WebApi para actualizarlo.';
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        return 'Tu sesión no tiene permisos de administrador. '
            'Vuelve a iniciar sesión como ADMIN.';
      }
      return e.userMessage.isNotEmpty ? e.userMessage : generico;
    }
    return generico;
  }


  void _marcarDecidida(UsuarioRetoResponse evidencia, String estado) {
    emit(
      state.copyWith(
        evidencias: state.evidencias
            .map(
              (e) => e.usuarioRetoId == evidencia.usuarioRetoId
                  ? e.copyWith(estado: estado)
                  : e,
            )
            .toList(),
        aprobandoId: null,
        rechazandoId: null,
      ),
    );
  }
}
