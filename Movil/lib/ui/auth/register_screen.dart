import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _passwordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[!@#$%^&*]').hasMatch(password)) strength += 0.125;
    return strength;
  }

  Color _strengthColor(double strength) {
    if (strength < 0.25) return AppColors.error;
    if (strength < 0.5) return AppColors.warning;
    if (strength < 0.75) return AppColors.info;
    return AppColors.success;
  }

  String _strengthLabel(double strength) {
    if (strength < 0.25) return 'Débil';
    if (strength < 0.5) return 'Media';
    if (strength < 0.75) return 'Buena';
    return 'Fuerte';
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    context.read<AuthCubit>().register(
          nombreUsuario: _nameController.text.trim(),
          correo: _emailController.text.trim(),
          contrasena: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strength = _passwordStrength(_passwordController.text);
    final strengthColor = _strengthColor(strength);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    if (value.length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: strength,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            strengthColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seguridad: ${_strengthLabel(strength)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: strengthColor == AppColors.success
                              ? Colors.white
                              : strengthColor,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (v) =>
                          setState(() => _acceptTerms = v ?? false),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Acepto los ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : AppColors.textSecondary,
                          ),
                          children: const [
                            TextSpan(
                              text: 'términos y condiciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _register,
                        child: state is AuthLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Crear cuenta'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
