import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/challenge/challenge_models.dart';
import '../widgets/category_chip.dart';
import 'cubit/modo_libre_cubit.dart';
import 'cubit/modo_libre_state.dart';

/// Pantalla de configuración de la partida de Modo Libre.
class ModoLibreConfigScreen extends StatefulWidget {
  const ModoLibreConfigScreen({super.key});

  @override
  State<ModoLibreConfigScreen> createState() => _ModoLibreConfigScreenState();
}

class _ModoLibreConfigScreenState extends State<ModoLibreConfigScreen> {
  static const _dificultades = [
    (null, 'Todas'),
    ('Facil', 'Fácil'),
    ('Intermedia', 'Normal'),
    ('Dificil', 'Difícil'),
  ];
  static const _cantidades = [5, 10, 15, 20];
  static const _tiempos = [
    (null, 'Sin límite'),
    (15, '15s'),
    (30, '30s'),
    (60, '60s'),
  ];

  late int? _categoriaId;
  late String? _dificultad;
  late int _cantidad;
  late Duration? _tiempo;

  @override
  void initState() {
    super.initState();
    final config = context.read<ModoLibreCubit>().state.config;
    _categoriaId = config.categoriaId;
    _dificultad = config.dificultad;
    _cantidad = _cantidades.contains(config.cantidadPreguntas)
        ? config.cantidadPreguntas
        : 10;
    _tiempo = config.tiempoPorPregunta;
  }

  void _guardarConfiguracion() {
    context.read<ModoLibreCubit>().actualizarConfiguracion(
      ModoLibreConfiguracion(
        categoriaId: _categoriaId,
        dificultad: _dificultad,
        cantidadPreguntas: _cantidad,
        tiempoPorPregunta: _tiempo,
      ),
    );
  }

