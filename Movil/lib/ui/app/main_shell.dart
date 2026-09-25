import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../../core/theme/app_theme.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../challenges/challenge_list_screen.dart';
import '../trivia/trivias_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import '../garden/garden_screen.dart';
import '../garden/cubit/garden_cubit.dart';
import '../shop/shop_screen.dart';
import '../inventory/inventory_screen.dart';
import '../achievements/achievements_screen.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/sidebar.dart';
import '../admin/admin_evidence_screen.dart';
import '../admin/cubit/admin_evidence_cubit.dart';
import '../../data/services/admin_service.dart';
import '../../data/services/gamification_service.dart';
import '../../core/notifications/notification_service.dart';
import '../profile/cubit/profile_cubit.dart';
import '../home/cubit/home_cubit.dart';
import '../community/cubit/community_cubit.dart';
import '../notifications/notification_screen.dart';


class MainShellScope extends InheritedWidget {
  final void Function(int index) irATab;

  const MainShellScope({
    super.key,
    required this.irATab,
    required super.child,
  });

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _sidebarOpen = false;
  StreamSubscription<String>? _aperturaNotificacionSub;

  @override
  void initState() {
    super.initState();
    _aperturaNotificacionSub =
        NotificationService.instance.aperturas.listen(_abrirDesdePayload);
  }

  @override
  void dispose() {
    _aperturaNotificacionSub?.cancel();
    super.dispose();
  }

