import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/challenge/challenge_models.dart';
import '../design/eco_widgets.dart';
import 'cubit/admin_evidence_cubit.dart';
import 'cubit/admin_evidence_state.dart';




class AdminEvidenceScreen extends StatefulWidget {
  const AdminEvidenceScreen({super.key});

  @override
  State<AdminEvidenceScreen> createState() => _AdminEvidenceScreenState();
}

class _AdminEvidenceScreenState extends State<AdminEvidenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminEvidenceCubit>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de revisión'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => context.read<AdminEvidenceCubit>().cargar(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<AdminEvidenceCubit, AdminEvidenceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return EcoErrorState(
              mensaje: state.error!,
              onReintentar: () => context.read<AdminEvidenceCubit>().cargar(),
            );
          }
          if (state.evidencias.isEmpty) {
            return const EcoEmptyState(
              icono: Icons.fact_check_outlined,
              titulo: 'Sin evidencias por revisar',
              mensaje:
                  'Cuando un estudiante envíe la evidencia de un reto, '
                  'aparecerá aquí para que la apruebes o la rechaces. '
                  'Los retos que se completan sin enviar evidencia no '
                  'entran a este panel.',
            );
          }
          return _buildLista(state);
        },
      ),
    );
  }

  Widget _buildLista(AdminEvidenceState state) {
    return Column(
      children: [
        _buildFiltros(state),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppColors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${state.pendientes} evidencia'
                  '${state.pendientes == 1 ? '' : 's'} pendiente'
                  '${state.pendientes == 1 ? '' : 's'} de revisión',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.evidenciasFiltradas.isEmpty
              ? EcoEmptyState(
                  icono: Icons.filter_alt_off_outlined,
                  titulo: 'Sin resultados',
                  mensaje:
                      'No hay evidencias en «${state.filtro.etiqueta}» '
                      'en este momento.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: state.evidenciasFiltradas.length,
                  itemBuilder: (context, i) => _buildTarjeta(
                    context,
                    state.evidenciasFiltradas[i],
                    state,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFiltros(AdminEvidenceState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (final filtro in EvidenceFiltro.values) ...[
            ChoiceChip(
              label: Text(filtro.etiqueta),
              selected: state.filtro == filtro,
              onSelected: (_) =>
                  context.read<AdminEvidenceCubit>().cambiarFiltro(filtro),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  bool _estaPendiente(UsuarioRetoResponse e) =>
      e.estado != 'COMPLETADO' && e.estado != 'RECHAZADO';

  Widget _chipEstado(UsuarioRetoResponse evidencia) {
    final (estado, color) = switch (evidencia.estado) {
      'COMPLETADO' => ('Aprobada', AppColors.success),
      'RECHAZADO' => ('Rechazada', AppColors.error),
      _ => ('Pendiente', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: color == AppColors.success ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _buildTarjeta(
    BuildContext context,
    UsuarioRetoResponse evidencia,
    AdminEvidenceState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final texto = _parsearEvidencia(evidencia.evidencia ?? '');
    final ocupado =
        state.aprobandoId == evidencia.usuarioRetoId ||
        state.rechazandoId == evidencia.usuarioRetoId;

    return EcoCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lavender.withValues(alpha: 0.35),
                child: Text(
                  evidencia.nombreUsuario.isNotEmpty
                      ? evidencia.nombreUsuario[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.levelPurple,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evidencia.nombreUsuario,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _fechaCorta(evidencia.fechaInicio),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _chipEstado(evidencia),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${evidencia.puntosReto} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.xpGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            evidencia.tituloReto,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
          if (evidencia.estado == 'RECHAZADO' &&
              (evidencia.motivoRechazo?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Motivo: ${evidencia.motivoRechazo}',
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          if (texto.comentario.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              texto.comentario,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
          if (texto.fotos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: texto.fotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _verFoto(context, texto.fotos[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      texto.fotos[i],
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 84,
                        height: 84,
                        color: AppColors.border.withValues(alpha: 0.5),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (_estaPendiente(evidencia))
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: ocupado
                        ? null
                        : () => _confirmarAprobar(context, evidencia),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: state.aprobandoId == evidencia.usuarioRetoId
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Aprobar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: ocupado
                        ? null
                        : () => _dialogoRechazo(context, evidencia),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: state.rechazandoId == evidencia.usuarioRetoId
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.replay_circle_filled, size: 18),
                    label: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarAprobar(
    BuildContext context,
    UsuarioRetoResponse evidencia,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.verified, color: Colors.white),
        title: const Text('¿Aprobar evidencia?'),
        content: Text(
          'El reto «${evidencia.tituloReto}» de '
          '${evidencia.nombreUsuario} quedará completado y '
          'otorgará ${evidencia.puntosReto} XP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final aprobado = await context.read<AdminEvidenceCubit>().aprobar(
        evidencia,
        evidencia.puntosReto,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              aprobado
                  ? 'Evidencia aprobada. Reto completado (+${evidencia.puntosReto} XP).'
                  : 'No se pudo aprobar la evidencia.',
            ),
            backgroundColor: aprobado ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _dialogoRechazo(
    BuildContext context,
    UsuarioRetoResponse evidencia,
  ) async {
    final control = TextEditingController(
      text:
          'La evidencia no cumple con lo pedido. Por favor vuelve a hacer el reto.',
    );
    final rechazar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.fact_check_outlined, color: AppColors.error),
        title: const Text('Rechazar evidencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se lo notificará a ${evidencia.nombreUsuario} para que '
              'rehaga el reto «${evidencia.tituloReto}».',
              style: const TextStyle(fontSize: 13.5, height: 1.3),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: control,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo',
                border: OutlineInputBorder(),
                hintText: 'Explica qué debe corregir el estudiante',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (rechazar == true && context.mounted) {
      final motivo = control.text.trim();
      if (motivo.isEmpty) return;
      final rechazado = await context.read<AdminEvidenceCubit>().rechazar(
        evidencia,
        motivo,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rechazado
                  ? 'Evidencia rechazada. El estudiante debe rehacerla.'
                  : 'No se pudo rechazar la evidencia.',
            ),
            backgroundColor: rechazado ? AppColors.error : AppColors.error,
          ),
        );
      }
    }
  }

  void _verFoto(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  ({String comentario, List<String> fotos}) _parsearEvidencia(String texto) {
    var comentario = '';
    final fotos = <String>[];
    for (final linea in texto.split('\n')) {
      if (linea.startsWith('Comentario:')) {
        comentario = linea.substring('Comentario:'.length).trim();
      } else if (linea.startsWith('Fotos:')) {
        fotos.addAll(
          linea
              .substring('Fotos:'.length)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      } else if (linea.isNotEmpty && comentario.isEmpty && fotos.isEmpty) {
        comentario = linea.trim();
      }
    }
    return (comentario: comentario, fotos: fotos);
  }

  String _fechaCorta(DateTime fecha) {
    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return 'Enviada el $dia/$mes/${local.year} · $hora:$minuto';
  }
}
