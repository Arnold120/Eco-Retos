import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/garden/plant_growth.dart';
import '../cubit/garden_cubit.dart';
import 'tool_icon.dart';

/// Abre el panel de detalle de una planta: etapa, porcentaje, fecha de
/// plantación, próximo objetivo, estado, agua, abono, plaga y herramientas.
Future<void> mostrarDetallePlanta(
  BuildContext context, {
  required String plantaId,
}) {
  final cubit = context.read<GardenCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider<GardenCubit>.value(
      value: cubit,
      child: _PlantaDetailSheet(plantaId: plantaId),
    ),
  );
}

class _PlantaDetailSheet extends StatelessWidget {
  final String plantaId;

  const _PlantaDetailSheet({required this.plantaId});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<GardenCubit>().state;
    PlantGrowth? planta;
    for (final candidata in estado.plantas) {
      if (candidata.id == plantaId) {
        planta = candidata;
        break;
      }
    }

    if (planta == null) {
      return const _PlantaNoEncontrada();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.border : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(context, planta),
                  const SizedBox(height: 16),
                  _progreso(planta),
                  const SizedBox(height: 20),
                  _lineaDeEtapas(planta),
                  const SizedBox(height: 20),
                  _tarjetaInfo(planta),
                  const SizedBox(height: 20),
                  _acciones(context, planta, estado.inventario),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(BuildContext context, PlantGrowth planta) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: planta.rarezaColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(planta.emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planta.nombre,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _chip(planta.rarezaLabel, planta.rarezaColor),
                  _chip(planta.etapa().label, AppColors.gardenGrass),
                  if (planta.tienePlaga)
                    _chip('Plaga detectada', AppColors.error),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _progreso(PlantGrowth planta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gardenGreen.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gardenGreen.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crecimiento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: planta.progreso()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, valor, _) => Text(
                  '${valor.round()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gardenGrass,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: planta.progreso() / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, valor, _) => LinearProgressIndicator(
                value: valor,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(planta.rarezaColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            planta.tienePlaga
                ? 'La plaga detiene el crecimiento. Usa insecticida para '
                      'protegerla.'
                : planta.etapa().descripcion,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineaDeEtapas(PlantGrowth planta) {
    final etapas = planta.tieneFloracion
        ? EtapaCrecimiento.values
        : EtapaCrecimiento.values
              .where((e) => e != EtapaCrecimiento.floracion)
              .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etapas de crecimiento',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final etapa in etapas)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: etapa.index <= planta.etapa().index
                            ? AppColors.gardenGreen
                            : Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: etapa.index == planta.etapa().index
                              ? AppColors.xpGold
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: etapa.index < planta.etapa().index
                          ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      etapa.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 8.5,
                        height: 1.1,
                        fontWeight: etapa.index == planta.etapa().index
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: etapa.index <= planta.etapa().index
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tarjetaInfo(PlantGrowth planta) {
    final proxima = planta.proximaEtapa;
    final proximoObjetivo = proxima == null
        ? '¡Alcanzó su etapa final!'
        : proxima == EtapaCrecimiento.floracion
        ? '${proxima.label} · unas ${planta.horasParaSiguienteEtapa.ceil()} h'
        : '${proxima.label} · unas ${planta.horasParaSiguienteEtapa.ceil()} h';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icono: Icons.local_florist_outlined,
            etiqueta: 'Nombre',
            valor: planta.nombre,
          ),
          _InfoRow(
            icono: Icons.eco_outlined,
            etiqueta: 'Etapa actual',
            valor: planta.etapa().label,
          ),
          _InfoRow(
            icono: Icons.percent,
            etiqueta: 'Crecimiento',
            valor: '${planta.progreso().round()}%',
          ),
          _InfoRow(
            icono: Icons.event_outlined,
            etiqueta: 'Plantada el',
            valor: _formatoFecha(planta.plantadaEl),
          ),
          _InfoRow(
            icono: Icons.flag_outlined,
            etiqueta: 'Próximo objetivo',
            valor: proximoObjetivo,
          ),
          _InfoRow(
            icono: Icons.favorite_outline,
            etiqueta: 'Estado de la planta',
            valor: planta.estadoSalud,
            destacado: true,
          ),
          _InfoRow(
            icono: Icons.water_drop_outlined,
            etiqueta: 'Agua',
            valor: planta.marchita
                ? '¡Seca! Riega ya'
                : planta.necesitaAgua
                ? 'Necesita agua'
                : planta.humedad,
          ),
          _InfoRow(
            icono: Icons.eco,
            etiqueta: 'Abono',
            valor: planta.faltaAbono
                ? '¡Falta abono!'
                : planta.puedeAbonar
                ? 'Disponible'
                : 'Recién abonada',
          ),
          _InfoRow(
            icono: Icons.bug_report_outlined,
            etiqueta: 'Plagas',
            valor: planta.tienePlaga
                ? 'Plaga detectada'
                : planta.estaProtegida()
                ? 'Protegida'
                : 'Sin plagas',
            ultimo: true,
          ),
        ],
      ),
    );
  }

  Widget _acciones(
    BuildContext context,
    PlantGrowth planta,
    InventarioJardin inventario,
  ) {
    final cubit = context.read<GardenCubit>();
    final puedeRegar = inventario.regadera && planta.puedeRegar;
    final puedeAbonar = inventario.abono > 0 && planta.puedeAbonar;
    final puedeFumigar =
        inventario.insecticida > 0 && planta.puedeInsecticida;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Accion(
                icono: const ToolIcon(
                  herramienta: HerramientaJardin.regadera,
                  size: 28,
                  conFondo: false,
                ),
                label: 'Regar',
                detalle: !inventario.regadera
                    ? 'Sin regadera'
                    : planta.puedeRegar
                    ? '+1 h'
                    : _formatoDuracion(planta.tiempoRestanteRiego),
                color: AppColors.info,
                habilitado: puedeRegar,
                onTap: () => cubit.regar(planta.id),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Accion(
                icono: const ToolIcon(
                  herramienta: HerramientaJardin.abono,
                  size: 28,
                  conFondo: false,
                ),
                label: 'Abonar',
                detalle: inventario.abono <= 0
                    ? 'Sin abono'
                    : planta.puedeAbonar
                    ? 'x${inventario.abono} · +2 h'
                    : _formatoDuracion(planta.tiempoRestanteAbono),
                color: AppColors.success,
                habilitado: puedeAbonar,
                onTap: () => cubit.abonar(planta.id),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Accion(
                icono: const ToolIcon(
                  herramienta: HerramientaJardin.insecticida,
                  size: 28,
                  conFondo: false,
                ),
                label: planta.tienePlaga ? 'Curar' : 'Insecticida',
                detalle: inventario.insecticida <= 0
                    ? 'Sin stock'
                    : planta.tienePlaga
                    ? 'x${inventario.insecticida} · curar'
                    : !planta.enCrecimiento
                    ? 'Planta adulta'
                    : !planta.puedeInsecticida
                    ? _formatoDuracion(planta.tiempoRestanteInsecticida)
                    : 'x${inventario.insecticida} · proteger',
                color: AppColors.warning,
                habilitado: puedeFumigar,
                onTap: () => cubit.fumigar(planta.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: Colors.white38),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _formatoFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _formatoDuracion(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;
    if (horas <= 0) return '${minutos}m';
    return '${horas}h ${minutos}m';
  }
}

class _Accion extends StatelessWidget {
  final Widget icono;
  final String label;
  final String detalle;
  final Color color;
  final bool habilitado;
  final VoidCallback onTap;

  const _Accion({
    required this.icono,
    required this.label,
    required this.detalle,
    required this.color,
    required this.habilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: habilitado ? 1 : 0.45,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: habilitado ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                icono,
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 9.5,
                    height: 1.15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final bool destacado;
  final bool ultimo;

  const _InfoRow({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultimo ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: AppColors.gardenGrass),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: destacado ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantaNoEncontrada extends StatelessWidget {
  const _PlantaNoEncontrada();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 46, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'No encontramos información de esta planta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Puede que ya no esté en tu jardín. Intenta actualizar la pantalla.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
