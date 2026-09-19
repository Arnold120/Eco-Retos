import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInstructions() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccess() : _buildForm(isDark),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Introduce tu correo electrónico y te enviaremos instrucciones para recuperar tu cuenta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
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
              if (!value.contains('@')) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendInstructions,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enviar instrucciones'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al inicio de sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Correo enviado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Revisa tu bandeja de entrada y sigue las instrucciones para recuperar tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al inicio de sesión'),
          ),
        ),
      ],
    );
  }
}
