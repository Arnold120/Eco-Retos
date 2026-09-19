import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/push_service.dart';
import 'ui/notifications/notification_screen.dart';
import 'ui/permissions/permission_gate.dart';
import 'data/services/auth_service.dart';
import 'data/services/user_service.dart';
import 'data/services/categoria_service.dart';
import 'data/services/reto_service.dart';
import 'data/repositories/reto_repository.dart';
import 'data/services/trivia_service.dart';
import 'data/services/recurso_service.dart';
import 'data/services/gamification_service.dart';
import 'data/services/social_service.dart';
import 'data/services/social_interaction_service.dart';
import 'data/services/mensaje_service.dart';
import 'data/services/busqueda_service.dart';
import 'data/services/perfil_social_service.dart';
import 'data/services/enlace_service.dart';
import 'data/services/account_service.dart';
import 'data/services/descarga_service.dart';
import 'data/services/imagen_service.dart';
import 'data/services/admin_service.dart';
import 'data/services/usuarios_service.dart';
import 'data/repositories/trivias_diario_local.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/auth/cubit/auth_cubit.dart';
import 'ui/auth/cubit/auth_state.dart';
import 'ui/auth/login_screen.dart';
import 'ui/app/main_shell.dart';
import 'ui/admin/admin_shell.dart';
import 'ui/home/cubit/home_cubit.dart';
import 'ui/challenges/cubit/challenge_cubit.dart';
import 'ui/profile/cubit/profile_cubit.dart';
import 'ui/community/cubit/community_cubit.dart';
import 'ui/messages/cubit/messages_cubit.dart';
import 'ui/notifications/cubit/notification_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FCM en segundo plano/cerrada. Este registro no necesita la Activity y
  // debe hacerse antes de runApp (requisito de firebase_messaging).
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('No se pudo registrar el handler de FCM: $e');
  }

  // IMPORTANTE: las notificaciones locales y FCM se inicializan DESPUÉS del
  // primer frame (ver _EcoRetoAppState). Hacerlo antes de runApp puede colgar
  // la app en Android porque la Activity todavía no está adjunta.
  runApp(const EcoRetoApp());
}

class EcoRetoApp extends StatefulWidget {
  const EcoRetoApp({super.key});

  @override
  State<EcoRetoApp> createState() => _EcoRetoAppState();
}

