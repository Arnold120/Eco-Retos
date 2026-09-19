import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/admin_service.dart';
import '../design/eco_widgets.dart';
import 'admin_evidence_screen.dart';
import 'admin_users_screen.dart';
import 'cubit/admin_evidence_cubit.dart';
import 'cubit/admin_panel_cubit.dart';
import 'cubit/admin_panel_state.dart';

/// Página principal del panel de administración: métricas y acceso a los
/// módulos de gestión. Interfaz completamente separada del lado estudiante.
class AdminHomeScreen extends StatefulWidget {
  final int usuarioIdActual;
  final String nombreAdmin;

  const AdminHomeScreen({
    super.key,
    required this.usuarioIdActual,
    required this.nombreAdmin,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPanelCubit>().cargarPanel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminPanelCubit, AdminPanelState>(
      builder: (context, state) {
        if (state.isLoading && state.totales == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.error != null && state.totales == null) {
          return EcoErrorState(
            mensaje: state.error!,
            onReintentar: () => context.read<AdminPanelCubit>().cargarPanel(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<AdminPanelCubit>().cargarPanel(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildEncabezado(context),
              const SizedBox(height: 16),
              _buildEstadisticas(context, state),
              const SizedBox(height: 20),
              const EcoSectionTitle(titulo: 'Módulos de administración'),
              const SizedBox(height: 10),
              _buildModulo(
                context,
                icono: Icons.verified_outlined,
                titulo: 'Revisar evidencias',
                descripcion:
                    'Acepta o rechaza la evidencia que envían los '
                    'estudiantes (fotos + comentario).',
                color: AppColors.success,
                badge: state.evidenciasPendientes,
                onTap: () => _abrirEvidencias(context),
              ),
              const SizedBox(height: 10),
              _buildModulo(
                context,
                icono: Icons.groups_outlined,
                titulo: 'Gestión de usuarios',
                descripcion:
                    'Activa o desactiva cuentas y asigna roles '
                    '(estudiante / administrador).',
                color: AppColors.info,
                onTap: () => _abrirUsuarios(context),
              ),
              const SizedBox(height: 24),
              const EcoSectionTitle(titulo: 'Próximamente'),
              const SizedBox(height: 2),
              const Text(
                'Estos módulos de creación/edición llegarán en la próxima '
                'versión.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textHint),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.15,
                children: const [
                  _ModuloProximamente(
                    icono: Icons.emoji_events_outlined,
                    titulo: 'Retos',
                  ),
                  _ModuloProximamente(
                    icono: Icons.quiz_outlined,
                    titulo: 'Trivias',
                  ),
                  _ModuloProximamente(
                    icono: Icons.inventory_2_outlined,
                    titulo: 'Materiales',
                  ),
                  _ModuloProximamente(
                    icono: Icons.military_tech_outlined,
                    titulo: 'Insignias',
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEncabezado(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.levelPurple, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.levelPurple.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${widget.nombreAdmin}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Panel de administración · Modo admin',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas(BuildContext context, AdminPanelState state) {
    final t = state.totales;
    return Row(
      children: [
        Expanded(
          child: EcoStatCard(
            icono: Icons.people_outline,
            valor: '${t?.total ?? 0}',
            etiqueta: 'Usuarios',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EcoStatCard(
            icono: Icons.check_circle_outline,
            valor: '${t?.activos ?? 0}',
            etiqueta: 'Activos',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EcoStatCard(
            icono: Icons.verified_outlined,
            valor: '${state.evidenciasPendientes}',
            etiqueta: 'Revisar',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildModulo(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    int? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icono,
                color: color == AppColors.success ? Colors.white : color,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null && badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  void _abrirEvidencias(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AdminEvidenceCubit(context.read<AdminService>()),
          child: const AdminEvidenceScreen(),
        ),
      ),
    );
  }

  void _abrirUsuarios(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminPanelCubit>(),
          child: AdminUsersScreen(usuarioIdActual: widget.usuarioIdActual),
        ),
      ),
    );
  }
}

class _ModuloProximamente extends StatelessWidget {
  final IconData icono;
  final String titulo;

  const _ModuloProximamente({required this.icono, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 30, color: AppColors.textHint),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
