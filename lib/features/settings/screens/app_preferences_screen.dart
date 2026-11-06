import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  bool _pushNotifications = true;
  bool _chargingAlerts = true;
  bool _priceDropAlerts = false;
  bool _weeklyReport = true;

  bool _showBatteryPct = true;
  bool _showRangeInMiles = false;
  bool _compactView = false;

  int _selectedColorIndex = 0;
  final List<Color> _accentColors = [
    AppColors.cyan,
    Colors.purpleAccent,
    AppColors.green,
    Colors.orangeAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preferences saved', style: AppTypography.body()),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 24),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.cyan,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool locked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2736),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: locked ? null : onChanged,
            activeThumbColor: AppColors.cyan,
            activeTrackColor: AppColors.cyan.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2736),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF004D61),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('App Preferences', style: AppTypography.heading()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.0, 0.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Appearance'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.dark_mode,
                            title: 'Dark Mode',
                            subtitle: 'System default dark theme',
                            value: true,
                            onChanged: (v) {},
                            locked: true,
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E2736),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.color_lens,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Accent Color',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(_accentColors.length, (
                                  index,
                                ) {
                                  final color = _accentColors[index];
                                  final isSelected =
                                      _selectedColorIndex == index;
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedColorIndex = index,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.only(left: 8),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                            : null,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: color.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.2, 0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Notifications'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.notifications,
                            title: 'Push Notifications',
                            subtitle: 'Allow app notifications',
                            value: _pushNotifications,
                            onChanged: (v) =>
                                setState(() => _pushNotifications = v),
                          ),
                          _buildToggleTile(
                            icon: Icons.battery_charging_full,
                            title: 'Charging Alerts',
                            subtitle: 'Session start/end and errors',
                            value: _chargingAlerts,
                            onChanged: (v) =>
                                setState(() => _chargingAlerts = v),
                          ),
                          _buildToggleTile(
                            icon: Icons.price_check,
                            title: 'Price Drop Alerts',
                            subtitle: 'Notify on cheap off-peak rates',
                            value: _priceDropAlerts,
                            onChanged: (v) =>
                                setState(() => _priceDropAlerts = v),
                          ),
                          _buildToggleTile(
                            icon: Icons.bar_chart,
                            title: 'Weekly Report',
                            subtitle: 'Summary of charging stats',
                            value: _weeklyReport,
                            onChanged: (v) => setState(() => _weeklyReport = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.4, 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Display'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.battery_std,
                            title: 'Show Battery %',
                            subtitle: 'Always display exact percentage',
                            value: _showBatteryPct,
                            onChanged: (v) =>
                                setState(() => _showBatteryPct = v),
                          ),
                          _buildToggleTile(
                            icon: Icons.speed,
                            title: 'Show Range in Miles',
                            subtitle: 'Use miles instead of km',
                            value: _showRangeInMiles,
                            onChanged: (v) =>
                                setState(() => _showRangeInMiles = v),
                          ),
                          _buildToggleTile(
                            icon: Icons.grid_view,
                            title: 'Compact View',
                            subtitle: 'Smaller cards on dashboard',
                            value: _compactView,
                            onChanged: (v) => setState(() => _compactView = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.6, 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Language & Region'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.language,
                            title: 'Language',
                            value: 'English (US)',
                          ),
                          const Divider(
                            color: AppColors.surfaceLight,
                            height: 16,
                          ),
                          _buildInfoTile(
                            icon: Icons.thermostat,
                            title: 'Temperature Unit',
                            value: '°C',
                          ),
                          const Divider(
                            color: AppColors.surfaceLight,
                            height: 16,
                          ),
                          _buildInfoTile(
                            icon: Icons.map,
                            title: 'Distance Unit',
                            value: 'km',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            CyanButton(
              text: 'Save Preferences',
              icon: Icons.save,
              onPressed: _savePreferences,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
