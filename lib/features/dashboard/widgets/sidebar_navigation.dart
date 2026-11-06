import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ev_logo.dart';
import '../../auth/screens/login_screen.dart';

class NavItemData {
  final String title;
  final IconData icon;
  final bool hasBadge;

  const NavItemData({
    required this.title,
    required this.icon,
    this.hasBadge = false,
  });
}

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  static const List<NavItemData> items = [
    NavItemData(title: 'Home', icon: Icons.home_rounded),
    NavItemData(title: 'Charging Stations', icon: Icons.ev_station_rounded),
    NavItemData(title: 'My Vehicles', icon: Icons.electric_car_rounded),
    NavItemData(title: 'Vehicle Control', icon: Icons.tune_rounded),
    NavItemData(title: 'Energy Usage', icon: Icons.bolt_rounded),
    NavItemData(title: 'Map', icon: Icons.explore_rounded),
    NavItemData(title: 'Profile', icon: Icons.person_rounded),
    NavItemData(title: 'Settings', icon: Icons.settings_rounded),
    NavItemData(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      hasBadge: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 76 : 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0.80),
            AppColors.background.withValues(alpha: 0.95),
          ],
        ),
        border: const Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: isCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Brand Logo
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 20),
            child: isCollapsed
                ? const Center(
                    child: EvLogo(
                      showTagline: false,
                      iconHeight: 34,
                      isHorizontal: false,
                    ),
                  )
                : const EvLogo(
                    iconHeight: 38,
                    showTagline: true,
                    isHorizontal: true,
                  ),
          ),

          const SizedBox(height: 10),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: AppColors.cyanBorder.withValues(alpha: 0.4),
                height: 24,
              ),
            )
          else
            const SizedBox(height: 16),

          // Nav label
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 6),
              child: Text(
                'MENU',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 8 : 12,
                vertical: 2,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _NavItemTile(
                    item: items[index],
                    isSelected: index == selectedIndex,
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected(index),
                  ),
                );
              },
            ),
          ),

          // Divider before logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: AppColors.cyanBorder.withValues(alpha: 0.3),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Logout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
            child: _LogoutButton(
              isCollapsed: isCollapsed,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, anim, secAnim) => const LoginScreen(),
                  transitionDuration: const Duration(milliseconds: 350),
                  transitionsBuilder: (context, anim, secAnim, child) =>
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                        child: child,
                      ),
                ),
                (route) => false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Nav Item Tile ──────────────────────────────────────────────────
class _NavItemTile extends StatefulWidget {
  final NavItemData item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_NavItemTile> createState() => _NavItemTileState();
}

class _NavItemTileState extends State<_NavItemTile>
    with SingleTickerProviderStateMixin {
  // Controls the active indicator bar fade+slide
  late AnimationController _indicatorCtrl;
  late Animation<double> _indicatorOpacity;
  late Animation<Offset> _indicatorSlide;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _indicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _indicatorOpacity = CurvedAnimation(
      parent: _indicatorCtrl,
      curve: Curves.easeOut,
    );
    _indicatorSlide =
        Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _indicatorCtrl, curve: Curves.easeOutCubic),
        );

    if (widget.isSelected) _indicatorCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavItemTile old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _indicatorCtrl.forward();
    } else if (!widget.isSelected && old.isSelected) {
      _indicatorCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _indicatorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: _pressed
            ? const Duration(milliseconds: 100)
            : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF02678B), Color(0xFF003850)],
                  )
                : null,
            color: widget.isSelected ? null : Colors.transparent,
            border: widget.isSelected
                ? Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.45),
                    width: 1.2,
                  )
                : Border.all(color: Colors.transparent, width: 1.2),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.22),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              // Active indicator bar
              if (!widget.isCollapsed)
                SlideTransition(
                  position: _indicatorSlide,
                  child: FadeTransition(
                    opacity: _indicatorOpacity,
                    child: Container(
                      width: 3,
                      height: 22,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cyan,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Icon with optional badge
              SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedScale(
                        scale: widget.isSelected ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          widget.item.icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      if (widget.item.hasBadge)
                        Positioned(
                          right: -3,
                          top: -3,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.red,
                              border: Border.all(
                                color: AppColors.background,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Label
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: 0.1,
                      color: widget.isSelected
                          ? Colors.white
                          : const Color(0xFFB8CDDF),
                    ),
                    child: Text(
                      widget.item.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Chevron for selected
                AnimatedOpacity(
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Logout Button ───────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onTap;

  const _LogoutButton({required this.isCollapsed, required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _hovered
                  ? AppColors.red.withValues(alpha: 0.10)
                  : Colors.transparent,
              border: Border.all(
                color: _hovered
                    ? AppColors.red.withValues(alpha: 0.30)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.white, size: 26),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: _hovered ? AppColors.red : const Color(0xFFB8CDDF),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
