import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/descarga_service.dart';


typedef ArchivoDescarga = ({String url, String tipo});


Future<void> descargarMultimedia(
  BuildContext context, {
  required List<ArchivoDescarga> archivos,
  String? nombreSugerido,
}) async {
  if (archivos.isEmpty) return;
  final service = context.read<DescargaService>();

  final progreso = ValueNotifier<double>(0);
  final indice = ValueNotifier<int>(0);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(
          archivos.length == 1 ? 'Descargando archivo' : 'Descargando archivos',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (archivos.length > 1)
              ValueListenableBuilder<int>(
                valueListenable: indice,
                builder: (context, valor, _) => Text(
                  'Archivo ${valor + 1} de ${archivos.length}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ValueListenableBuilder<double>(
              valueListenable: progreso,
              builder: (context, valor, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: valor <= 0 ? null : valor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 6),
                  Text('${(valor * 100).clamp(0, 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  try {
    String? ultimo;
    for (var i = 0; i < archivos.length; i++) {
      indice.value = i;
      progreso.value = 0;
      ultimo = await service.descargar(
        archivos[i].url,
        tipo: archivos[i].tipo,
        nombreSugerido: nombreSugerido,
        onProgress: (p) => progreso.value = p,
      );
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          archivos.length == 1
              ? 'Descargado en: $ultimo'
              : '${archivos.length} archivos descargados en ${DescargaService.carpetaApp}',
        ),
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo descargar el archivo. Inténtalo nuevamente.'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
