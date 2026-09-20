import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/gamification/gamification_models.dart';
import '../widgets/empty_state_widget.dart';
import 'insignia_categoria.dart';

enum _FiltroLogros {
  todas('Todas', Icons.apps_rounded),
  desbloqueadas('Desbloqueadas', Icons.lock_open_rounded),
  bloqueadas('Bloqueadas', Icons.lock_outline_rounded);

  const _FiltroLogros(this.etiqueta, this.icono);

  final String etiqueta;
  final IconData icono;
}

class AchievementsCategoryScreen extends StatefulWidget {
  final InsigniaCategoria categoria;
  final List<InsigniaResponse> insignias;
  final Map<int, UsuarioInsigniaResponse> obtenidasPorId;
  final MetricasLogros metricas;

  const AchievementsCategoryScreen({
    super.key,
    required this.categoria,
    required this.insignias,
    required this.obtenidasPorId,
    required this.metricas,
  });

  @override
  State<AchievementsCategoryScreen> createState() =>
      _AchievementsCategoryScreenState();
}

class _AchievementsCategoryScreenState
    extends State<AchievementsCategoryScreen> {
  final TextEditingController _buscador = TextEditingController();
  String _busqueda = '';
  _FiltroLogros _filtro = _FiltroLogros.todas;

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  bool _estaObtenida(InsigniaResponse insignia) =>
      widget.obtenidasPorId.containsKey(insignia.insigniaId);

  int get _totalObtenidas => widget.insignias.where(_estaObtenida).length;

  List<InsigniaResponse> get _filtradas {
    final consulta = normalizarTexto(_busqueda.trim());
    final lista = widget.insignias.where((insignia) {
      final obtenida = _estaObtenida(insignia);
      if (_filtro == _FiltroLogros.desbloqueadas && !obtenida) return false;
      if (_filtro == _FiltroLogros.bloqueadas && obtenida) return false;
      if (consulta.isEmpty) return true;
      return normalizarTexto(
        '${insignia.nombreInsignia} ${insignia.descripcion} ${insignia.requisito}',
      ).contains(consulta);
    }).toList();
    lista.sort((a, b) {
      final aObtenida = _estaObtenida(a) ? 0 : 1;
      final bObtenida = _estaObtenida(b) ? 0 : 1;
      if (aObtenida != bObtenida) return aObtenida - bObtenida;
      return a.nombreInsignia
          .toLowerCase()
          .compareTo(b.nombreInsignia.toLowerCase());
    });
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtradas = _filtradas;

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria.nombre)),
      body: Column(
        children: [
          _buildHeader(),
          _buildBuscador(isDark),
          _buildFiltros(),
          Expanded(
            child: filtradas.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: _busqueda.isNotEmpty ||
                            _filtro != _FiltroLogros.todas
                        ? 'Sin resultados'
                        : 'Aún no hay logros en esta categoría',
                    subtitle: _busqueda.isNotEmpty
                        ? 'Prueba con otra palabra clave.'
                        : 'Sigue avanzando para desbloquearlos.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildLogroCard(filtradas[index], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final categoria = widget.categoria;
    final total = widget.insignias.length;
    final obtenidas = _totalObtenidas;
    final progreso = total == 0 ? 0.0 : obtenidas / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: categoria.gradiente),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: categoria.color.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(categoria.icono, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$obtenidas de $total desbloqueados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoria.descripcion,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _buscador,
        onChanged: (valor) => setState(() => _busqueda = valor),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar en ${widget.categoria.nombre.toLowerCase()}...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _busqueda.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _buscador.clear();
                    setState(() => _busqueda = '');
                  },
                ),
          filled: true,
          fillColor: isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: widget.categoria.color.withValues(alpha: 0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: widget.categoria.color,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    final desbloqueadas = _totalObtenidas;
    final conteos = {
      _FiltroLogros.todas: widget.insignias.length,
      _FiltroLogros.desbloqueadas: desbloqueadas,
      _FiltroLogros.bloqueadas: widget.insignias.length - desbloqueadas,
    };

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        scrollDirection: Axis.horizontal,
        itemCount: _FiltroLogros.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filtro = _FiltroLogros.values[index];
          final seleccionado = _filtro == filtro;
          final color = widget.categoria.color;
          return ChoiceChip(
            selected: seleccionado,
            showCheckmark: false,
            avatar: Icon(
              filtro.icono,
              size: 16,
              color: seleccionado ? Colors.white : color,
            ),
            label: Text('${filtro.etiqueta} (${conteos[filtro] ?? 0})'),
            labelStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: seleccionado ? Colors.white : color,
            ),
            selectedColor: color,
            backgroundColor: color.withValues(alpha: 0.10),
            side: BorderSide(
              color: color.withValues(alpha: seleccionado ? 1 : 0.30),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (_) => setState(() => _filtro = filtro),
          );
        },
      ),
    );
  }

  Widget _buildLogroCard(InsigniaResponse insignia, bool isDark) {
    final obtenida = _estaObtenida(insignia);
    final usuarioInsignia = widget.obtenidasPorId[insignia.insigniaId];
    final progreso = obtenida ? null : widget.metricas.progresoDe(insignia);
    final objetivo = insignia.objetivo;
    final actual = widget.metricas.valorPara(insignia.categoria);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _mostrarDetalle(insignia, obtenida, usuarioInsignia),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: obtenida
                ? (isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard)
                : (isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim)
                    .withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: obtenida
                  ? AppColors.xpGold.withValues(alpha: 0.55)
                  : (isDark ? AppColorsDark.border : AppColors.border),
              width: obtenida ? 1.5 : 1,
            ),
            boxShadow: obtenida
                ? [
                    BoxShadow(
                      color: AppColors.xpGold
                          .withValues(alpha: isDark ? 0.08 : 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcono(obtenida),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insignia.nombreInsignia,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: obtenida
                            ? null
                            : onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insignia.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: onSurface
                            .withValues(alpha: obtenida ? 0.60 : 0.45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadgeEstado(obtenida),
                        const SizedBox(width: 8),
                        _buildPildoraMonedas(insignia.monedasRecompensa),
                      ],
                    ),
                    if (!obtenida &&
                        progreso != null &&
                        objetivo != null &&
                        actual > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: progreso,
                                minHeight: 5,
                                backgroundColor: widget.categoria.color
                                    .withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.categoria.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${actual > objetivo ? objetivo : actual}/$objetivo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.categoria.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (obtenida && usuarioInsignia != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Obtenido el ${_formatDate(usuarioInsignia.fechaObtencion)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcono(bool obtenida) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: obtenida
            ? LinearGradient(colors: widget.categoria.gradiente)
            : null,
        color: obtenida
            ? null
            : (isDark ? AppColorsDark.surfaceDim : AppColors.surfaceDim),
        borderRadius: BorderRadius.circular(16),
        border: obtenida
            ? null
            : Border.all(color: onSurface.withValues(alpha: 0.12)),
        boxShadow: obtenida
            ? [
                BoxShadow(
                  color: widget.categoria.color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        obtenida ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
        color: obtenida ? Colors.white : onSurface.withValues(alpha: 0.35),
        size: 28,
      ),
    );
  }

  Widget _buildBadgeEstado(bool obtenida) {
    final color = obtenida ? AppColors.success : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            obtenida ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            obtenida ? 'Desbloqueado' : 'Bloqueado',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPildoraMonedas(int monedas) {
    final color = monedas <= 0 ? AppColors.textHint : AppColors.coinGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$monedas',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(
    InsigniaResponse insignia,
    bool obtenida,
    UsuarioInsigniaResponse? usuarioInsignia,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoria = insignia.categoria;
    final progreso = obtenida ? null : widget.metricas.progresoDe(insignia);
    final objetivo = insignia.objetivo;
    final actual = widget.metricas.valorPara(categoria);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final onSurface = Theme.of(sheetContext).colorScheme.onSurface;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: categoria.gradiente),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: categoria.color.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  insignia.nombreInsignia,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insignia.descripcion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetalleItem(
                  Icons.flag_rounded,
                  'Requisito',
                  insignia.requisito,
                ),
                if (!obtenida && objetivo != null)
                  _buildDetalleItem(
                    Icons.trending_up_rounded,
                    'Tu progreso',
                    '${actual > objetivo ? objetivo : actual} de $objetivo',
                  ),
                _buildDetalleItem(
                  Icons.stars_rounded,
                  'Recompensa',
                  '${insignia.monedasRecompensa} monedas',
                ),
                _buildDetalleItem(
                  obtenida
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                  'Estado',
                  obtenida && usuarioInsignia != null
                      ? 'Desbloqueado el ${_formatDate(usuarioInsignia.fechaObtencion)}'
                      : 'Aún bloqueado',
                ),
                if (!obtenida && progreso != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 7,
                      backgroundColor:
                          categoria.color.withValues(alpha: 0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(categoria.color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetalleItem(IconData icono, String titulo, String valor) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.categoria.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, size: 18, color: widget.categoria.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}
