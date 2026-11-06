import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';
import 'app_preferences_screen.dart';
import 'vehicle_settings_screen.dart';
import 'charging_settings_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.settings);
  }

  // ── The 4 main settings categories ───────────────────────────────────────
  static const _settingsItems = [
    _SettingItem(
      icon: Icons.settings_outlined,
      title: 'App Preferences',
      subtitle: 'Light / Dark Mode  •  Notifications',
    ),
    _SettingItem(
      icon: Icons.directions_car_outlined,
      title: 'Vehicle Settings',
      subtitle: 'Default Location  •  Units  •  Preferences',
    ),
    _SettingItem(
      icon: Icons.bolt_rounded,
      title: 'Charging Settings',
      subtitle: 'Auto Start  •  Payment Methods  •  Notifications',
    ),
    _SettingItem(
      icon: Icons.help_outline_rounded,
      title: 'Help & Support',
      subtitle: 'FAQs  •  Contact Us  •  Support',
    ),
  ];

  void _onSettingTap(int index) {
    final routes = [
      () => const AppPreferencesScreen(),
      () => const VehicleSettingsScreen(),
      () => const ChargingSettingsScreen(),
      () => const HelpSupportScreen(),
    ];
    Navigator.push(context, MaterialPageRoute(builder: (_) => routes[index]()));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;
    final isMobile = screenWidth < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.settings,
                onItemSelected: (i) {
                  Navigator.pop(context);
                  _onNavSelected(i);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            SidebarNavigation(
              selectedIndex: AppRoutes.settings,
              onItemSelected: _onNavSelected,
            )
          else if (isTablet)
            SidebarNavigation(
              isCollapsed: true,
              selectedIndex: AppRoutes.settings,
              onItemSelected: _onNavSelected,
            ),

          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.settings,
                  showMenuButton: isMobile,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 28,
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Page title ─────────────────────────────
                            Text(
                              'Settings',
                              style: GoogleFonts.outfit(
                                fontSize: isMobile ? 22 : 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: isMobile ? 20 : 24),

                            // ── 4 large navigation tiles ───────────────
                            ...List.generate(_settingsItems.length, (i) {
                              final item = _settingsItems[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSettingsTile(
                                  item: item,
                                  onTap: () => _onSettingTap(i),
                                  isMobile: isMobile,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required _SettingItem item,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: GlassContainer(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 18 : 22,
          ),
          borderRadius: 18,
          borderColor: AppColors.cyanBorder,
          child: Row(
            children: [
              // Icon circle
              Container(
                width: isMobile ? 46 : 52,
                height: isMobile ? 46 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E2736),
                  border: Border.all(
                    color: const Color(0xFF004D61),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: isMobile ? 22 : 24,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 14 : 18),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 12 : 13,
                        color: const Color(0xFF004D61),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron arrow
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E2736),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data class for settings items
class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
