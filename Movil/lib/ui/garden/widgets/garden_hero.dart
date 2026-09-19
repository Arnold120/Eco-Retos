import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/garden/plant_growth.dart';
import '../cubit/garden_state.dart';
import 'garden_effects.dart';
import 'plant_3d_viewer.dart';
import 'plant_art.dart';
import 'tool_icon.dart';



class GardenHero extends StatefulWidget {
  final PlantGrowth planta;
  final InventarioJardin inventario;
  final EfectoJardin? efecto;
  final String? efectoPlantaId;
  final int efectoToken;
  final VoidCallback onRegar;
  final VoidCallback onAbonar;
  final VoidCallback onFumigar;
  final VoidCallback onVerDetalle;

  const GardenHero({
    super.key,
    required this.planta,
    required this.inventario,
    required this.onRegar,
    required this.onAbonar,
    required this.onFumigar,
    required this.onVerDetalle,
    this.efecto,
    this.efectoPlantaId,
    this.efectoToken = 0,
  });

  @override
  State<GardenHero> createState() => _GardenHeroState();
}

class _GardenHeroState extends State<GardenHero>
    with SingleTickerProviderStateMixin {
  final Plant3DController _controller = Plant3DController();
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();
  Timer? _swap;
  String? _src;
  String? _plantaId;
  int _etapaIndex = -1;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _plantaId = widget.planta.id;
    _etapaIndex = widget.planta.etapa().index;
    _src = widget.planta.assetModelo;
    _visible = true;
  }

  @override
  void didUpdateWidget(covariant GardenHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    final planta = widget.planta;
    if (planta.id != _plantaId) {
      _cambiarModelo(planta, reiniciar: true);
      return;
    }
    final nuevaEtapa = planta.etapa().index;
    if (nuevaEtapa != _etapaIndex) {
      _etapaIndex = nuevaEtapa;
      if (planta.assetModelo == _src) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.escala(planta.escalaModelo);
          _controller.pulso();
          _controller.reproducir();
        });
      } else {
        _cambiarModelo(planta, reiniciar: true);
      }
    }
  }

  void _cambiarModelo(PlantGrowth planta, {required bool reiniciar}) {
    _swap?.cancel();
    setState(() => _visible = false);
    _swap = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _plantaId = planta.id;
        _etapaIndex = planta.etapa().index;
        _src = planta.assetModelo;
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    _swap?.cancel();
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planta = widget.planta;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tieneEfecto =
        widget.efecto != null && widget.efectoPlantaId == planta.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColorsDark.border : AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezado(planta, isDark),
          const SizedBox(height: 12),
          _visor(planta, tieneEfecto, isDark),
          const SizedBox(height: 14),
          _progreso(planta),
          const SizedBox(height: 10),
          _alerta(planta),
          const SizedBox(height: 14),
          _etapas(planta),
          const SizedBox(height: 14),
          _herramientas(planta),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onVerDetalle,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Ver detalles'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gardenGrass,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(PlantGrowth planta, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: planta.rarezaColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(planta.emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planta.nombre,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _chip(planta.etapa().label, AppColors.gardenGrass),
                  _chip(planta.rarezaLabel, planta.rarezaColor),
                  _chip(
                    planta.estadoSalud,
                    planta.tienePlaga
                        ? AppColors.error
                        : (planta.estadoSalud == 'Necesita agua'
                              ? AppColors.warning
                              : AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _visor(PlantGrowth planta, bool tieneEfecto, bool isDark) {
    final modeloDesbloqueado = planta.esAdulta;
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bluePastel.withValues(alpha: 0.18),
            AppColors.gardenGrass.withValues(alpha: 0.26),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gardenGreen.withValues(alpha: 0.35),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!modeloDesbloqueado || _src == null)
              _spriteDeCrecimiento(planta)
            else
              AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: Plant3DViewer(
                  key: ValueKey(_src),
                  src: _src!,
                  alt:
                      'Modelo 3D de ${planta.nombre} (${planta.etapa().label})',
                  escala: planta.escalaModelo,
                  animationName: planta.animacion,
                  controller: _controller,
                ),
              ),
            if (planta.humedad == 'Hidratada') const SueloHumedoOverlay(),
            if (tieneEfecto)
              GardenEffectOverlay(
                key: ValueKey('efecto_${widget.efectoToken}'),
                tipo: switch (widget.efecto!) {
                  EfectoJardin.riego => GardenEffectType.gotas,
                  EfectoJardin.abono => GardenEffectType.abono,
                  EfectoJardin.insecticida => GardenEffectType.insecticida,
                },
              ),
            if (planta.tienePlaga)
              const Positioned(
                top: 10,
                left: 10,
                child: _Aviso(
                  icono: Icons.bug_report,
                  texto: 'Plaga detectada',
                  color: AppColors.error,
                ),
              ),
            if (!modeloDesbloqueado) _candado3D(planta),
          ],
        ),
      ),
    );
  }

  Widget _spriteDeCrecimiento(PlantGrowth planta) {
    return RepaintBoundary(
      child: PlantSprite(
        planta: planta,
        animacion: _sway,
        fase: 0.1,
        marchita: planta.marchita,
        marchitez: planta.marchitez,
        recienRegada: planta.horasSinRiego < 6,
      ),
    );
  }

  Widget _candado3D(PlantGrowth planta) {
    final proxima = planta.proximaEtapa;
    final faltan = planta.horasParaSiguienteEtapa.ceil();
    return Positioned(
      left: 10,
      right: 10,
      bottom: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.gardenGrass.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.gardenGrass.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 17,
                color: AppColors.gardenGrass,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modelo 3D bloqueado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proxima == null
                        ? 'Se desbloquea al llegar a la etapa adulta.'
                        : 'Se desbloquea en la etapa adulta · ${proxima.label} '
                              'en ~${faltan}h. ¡Cuida tu planta!',
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.25,
                      color: Colors.white70,
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

  Widget _progreso(PlantGrowth planta) {
    final proxima = planta.proximaEtapa;
    final progreso = planta.progreso();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Crecimiento',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(alpha: 0.95),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progreso),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, valor, _) => Text(
                '${valor.round()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gardenGrass,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progreso / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => LinearProgressIndicator(
              value: valor,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(planta.rarezaColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          proxima == null
              ? (planta.tienePlaga
                    ? 'La plaga detiene su crecimiento. Usa insecticida.'
                    : '¡Tu planta llegó a su etapa final!')
              : planta.tienePlaga
              ? 'Crecimiento en pausa por plaga · próxima etapa: ${proxima.label}'
              : 'Próxima etapa: ${proxima.label} · unas ${planta.horasParaSiguienteEtapa.ceil()} h',
          style: TextStyle(
            fontSize: 12,
            color: planta.tienePlaga
                ? AppColors.error
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _alerta(PlantGrowth planta) {
    final String texto;
    final Color color;
    final IconData icono;

    if (planta.tienePlaga) {
      color = AppColors.error;
      icono = Icons.bug_report;
      texto =
          'Plaga sin tratar: se perderá en ${_formatoHoras(planta.horasParaPerderse)}. Usa insecticida.';
    } else if (planta.marchita) {
      color = AppColors.error;
      icono = Icons.water_damage_outlined;
      texto =
          'Se está secando: riégala en ${_formatoHoras(planta.horasParaPerderse)} o la perderás.';
    } else if (planta.necesitaAgua) {
      color = AppColors.warning;
      icono = Icons.water_drop_outlined;
      texto = 'Tiene sed: riégala pronto para que siga creciendo sana.';
    } else if (planta.faltaAbono) {
      color = AppColors.warning;
      icono = Icons.eco_outlined;
      texto =
          'Le falta abono: su crecimiento está detenido. Aplica abono para continuar.';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatoHoras(double horas) {
    if (horas <= 0) return 'menos de 1 h';
    if (horas < 1) return '${(horas * 60).round()} min';
    final enteras = horas.floor();
    final minutos = ((horas - enteras) * 60).round();
    if (enteras >= 24) {
      final dias = (enteras / 24).floor();
      return '$dias día${dias == 1 ? '' : 's'}';
    }
    return minutos == 0 ? '$enteras h' : '$enteras h $minutos min';
  }

  Widget _etapas(PlantGrowth planta) {
    final etapas = planta.tieneFloracion
        ? EtapaCrecimiento.values
        : EtapaCrecimiento.values
              .where((e) => e != EtapaCrecimiento.floracion)
              .toList();
    final actual = planta.etapa().index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gardenGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gardenGreen.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seguimiento de crecimiento',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < etapas.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: i <= actual
                            ? planta.rarezaColor
                            : Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      width: i == actual ? 26 : 18,
                      height: i == actual ? 26 : 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < actual
                            ? AppColors.gardenGreen
                            : i == actual
                            ? planta.rarezaColor
                            : Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: i <= actual
                              ? AppColors.gardenGreen.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.18),
                          width: i == actual ? 2.5 : 1.2,
                        ),
                        boxShadow: i == actual
                            ? [
                                BoxShadow(
                                  color: planta.rarezaColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: i < actual
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : i == actual
                          ? const Icon(
                              Icons.eco,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 42,
                      child: Text(
                        etapas[i].label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: i == actual
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: i <= actual
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _herramientas(PlantGrowth planta) {
    final inventario = widget.inventario;
    final puedeRegar = inventario.regadera && planta.puedeRegar;
    final puedeAbonar = inventario.abono > 0 && planta.puedeAbonar;
    final puedeFumigar =
        inventario.insecticida > 0 && planta.puedeInsecticida;

    return Row(
      children: [
        Expanded(
          child: _BotonHerramienta(
            icono: const ToolIcon(
              herramienta: HerramientaJardin.regadera,
              size: 30,
              conFondo: false,
            ),
            label: 'Regar',
            detalle: !inventario.regadera
                ? 'Sin regadera'
                : planta.puedeRegar
                ? '+1 h de crecimiento'
                : 'En ${_formato(planta.tiempoRestanteRiego)}',
            color: AppColors.info,
            habilitado: puedeRegar,
            onTap: widget.onRegar,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BotonHerramienta(
            icono: const ToolIcon(
              herramienta: HerramientaJardin.abono,
              size: 30,
              conFondo: false,
            ),
            label: 'Abonar',
            detalle: inventario.abono <= 0
                ? 'Sin abono'
                : planta.puedeAbonar
                ? 'x${inventario.abono} · +2 h'
                : 'x${inventario.abono} · en ${_formato(planta.tiempoRestanteAbono)}',
            color: AppColors.success,
            habilitado: puedeAbonar,
            onTap: widget.onAbonar,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BotonHerramienta(
            icono: const ToolIcon(
              herramienta: HerramientaJardin.insecticida,
              size: 30,
              conFondo: false,
            ),
            label: planta.tienePlaga ? 'Curar' : 'Proteger',
            detalle: inventario.insecticida <= 0
                ? 'Sin insecticida'
                : planta.tienePlaga
                ? 'x${inventario.insecticida} · curar'
                : !planta.enCrecimiento
                ? 'Planta adulta'
                : !planta.puedeInsecticida
                ? 'en ${_formato(planta.tiempoRestanteInsecticida)}'
                : 'x${inventario.insecticida} · proteger',
            color: AppColors.warning,
            habilitado: puedeFumigar,
            onTap: widget.onFumigar,
          ),
        ),
      ],
    );
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _formato(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;
    if (horas <= 0) return '${minutos}m';
    return '${horas}h ${minutos}m';
  }
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;

  const _Aviso({required this.icono, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonHerramienta extends StatelessWidget {
  final Widget icono;
  final String label;
  final String detalle;
  final Color color;
  final bool habilitado;
  final VoidCallback onTap;

  const _BotonHerramienta({
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
                  style: const TextStyle(
                    fontSize: 12,
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
