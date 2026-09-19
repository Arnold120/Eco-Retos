import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/account_service.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/cubit/profile_cubit.dart';
import 'legal_screen.dart';

/// Evita que toques repetidos generen varios códigos de sesión seguidos
/// mientras el navegador se abre.
bool _abriendoSoporte = false;

/// Configuración de la cuenta. Solo incluye opciones que ejecutan acciones
/// reales contra el backend o preferencias con efecto comprobable.
class SettingsScreen extends StatelessWidget {
  final int usuarioId;

  const SettingsScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          _seccion('Cuenta'),
          _tile(
            context,
            icon: Icons.person_outlined,
            title: 'Editar perfil',
            subtitle: 'Nombre, foto, centro educativo',
            onTap: () => _editarPerfil(context),
          ),
          _tile(
            context,
            icon: Icons.badge_outlined,
            title: 'Nombre de usuario y correo',
            subtitle: 'Actualiza tus datos de acceso',
            onTap: () => _cambiarDatos(context),
          ),
          _tile(
            context,
            icon: Icons.lock_outlined,
            title: 'Cambiar contraseña',
            subtitle: 'Actualiza tu contraseña de acceso',
            onTap: () => _cambiarContrasena(context),
          ),
          _seccion('Apariencia'),
          SwitchListTile(
            secondary: _icono(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            title: Text(
              isDark ? 'Modo claro' : 'Modo oscuro',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Cambia el tema de la aplicación'),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          SwitchListTile(
            secondary: _icono(Icons.visibility_outlined),
            title: const Text(
              'Modo daltónico',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Ajusta los colores para distinguirlos con daltonismo',
            ),
            value: themeProvider.modoDaltonico,
            onChanged: themeProvider.setModoDaltonico,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          _seccion('Privacidad'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.privacy_tip_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Visibilidad de tus publicaciones',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Al crear una publicación eliges quién puede verla:\n'
                    '· Público: todo el Muro Eco.\n'
                    '· Seguidores: solo quienes te siguen.\n'
                    '· Solo yo: contenido privado.',
                    style: TextStyle(
                      height: 1.45,
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Eliminar cuenta',
            subtitle: 'Tu cuenta dejará de ser accesible',
            titleColor: AppColors.error,
            onTap: () => _desactivarCuenta(context),
          ),
          _seccion('Información y soporte'),
          _tile(
            context,
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  titulo: 'Términos y condiciones',
                  contenido: kTerminosEcoRetos,
                ),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidad',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  titulo: 'Política de privacidad',
                  contenido: kPrivacidadEcoRetos,
                ),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Reportar un problema',
            onTap: () => _abrirSoporte(context),
          ),
          _tile(
            context,
            icon: Icons.info_outline,
            title: 'Acerca de Eco Retos',
            onTap: () => _acercaDe(context),
          ),
          _tile(
            context,
            icon: Icons.code_outlined,
            title: 'Versión',
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () => _cerrarSesion(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Acciones reales ────────────────────────────────────────────────────

  void _editarPerfil(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: const EditProfileScreen(),
        ),
      ),
    );
  }

  Future<void> _cambiarContrasena(BuildContext context) async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final confirmar = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var guardando = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: actual,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => (v?.isEmpty ?? true)
                      ? 'Ingresa tu contraseña actual'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nueva,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Ingresa una contraseña';
                    if ((v?.length ?? 0) < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmar,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      v != nueva.text ? 'Las contraseñas no coinciden' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: guardando ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: guardando
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setState(() => guardando = true);
                      try {
                        await ctx.read<AccountService>().cambiarContrasena(
                              usuarioId,
                              actual: actual.text,
                              nueva: nueva.text,
                            );
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        _aviso(context,
                            'Contraseña actualizada correctamente');
                      } catch (e) {
                        setState(() => guardando = false);
                        _aviso(context,
                            e is ApiException && e.message.isNotEmpty
                                ? e.message
                                : 'No se pudo cambiar la contraseña.');
                      }
                    },
              child: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    actual.dispose();
    nueva.dispose();
    confirmar.dispose();
  }

  Future<void> _cambiarDatos(BuildContext context) async {
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) return;

