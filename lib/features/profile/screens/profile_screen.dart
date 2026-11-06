import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';
import '../../history/screens/charging_history_screen.dart';
import '../../vehicles/screens/my_vehicles_screen.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _notificationsEnabled = true;
  bool _dataSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.profile);
  }

  void _showAchievementsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AchievementsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 700 && size.width < 1024;
    final isMobile = size.width < 700;

    final content = Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.profile,
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
              selectedIndex: AppRoutes.profile,
              onItemSelected: _onNavSelected,
            ),
          if (isTablet)
            SidebarNavigation(
              isCollapsed: true,
              selectedIndex: AppRoutes.profile,
              onItemSelected: _onNavSelected,
            ),
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.profile,
                  showMenuButton: isMobile,
                  onMenuPressed: isMobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderSection(),
                            const SizedBox(height: 32),
                            _buildStatsRow(),
                            const SizedBox(height: 32),
                            Text('Account', style: AppTypography.heading()),
                            const SizedBox(height: 16),
                            _buildQuickActions(context),
                            const SizedBox(height: 32),
                            Text('Preferences', style: AppTypography.heading()),
                            const SizedBox(height: 16),
                            _buildSettingsSection(),
                            const SizedBox(height: 48),
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

    return isMobile ? Builder(builder: (ctx) => content) : content;
  }

  Widget _buildHeaderSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: _avatarScaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.cyan, AppColors.cyanDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanGlow.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Profile',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EV Driver',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Location not set',
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.cyanBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.outfit(
                    color: AppColors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total Charges', '47')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Total kWh', '284.3')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Total Cost', '\$142.80')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: const Color(0xFF0F172A),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.65),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.electric_car_rounded,
        title: 'My Vehicles',
        subtitle: 'Manage your EV fleet',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyVehiclesScreen()),
        ),
      ),
      _ActionItem(
        icon: Icons.history_rounded,
        title: 'Charging History',
        subtitle: 'View past sessions',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChargingHistoryScreen()),
        ),
      ),
      _ActionItem(
        icon: Icons.credit_card_rounded,
        title: 'Payment Methods',
        subtitle: 'Cards and billing',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
        ),
      ),
      _ActionItem(
        icon: Icons.emoji_events_rounded,
        title: 'Achievements',
        subtitle: 'Badges and rewards',
        onTap: () => _showAchievementsModal(context),
      ),
    ];

    return Column(
      children: List.generate(actions.length, (index) {
        final item = actions[index];

        final delay = 0.2 + (index * 0.05);
        final endDelay = delay + 0.3;
        final clampedEndDelay = endDelay > 1.0 ? 1.0 : endDelay;

        final animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, clampedEndDelay, curve: Curves.easeOutCubic),
        );

        final slideAnim = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation);
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(animation);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnim.value,
              child: FractionalTranslation(
                translation: slideAnim.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassContainer(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2736),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF004D61),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 22),
                      ),
                      title: Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.65),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF334155),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        width: 28,
                        height: 28,
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
                      onTap: item.onTap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSwitchTile(title: 'Dark Mode', value: true, onChanged: null),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Push Notifications',
          value: _notificationsEnabled,
          onChanged: (val) => setState(() => _notificationsEnabled = val),
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Data Sharing',
          value: _dataSharingEnabled,
          onChanged: (val) => setState(() => _dataSharingEnabled = val),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.white.withValues(alpha: 0.65),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.cyan,
              activeTrackColor: AppColors.cyanDark.withValues(alpha: 0.5),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.surfaceLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class AchievementsBottomSheet extends StatelessWidget {
  const AchievementsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _Badge(
        'Early Adopter',
        'Joined in beta',
        Icons.star_rounded,
        AppColors.amber,
      ),
      _Badge(
        'Green Miles',
        '500km driven on EV',
        Icons.eco_rounded,
        AppColors.green,
      ),
      _Badge('Power User', '100 sessions', Icons.bolt_rounded, AppColors.cyan),
      _Badge(
        'Night Owl',
        'Charge after midnight',
        Icons.nights_stay_rounded,
        Colors.purpleAccent,
      ),
      _Badge(
        'Speed Demon',
        'Used 350kW charger',
        Icons.speed_rounded,
        AppColors.red,
      ),
      _Badge(
        'Eco Champion',
        '1000kg CO2 saved',
        Icons.park_rounded,
        Colors.lightGreen,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.cyanBorder.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Achievements',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final badge = achievements[index];
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceLight,
                      border: Border.all(
                        color: badge.color.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: badge.color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(badge.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.name,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.condition,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String name;
  final String condition;
  final IconData icon;
  final Color color;

  _Badge(this.name, this.condition, this.icon, this.color);
}
