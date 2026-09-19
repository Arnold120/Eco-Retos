import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../../data/models/garden/garden_catalog.dart';
import '../../data/models/garden/plant_growth.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as eco;
import 'cubit/garden_cubit.dart';
import 'cubit/garden_state.dart';
import 'widgets/garden_bed.dart';
import 'widgets/garden_hero.dart';
import 'widgets/plant_detail_sheet.dart';
import 'widgets/plant_lost_notice.dart';
import 'widgets/tool_icon.dart';
import 'widgets/unlock_celebration.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 Mi Jardín Virtual'),
        actions: [
          IconButton(
            tooltip: 'Catálogo de plantas',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => _mostrarCatalogo(context),
          ),
        ],
      ),
      body: BlocConsumer<GardenCubit, GardenState>(
        listenWhen: (anterior, actual) =>
            (actual.mejora != null && anterior.mejora != actual.mejora) ||
            (actual.error != null && anterior.error != actual.error) ||
            (actual.mensaje != null && anterior.mensaje != actual.mensaje) ||
            (actual.plantasPerdidas.isNotEmpty &&
                anterior.plantasPerdidas != actual.plantasPerdidas) ||
            (actual.advertencia != null &&
                anterior.advertencia != actual.advertencia),
        listener: (context, state) {
          final mensajero = ScaffoldMessenger.of(context);
          final cubit = context.read<GardenCubit>();
          final perdidas = state.plantasPerdidas;
          if (perdidas.isNotEmpty) {
            cubit.limpiarPerdidas();
            showDialog<void>(
              context: context,
              builder: (_) => PlantLostNotice(
                perdidas: perdidas,
                onCerrar: () {},
              ),
            );
            return;
          }
          final mejora = state.mejora;
          if (mejora != null) {
            mensajero.hideCurrentSnackBar();
            mensajero.showSnackBar(
              SnackBar(
                content: Text(
                  '¡${mejora.planta.nombre} pasó a ${mejora.nueva.label}! 🎉',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            return;
          }
          if (state.error != null) {
            mensajero.hideCurrentSnackBar();
            mensajero.showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          if (state.mensaje != null) {
            mensajero.hideCurrentSnackBar();
            mensajero.showSnackBar(
              SnackBar(
                content: Text(state.mensaje!),
                backgroundColor: AppColors.success,
              ),
            );
            cubit.limpiarMensaje();
            return;
          }
          if (state.advertencia != null) {
            mensajero.hideCurrentSnackBar();
            mensajero.showSnackBar(
              SnackBar(
                content: Text(state.advertencia!),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final sinDatos = state.jardin == null && state.plantas.isEmpty;
          if (state.isLoading && sinDatos) {
            return _buildSkeleton(context);
          }
          if (state.error != null && sinDatos) {
            return eco.ErrorWidget(
              message: state.error!,
              actionLabel: 'Reintentar',
              onAction: () => context.read<GardenCubit>().refresh(),
            );
          }
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => context.read<GardenCubit>().refresh(),
                child: const _GardenContent(),
              ),
              if (state.desbloqueoCarnicora)
                UnlockCelebration(
                  onVerPlanta: () {
                    final cubit = context.read<GardenCubit>();
                    for (final planta in state.plantas) {
                      if (planta.catalogoId == CatalogoJardin.carnicora.id) {
                        cubit.seleccionarPlanta(planta.id);
                        break;
                      }
                    }
                    cubit.limpiarDesbloqueo();
                  },
                  onCerrar: () =>
                      context.read<GardenCubit>().limpiarDesbloqueo(),
                ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarCatalogo(BuildContext context) {
    final cubit = context.read<GardenCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<GardenCubit>.value(
        value: cubit,
        child: const _CatalogoJardinSheet(),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonWidgets.gardenHeader(isDark: isDark),
          const SizedBox(height: 20),
          SkeletonWidgets.gardenVisualization(isDark: isDark),
          const SizedBox(height: 20),
          SkeletonWidgets.plantShopItem(isDark: isDark),
          const SizedBox(height: 10),
          SkeletonWidgets.plantShopItem(isDark: isDark),
          const SizedBox(height: 10),
          SkeletonWidgets.plantShopItem(isDark: isDark),
          const SizedBox(height: 10),
          SkeletonWidgets.plantShopItem(isDark: isDark),
        ],
      ),
    );
  }
}

class _GardenContent extends StatefulWidget {
  const _GardenContent();

  @override
  State<_GardenContent> createState() => _GardenContentState();
}

class _GardenContentState extends State<_GardenContent> {
  final ScrollController _scroll = ScrollController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Solo refresca la interfaz: el progreso real se calcula con timestamps.
    // Cada 30 s también se revisa si alguna planta se perdió por descuido.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      context.read<GardenCubit>().revisarPerdidas();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _irATienda() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<GardenCubit>().state;
    final seleccionada = estado.plantaSeleccionada;

    return ListView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _cabecera(estado),
        const SizedBox(height: 16),
        _rachaCard(estado),
        const SizedBox(height: 20),
        if (seleccionada != null)
          GardenHero(
            planta: seleccionada,
            inventario: estado.inventario,
            efecto: estado.efecto,
            efectoPlantaId: estado.efectoPlantaId,
            efectoToken: estado.efectoToken,
            onRegar: () => context.read<GardenCubit>().regar(seleccionada.id),
            onAbonar: () => context.read<GardenCubit>().abonar(seleccionada.id),
            onFumigar: () =>
                context.read<GardenCubit>().fumigar(seleccionada.id),
            onVerDetalle: () => _abrirDetalle(context, seleccionada),
          )
        else
          _jardinVacio(),
        const SizedBox(height: 20),
        _cantero(estado),
        const SizedBox(height: 20),
        _herramientas(estado),
        const SizedBox(height: 20),
        _tienda(estado),
        const SizedBox(height: 20),
        _info(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Cabecera y racha
  // ---------------------------------------------------------------------------

  Widget _cabecera(GardenState estado) {
    final jardin = estado.jardin;
    final nivel = jardin?.nivelJardin ?? 1;
    final puntos = jardin?.puntosJardin ?? estado.totalPlantas;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gardenGreen, AppColors.gardenGrass],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.gardenGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.yard_outlined, size: 30, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MI JARDÍN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Nivel $nivel · $puntos puntos de jardín',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (estado.racha > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.streakFire.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.streakFire.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.streakFire,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${estado.racha}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _datoCabecera(
                Icons.park_outlined,
                '${estado.totalPlantas}',
                'plantas',
              ),
              _datoCabecera(
                Icons.monetization_on_outlined,
                '${estado.monedas}',
                'Monedas Eco',
              ),
              _datoCabecera(
                Icons.local_florist_outlined,
                '${estado.espaciosLibres}',
                'espacios libres',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datoCabecera(IconData icono, String valor, String etiqueta) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _rachaCard(GardenState estado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final desbloqueada = estado.inventario.carnicoraDesbloqueada;
    final enJardin = estado.carnicoraEnJardin;
    final progreso = (estado.racha / GardenGrowthConfig.rachaCarnicora).clamp(
      0.0,
      1.0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.streakFire.withValues(alpha: isDark ? 0.12 : 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.streakFire.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.streakFire,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  estado.racha > 0
                      ? 'Racha de ${estado.racha} días'
                      : 'Aún no tienes racha',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (enJardin)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.streakFire,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enJardin
                ? '🪴 Planta carnívora desbloqueada y presente en tu jardín.'
                : desbloqueada
                ? '¡Racha de 30 días conseguida! Reclama tu planta carnívora.'
                : estado.racha == 0
                ? 'Completa la trivia diaria para iniciar tu racha. A los 30 días desbloqueas la planta carnívora.'
                : 'Te faltan ${estado.rachaParaCarnicora} días de racha para desbloquear la planta carnívora.',
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
          if (desbloqueada && !enJardin) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.read<GardenCubit>().reclamarCarnicora(),
                icon: const Icon(Icons.card_giftcard),
                label: const Text('Reclamar planta carnívora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gardenGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Jardín
  // ---------------------------------------------------------------------------

  Widget _jardinVacio() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.gardenGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gardenGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.yard_outlined,
            size: 52,
            color: AppColors.gardenGrass,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu jardín está esperando su primera planta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige una especie en la tienda de abajo. Crecerá con el tiempo real y con tus cuidados.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _irATienda,
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Explorar plantas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gardenGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cantero(GardenState estado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vista de tu jardín',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
              _badge('${estado.totalPlantas} plantas', AppColors.gardenGreen),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Toca una planta para ver su seguimiento. El modelo 3D se '
            'desbloquea cuando llega a la etapa adulta.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          GardenBed(
            plantas: estado.plantas,
            maxSlots: GardenGrowthConfig.maxSlots,
            seleccionadaId: estado.seleccionadaId,
            mejora: estado.mejora,
            onVerPlanta: (planta) {
              context.read<GardenCubit>().seleccionarPlanta(planta.id);
              _abrirDetalle(context, planta);
            },
            onPlantarNueva: _irATienda,
          ),
        ],
      ),
    );
  }

  void _abrirDetalle(BuildContext context, PlantGrowth planta) {
    mostrarDetallePlanta(context, plantaId: planta.id);
  }

  // ---------------------------------------------------------------------------
  // Tienda de herramientas
  // ---------------------------------------------------------------------------

  Widget _herramientas(GardenState estado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Herramientas de cuidado',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
              _badge('🪙 ${estado.monedas}', AppColors.xpGold),
            ],
          ),
          const SizedBox(height: 12),
          for (final herramienta in HerramientaJardin.values) ...[
            _filaHerramienta(estado, herramienta),
            if (herramienta != HerramientaJardin.values.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _filaHerramienta(GardenState estado, HerramientaJardin herramienta) {
    final cantidad = estado.inventario.cantidad(herramienta);
    final esPermanente = herramienta == HerramientaJardin.regadera;
    final adquirida = esPermanente && cantidad > 0;
    final puedeComprar =
        !estado.comprandoHerramienta &&
        estado.monedas >= herramienta.precio &&
        !adquirida;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          ToolIcon(herramienta: herramienta, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        herramienta.nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!esPermanente && cantidad > 0) ...[
                      const SizedBox(width: 6),
                      _badge('x$cantidad', AppColors.gardenGrass),
                    ],
                    if (adquirida) ...[
                      const SizedBox(width: 6),
                      _badge('Adquirida', AppColors.success),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  herramienta.descripcion,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: puedeComprar
                ? () => context.read<GardenCubit>().comprarHerramienta(
                    herramienta,
                  )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              adquirida
                  ? 'Lista'
                  : esPermanente
                  ? '${herramienta.precio} 🪙'
                  : '+${herramienta.precio} 🪙',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tienda de plantas
  // ---------------------------------------------------------------------------

  Widget _tienda(GardenState estado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plantas para tu jardín',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cada especie usa su propio modelo 3D. Desliza para ver todas.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 208,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CatalogoJardin.especies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final especie = CatalogoJardin.especies[index];
                final cantidad = estado.plantas
                    .where((p) => p.catalogoId == especie.id)
                    .length;
                return _EspecieCard(
                  especie: especie,
                  cantidad: cantidad,
                  monedas: estado.monedas,
                  comprando: estado.comprando,
                  carnicoraDesbloqueada:
                      estado.inventario.carnicoraDesbloqueada,
                  tieneEspacio: estado.espaciosLibres > 0,
                  onComprar: () =>
                      context.read<GardenCubit>().comprarPlanta(especie),
                  onReclamar: () =>
                      context.read<GardenCubit>().reclamarCarnicora(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Información
  // ---------------------------------------------------------------------------

  Widget _info() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cómo crece tu jardín',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _filaInfo(
            Icons.schedule,
            'El crecimiento usa tiempo real: 5 h por etapa hasta planta '
            'pequeña y luego 4-6 h más.',
          ),
          _filaInfo(
            Icons.water_drop,
            'Regar suma 1 h de crecimiento (cada 3 h) y abonar 2 h (cada 6 h).',
          ),
          _filaInfo(
            Icons.eco,
            'Si dejas de abonarla, su crecimiento se detiene hasta que la '
            'fertilices de nuevo.',
          ),
          _filaInfo(
            Icons.water_damage_outlined,
            'Sin agua se marchita hora a hora y se pierde a las 5 h. Una plaga '
            'sin tratar también se la lleva en 1 día.',
          ),
          _filaInfo(
            Icons.bug_report,
            'El insecticida se aplica mientras la planta crece: la protege de '
            'plagas y acelera su crecimiento. Si aparece una plaga, cúrala.',
          ),
          _filaInfo(
            Icons.lock_outline,
            'El modelo 3D se desbloquea cuando la planta llega a la etapa '
            'adulta. ¡Cuídala hasta entonces!',
          ),
          _filaInfo(
            Icons.local_fire_department,
            'Mantén tu racha diaria: a los 30 días desbloqueas la planta '
            'carnívora.',
          ),
        ],
      ),
    );
  }

  Widget _filaInfo(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 19, color: AppColors.gardenGrass),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Utilidades visuales
  // ---------------------------------------------------------------------------

  BoxDecoration _cardBox(bool isDark) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (isDark ? AppColorsDark.border : AppColors.border),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _badge(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tarjeta de especie (tienda horizontal)
// -----------------------------------------------------------------------------

class _EspecieCard extends StatelessWidget {
  final EspecieJardin especie;
  final int cantidad;
  final int monedas;
  final bool comprando;
  final bool carnicoraDesbloqueada;
  final bool tieneEspacio;
  final VoidCallback onComprar;
  final VoidCallback onReclamar;

  const _EspecieCard({
    required this.especie,
    required this.cantidad,
    required this.monedas,
    required this.comprando,
    required this.carnicoraDesbloqueada,
    required this.tieneEspacio,
    required this.onComprar,
    required this.onReclamar,
  });

  @override
  Widget build(BuildContext context) {
    final especial = especie.especialRacha;
    final bloqueada = especial && !carnicoraDesbloqueada;
    final yaEnJardin = especial && cantidad > 0;
    final puedeComprar =
        !comprando && !bloqueada && tieneEspacio && monedas >= especie.precio;
    final esPlantaCarnicora = especial && carnicoraDesbloqueada;

    return Container(
      width: 154,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: especie.rareza.rarezaColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(especie.emoji, style: const TextStyle(fontSize: 26)),
              const Spacer(),
              if (cantidad > 0) _badge('x$cantidad'),
              if (bloqueada)
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: AppColors.textHint,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            especie.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${especie.tipo.label} · ${especie.rarezaLabel}',
            style: TextStyle(
              fontSize: 10.5,
              color: especie.rareza.rarezaColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (especial)
            Text(
              bloqueada
                  ? 'Racha ${especie.rachaRequerida} días'
                  : '¡Desbloqueada!',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: bloqueada ? AppColors.streakFire : AppColors.success,
              ),
            )
          else
            Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(
                  '${especie.precio}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.xpGold,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: yaEnJardin
                  ? null
                  : esPlantaCarnicora
                  ? (tieneEspacio ? onReclamar : null)
                  : (puedeComprar ? onComprar : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: bloqueada
                    ? AppColors.textHint
                    : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                bloqueada
                    ? 'Bloqueada'
                    : yaEnJardin
                    ? 'En tu jardín'
                    : esPlantaCarnicora
                    ? (tieneEspacio ? 'Plantar' : 'Sin espacio')
                    : !tieneEspacio
                    ? 'Sin espacio'
                    : 'Sembrar',
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gardenGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.gardenGrass,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Catálogo de plantas (hoja modal)
// -----------------------------------------------------------------------------

class _CatalogoJardinSheet extends StatelessWidget {
  const _CatalogoJardinSheet();

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<GardenCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.gardenGrass,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Catálogo de plantas',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              itemCount: CatalogoJardin.especies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final especie = CatalogoJardin.especies[index];
                final cantidad = estado.plantas
                    .where((p) => p.catalogoId == especie.id)
                    .length;
                return _CatalogoItem(
                  especie: especie,
                  cantidad: cantidad,
                  estado: estado,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogoItem extends StatelessWidget {
  final EspecieJardin especie;
  final int cantidad;
  final GardenState estado;

  const _CatalogoItem({
    required this.especie,
    required this.cantidad,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final bloqueada =
        especie.especialRacha && !estado.inventario.carnicoraDesbloqueada;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: especie.rareza.rarezaColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(especie.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      especie.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${especie.tipo.label} · ${especie.rarezaLabel}'
                      '${cantidad > 0 ? ' · Tienes $cantidad' : ''}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: especie.rareza.rarezaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (bloqueada)
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.textHint,
                  size: 20,
                )
              else
                Text(
                  especie.especialRacha ? 'Racha 30' : '🪙 ${especie.precio}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.xpGold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            especie.descripcion,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
          if (bloqueada) ...[
            const SizedBox(height: 8),
            Text(
              'Se desbloquea con una racha de ${especie.rachaRequerida} días '
              '(llevas ${estado.racha}).',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.streakFire,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