    final nombre = TextEditingController(text: auth.nombreUsuario);
    final correo = TextEditingController(text: auth.correo);
    final formKey = GlobalKey<FormState>();
    var guardando = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Datos de la cuenta'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Mínimo 3 caracteres'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: correo,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    final texto = v?.trim() ?? '';
                    if (texto.isEmpty) return 'Ingresa tu correo';
                    if (!texto.contains('@') || !texto.contains('.')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: guardando ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: guardando
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setState(() => guardando = true);
                      try {
                        await ctx.read<AccountService>().actualizarCuenta(
                              usuarioId,
                              nombreUsuario: nombre.text.trim(),
                              correo: correo.text.trim(),
                            );
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        _aviso(context,
                            'Datos actualizados. Vuelve a iniciar sesión para '
                            'refrescar tu sesión.');
                        if (context.mounted) {
                          context.read<ProfileCubit>().refresh();
                        }
                      } catch (e) {
                        setState(() => guardando = false);
                        _aviso(context,
                            e is ApiException && e.message.isNotEmpty
                                ? e.message
                                : 'No se pudieron actualizar tus datos.');
                      }
                    },
              child: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );

    nombre.dispose();
    correo.dispose();
  }

  Future<void> _desactivarCuenta(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar tu cuenta?'),
        content: const Text(
          'Tu cuenta dejará de ser accesible y no podrás iniciar sesión '
          'de nuevo. Tus publicaciones se conservan de forma anónima.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final contrasena = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var procesando = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Confirmar desactivación'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: contrasena,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Tu contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Ingresa tu contraseña' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: procesando ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: procesando
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setState(() => procesando = true);
                      try {
                        await ctx
                            .read<AccountService>()
                            .desactivarMiCuenta(contrasena.text);
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        if (context.mounted) {
                          context.read<AuthCubit>().logout();
                        }
                      } catch (e) {
                        setState(() => procesando = false);
                        _aviso(context,
                            e is ApiException && e.message.isNotEmpty
                                ? e.message
                                : 'No se pudo desactivar la cuenta.');
                      }
                    },
              child: procesando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Desactivar'),
            ),
          ],
        ),
      ),
    );

    contrasena.dispose();
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tu progreso está guardado en la nube.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _aviso(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Abre una URL en el navegador. No depende de `canLaunchUrl` (en Android
  /// 11+ puede devolver false si falta la visibilidad de paquetes) y prueba
  /// varios modos antes de rendirse.
  Future<bool> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    for (final modo in const [
      LaunchMode.externalApplication,
      LaunchMode.inAppBrowserView,
      LaunchMode.platformDefault,
    ]) {
      try {
        if (await launchUrl(uri, mode: modo)) return true;
      } catch (_) {
        // Se intenta el siguiente modo.
      }
    }
    return false;
  }

  /// Abre el Centro de Soporte web.
  ///
  /// Primero pide al backend un código de un solo uso (90 s) y abre
  /// `/soporte?codigo=...` para iniciar sesión sin exponer el JWT en la URL.
  /// Si el código falla, se abre el soporte con login manual como respaldo.
  Future<void> _abrirSoporte(BuildContext context) async {
    if (_abriendoSoporte) return;
    _abriendoSoporte = true;
    const urlSoporte = 'https://eco-retos-soporte.netlify.app/soporte';
    try {
      String? codigo;
      try {
        final api = context.read<ApiClient>();
        final respuesta = await api.dio.post('/Soporte/sesion/codigo');
        codigo = respuesta.data is Map
            ? respuesta.data['codigo']?.toString()
            : null;
      } catch (_) {
        // Sin conexión con el código: se abre el login manual del soporte.
      }

      final url = (codigo != null && codigo.isNotEmpty)
          ? '$urlSoporte?codigo=$codigo'
          : urlSoporte;
      final abierto = await _abrirUrl(url);
      if (!abierto && context.mounted) {
        _aviso(context,
            'No se pudo abrir el navegador. Puedes entrar manualmente en $urlSoporte');
      }
    } finally {
      _abriendoSoporte = false;
    }
  }

  void _acercaDe(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppColors.primary, size: 26),
            SizedBox(width: 10),
            Text('Eco Retos'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pequeñas acciones, grandes cambios.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
            SizedBox(height: 12),
            Text('Versión 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Aplicación de gamificación ambiental para aprender sobre '
              'sostenibilidad, completar retos, responder trivias y construir '
              'tu jardín virtual.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ─── Widgets ────────────────────────────────────────────────────────────

  Widget _seccion(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _icono(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: titleColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