  void _abrirDesdePayload(String payload) {
    if (!mounted) return;
    final destino = _destinoDesdePayload(payload);
    switch (destino) {
      case 'home':
        _irATab(0);
        break;
      case 'challenges':
        _irATab(1);
        break;
      case 'trivia':
        _irATab(2);
        break;
      case 'community':
        _irATab(3);
        break;
      case 'profile':
        _irATab(4);
        break;
      case 'notifications':
default:
  final notificationCubit = context.read<NotificationCubit>();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: notificationCubit,
        child: const NotificationScreen(),
      ),
    ),
  );
  break;
    }
  }

  String _destinoDesdePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final screen = decoded['screen'] ?? decoded['seccion'] ?? decoded['tipo'];
        return _normalizarDestino(screen?.toString());
      }
    } catch (_) {
      return _normalizarDestino(payload);
    }
    return _normalizarDestino(payload);
  }

  String _normalizarDestino(String? valor) {
    switch (valor?.toLowerCase()) {
      case 'home':
      case 'inicio':
        return 'home';
      case 'challenge':
      case 'challenges':
      case 'reto':
      case 'retos':
        return 'challenges';
      case 'trivia':
      case 'trivias':
        return 'trivia';
      case 'community':
      case 'comunidad':
      case 'publicacion':
      case 'publicaciones':
        return 'community';
      case 'profile':
      case 'perfil':
        return 'profile';
      case 'notification':
      case 'notifications':
      case 'notificacion':
      case 'notificaciones':
        return 'notifications';
      default:
        return 'notifications';
    }
  }

  void _openSidebar() => setState(() => _sidebarOpen = true);
  void _closeSidebar() => setState(() => _sidebarOpen = false);

  void _irATab(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (index) {
        case 0:
          context.read<HomeCubit>().loadDashboard();
          break;
        case 3:
          context.read<CommunityCubit>().refrescarSilencioso();
          break;
        case 4:
          context.read<ProfileCubit>().refresh();
          break;
      }
    });
  }

  void _onSidebarOption(String option) {
    _closeSidebar();
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;
    final usuarioId = authState.usuarioId;

    switch (option) {
      case 'home':
        _irATab(0);
        break;
      case 'challenges':
        _irATab(1);
        break;
      case 'trivia':
        _irATab(2);
        break;
      case 'community':
        _irATab(3);
        break;
      case 'shop':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ShopScreen(usuarioId: usuarioId)),
        );
        break;
      case 'inventory':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InventoryScreen(usuarioId: usuarioId),
          ),
        );
        break;
      case 'garden':
        _openGarden(usuarioId);
        break;
      case 'achievements':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AchievementsScreen(usuarioId: usuarioId),
          ),
        );
        break;
      case 'statistics':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StatisticsScreen(usuarioId: usuarioId),
          ),
        );
        break;
      case 'admin':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => AdminEvidenceCubit(context.read<AdminService>()),
              child: const AdminEvidenceScreen(),
            ),
          ),
        );
        break;
      case 'settings':
      case 'privacy':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SettingsScreen(usuarioId: usuarioId),
          ),
        );
        break;
      case 'help':
        _showHelpDialog();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tu progreso está guardado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _openGarden(int usuarioId) async {
    final perfil = context.read<ProfileCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GardenCubit(
            usuarioId: usuarioId,
            jardinService: context.read<JardinService>(),
            monederoService: context.read<MonederoService>(),
          )..loadGarden(),
          child: const GardenScreen(),
        ),
      ),
    );
    if (!mounted) return;
    perfil.refresh();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ayuda - Eco Retos'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo funciona Eco Retos?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '1. Aprende sobre sostenibilidad respondiendo trivias.\n'
                '2. Gana XP y Monedas Eco por tus respuestas correctas.\n'
                '3. Compra materiales en la Tienda Eco con tu XP.\n'
                '4. Completa retos ambientales para ganar más recompensas.\n'
                '5. Compra plantas con Monedas Eco para tu Jardín Virtual.\n'
                '6. Comparte tus acciones en el Muro Eco.\n'
                '7. ¡Sube de nivel y desbloquea logros!',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const LoginScreen();
    }

    final usuarioId = authState.usuarioId;
    final nombreUsuario = authState.nombreUsuario;
    final correo = authState.correo;
    final nivel = authState.nivel;

    final profileState = context.watch<ProfileCubit>().state;
    final profileXp = profileState.xpTotal;
    final fotoPerfil = profileState.perfil?.fotoPerfil;

    return MainShellScope(
      irATab: _irATab,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final usarRail = constraints.maxWidth >= 800;
          return Stack(
            children: [
              Scaffold(
                body: usarRail
                    ? Row(
                        children: [
                          _buildRail(),
                          Expanded(
                            child: _buildBody(usuarioId, nombreUsuario),
                          ),
                        ],
                      )
                    : _buildBody(usuarioId, nombreUsuario),
                bottomNavigationBar: usarRail ? null : _buildBottomNav(),
              ),
              if (_sidebarOpen)
                GestureDetector(
                  onTap: _closeSidebar,
                  child: Container(color: AppColors.overlay),
                ),
              if (_sidebarOpen)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  left: _sidebarOpen ? 0 : -320,
                  top: 0,
                  bottom: 0,
                  child: Sidebar(
                    nombreUsuario: nombreUsuario,
                    correo: correo,
                    nivel: nivel,
                    xp: profileXp,
                    xpMaximo: nivel * 100,
                    fotoPerfil: fotoPerfil,
                    esAdmin: authState.esAdmin,
                    onClose: _closeSidebar,
                    onOptionSelected: _onSidebarOption,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(int usuarioId, String nombreUsuario) {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          usuarioId: usuarioId,
          nombreUsuario: nombreUsuario,
          onMenuTap: _openSidebar,
          onGotoRetos: () => _irATab(1),
        );
      case 1:
        return ChallengeListScreen(
          usuarioId: usuarioId,
          onMenuTap: _openSidebar,
        );
      case 2:
        return TriviasScreen(usuarioId: usuarioId, onMenuTap: _openSidebar);
      case 3:
        return CommunityScreen(
          usuarioId: usuarioId,
          nombreUsuario: nombreUsuario,
          onMenuTap: _openSidebar,
        );
      case 4:
        return ProfileScreen(usuarioId: usuarioId, onMenuTap: _openSidebar);
      default:
        return HomeScreen(
          usuarioId: usuarioId,
          nombreUsuario: nombreUsuario,
          onMenuTap: _openSidebar,
          onGotoRetos: () => _irATab(1),
        );
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _irATab,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            _navItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
            _navItem(
                1, Icons.emoji_events_outlined, Icons.emoji_events, 'Retos'),
            _navItem(2, Icons.quiz_outlined, Icons.quiz, 'Trivia'),
            _navItem(3, Icons.forum_outlined, Icons.forum, 'Muro'),
            _navItem(4, Icons.person_outlined, Icons.person, 'Perfil'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 6 : 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: isSelected ? 25 : 23,
          color: isSelected ? AppColors.primary : AppColors.textHint,
        ),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(activeIcon, size: 26, color: Colors.white),
      ),
      label: label,
    );
  }

  Widget _buildRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: _irATab,
      labelType: NavigationRailLabelType.all,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.18),
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events),
          label: Text('Retos'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: Text('Trivia'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum),
          label: Text('Muro'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
      ],
    );
  }
}
