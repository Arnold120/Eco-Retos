import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalogos/retos/reto_model.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../design/eco_widgets.dart';
import '../widgets/global_header_actions.dart';
import 'cubit/challenge_cubit.dart';
import 'cubit/challenge_state.dart';
import 'challenge_detail_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  final int usuarioId;
  final VoidCallback? onMenuTap;

  const ChallengeListScreen({
    super.key,
    required this.usuarioId,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<ChallengeCubit>().state;
    final categoriaAbierta = estado.categoriaSeleccionada;

    return Scaffold(
      appBar: AppBar(
        leading: categoriaAbierta == null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap)
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Volver a categorías',
                onPressed: () => context
                    .read<ChallengeCubit>()
                    .filtrarCategoria(null),
              ),
        title: categoriaAbierta == null
            ? const Text('Retos Eco')
            : _AppBarCategoria(categoria: categoriaAbierta),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filtros',
            onPressed: () => _abrirFiltros(context),
          ),
          const GlobalHeaderActions(),
        ],
      ),
      body: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          _celebrarAprobaciones(context, state);

          if (state.isLoading && state.retos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.error != null && state.retos.isEmpty) {
            return EcoErrorState(
              mensaje: state.error!,
              onReintentar: () => context.read<ChallengeCubit>().refresh(),
            );
          }

          final cubit = context.read<ChallengeCubit>();
          final categoria = state.categoriaSeleccionada;
          final vista = categoria == null
              ? _SelectorCategorias(
                  key: const ValueKey('selector'),
                  cubit: cubit,
                  retos: state.retos,
                )
              : _RetosDeCategoria(
                  key: ValueKey('categoria-${categoria.id}'),
                  cubit: cubit,
                  state: state,
                  categoria: categoria,
                );

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.985, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            ),
            child: vista,
          );
        },
      ),
    );
  }



  void _abrirFiltros(BuildContext context) {
    final cubit = context.read<ChallengeCubit>();
    final state = context.read<ChallengeState>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EcoSectionTitle(titulo: 'Filtrar por categoría'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: state.categoriaSeleccionada == null,
                        onSelected: (_) {
                          Navigator.of(ctx).pop();
                          cubit.filtrarCategoria(null);
                        },
                      ),
                      for (final categoria in RetoCategoria.values)
                        ChoiceChip(
                          label: Text(categoria.nombre),
                          selected: state.categoriaSeleccionada == categoria,
                          onSelected: (_) {
                            Navigator.of(ctx).pop();
                            cubit.filtrarCategoria(categoria);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const EcoSectionTitle(titulo: 'Tipo de reto'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tipo in RetoTipo.values)
                        ChoiceChip(
                          label: Text(tipo.label),
                          selected: state.tipoSeleccionado == tipo,
                          onSelected: (_) {
                            setModalState(() {
                              cubit.filtrarTipo(
                                state.tipoSeleccionado == tipo ? null : tipo,
                              );
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  void _celebrarAprobaciones(BuildContext context, ChallengeState state) {
    final aprobaciones = state.aprobacionesRecientes;
    if (aprobaciones.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => _AprobacionDialog(
          aprobaciones: aprobaciones,
          onCerrar: () {
            Navigator.of(ctx).pop();
            context.read<ChallengeCubit>().limpiarAprobaciones();
          },
        ),
      );
    });
  }
}



class _SelectorCategorias extends StatelessWidget {
  final ChallengeCubit cubit;
  final List<RetoProgreso> retos;

  const _SelectorCategorias({
    super.key,
    required this.cubit,
    required this.retos,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: EcoSectionTitle(
              titulo: 'Categorías',
              subtitulo: 'Elige una categoría para comenzar',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 184,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categoria = RetoCategoria.values[index];
                  final cantidad = retos
                      .where((p) => p.reto.categoria == categoria)
                      .length;
                  return _CategoriaCard(
                    categoria: categoria,
                    cantidadRetos: cantidad,
                    onTap: () => cubit.filtrarCategoria(categoria),
                  );
                },
                childCount: RetoCategoria.values.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _CategoriaCard extends StatefulWidget {
  final RetoCategoria categoria;
  final int cantidadRetos;
  final VoidCallback onTap;

  const _CategoriaCard({
    required this.categoria,
    required this.cantidadRetos,
    required this.onTap,
  });

  @override
  State<_CategoriaCard> createState() => _CategoriaCardState();
}

class _CategoriaCardState extends State<_CategoriaCard> {
  bool _presionado = false;

  void _setPresionado(bool valor) {
    if (_presionado == valor) return;
    setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    final categoria = widget.categoria;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = Color(categoria.lightColor);
    final acento = _acentoCategoria(categoria, isDark);
    final superficie =
        isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard;
    final colorTitulo =
        isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final colorTexto =
        isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return AnimatedScale(
      scale: _presionado ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          onTapDown: (_) => _setPresionado(true),
          onTapUp: (_) => _setPresionado(false),
          onTapCancel: () => _setPresionado(false),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: superficie,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(superficie, base, isDark ? 0.16 : 0.10)!,
                  superficie,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: acento.withValues(alpha: isDark ? 0.55 : 0.32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: base,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: base.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        categoria.icono,
                        color: _sobreCategoria(base),
                        size: 23,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: acento, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  categoria.nombreLimpio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: colorTitulo,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    categoria.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: colorTexto,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.eco_outlined, size: 14, color: acento),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.cantidadRetos} '
                      '${widget.cantidadRetos == 1 ? 'reto' : 'retos'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: acento,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





class _RetosDeCategoria extends StatefulWidget {
  final ChallengeCubit cubit;
  final ChallengeState state;
  final RetoCategoria categoria;

  const _RetosDeCategoria({
    super.key,
    required this.cubit,
    required this.state,
    required this.categoria,
  });

  @override
  State<_RetosDeCategoria> createState() => _RetosDeCategoriaState();
}

class _RetosDeCategoriaState extends State<_RetosDeCategoria> {
  late final TextEditingController _busqueda;

  _OrdenRetos _orden = _OrdenRetos.recientes;



  int _revision = 0;

  String _firmaAnterior = '';

  @override
  void initState() {
    super.initState();
    _busqueda = TextEditingController(text: widget.state.busqueda);
    _firmaAnterior = _firma(widget.state);
  }

  @override
  void didUpdateWidget(covariant _RetosDeCategoria oldWidget) {
    super.didUpdateWidget(oldWidget);
    final firma = _firma(widget.state);
    if (firma != _firmaAnterior) {
      _firmaAnterior = firma;
      _revision++;
    }
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }


  String _firma(ChallengeState state) =>
      '${state.seccion}|${state.dificultadSeleccionada}|'
      '${state.tipoSeleccionado}';

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final base = state.retosFiltrados;
    final visibles = _aplicarOrden(base);
    final hayFiltros =
        state.busqueda.trim().isNotEmpty ||
        state.seccion != RetosSeccion.todos ||
        state.dificultadSeleccionada != null ||
        state.tipoSeleccionado != null;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(context, visibles.length, hayFiltros),
        ),
        if (visibles.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: EcoEmptyState(
                icono: Icons.eco_outlined,
                titulo: 'No encontramos retos',
                mensaje: 'Prueba quitando algún filtro.',
                accionLabel: 'Limpiar filtros',
                onAccion: _limpiarTodo,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList.builder(
              itemCount: visibles.length,
              itemBuilder: (context, index) {
                final progreso = visibles[index];
                return _EntranceCard(
                  key: ValueKey('$_revision-$index'),
                  child: _RetoCard(
                    progreso: progreso,
                    onTap: () => _abrirDetalle(context, progreso),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }



  Widget _buildHeader(
    BuildContext context,
    int cantidad,
    bool hayFiltros,
  ) {
    final state = widget.state;
    final cubit = widget.cubit;
    final q = state.busqueda.trim();

    final activos = <Widget>[
      if (state.seccion != RetosSeccion.todos)
        _FiltroActivo(
          label: state.seccion.label,
          onEliminar: () => cubit.cambiarSeccion(RetosSeccion.todos),
        ),
      if (state.dificultadSeleccionada != null)
        _FiltroActivo(
          label: state.dificultadSeleccionada!.label,
          onEliminar: () => cubit.filtrarDificultad(null),
        ),
      if (state.tipoSeleccionado != null)
        _FiltroActivo(
          label: state.tipoSeleccionado!.label,
          onEliminar: () => cubit.filtrarTipo(null),
        ),
      if (q.isNotEmpty)
        _FiltroActivo(
          label: '“$q”',
          onEliminar: _limpiarBusqueda,
        ),
    ];

    final contadorLabel = q.isNotEmpty
        ? '$cantidad ${cantidad == 1 ? 'reto encontrado' : 'retos encontrados'}'
        : '$cantidad ${cantidad == 1 ? 'reto' : 'retos'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _buildBuscador(cubit),
        ),
        const SizedBox(height: 18),
        const _FiltroEtiqueta(texto: 'Estado del reto'),
        _chipsFila([
          for (final seccion in RetosSeccion.values)
            _FiltroChip(
              label: seccion.label,
              icono: _iconoSeccion(seccion),
              activo: state.seccion == seccion,
              onTap: () => cubit.cambiarSeccion(seccion),
            ),
        ]),
        const SizedBox(height: 20),
        const _FiltroEtiqueta(texto: 'Dificultad'),
        _chipsFila([
          for (final dificultad in RetoDificultad.values)
            _FiltroChip(
              label: dificultad.label,
              activo: state.dificultadSeleccionada == dificultad,
              onTap: () => cubit.filtrarDificultad(dificultad),
            ),
        ]),
        if (hayFiltros) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...activos,
                _LimpiarTodoBoton(onTap: _limpiarTodo),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                  child: Text(
                    contadorLabel,
                    key: ValueKey(contadorLabel),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColorsDark.textPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _abrirOrdenar,
                icon: Icon(
                  Icons.swap_vert,
                  size: 17,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.textSecondary
                      : AppColors.textSecondary,
                ),
                label: Text(
                  'Ordenar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildBuscador(ChallengeCubit cubit) {
    final conTexto = widget.state.busqueda.isNotEmpty;
    return TextField(
      controller: _busqueda,
      onChanged: cubit.buscar,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Buscar retos, materiales, categorías...',
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: conTexto
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Limpiar búsqueda',
                onPressed: _limpiarBusqueda,
              )
            : null,
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
    );
  }

  Widget _chipsFila(List<_FiltroChip> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final chip in chips) ...[
            chip,
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }



  List<RetoProgreso> _aplicarOrden(List<RetoProgreso> lista) {
    if (_orden == _OrdenRetos.recientes) return lista;
    final rapida = List<RetoProgreso>.of(lista);
    switch (_orden) {
      case _OrdenRetos.faciles:
        rapida.sort(
          (a, b) => a.reto.dificultad.index.compareTo(b.reto.dificultad.index),
        );
      case _OrdenRetos.dificiles:
        rapida.sort(
          (a, b) => b.reto.dificultad.index.compareTo(a.reto.dificultad.index),
        );
      case _OrdenRetos.mayorXp:
        rapida.sort((a, b) => b.reto.xp.compareTo(a.reto.xp));
      case _OrdenRetos.menorTiempo:
        rapida.sort((a, b) => a.reto.tiempoMin.compareTo(b.reto.tiempoMin));
      case _OrdenRetos.recientes:
        break;
    }
    return rapida;
  }

  Future<void> _abrirOrdenar() async {
    final seleccion = await showModalBottomSheet<_OrdenRetos>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EcoSectionTitle(titulo: 'Ordenar retos'),
            for (final orden in _OrdenRetos.values)
              ListTile(
                leading: Icon(
                  orden.icono,
                  color: _orden == orden
                      ? AppColors.secondary
                      : AppColors.textHint,
                ),
                title: Text(
                  orden.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: _orden == orden ? FontWeight.w800 : FontWeight.w600,
                    color: _orden == orden
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary)
                        : (Theme.of(context).brightness == Brightness.dark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary),
                  ),
                ),
                trailing: _orden == orden
                    ? const Icon(Icons.check_circle, color: AppColors.secondary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(orden),
              ),
          ],
        ),
      ),
    );
    if (seleccion != null && seleccion != _orden && mounted) {
      setState(() {
        _orden = seleccion;
        _revision++;
      });
    }
  }



  void _limpiarBusqueda() {
    _busqueda.clear();
    widget.cubit.buscar('');
  }

  void _limpiarTodo() {
    _busqueda.clear();
    final cubit = widget.cubit;
    cubit.buscar('');
    cubit.filtrarDificultad(null);
    cubit.filtrarTipo(null);
    cubit.cambiarSeccion(RetosSeccion.todos);
  }

  IconData _iconoSeccion(RetosSeccion seccion) {
    switch (seccion) {
      case RetosSeccion.todos:
        return Icons.grid_view;
      case RetosSeccion.enProgreso:
        return Icons.play_circle;
      case RetosSeccion.completados:
        return Icons.check_circle;
    }
  }

  void _abrirDetalle(BuildContext context, RetoProgreso progreso) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: widget.cubit,
          child: ChallengeDetailScreen(reto: progreso.reto),
        ),
      ),
    );

  }
}



enum _OrdenRetos {
  recientes('Más recientes', Icons.history),
  faciles('Más fáciles', Icons.trending_down),
  dificiles('Más difíciles', Icons.trending_up),
  mayorXp('Mayor XP', Icons.star),
  menorTiempo('Menor tiempo', Icons.timer_outlined);

  final String label;
  final IconData icono;

  const _OrdenRetos(this.label, this.icono);
}

class _FiltroEtiqueta extends StatelessWidget {
  final String texto;

  const _FiltroEtiqueta({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}




class _FiltroChip extends StatefulWidget {
  final String label;
  final IconData? icono;
  final bool activo;
  final VoidCallback? onTap;

  const _FiltroChip({
    required this.label,
    this.icono,
    this.activo = false,
    this.onTap,
  });

  @override
  State<_FiltroChip> createState() => _FiltroChipState();
}

class _FiltroChipState extends State<_FiltroChip> {
  bool _presionado = false;

  void _setPresionado(bool valor) {
    if (_presionado == valor) return;
    setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _presionado ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: widget.activo ? AppColors.secondary : AppColors.surface,
          border: Border.all(
            color: widget.activo
                ? AppColors.tertiary.withValues(alpha: 0.95)
                : AppColors.border.withValues(alpha: 0.6),
          ),
          boxShadow: widget.activo
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            onTap: widget.onTap,
            onTapDown: (_) => _setPresionado(true),
            onTapUp: (_) => _setPresionado(false),
            onTapCancel: () => _setPresionado(false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icono != null) ...[
                    Icon(
                      widget.icono,
                      size: 16,
                      color: widget.activo
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: widget.activo ? FontWeight.w800 : FontWeight.w600,
                      color: widget.activo
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _FiltroActivo extends StatelessWidget {
  final String label;
  final VoidCallback onEliminar;

  const _FiltroActivo({required this.label, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTexto = isDark ? Colors.white : AppColors.primaryDark;
    return Material(
      color: AppColors.secondary.withValues(alpha: isDark ? 0.16 : 0.14),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.7)),
      ),
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: colorTexto),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorTexto,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onEliminar,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.close, size: 16, color: colorTexto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimpiarTodoBoton extends StatelessWidget {
  final VoidCallback onTap;

  const _LimpiarTodoBoton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.filter_alt_off, size: 16),
      label: const Text('Limpiar filtros'),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isDark ? AppColorsDark.textPrimary : AppColors.primaryDark,
        side: BorderSide(
          color: isDark
              ? AppColorsDark.border.withValues(alpha: 0.8)
              : AppColors.border.withValues(alpha: 0.9),
        ),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}



class _AppBarCategoria extends StatelessWidget {
  final RetoCategoria categoria;

  const _AppBarCategoria({required this.categoria});

  @override
  Widget build(BuildContext context) {
    final base = Color(categoria.lightColor);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: base,
            shape: BoxShape.circle,
          ),
          child: Icon(categoria.icono, size: 17, color: _sobreCategoria(base)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            categoria.nombreLimpio,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}





class _EntranceCard extends StatelessWidget {
  final Widget child;

  const _EntranceCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, valor, child) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, (1 - valor) * 8),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _RetoCard extends StatelessWidget {
  final RetoProgreso progreso;
  final VoidCallback onTap;

  const _RetoCard({required this.progreso, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final reto = progreso.reto;
    return EcoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reto.titulo,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              EcoDificultadTag(dificultad: reto.dificultad),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reto.categoria.nombre +
                (reto.subcategoria != null ? ' · ${reto.subcategoria}' : ''),
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _Tag(
                icon: Icons.star,
                texto: '${reto.xp} XP',
                color: AppColors.accent,
              ),
              _Tag(
                icon: Icons.monetization_on,
                texto: '${reto.monedas} ECO',
                color: AppColors.coinGold,
              ),
              _Tag(
                icon: Icons.schedule,
                texto: '${reto.tiempoMin} min',
                color: AppColors.textHint,
              ),
              if (reto.requiereEvidencia)
                const _Tag(
                  icon: Icons.photo_camera_outlined,
                  texto: 'Evidencia',
                  color: AppColors.info,
                ),
            ],
          ),
          if (progreso.estado == RetoEstado.enProgreso ||
              progreso.estado == RetoEstado.pendienteRevision) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  'Progreso',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progreso.porcentaje * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            EcoProgressBar(progreso: progreso.porcentaje),
          ] else if (progreso.estado == RetoEstado.completado) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Completado ${_hace(progreso.fechaCompletado)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          _BottonAccion(estado: progreso.estado, onTap: onTap),
        ],
      ),
    );
  }
}

class _BottonAccion extends StatelessWidget {
  final RetoEstado estado;
  final VoidCallback onTap;

  const _BottonAccion({required this.estado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icono, etiqueta) = switch (estado) {
      RetoEstado.enProgreso || RetoEstado.pendienteRevision => (
        Icons.play_arrow,
        'Continuar',
      ),
      RetoEstado.completado ||
      RetoEstado.rechazado ||
      RetoEstado.expirado ||
      RetoEstado.bloqueado ||
      RetoEstado.requiereEvidencia => (
        Icons.remove_red_eye_outlined,
        'Ver reto',
      ),
      _ => (Icons.bolt, 'Comenzar reto'),
    };

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icono, size: 19),
        label: Text(etiqueta),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color color;

  const _Tag({required this.icon, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}



class _AprobacionDialog extends StatelessWidget {
  final List<AprobacionReciente> aprobaciones;
  final VoidCallback onCerrar;

  const _AprobacionDialog({required this.aprobaciones, required this.onCerrar});

  @override
  Widget build(BuildContext context) {
    final total = aprobaciones.length;
    return AlertDialog(
      icon: const Icon(Icons.verified, color: AppColors.success, size: 40),
      title: Text(
        total == 1 ? '¡Evidencia aprobada!' : '¡$total evidencias aprobadas!',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Un admin revisó tu evidencia y la aceptó. '
              '¡Buen trabajo!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            for (final aprobacion in aprobaciones) ...[
              _AprobacionTile(
                titulo: aprobacion.progreso.reto.titulo,
                xp: aprobacion.progreso.reto.xp,
                monedas: aprobacion.progreso.reto.monedas,
                logros: aprobacion.logros,
              ),
              if (aprobacion != aprobaciones.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: onCerrar, child: const Text('¡Genial!')),
      ],
    );
  }
}

class _AprobacionTile extends StatelessWidget {
  final String titulo;
  final int xp;
  final int monedas;
  final List<InsigniaResponse> logros;

  const _AprobacionTile({
    required this.titulo,
    required this.xp,
    required this.monedas,
    required this.logros,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, size: 15, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                '+$xp XP',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.monetization_on,
                size: 15,
                color: AppColors.coinGold,
              ),
              const SizedBox(width: 4),
              Text(
                '+$monedas ECO',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coinGold,
                ),
              ),
            ],
          ),
          if (logros.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final logro in logros)
                  Chip(
                    avatar: const Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(logro.nombreInsignia),
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.levelPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}






Color _acentoCategoria(RetoCategoria categoria, bool isDark) {
  final base = Color(categoria.lightColor);
  return isDark
      ? Color.lerp(base, Colors.white, 0.28)!
      : Color.lerp(base, Colors.black, 0.22)!;
}


Color _sobreCategoria(Color base) =>
    base.computeLuminance() > 0.5 ? AppColors.textPrimary : Colors.white;



extension _RetoCategoriaVisual on RetoCategoria {
  IconData get icono {
    switch (this) {
      case RetoCategoria.reciclaje:
        return Icons.recycling;
      case RetoCategoria.movilidad:
        return Icons.directions_bike;
      case RetoCategoria.reforestacion:
        return Icons.forest;
      case RetoCategoria.consumo:
        return Icons.shopping_bag_outlined;
      case RetoCategoria.eficienciaEnergetica:
        return Icons.energy_savings_leaf;
      case RetoCategoria.alimentacion:
        return Icons.restaurant;
      case RetoCategoria.economiaCircular:
        return Icons.autorenew;
    }
  }


  String get nombreLimpio {
    final partes = nombre.split(' ');
    return partes.length > 1 ? partes.skip(1).join(' ') : nombre;
  }
}

String _hace(DateTime? fecha) {
  if (fecha == null) return '';
  final dias = DateTime.now().difference(fecha).inDays;
  if (dias <= 0) return 'hoy';
  if (dias == 1) return 'ayer';
  return 'hace $dias días';
}