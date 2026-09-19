import 'package:flutter/material.dart';

import '../../../data/models/garden/plant_growth.dart';




class ToolIcon extends StatelessWidget {
  final HerramientaJardin herramienta;
  final double size;
  final bool conFondo;

  const ToolIcon({
    super.key,
    required this.herramienta,
    this.size = 40,
    this.conFondo = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagen = Image.asset(
      herramienta.assetIcono,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Text(
          herramienta.emoji,
          style: TextStyle(fontSize: size * 0.48),
        ),
      ),
    );

    if (!conFondo) {
      return SizedBox(width: size, height: size, child: imagen);
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.07),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.16),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: imagen,
    );
  }
}
