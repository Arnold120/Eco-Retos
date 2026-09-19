import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../core/theme/app_theme.dart';




class Plant3DController {
  Future<void> Function(String)? _ejecutar;
  Object? _dueno;

  void _attach(Object dueno, Future<void> Function(String)? ejecutar) {
    _dueno = dueno;
    _ejecutar = ejecutar;
  }

  void _detach(Object dueno) {
    if (identical(_dueno, dueno)) {
      _dueno = null;
      _ejecutar = null;
    }
  }

  bool get activo => _ejecutar != null;


  void reproducir() {
    _llamar(
      "const m=document.querySelector('model-viewer');"
      "if(m&&m.play){m.play();}",
    );
  }


  void pulso() {
    _llamar(
      "const m=document.querySelector('model-viewer');"
      "if(m&&m.animate){m.animate(["
      "{transform:'scale(1)'},{transform:'scale(1.055)'},{transform:'scale(1)'}"
      "],{duration:700,easing:'ease-out'});}",
    );
  }


  void escala(double valor) {
    _llamar(
      "const m=document.querySelector('model-viewer');"
      "if(m){m.setAttribute('scale','$valor $valor $valor');}",
    );
  }


  void autoRotar(bool activo) {
    _llamar(
      "const m=document.querySelector('model-viewer');"
      "if(m){m.autoRotate=$activo;}",
    );
  }

  void _llamar(String js) {
    final ejecutar = _ejecutar;
    if (ejecutar == null) return;
    unawaited(ejecutar(js).catchError((Object _) {}));
  }
}




class Plant3DViewer extends StatefulWidget {
  final String src;
  final String alt;
  final double escala;
  final bool autoRotate;
  final String? animationName;
  final Plant3DController? controller;

  const Plant3DViewer({
    super.key,
    required this.src,
    required this.alt,
    this.escala = 1,
    this.autoRotate = true,
    this.animationName,
    this.controller,
  });

  @override
  State<Plant3DViewer> createState() => _Plant3DViewerState();
}

class _Plant3DViewerState extends State<Plant3DViewer> {
  static const String _jsEventos =
      "const ecoMv=document.querySelector('model-viewer');"
      "if(ecoMv){"
      "ecoMv.addEventListener('load',()=>EcoModelo.postMessage('load'));"
      "ecoMv.addEventListener('error',()=>EcoModelo.postMessage('error'));"
      "}";

  Future<void> Function(String)? _ejecutarJs;
  final Object _token = Object();
  Timer? _tiempoLimite;
  bool _cargado = false;
  bool _error = false;
  int _reintentos = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_token, (js) async {
      final ejecutar = _ejecutarJs;
      if (ejecutar != null) await ejecutar(js);
    });
    _programarTiempoLimite();
  }

  void _programarTiempoLimite() {
    _tiempoLimite?.cancel();
    _tiempoLimite = Timer(const Duration(seconds: 20), () {
      if (mounted && !_cargado && !_error) {
        setState(() => _error = true);
      }
    });
  }

  @override
  void dispose() {
    widget.controller?._detach(_token);
    _tiempoLimite?.cancel();
    super.dispose();
  }

  void _reiniciar() {
    setState(() {
      _error = false;
      _cargado = false;
      _reintentos++;
    });
    _programarTiempoLimite();
  }

  void _repetirAnimacion() {
    widget.controller?.reproducir();
    widget.controller?.pulso();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return _VistaErrorModelo(onReintentar: _reiniciar);

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          opacity: _cargado ? 1 : 0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: ModelViewer(
            key: ValueKey('${widget.src}_$_reintentos'),
            src: widget.src,
            alt: widget.alt,
            cameraControls: true,
            disableZoom: false,
            disablePan: true,
            touchAction: TouchAction.panY,
            autoRotate: widget.autoRotate,
            rotationPerSecond: '12deg',
            autoPlay: widget.animationName != null,
            animationName: widget.animationName,
            animationCrossfadeDuration: 0.5,
            cameraOrbit: '0deg 75deg 128%',
            minCameraOrbit: 'auto auto 60%',
            maxCameraOrbit: 'auto auto 210%',
            fieldOfView: '32deg',
            minFieldOfView: '18deg',
            maxFieldOfView: '45deg',
            exposure: 1.12,
            environmentImage: 'neutral',
            backgroundColor: Colors.transparent,
            loading: Loading.eager,
            reveal: Reveal.auto,
            debugLogging: false,
            scale: '${widget.escala} ${widget.escala} ${widget.escala}',
            relatedJs: _jsEventos,
            javascriptChannels: {
              JavascriptChannel(
                'EcoModelo',
                onMessageReceived: (mensaje) {
                  if (!mounted) return;
                  if (mensaje.message == 'load') {
                    _tiempoLimite?.cancel();
                    setState(() => _cargado = true);
                    widget.controller?.escala(widget.escala);
                  } else if (mensaje.message.startsWith('error')) {
                    _tiempoLimite?.cancel();
                    setState(() => _error = true);
                  }
                },
              ),
            },
            onWebViewCreated: (controller) {
              _ejecutarJs = controller.runJavaScript;
            },
          ),
        ),
        if (!_cargado && !_error)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: AppColors.gardenGreen.withValues(alpha: 0.10),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: AppColors.gardenGrass,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Cargando modelo 3D…',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_cargado)
          Positioned(
            right: 8,
            bottom: 8,
            child: Tooltip(
              message: 'Repetir animación',
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _repetirAnimacion,
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.replay, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VistaErrorModelo extends StatelessWidget {
  final VoidCallback onReintentar;

  const _VistaErrorModelo({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gardenGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.view_in_ar_outlined,
            size: 42,
            color: Colors.white70,
          ),
          const SizedBox(height: 10),
          const Text(
            'No pudimos cargar el modelo 3D',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'La información de tu planta sigue disponible.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }
}
