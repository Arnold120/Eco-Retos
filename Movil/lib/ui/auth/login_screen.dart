import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/user_service.dart';
import '../../data/services/gamification_service.dart';
import '../../data/services/categoria_service.dart';
import '../../data/services/reto_service.dart';
import '../../data/services/trivia_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/mensaje_service.dart';
import '../../data/services/imagen_service.dart';
import '../../data/repositories/reto_repository.dart';
import '../../data/repositories/trivias_diario_local.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'welcome_screen.dart';
import '../app/main_shell.dart';
import '../home/cubit/home_cubit.dart';
import '../challenges/cubit/challenge_cubit.dart';
import '../trivia/cubit/trivia_cubit.dart';
import '../profile/cubit/profile_cubit.dart';
import '../community/cubit/community_cubit.dart';
import '../messages/cubit/messages_cubit.dart';
import '../notifications/cubit/notification_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _claveCorreo = 'ultimo_correo';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorInline;

  @override
  void initState() {
    super.initState();
    _cargarCorreoGuardado();
  }

  /// Recuerda el correo para no tener que escribirlo cada vez.
  Future<void> _cargarCorreoGuardado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final correo = prefs.getString(_claveCorreo);
      if (!mounted || correo == null || correo.isEmpty) return;
      setState(() => _emailController.text = correo);
    } catch (_) {
      // Si falla, el campo queda vacio.
    }
  }

  Future<void> _guardarCorreo(String correo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveCorreo, correo);
    } catch (_) {
      // Preferencia secundaria.
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    // Se conserva el correo y la contraseña escritos aunque falle el intento.
    _guardarCorreo(_emailController.text.trim());
    setState(() => _errorInline = null);
    context.read<AuthCubit>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setState(() => _errorInline = state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is Authenticated || state is AuthLoading) {
          if (_errorInline != null) setState(() => _errorInline = null);
        } else if (state is AuthRegistrationSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => WelcomeScreen(
                nombre: state.nombre,
                onStart: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => HomeCubit(
                              usuarioId: state.usuarioId,
                              nombreUsuario: state.nombre,
                              categoriaService: context
                                  .read<CategoriaService>(),
                              retoService: context.read<RetoService>(),
                              progresoService: context.read<ProgresoService>(),
                              jardinService: context.read<JardinService>(),
                              diarioStore:
                                  DiarioStore(usuarioId: state.usuarioId),
                              monederoService: context
                                  .read<MonederoService>(),
                              notificacionService: context
                                  .read<NotificacionService>(),
                              publicacionService: context
                                  .read<PublicacionService>(),
                            )..loadDashboard(),
                          ),
                          BlocProvider(
                            create: (_) => ChallengeCubit(
                              repositorio: RetoRepository(
                                usuarioId: state.usuarioId,
                                retoService: context.read<RetoService>(),
                                monederoService: context
                                    .read<MonederoService>(),
                                progresoService: context
                                    .read<ProgresoService>(),
                                insigniaService: context
                                    .read<InsigniaService>(),
                              ),
                            )..cargar(),
                          ),
                          BlocProvider(
                            create: (_) => TriviaCubit(
                              usuarioId: state.usuarioId,
                              categoriaService: context
                                  .read<CategoriaService>(),
                              triviaService: context.read<TriviaService>(),
                              monederoService: context
                                  .read<MonederoService>(),
                              progresoService: context.read<ProgresoService>(),
                            )..loadTrivias(),
                          ),
                          BlocProvider(
                            create: (_) => ProfileCubit(
                              usuarioId: state.usuarioId,
                              nombreUsuario: state.nombre,
                              correo: state.correo,
                              userService: context.read<UserService>(),
                              progresoService: context.read<ProgresoService>(),
                              jardinService: context.read<JardinService>(),
                              insigniaService: context.read<InsigniaService>(),
                              monederoService: context
                                  .read<MonederoService>(),
                              diarioStore:
                                  DiarioStore(usuarioId: state.usuarioId),
                              imagenService: context.read<ImagenService>(),
                            )..loadProfile(),
                          ),
                          BlocProvider(
                            create: (_) => CommunityCubit(
                              usuarioId: state.usuarioId,
                              publicacionService:
                                  context.read<PublicacionService>(),
                              reaccionService: context.read<ReaccionService>(),
                              seguimientoService:
                                  context.read<SeguimientoService>(),
                              guardadoService: context.read<GuardadoService>(),
                            )..loadPublicaciones(),
                          ),
                          BlocProvider(
                            create: (_) => MessagesCubit(
                              context.read<MensajeService>(),
                            )
                              ..load()
                              ..iniciarPolling(),
                          ),
                          BlocProvider(
                            create: (_) => NotificationCubit(
                              usuarioId: state.usuarioId,
                              service: context.read<NotificacionService>(),
                            )
                              ..loadNotificaciones()
                              ..iniciarPolling(),
                          ),
                        ],
                        child: const MainShell(),
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  _buildLogo(isDark),
                  const SizedBox(height: 40),
                  Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColorsDark.textPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
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
                        return 'Ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorInline != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorInline!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _login,
                          child: state is AuthLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Iniciar sesión'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta? ',
                        style: TextStyle(
                          color: isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
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
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.eco, size: 50, color: Colors.white),
    );
  }
}
