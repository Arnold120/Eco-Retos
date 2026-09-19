import 'reto_model.dart';

/// Punto único de entrada al catálogo de retos.
///
/// A partir de la migración al backend, el catálogo se carga en tiempo de
/// ejecución desde `GET /api/Retos` (antes eran archivos const locales):
/// - `RetoCatalogo.cargar(...)` dispara (y comparte) la carga una sola vez.
/// - Los consumidores solo leen los getters/consultas, nunca los llenan.
/// - Si la app está offline, el catálogo queda vacío o con lo ya cargado.
///
/// Las pantallas SIEMPRE consultan esta clase (o al `RetoRepository`),
/// nunca declaran retos inline.
class RetoCatalogo {
  const RetoCatalogo._();

  /// Catálogo completo, poblado por [cargar]. Vacío hasta la primera carga.
  static List<Reto> todos = const [];

  /// true cuando la primera carga terminó (con o sin retos).
  static bool cargado = false;

  static Future<void>? _cargando;
  static Future<List<Reto>> Function()? _cargador;

  /// Carga el catálogo desde el backend. La primera llamada fija el cargador
  /// y las llamadas concurrentes comparten la misma carga (una sola red).
  static Future<void> cargar(Future<List<Reto>> Function() cargador) {
    _cargador ??= cargador;
    if (cargado) return Future.value();
    final enCurso = _cargando;
    if (enCurso != null) return enCurso;
    final future = () async {
      try {
        final lista = await _cargador!();
        todos = List.unmodifiable(lista);
        cargado = true;
      } catch (_) {
        // Sin conexión o backend caído: el catálogo queda vacío (offline) o
        // con lo ya cargado, y se reintenta en la próxima carga. No es fatal.
      } finally {
        _cargando = null;
      }
    }();
    _cargando = future;
    return future;
  }

  static int get total => todos.length;

  static const List<RetoCategoria> categorias = RetoCategoria.values;

  static const List<RetoDificultad> dificultades = RetoDificultad.values;

  static const List<RetoTipo> tipos = RetoTipo.values;

  static List<Reto> get destacados => todos.where((r) => r.destacado).toList();

  static List<Reto> get especiales => todos.where((r) => r.especial).toList();

  static Reto? porId(String id) {
    for (final reto in todos) {
      if (reto.id == id) return reto;
    }
    return null;
  }

  static List<Reto> porCategoria(RetoCategoria categoria) =>
      todos.where((r) => r.categoria == categoria).toList();

  static List<Reto> porDificultad(RetoDificultad dificultad) =>
      todos.where((r) => r.dificultad == dificultad).toList();

  static List<Reto> porTipo(RetoTipo tipo) =>
      todos.where((r) => r.tipo == tipo).toList();

  static List<Reto> porEtiqueta(String etiqueta) => todos
      .where(
        (r) =>
            r.etiquetas.any((e) => e.toLowerCase() == etiqueta.toLowerCase()),
      )
      .toList();

  /// Búsqueda instantánea por nombre, categoría, etiqueta, material y tipo.
  static List<Reto> buscar(String termino) {
    final q = termino.trim().toLowerCase();
    if (q.isEmpty) return todos;
    return todos.where((r) {
      final campos = [
        r.titulo,
        r.descripcion,
        r.subcategoria ?? '',
        r.categoria.nombre,
        r.categoria.id,
        r.tipo.label,
        r.dificultad.label,
        ...r.etiquetas,
        ...r.materiales.map((m) => m.nombre),
        ...r.consejos,
        ...r.instrucciones,
      ].join(' ').toLowerCase();
      return campos.contains(q);
    }).toList();
  }

  /// Filtros combinables (panel de filtros avanzados).
  static List<Reto> filtrar({
    RetoDificultad? dificultad,
    RetoCategoria? categoria,
    RetoTipo? tipo,
    int? maxMinutos,
    bool conMateriales = false,
    bool sinMateriales = false,
    bool soloConEvidencia = false,
  }) {
    return todos.where((r) {
      if (dificultad != null && r.dificultad != dificultad) return false;
      if (categoria != null && r.categoria != categoria) return false;
      if (tipo != null && r.tipo != tipo) return false;
      if (maxMinutos != null && r.tiempoMin > maxMinutos) return false;
      if (conMateriales && r.materiales.isEmpty) return false;
      if (sinMateriales && r.materiales.isNotEmpty) return false;
      if (soloConEvidencia && !r.requiereEvidencia) return false;
      return true;
    }).toList();
  }

  /// 🔥 Reto del día: determinístico por fecha, con rotación para no
  /// repetir el mismo reto dos días seguidos.
  static Reto? retoDelDia(DateTime dia) {
    if (todos.isEmpty) return null;
    final pool = diarios.isNotEmpty ? diarios : todos;
    final indice = _indiceDelDia(dia, pool.length);
    return pool[indice];
  }

  static List<Reto> get diarios => todos.where((r) => r.diario).toList();

  static List<Reto> get semanales => todos.where((r) => r.semanal).toList();

  /// 🔥 Desafío semanal: determinístico por semana del año.
  static Reto? retoSemanal(DateTime fecha) {
    if (todos.isEmpty) return null;
    final pool = semanales.isNotEmpty ? semanales : todos;
    final semana = _numeroDeSemana(fecha);
    return pool[semana % pool.length];
  }

  /// Recomendados por afinidad: categoría favorita + dificultad cercana al
  /// nivel + no completados previamente.
  static List<RetoProgreso> recomendados({
    required int nivelUsuario,
    required List<RetoCategoria> categoriasFavoritas,
    required Set<String> completados,
    int limite = 8,
  }) {
    final dificultadObjetivo = switch (nivelUsuario) {
      <= 2 => RetoDificultad.facil,
      <= 5 => RetoDificultad.intermedio,
      <= 9 => RetoDificultad.dificil,
      _ => RetoDificultad.experto,
    };

    final puntuados =
        todos
            .map((r) {
              if (completados.contains(r.id)) return (reto: r, score: -1);
              var score = 0;
              if (categoriasFavoritas.contains(r.categoria)) score += 6;
              if (r.dificultad == dificultadObjetivo) score += 3;
              if (r.dificultad.index <= dificultadObjetivo.index + 1) {
                score += 1;
              }
              if (r.destacado) score += 2;
              if (r.diario) score += 1;
              return (reto: r, score: score);
            })
            .where((e) => e.score >= 0)
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    return puntuados
        .take(limite)
        .map((e) => RetoProgreso(reto: e.reto, estado: RetoEstado.disponible))
        .toList();
  }

  static int _indiceDelDia(DateTime dia, int poolSize) {
    final inicio = DateTime(dia.year, 1, 1);
    final dias = dia.difference(inicio).inDays;
    return (dias + dia.year) % poolSize;
  }

  static int _numeroDeSemana(DateTime fecha) {
    final inicio = DateTime(fecha.year, 1, 1);
    return (fecha.difference(inicio).inDays / 7).floor();
  }
}

/// Cantidades aproximadas por dificultad para la UI (estadísticas).
class RetoCatalogoStats {
  const RetoCatalogoStats._();

  static int porDificultad(RetoDificultad d) =>
      RetoCatalogo.todos.where((r) => r.dificultad == d).length;
}