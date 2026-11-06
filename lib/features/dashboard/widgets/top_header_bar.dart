import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';

class TopHeaderBar extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final int currentIndex;

  const TopHeaderBar({
    super.key,
    this.onMenuPressed,
    this.showMenuButton = false,
    this.currentIndex = 0,
  });

  @override
  State<TopHeaderBar> createState() => _TopHeaderBarState();
}

class _TopHeaderBarState extends State<TopHeaderBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  bool _hasSearchText = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });

    _searchCtrl.addListener(() {
      final hasText = _searchCtrl.text.trim().isNotEmpty;
      if (hasText != _hasSearchText) {
        setState(() => _hasSearchText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    if (q.contains('station') ||
        q.contains('charge') ||
        q.contains('plug') ||
        q.contains('slot')) {
      AppRouter.navigate(context, AppRoutes.stations, widget.currentIndex);
    } else if (q.contains('car') ||
        q.contains('vehicle') ||
        q.contains('tesla') ||
        q.contains('bmw') ||
        q.contains('ioniq')) {
      AppRouter.navigate(context, AppRoutes.vehicles, widget.currentIndex);
    } else if (q.contains('control') ||
        q.contains('lock') ||
        q.contains('climate') ||
        q.contains('ac') ||
        q.contains('trunk')) {
      AppRouter.navigate(
        context,
        AppRoutes.vehicleControl,
        widget.currentIndex,
      );
    } else if (q.contains('energy') ||
        q.contains('usage') ||
        q.contains('power') ||
        q.contains('kwh') ||
        q.contains('solar')) {
      AppRouter.navigate(context, AppRoutes.energy, widget.currentIndex);
    } else if (q.contains('map') ||
        q.contains('route') ||
        q.contains('trip') ||
        q.contains('locate') ||
        q.contains('near')) {
      AppRouter.navigate(context, AppRoutes.map, widget.currentIndex);
    } else if (q.contains('profile') ||
        q.contains('user') ||
        q.contains('account')) {
      AppRouter.navigate(context, AppRoutes.profile, widget.currentIndex);
    } else if (q.contains('setting') ||
        q.contains('pref') ||
        q.contains('dark') ||
        q.contains('theme')) {
      AppRouter.navigate(context, AppRoutes.settings, widget.currentIndex);
    } else if (q.contains('notif') ||
        q.contains('alert') ||
        q.contains('bell') ||
        q.contains('update')) {
      AppRouter.navigate(context, AppRoutes.notifications, widget.currentIndex);
    } else {
      _showSearchQuickMenu(query);
    }
  }

  void _showSearchQuickMenu(String query) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.cyanBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Results for "$query"',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchQuickLink(
              Icons.ev_station_rounded,
              'Find Nearby Stations',
              () {
                Navigator.pop(ctx);
                AppRouter.navigate(
                  context,
                  AppRoutes.stations,
                  widget.currentIndex,
                );
              },
            ),
            _buildSearchQuickLink(
              Icons.electric_car_rounded,
              'View Your Vehicles',
              () {
                Navigator.pop(ctx);
                AppRouter.navigate(
                  context,
                  AppRoutes.vehicles,
                  widget.currentIndex,
                );
              },
            ),
            _buildSearchQuickLink(Icons.explore_rounded, 'Explore EV Map', () {
              Navigator.pop(ctx);
              AppRouter.navigate(context, AppRoutes.map, widget.currentIndex);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchQuickLink(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white,
        size: 18,
      ),
      onTap: onTap,
    );
  }

  void _showWeatherDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cyanBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.2),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '28°C • Bengaluru',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Clear Sky • Humidity 52%',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cyanBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.battery_charging_full_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Optimal ambient temperature for lithium EV battery efficiency (+4% range boost).',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.90),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Drawer menu toggle for mobile / tablet
          if (widget.showMenuButton) ...[
            _AnimatedIconButton(
              icon: Icons.menu_rounded,
              color: Colors.white,
              tooltip: 'Menu',
              onTap: widget.onMenuPressed ?? () {},
            ),
            const SizedBox(width: 8),
          ],

          // Search Field
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 40,
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: _isSearchFocused
                    ? AppColors.surfaceLight.withValues(alpha: 0.9)
                    : AppColors.surfaceLight.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSearchFocused
                      ? AppColors.cyan
                      : AppColors.borderSubtle,
                  width: _isSearchFocused ? 1.4 : 1.0,
                ),
                boxShadow: _isSearchFocused
                    ? [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                cursorColor: AppColors.cyan,
                textInputAction: TextInputAction.search,
                onSubmitted: _handleSearch,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Search...'
                      : 'Search stations, vehicles, energy, or map...',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => _handleSearch(_searchCtrl.text),
                  ),
                  suffixIcon: _hasSearchText
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _hasSearchText = false);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Weather Widget (interactive with dialog)
          if (!isMobile) ...[
            _AnimatedHoverTile(
              onTap: _showWeatherDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '28°C',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Bengaluru',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Notification Bell (interactive + pulsing badge)
          _AnimatedHoverTile(
            onTap: () => AppRouter.navigate(
              context,
              AppRoutes.notifications,
              widget.currentIndex,
            ),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.currentIndex == AppRoutes.notifications
                    ? AppColors.cyan.withValues(alpha: 0.20)
                    : AppColors.surface.withValues(alpha: 0.75),
                border: Border.all(
                  color: widget.currentIndex == AppRoutes.notifications
                      ? AppColors.cyan
                      : AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.currentIndex == AppRoutes.notifications
                        ? Icons.notifications_rounded
                        : Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  Positioned(
                    right: -1,
                    top: -1,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, _) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cyan.withValues(
                            alpha: _pulseAnim.value,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(
                                alpha: (_pulseAnim.value * 0.8).clamp(0.0, 1.0),
                              ),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Profile Avatar (interactive)
          _AnimatedHoverTile(
            onTap: () => AppRouter.navigate(
              context,
              AppRoutes.profile,
              widget.currentIndex,
            ),
            child: Tooltip(
              message: 'View Profile',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.currentIndex == AppRoutes.profile
                            ? AppColors.cyan
                            : AppColors.cyan.withValues(alpha: 0.6),
                        width: widget.currentIndex == AppRoutes.profile
                            ? 2.0
                            : 1.5,
                      ),
                      boxShadow: widget.currentIndex == AppRoutes.profile
                          ? [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF005F80)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Hover & Press Tile ─────────────────────────────────────────────
class _AnimatedHoverTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedHoverTile({required this.child, required this.onTap});

  @override
  State<_AnimatedHoverTile> createState() => _AnimatedHoverTileState();
}

class _AnimatedHoverTileState extends State<_AnimatedHoverTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ─── Animated Icon Button ───────────────────────────────────────────────────
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.6),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