  Future<void> _comenzar() async {
    _guardarConfiguracion();
    await context.read<ModoLibreCubit>().iniciarPartida();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.select(
      (ModoLibreCubit cubit) => cubit.state.categorias,
    );
    final isLoading = context.select(
      (ModoLibreCubit cubit) => cubit.state.isLoading,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo libre'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configura tu partida',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Elige categoría, dificultad, cantidad y tiempo. ¡Aprende y gana XP!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                const _Seccion(titulo: 'Categoría'),
                const SizedBox(height: 10),
                _buildCategorySelector(categorias),
                const SizedBox(height: 22),
                const _Seccion(titulo: 'Dificultad'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (valor, etiqueta) in _dificultades)
                      CategoryChip(
                        label: etiqueta,
                        isSelected: _dificultad == valor,
                        onTap: () => setState(() {
                          _dificultad = valor;
                          _guardarConfiguracion();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                const _Seccion(titulo: 'Cantidad de preguntas'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cantidad in _cantidades)
                      CategoryChip(
                        label: '$cantidad',
                        isSelected: _cantidad == cantidad,
                        onTap: () => setState(() {
                          _cantidad = cantidad;
                          _guardarConfiguracion();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                const _Seccion(titulo: 'Tiempo por pregunta'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (segundos, etiqueta) in _tiempos)
                      CategoryChip(
                        label: etiqueta,
                        isSelected: _tiempo == _duracion(segundos),
                        onTap: () => setState(() {
                          _tiempo = _duracion(segundos);
                          _guardarConfiguracion();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.bolt, size: 20, color: AppColors.mintStrong),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Responde rápido para ganar un bonus de velocidad extra.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : _comenzar,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('COMENZAR'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  /// Selector compacto de categoría: ocupa una sola fila sin importar cuántas
  /// categorías existan. El listado completo se abre en una hoja inferior con
  /// búsqueda, así la pantalla no se satura cuando crecen las categorías.
  Widget _buildCategorySelector(List<CategoriaResponse> categorias) {
    CategoriaResponse? seleccionada;
    for (final cat in categorias) {
      if (cat.categoriaId == _categoriaId) seleccionada = cat;
    }
    final esTodas = seleccionada == null;
    final nombre = seleccionada?.nombreCategoria ?? 'Todas las categorías';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _abrirSelectorCategorias(categorias),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  esTodas ? Icons.grid_view_rounded : Icons.category_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      esTodas
                          ? '${categorias.length} categorías disponibles'
                          : 'Toca para cambiar de categoría',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirSelectorCategorias(
    List<CategoriaResponse> categorias,
  ) async {
    final seleccion = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectorCategoriasSheet(
        categorias: categorias,
        categoriaId: _categoriaId,
      ),
    );
    if (seleccion == null || !mounted) return;
    setState(() {
      _categoriaId = seleccion == _SelectorCategoriasSheet.todasId
          ? null
          : seleccion;
    });
    _guardarConfiguracion();
  }

  static Duration? _duracion(int? segundos) =>
      segundos == null ? null : Duration(seconds: segundos);
}

class _Seccion extends StatelessWidget {
  final String titulo;

  const _Seccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Hoja inferior con búsqueda para elegir una categoría. Escala a cualquier
/// cantidad de categorías sin ocupar espacio fijo en la pantalla.
class _SelectorCategoriasSheet extends StatefulWidget {
  /// Id reservado para la opción "Todas las categorías" (los ids reales son
  /// positivos, así se distingue de un `pop` cancelado que devuelve null).
  static const int todasId = -1;

  final List<CategoriaResponse> categorias;
  final int? categoriaId;

  const _SelectorCategoriasSheet({
    required this.categorias,
    required this.categoriaId,
  });

  @override
  State<_SelectorCategoriasSheet> createState() =>
      _SelectorCategoriasSheetState();
}

class _SelectorCategoriasSheetState extends State<_SelectorCategoriasSheet> {
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  String get _consulta => _sinAcentos(_busqueda.text.trim());

  bool get _mostrarTodas =>
      _consulta.isEmpty || _sinAcentos('todas las categorías').contains(_consulta);

  List<CategoriaResponse> get _filtradas {
    if (_consulta.isEmpty) return widget.categorias;
    return [
      for (final cat in widget.categorias)
        if (_sinAcentos(cat.nombreCategoria).contains(_consulta)) cat,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final altura = (media.size.height - media.viewInsets.bottom) * 0.78;
    final filtradas = _filtradas;

    return Container(
      height: altura,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Elige una categoría',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textHint),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar categoría...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: [
                if (_mostrarTodas)
                  _opcion(
                    id: _SelectorCategoriasSheet.todasId,
                    nombre: 'Todas las categorías',
                    descripcion:
                        'Preguntas de todas las categorías disponibles',
                    icono: Icons.grid_view_rounded,
                  ),
                for (final cat in filtradas)
                  _opcion(
                    id: cat.categoriaId,
                    nombre: cat.nombreCategoria,
                    descripcion: cat.descripcion,
                    icono: Icons.category_outlined,
                  ),
                if (filtradas.isEmpty && !_mostrarTodas)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Sin resultados para tu búsqueda',
                        style: TextStyle(color: AppColors.textHint),
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

  Widget _opcion({
    required int id,
    required String nombre,
    required String descripcion,
    required IconData icono,
  }) {
    final esTodas = id == _SelectorCategoriasSheet.todasId;
    final seleccionada =
        widget.categoriaId == (esTodas ? null : id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: seleccionada
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).pop(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: seleccionada ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icono,
                    size: 20,
                    color: seleccionada ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: seleccionada
                              ? AppColors.primaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (descripcion.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  seleccionada
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: seleccionada ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Normaliza texto para búsquedas: minúsculas y sin acentos.
String _sinAcentos(String texto) {
  const conAcento = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const sinAcento = 'aaaaaeeeeiiiiooooouuuunc';
  final resultado = texto.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in resultado.runes) {
    final caracter = String.fromCharCode(rune);
    final indice = conAcento.indexOf(caracter);
    buffer.write(indice == -1 ? caracter : sinAcento[indice]);
  }
  return buffer.toString();
}