class _EcoRetoAppState extends State<EcoRetoApp> {
  final _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_onThemeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarNotificaciones();
    });
  }

  /// Inicializa los servicios de notificación una vez que hay UI y Activity.
  /// Nunca bloquea el arranque: cada fallo se registra y la app continúa.
  Future<void> _inicializarNotificaciones() async {
    try {
      await NotificationService.instance.init();
    } catch (e) {
      debugPrint('No se pudo inicializar las notificaciones locales: $e');
    }
    try {
      await PushService.instance.init();
    } catch (e) {
      debugPrint('No se pudo inicializar FCM: $e');
    }
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: authService),
        RepositoryProvider(create: (_) => UserService(apiClient)),
        RepositoryProvider(create: (_) => CategoriaService(apiClient)),
        RepositoryProvider(create: (_) => RetoService(apiClient)),
        RepositoryProvider(create: (_) => TriviaService(apiClient)),
        RepositoryProvider(create: (_) => RecursoService(apiClient)),
        RepositoryProvider(create: (_) => MaterialService(apiClient)),
        RepositoryProvider(create: (_) => ProgresoService(apiClient)),
        RepositoryProvider(create: (_) => JardinService(apiClient)),
        RepositoryProvider(create: (_) => InsigniaService(apiClient)),
        RepositoryProvider(create: (_) => MonederoService(apiClient)),
        RepositoryProvider(create: (_) => RachaService(apiClient)),
        RepositoryProvider(create: (_) => PublicacionService(apiClient)),
        RepositoryProvider(create: (_) => NotificacionService(apiClient)),
        RepositoryProvider(create: (_) => ReaccionService(apiClient)),
        RepositoryProvider(create: (_) => SeguimientoService(apiClient)),
        RepositoryProvider(create: (_) => GuardadoService(apiClient)),
        RepositoryProvider(create: (_) => DenunciaService(apiClient)),
        RepositoryProvider(create: (_) => MensajeService(apiClient)),
        RepositoryProvider(create: (_) => BusquedaService(apiClient)),
        RepositoryProvider(create: (_) => PerfilSocialService(apiClient)),
        RepositoryProvider(create: (_) => EnlaceService(apiClient)),
        RepositoryProvider(create: (_) => AccountService(apiClient)),
        RepositoryProvider(create: (_) => DescargaService(apiClient)),
        RepositoryProvider(create: (_) => InventarioService(apiClient)),
        RepositoryProvider(create: (_) => ImagenService(apiClient)),
        RepositoryProvider(create: (_) => CompraService(apiClient)),
        RepositoryProvider(create: (_) => AdminService(apiClient)),
        RepositoryProvider(create: (_) => UsuariosService(apiClient)),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(authService)..checkAuthStatus(),
        child: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _splashDone = false;

  /// Evita mostrar la pantalla de carga durante un intento de login: asi el
  /// formulario no se destruye y el error se ve en la misma pantalla.
  bool _estadoInicialResuelto = false;

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _aperturaNotifSub;

  @override
  void initState() {
    super.initState();
    _aperturaNotifSub =
        NotificationService.instance.aperturas.listen(_abrirNotificaciones);
    PushService.instance.onMensajeRecibido = _refrescarNotificaciones;
  }

  @override
  void dispose() {
    _aperturaNotifSub?.cancel();
    PushService.instance.onMensajeRecibido = null;
    super.dispose();
  }

  /// Refresca el contador y la lista cuando llega un push en primer plano.
  void _refrescarNotificaciones() {
    if (!mounted) return;
    try {
      context.read<NotificationCubit>().loadNotificaciones();
    } catch (_) {
      // Todavía no hay sesión: el cubit se crea al autenticarse.
    }
  }

  /// Abre la pantalla de notificaciones al tocar un push (solo con sesión).
  void _abrirNotificaciones(String payload) {
    if (!mounted) return;
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) return;

    // Consumido: evita una segunda navegación desde la comprobación inicial.
    PushService.instance.payloadInicial = null;
    NotificationService.instance.payloadInicial = null;

    _navKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // IMPORTANTE: se construye UN solo MaterialApp estable y el contenido de
    // arranque se decide dentro de `home`. Si se alternara entre devolver el
    // MaterialApp o un contenedor distinto (BlocBuilder, etc.), el framework
    // reutiliza el Navigator por su GlobalKey y la ruta inicial queda ligada
    // al estado anterior: la app se quedaba cargando en el splash.
    return MaterialApp(
      title: 'Eco Retos',
      navigatorKey: _navKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      // Modo daltonico: filtro de correccion de color para toda la app.
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        if (!themeProvider.modoDaltonico) return child;
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.80, 0.20, 0.00, 0, 0,
            0.258, 0.742, 0.00, 0, 0,
            0.00, 0.142, 0.858, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: child,
        );
      },
      home: _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(
        onComplete: () => setState(() => _splashDone = true),
      );
    }

    // Los permisos obligatorios se piden despues del splash y antes de
    // mostrar la pantalla de inicio o el login.
    return PermissionGate(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial ||
              (state is AuthLoading && !_estadoInicialResuelto)) {
            return const Scaffold(
              backgroundColor: AppColors.primary,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 80, color: Colors.white),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            );
          }

          if (state is Authenticated) {
            _estadoInicialResuelto = true;

            // Si la app se abrió tocando una notificación (FCM o local) con la
            // app cerrada, se navega a Notificaciones una vez que hay sesión.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final pendiente = PushService.instance.payloadInicial ??
                  NotificationService.instance.payloadInicial;
              if (pendiente != null && pendiente.isNotEmpty) {
                PushService.instance.payloadInicial = null;
                NotificationService.instance.payloadInicial = null;
                _abrirNotificaciones(pendiente);
              }
            });

            // Los cubits viven por encima del Navigator para que cualquier ruta
            // (perfil, publicación, mensajes) comparta el mismo estado.
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => HomeCubit(
                    usuarioId: state.usuarioId,
                    nombreUsuario: state.nombreUsuario,
                    categoriaService: context.read<CategoriaService>(),
                    retoService: context.read<RetoService>(),
                    progresoService: context.read<ProgresoService>(),
                    jardinService: context.read<JardinService>(),
                    diarioStore: DiarioStore(usuarioId: state.usuarioId),
                    monederoService: context.read<MonederoService>(),
                    notificacionService: context.read<NotificacionService>(),
                    publicacionService: context.read<PublicacionService>(),
                  )..loadDashboard(),
                ),
                BlocProvider(
                  create: (_) => ChallengeCubit(
                    repositorio: RetoRepository(
                      usuarioId: state.usuarioId,
                      retoService: context.read<RetoService>(),
                      monederoService: context.read<MonederoService>(),
                      progresoService: context.read<ProgresoService>(),
                      insigniaService: context.read<InsigniaService>(),
                    ),
                  )..cargar(),
                ),
                BlocProvider(
                  create: (_) => ProfileCubit(
                    usuarioId: state.usuarioId,
                    nombreUsuario: state.nombreUsuario,
                    correo: state.correo,
                    userService: context.read<UserService>(),
                    progresoService: context.read<ProgresoService>(),
                    jardinService: context.read<JardinService>(),
                    insigniaService: context.read<InsigniaService>(),
                    monederoService: context.read<MonederoService>(),
                    diarioStore: DiarioStore(usuarioId: state.usuarioId),
                    imagenService: context.read<ImagenService>(),
                  )..loadProfile(),
                ),
                BlocProvider(
                  create: (_) => CommunityCubit(
                    usuarioId: state.usuarioId,
                    publicacionService: context.read<PublicacionService>(),
                    reaccionService: context.read<ReaccionService>(),
                    seguimientoService: context.read<SeguimientoService>(),
                    guardadoService: context.read<GuardadoService>(),
                  )..loadPublicaciones(),
                ),
                BlocProvider(
                  create: (_) => MessagesCubit(context.read<MensajeService>())
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
              child: state.esAdmin ? const AdminShell() : const MainShell(),
            );
          }

          // Incluye AuthLoading durante un intento de login: el formulario
          // permanece visible con su boton en estado "cargando".
          _estadoInicialResuelto = true;
          return const LoginScreen();
        },
      ),
    );
  }
}
