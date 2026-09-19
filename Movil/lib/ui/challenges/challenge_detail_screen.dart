import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalogos/retos/reto_model.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../../data/repositories/reto_repository.dart';
import '../../data/services/imagen_service.dart';
import '../design/eco_widgets.dart';
import 'cubit/challenge_cubit.dart';
import 'cubit/challenge_state.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final Reto reto;

  const ChallengeDetailScreen({super.key, required this.reto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reto.categoria.nombre)),
      body: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          final progreso = _estadoDe(state, reto.id);
          final cubit = context.read<ChallengeCubit>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              _buildHero(context, progreso),
              if (progreso.estado == RetoEstado.pendienteRevision &&
                  progreso.evidenciaPendiente != null) ...[
                const SizedBox(height: 16),
                _buildEvidenciaEnviada(context, progreso.evidenciaPendiente!),
              ],
              const SizedBox(height: 16),
              _buildDescripcion(context, reto),
              if (reto.materiales.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildMateriales(reto),
              ],
              if (reto.requisitos.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildRequisitos(context, reto),
              ],
              if (reto.instrucciones.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildInstrucciones(context, progreso, cubit),
              ],
              if (reto.consejos.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildConsejos(context, reto),
              ],
              if (reto.advertencias.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildAdvertencias(context, reto),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          final cubit = context.read<ChallengeCubit>();
          return _buildAcciones(context, _estadoDe(state, reto.id), cubit);
        },
      ),
    );
  }

  RetoProgreso _estadoDe(ChallengeState state, String id) {
    for (final p in state.retos) {
      if (p.reto.id == id) return p;
    }
    return RetoProgreso(reto: reto);
  }

  // ─── Secciones ─────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, RetoProgreso progreso) {
    final base = Color(reto.categoria.lightColor);
    final fondoClaro = base.computeLuminance() > 0.5;
    final color = fondoClaro ? base : Color.lerp(base, Colors.black, 0.30)!;
    final fg = fondoClaro ? AppColors.textPrimary : Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [base, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reto.categoria.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reto.titulo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          if (reto.subcategoria != null) ...[
            const SizedBox(height: 6),
            Text(
              reto.subcategoria!,
              style: TextStyle(fontSize: 12.5, color: fg),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _ChipBlanco(
                icono: Icons.star,
                texto: '${reto.xp} XP',
                sobreClaro: fondoClaro,
              ),
              const SizedBox(width: 8),
              _ChipBlanco(
                icono: Icons.monetization_on,
                texto: '${reto.monedas} ECO',
                sobreClaro: fondoClaro,
              ),
              const SizedBox(width: 8),
              _ChipBlanco(
                icono: Icons.schedule,
                texto: '${reto.tiempoMin} min',
                sobreClaro: fondoClaro,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              EcoDificultadTag(dificultad: reto.dificultad),
              const SizedBox(width: 8),
              _ChipBlanco(
                icono: Icons.category,
                texto: reto.tipo.label,
                sobreClaro: fondoClaro,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcion(BuildContext context, Reto reto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EcoSectionTitle(titulo: 'Descripción'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            reto.descripcion,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: _textoSobreFondo(context, secundario: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMateriales(Reto reto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EcoSectionTitle(
          titulo: '🧰 Materiales',
          subtitulo: 'Revisa tu Inventario',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final material in reto.materiales)
              EcoChip(
                label: '${material.nombre} ×${material.cantidad}',
                icono: Icons.inventory_2_outlined,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequisitos(BuildContext context, Reto reto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EcoSectionTitle(titulo: 'Requisitos'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final requisito in reto.requisitos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          requisito,
                          style: TextStyle(
                            fontSize: 14,
                            color: _textoSobreFondo(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstrucciones(
    BuildContext context,
    RetoProgreso progreso,
    ChallengeCubit cubit,
  ) {
    final puedeAvanzar = progreso.estado == RetoEstado.enProgreso;
    final pasos = progreso.pasosCompletadas ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EcoSectionTitle(
          titulo: '📋 Instrucciones',
          subtitulo: puedeAvanzar
              ? 'Toca cada paso al completarlo'
              : 'Comenzará el reto para marcar pasos',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < reto.instrucciones.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: puedeAvanzar && i < reto.instrucciones.length
                          ? () => cubit.avanzarPaso(reto, i + 1)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: i < pasos
                                ? AppColors.success.withValues(alpha: 0.4)
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              i < pasos
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: i < pasos
                                  ? AppColors.success
                                  : AppColors.textHint,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${i + 1}. ${reto.instrucciones[i]}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.35,
                                  color: i < pasos
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                                  decoration: i < pasos
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsejos(BuildContext context, Reto reto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EcoSectionTitle(titulo: '💡 Consejos'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final consejo in reto.consejos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          consejo,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: _textoSobreFondo(context, secundario: true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvertencias(BuildContext context, Reto reto) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ Precauciones',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          for (final advertencia in reto.advertencias)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '· $advertencia',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: _textoSobreFondo(context, secundario: true),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvidenciaEnviada(BuildContext context, String evidencia) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var comentario = '';
    final urls = <String>[];
    for (final linea in evidencia.split('\n')) {
      if (linea.startsWith('Comentario:')) {
        comentario = linea.substring('Comentario:'.length).trim();
      } else if (linea.startsWith('Fotos:')) {
        urls.addAll(
          linea
              .substring('Fotos:'.length)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color:
                    isDark ? AppColorsDark.mintStrong : AppColors.primaryDark,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Tu evidencia enviada',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          if (comentario.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comentario,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
          if (urls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    urls[i],
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.border,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Quedó en revisión. Si es aprobada, sumarás los puntos.',
            style: TextStyle(
              fontSize: 12,
              color: _textoSobreFondo(context, secundario: true),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Acciones ──────────────────────────────────────────────────────────

  Widget _buildAcciones(
    BuildContext context,
    RetoProgreso progreso,
    ChallengeCubit cubit,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surface : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: switch (progreso.estado) {
          RetoEstado.disponible || RetoEstado.bloqueado => SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _confirmarComenzar(context, cubit),
              icon: const Icon(Icons.bolt),
              label: Text('Comenzar reto · +${reto.xp} XP'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          RetoEstado.enProgreso => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: EcoProgressBar(
                      progreso: progreso.porcentaje,
                      color: AppColors.primary,
                      altura: 10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progreso.porcentaje * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _textoSobreFondo(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (reto.requiereEvidencia)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _abrirEvidencia(context, cubit, progreso),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text('Enviar evidencia (${reto.evidencia.label})'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _completar(context, cubit, progreso),
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: const Text('Completar reto'),
                  ),
                ),
            ],
          ),
          RetoEstado.requiereEvidencia => const _CtaInfo(
            texto: '¡Casi listo! Envía tu evidencia para revisión.',
          ),
          RetoEstado.pendienteRevision => const _CtaInfo(
            icono: Icons.verified_outlined,
            texto: 'Tu evidencia está en revisión. ¡Vuelve pronto!',
          ),
          RetoEstado.rechazado => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progreso.motivoRechazo != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          progreso.motivoRechazo!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => reto.requiereEvidencia
                      ? _abrirEvidencia(context, cubit, progreso)
                      : _confirmarComenzar(context, cubit),
                  icon: Icon(
                    reto.requiereEvidencia
                        ? Icons.camera_alt_outlined
                        : Icons.refresh,
                  ),
                  label: Text(
                    reto.requiereEvidencia
                        ? 'Reenviar evidencia'
                        : 'Reintentar reto',
                  ),
                ),
              ),
            ],
          ),
          RetoEstado.expirado => const _CtaInfo(
            icono: Icons.timer_off_outlined,
            texto: 'El tiempo límite terminó. El reto ya no está disponible.',
          ),
          RetoEstado.completado => _PanelCompletado(progreso: progreso),
        },
      ),
    );
  }

  void _confirmarComenzar(BuildContext context, ChallengeCubit cubit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.bolt, color: AppColors.primary),
        title: const Text('Comenzar reto'),
        content: Text(
          'Ganarás ${reto.xp} XP y ${reto.monedas} ECO\n'
          'Duración estimada: ${reto.tiempoMin} minutos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Comenzar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await cubit.comenzar(reto);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reto iniciado. ¡A por ello! 🌱'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _abrirEvidencia(
    BuildContext context,
    ChallengeCubit cubit,
    RetoProgreso progreso,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) =>
          _EvidenciaSheet(reto: reto, cubit: cubit, progreso: progreso),
    );
  }

  void _completar(
    BuildContext context,
    ChallengeCubit cubit,
    RetoProgreso progreso,
  ) async {
    if (progreso.estado == RetoEstado.completado) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.emoji_events, color: AppColors.xpGold),
        title: const Text('¿Completar el reto?'),
        content: Text(
          'Recibirás ${reto.xp} XP y ${reto.monedas} ECO.\n'
          'No podrás volver a ganar recompensa por este reto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final resultado = await cubit.completar(reto);
    if (!context.mounted) return;

    if (resultado is! CompletadoNuevo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este reto ya estaba completado (sin recompensa doble)',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final p = resultado.progreso;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _CelebracionSheet(
        titulo: reto.titulo,
        xp: p.reto.xp,
        eco: p.reto.monedas,
        logros: resultado.logros,
        onCerrar: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

// ─── Helpers de UI ────────────────────────────────────────────────────────

/// Color de texto para contenido que va directo sobre el fondo del Scaffold.
Color _textoSobreFondo(BuildContext context, {bool secundario = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (secundario) {
    return isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
  }
  return isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
}

class _ChipBlanco extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool sobreClaro;

  const _ChipBlanco({
    required this.icono,
    required this.texto,
    this.sobreClaro = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = sobreClaro ? AppColors.textPrimary : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: sobreClaro
            ? AppColors.textPrimary.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaInfo extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _CtaInfo({this.icono = Icons.info_outline, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icono, color: AppColors.info, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _textoSobreFondo(context, secundario: true),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelCompletado extends StatelessWidget {
  final RetoProgreso progreso;

  const _PanelCompletado({required this.progreso});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.35),
          ),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Reto completado!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textoSobreFondo(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+${progreso.reto.xp} XP · +${progreso.reto.monedas} ECO '
                  'ya en tu cuenta.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _textoSobreFondo(context, secundario: true),
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Evidencia con fotos ──────────────────────────────────────────────────

class _EvidenciaSheet extends StatefulWidget {
  final Reto reto;
  final ChallengeCubit cubit;
  final RetoProgreso progreso;

  const _EvidenciaSheet({
    required this.reto,
    required this.cubit,
    required this.progreso,
  });

  @override
  State<_EvidenciaSheet> createState() => _EvidenciaSheetState();
}

class _EvidenciaSheetState extends State<_EvidenciaSheet> {
  final _comentario = TextEditingController();
  final List<XFile> _fotos = [];
  late int _cantidad;
  bool _enviando = false;
  String? _error;

  bool get _esCantidad => widget.reto.evidencia == RetoTipoEvidencia.cantidad;

  /// Tipos que exigen al menos una fotografía como evidencia visual.
  bool get _requiereFoto =>
      widget.reto.evidencia == RetoTipoEvidencia.foto ||
      widget.reto.evidencia == RetoTipoEvidencia.galeria ||
      widget.reto.evidencia == RetoTipoEvidencia.video;

  @override
  void initState() {
    super.initState();
    final objetivo = widget.reto.cantidadObjetivo ?? 1;
    _cantidad = widget.progreso.progresoActual.clamp(1, objetivo);
  }

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _agregarFotos() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Tomar foto'),
              subtitle: const Text('Usa la cámara del dispositivo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.levelPurple,
              ),
              title: const Text('Elegir de la galería'),
              subtitle: const Text('Puedes seleccionar varias'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      if (source == ImageSource.gallery) {
        final elegidas = await ImagePicker().pickMultiImage(
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 82,
        );
        if (elegidas.isNotEmpty) {
          setState(() {
            _fotos.addAll(elegidas);
            _error = null;
          });
        }
      } else {
        final foto = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 82,
        );
        if (foto != null) {
          setState(() {
            _fotos.add(foto);
            _error = null;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la cámara o galería')),
        );
      }
    }
  }

  Future<void> _enviar() async {
    if (_enviando) return;

    setState(() {
      _error = null;
      _enviando = true;
    });

    try {
      final urls = <String>[];
      final imagenService = context.read<ImagenService>();
      for (final foto in _fotos) {
        final url = await imagenService.subirImagen(File(foto.path));
        urls.add(url);
      }

      final partes = <String>[];
      if (_esCantidad) {
        partes.add('Cantidad: $_cantidad');
      }
      final comentario = _comentario.text.trim();
      if (comentario.isNotEmpty) {
        partes.add('Comentario: $comentario');
      }
      if (urls.isNotEmpty) {
        partes.add('Fotos: ${urls.join(', ')}');
      }
      if (partes.isEmpty) {
        partes.add('Sin descripción');
      }

      await widget.cubit.enviarEvidencia(widget.reto, partes.join('\n'));

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia enviada. ¡En revisión! 📸'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = _fotos.isEmpty
            ? 'No se pudo enviar la evidencia. Revisa tu conexión.'
            : 'No se pudieron subir las fotos. Revisa tu conexión.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;
    final objetivo = widget.reto.cantidadObjetivo;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColorsDark.border : AppColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_outlined,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _esCantidad
                          ? '¿Cuánto lograste?'
                          : _requiereFoto
                          ? 'Adjunta tu evidencia'
                          : 'Tu evidencia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_esCantidad) ...[
                Text(
                  'Cantidad lograda',
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _cantidad > 1
                          ? () => setState(() => _cantidad--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '$_cantidad'
                          '${objetivo != null ? ' / $objetivo' : ''}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => setState(() {
                        _cantidad =
                            objetivo?.clamp(1, _cantidad + 1) ?? _cantidad + 1;
                      }),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              if (_requiereFoto) ...[
                Text(
                  'Fotos ${_requiereFoto ? '(obligatorias)' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (_fotos.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: _fotos.length,
                    itemBuilder: (context, i) => Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_fotos[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _fotos.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _agregarFotos,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            (isDark ? AppColorsDark.border : AppColors.border)
                                .withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: textColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _fotos.isEmpty
                              ? 'Agregar fotos'
                              : 'Agregar más fotos (${_fotos.length})',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _comentario,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: _requiereFoto
                      ? 'Describe en pocas palabras lo que hiciste (opcional)'
                      : _esCantidad
                      ? 'Nota o comentario (opcional)'
                      : 'Cuéntanos cómo completaste el reto (opcional)',
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 4),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enviando
                      ? null
                      : () {
                          if (_requiereFoto && _fotos.isEmpty) {
                            setState(() {
                              _error =
                                  'Adjunta al menos una foto como evidencia.';
                            });
                            return;
                          }
                          _enviar();
                        },
                  icon: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _enviando
                        ? 'Enviando...'
                        : 'Enviar evidencia para revisión',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Celebración al completar ─────────────────────────────────────────────

class _CelebracionSheet extends StatelessWidget {
  final String titulo;
  final int xp;
  final int eco;
  final List<InsigniaResponse> logros;
  final VoidCallback onCerrar;

  const _CelebracionSheet({
    required this.titulo,
    required this.xp,
    required this.eco,
    required this.logros,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '¡Reto completado! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: AppColors.xpGold, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        '+$xp XP',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.xpGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.coinGold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppColors.coinGold,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+$eco ECO',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.coinGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (logros.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              logros.length == 1
                  ? '¡Desbloqueaste 1 logro!'
                  : '¡Desbloqueaste ${logros.length} logros!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.levelPurple,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: logros.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final logro = logros[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lavender.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.lavender.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.military_tech,
                          color: AppColors.levelPurple,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                logro.nombreInsignia,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.levelPurple,
                                ),
                              ),
                              if (logro.descripcion.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  logro.descripcion,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.xpGold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${logro.monedasRecompensa} Monedas',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.xpGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCerrar,
              icon: const Icon(Icons.check),
              label: const Text('¡Seguir con mi jardín!'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
