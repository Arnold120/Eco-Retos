import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';

class Sidebar extends StatelessWidget {
  final String nombreUsuario;
  final String correo;
  final int nivel;
  final int xp;
  final int xpMaximo;
  final String? fotoPerfil;
  final bool esAdmin;
  final VoidCallback onClose;
  final Function(String option) onOptionSelected;

  const Sidebar({
    super.key,
    required this.nombreUsuario,
    required this.correo,
    required this.nivel,
    required this.xp,
    required this.xpMaximo,
    this.fotoPerfil,
    this.esAdmin = false,
    required this.onClose,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColorsDark.textSecondary
        : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final xpProgress = xpMaximo > 0 ? (xp / xpMaximo).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: AppColors.overlay,
        child: GestureDetector(
          onTap: () {},
          child: Material(
            color: surfaceColor,
            child: SafeArea(
              child: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    _buildProfileHeader(
                      textColor,
                      secondaryTextColor,
                      xpProgress,
                      isDark,
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _buildMenuItem(
                            icon: Icons.dashboard_outlined,
                            label: 'Mi Eco Panel',
                            onTap: () => onOptionSelected('home'),
                          ),
                          _buildMenuItem(
                            icon: Icons.emoji_events_outlined,
                            label: 'Retos Eco',
                            onTap: () => onOptionSelected('challenges'),
                          ),
                          _buildMenuItem(
                            icon: Icons.store_outlined,
                            label: 'Tienda Eco',
                            onTap: () => onOptionSelected('shop'),
                          ),
                          _buildMenuItem(
                            icon: Icons.inventory_2_outlined,
                            label: 'Inventario',
                            onTap: () => onOptionSelected('inventory'),
                          ),
                          _buildMenuItem(
                            icon: Icons.park_outlined,
                            label: 'Jardín Virtual',
                            onTap: () => onOptionSelected('garden'),
                          ),
                          _buildMenuItem(
                            icon: Icons.quiz_outlined,
                            label: 'Trivia Eco',
                            onTap: () => onOptionSelected('trivia'),
                          ),
                          _buildMenuItem(
                            icon: Icons.forum_outlined,
                            label: 'Muro Eco',
                            onTap: () => onOptionSelected('community'),
                          ),
                          _buildMenuItem(
                            icon: Icons.mail_outline,
                            label: 'Mensajes',
                            onTap: () => onOptionSelected('messages'),
                          ),
                          _buildMenuItem(
                            icon: Icons.military_tech_outlined,
                            label: 'Mis Logros',
                            onTap: () => onOptionSelected('achievements'),
                          ),
                          _buildMenuItem(
                            icon: Icons.bar_chart_outlined,
                            label: 'Estadísticas',
                            onTap: () => onOptionSelected('statistics'),
                          ),
                          _buildMenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notificaciones',
                            onTap: () => onOptionSelected('notifications'),
                          ),
                          if (esAdmin) ...[
                            const Divider(indent: 16, endIndent: 16),
                            _buildMenuItem(
                              icon: Icons.admin_panel_settings_outlined,
                              label: 'Panel de revisión',
                              color: AppColors.levelPurple,
                              onTap: () => onOptionSelected('admin'),
                            ),
                          ],
                          const Divider(indent: 16, endIndent: 16),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            label: 'Configuración',
                            onTap: () => onOptionSelected('settings'),
                          ),
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            label: 'Ayuda',
                            onTap: () => onOptionSelected('help'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.logout,
                      label: 'Cerrar sesión',
                      color: AppColors.error,
                      onTap: () => onOptionSelected('logout'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    Color textColor,
    Color secondaryTextColor,
    double xpProgress,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColorsDark.tertiary,
                  AppColorsDark.primary.withValues(alpha: 0.5),
                ]
              : [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: resolverUrlMedia(fotoPerfil) != null
                    ? NetworkImage(resolverUrlMedia(fotoPerfil)!)
                    : null,
                child: fotoPerfil == null
                    ? Text(
                        nombreUsuario.isNotEmpty
                            ? nombreUsuario[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreUsuario,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      correo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nivel $nivel',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.xpGold,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$xp / $xpMaximo XP',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
