import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

const kPostReactions = ['❤️', '🌱', '👏', '🌎'];

String timeAgo(DateTime fecha, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(fecha);
  if (diff.isNegative) return 'Ahora';
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays < 7) {
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
  }
  return '${fecha.day}/${fecha.month}/${fecha.year}';
}

String fechaCompleta(DateTime fecha) {
  final d = fecha.day.toString().padLeft(2, '0');
  final m = fecha.month.toString().padLeft(2, '0');
  final h = fecha.hour.toString().padLeft(2, '0');
  final min = fecha.minute.toString().padLeft(2, '0');
  return '$d/$m/${fecha.year} · $h:$min';
}

String horaMensaje(DateTime fecha) {
  final hora12 = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final min = fecha.minute.toString().padLeft(2, '0');
  final sufijo = fecha.hour < 12 ? 'a.m.' : 'p.m.';
  return '$hora12:$min $sufijo';
}

String initialOf(String nombre) {
  if (nombre.isEmpty) return '?';
  return nombre.trim()[0].toUpperCase();
}

String usernameSlug(String nombre) {
  var slug = nombre.trim().toLowerCase();
  const acentos = 'áéíóúüñ';
  const sin = 'aeiouun';
  for (var i = 0; i < acentos.length; i++) {
    slug = slug.replaceAll(acentos[i], sin[i]);
  }
  slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '.');
  slug = slug.replaceAll(RegExp(r'^\.+|\.+$'), '');
  return '@${slug.isEmpty ? 'eco.heroe' : slug}';
}

String formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return '$count';
}


String? primerEnlace(String texto) {
  final match = RegExp(r'https?://[^\s<>()]+', caseSensitive: false)
      .firstMatch(texto);
  if (match == null) return null;
  var url = match.group(0) ?? '';
  while (url.isNotEmpty && '.,;:!?)]}'.contains(url[url.length - 1])) {
    url = url.substring(0, url.length - 1);
  }
  return url.isEmpty ? null : url;
}

Color surfaceCard(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.surfaceCard
        : AppColors.surfaceCard;

Color textColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;

Color textSecondaryColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.textSecondary
        : AppColors.textSecondary;

Color borderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.border
        : AppColors.border;

Color dividerColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.divider
        : AppColors.divider;

Color primaryOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.primary
        : AppColors.primary;



class AnchoLectura extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AnchoLectura({super.key, required this.child, this.maxWidth = 720});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;
        return Center(
          child: SizedBox(width: ancho, child: child),
        );
      },
    );
  }
}

class PostCardContainer extends StatelessWidget {
  final Widget child;
  final bool destacada;
  final EdgeInsetsGeometry padding;

  const PostCardContainer({
    super.key,
    required this.child,
    this.destacada = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: surfaceCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: destacada
              ? AppColors.xpGold
              : (isDark ? AppColorsDark.border : AppColors.border)
                  .withValues(alpha: 0.6),
          width: destacada ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColorsDark.cardShadow : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}


class ExpandableRichText extends StatefulWidget {
  final String texto;
  final TextStyle? baseStyle;
  final int limite;
  final VoidCallback? onHashtagTap;
  final void Function(String nombreUsuario)? onMentionTap;

  const ExpandableRichText({
    super.key,
    required this.texto,
    this.baseStyle,
    this.limite = 220,
    this.onHashtagTap,
    this.onMentionTap,
  });

  @override
  State<ExpandableRichText> createState() => _ExpandableRichTextState();
}

class _ExpandableRichTextState extends State<ExpandableRichText> {
  final List<TapGestureRecognizer> _recognizers = [];
  bool _expandido = false;

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  String get _visible {
    if (_expandido || widget.texto.length <= widget.limite) {
      return widget.texto;
    }
    return '${widget.texto.substring(0, widget.limite)}…';
  }

  bool get _esLargo => widget.texto.length > widget.limite;

  @override
  Widget build(BuildContext context) {
    final estilo = widget.baseStyle ??
        TextStyle(
          fontSize: 14.5,
          height: 1.4,
          color: textColor(context),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: estilo,
            children: _spans(_visible, estilo),
          ),
        ),
        if (_esLargo)
          TextButton(
            onPressed: () => setState(() => _expandido = !_expandido),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _expandido ? 'Ver menos' : 'Ver más',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  List<TextSpan> _spans(String texto, TextStyle estilo) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(#[\wáéíóúüñÁÉÍÓÚÜÑ]+|@[\w.\-áéíóúüñÁÉÍÓÚÜÑ]+)');
    var last = 0;
    for (final m in regex.allMatches(texto)) {
      if (m.start > last) {
        spans.add(TextSpan(text: texto.substring(last, m.start)));
      }
      final token = m.group(0)!;
      final esMencion = token.startsWith('@');
      TapGestureRecognizer? recognizer;
      if (esMencion && widget.onMentionTap != null) {
        recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onMentionTap!(token.substring(1));
        _recognizers.add(recognizer);
      }
      spans.add(TextSpan(
        text: token,
        recognizer: recognizer,
        style: estilo.copyWith(
          color: primaryOf(context),
          fontWeight: FontWeight.w700,
        ),
      ));
      last = m.end;
    }
    if (last < texto.length) {
      spans.add(TextSpan(text: texto.substring(last)));
    }
    return spans;
  }
}
