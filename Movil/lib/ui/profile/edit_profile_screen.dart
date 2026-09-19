import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';
import '../../data/models/user/user_models.dart';
import '../profile/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _carnetController;
  late TextEditingController _centroController;
  late TextEditingController _gradoController;
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<ProfileCubit>().state;
      _nombreController = TextEditingController(
        text: state.perfil?.nombre ?? '',
      );
      _apellidoController = TextEditingController(
        text: state.perfil?.apellido ?? '',
      );
      _carnetController = TextEditingController(
        text: state.perfil?.carnet ?? '',
      );
      _centroController = TextEditingController(
        text: state.perfil?.centroEducativo ?? '',
      );
      _gradoController = TextEditingController(text: state.perfil?.grado ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _carnetController.dispose();
    _centroController.dispose();
    _gradoController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final cubit = context.read<ProfileCubit>();
    await cubit.actualizarPerfil(
      ActualizarPerfilRequest(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        carnet: _carnetController.text.trim().isEmpty
            ? null
            : _carnetController.text.trim(),
        centroEducativo: _centroController.text.trim().isEmpty
            ? null
            : _centroController.text.trim(),
        grado: _gradoController.text.trim().isEmpty
            ? null
            : _gradoController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (cubit.state.error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo guardar: ${cubit.state.error}')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Perfil actualizado 🎉')),
      );
      Navigator.of(context).pop();
    }
  }

  String? _requerido(String? v) {
    return (v?.trim().isEmpty ?? true) ? 'Campo requerido' : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final perfil = context.read<ProfileCubit>().state.perfil;
    final foto = perfil?.fotoPerfil;
    final inicial = (perfil?.nombre.isNotEmpty ?? false)
        ? perfil!.nombre[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColorsDark.primary, AppColorsDark.secondary]
                    : [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  backgroundImage: resolverUrlMedia(foto) != null
                      ? NetworkImage(resolverUrlMedia(foto)!)
                      : null,
                  child: foto == null
                      ? Text(
                          inicial,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Edita tu información personal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Los datos se guardarán en tu cuenta.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField(
                  label: 'Nombre *',
                  controller: _nombreController,
                  icon: Icons.person_outlined,
                  validator: _requerido,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Apellido *',
                  controller: _apellidoController,
                  icon: Icons.person_outline,
                  validator: _requerido,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Número de carnet',
                  controller: _carnetController,
                  icon: Icons.badge_outlined,
                  helperText: 'Opcional',
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Centro educativo',
                  controller: _centroController,
                  icon: Icons.school_outlined,
                  helperText: 'Opcional',
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Grado',
                  controller: _gradoController,
                  icon: Icons.grade_outlined,
                  helperText: 'Opcional',
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          ElevatedButton.icon(
            onPressed: _saving ? null : _onSave,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
