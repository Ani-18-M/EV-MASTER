import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';

class VehicleSettingsScreen extends StatefulWidget {
  const VehicleSettingsScreen({super.key});

  @override
  State<VehicleSettingsScreen> createState() => _VehicleSettingsScreenState();
}

class _VehicleSettingsScreenState extends State<VehicleSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  String _selectedVehicle = 'Tesla Model 3';
  final List<String> _vehicles = [
    'Tesla Model 3',
    'BYD Atto 3',
    'Hyundai IONIQ 5',
  ];

  double _targetSoc = 80.0;
  double _chargeLimit = 32.0;

  bool _scheduledCharging = false;
  String _rangeUnit = 'km';
  String _tempUnit = 'C';

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

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vehicle settings saved', style: AppTypography.body()),
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
        title: Text('Vehicle Settings', style: AppTypography.heading()),
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
                      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.0, 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Default Vehicle'),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicle,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1E2736),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                          items: _vehicles.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedVehicle = newValue);
                            }
                          },
                        ),
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
                      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.2, 0.7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Charging Preferences'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target SOC',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${_targetSoc.toInt()}%',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004D61),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _targetSoc,
                            min: 50,
                            max: 100,
                            divisions: 10,
                            activeColor: AppColors.cyan,
                            inactiveColor: AppColors.surfaceLight,
                            onChanged: (v) => setState(() => _targetSoc = v),
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Charge Limit',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${_chargeLimit.toInt()}A',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004D61),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _chargeLimit,
                            min: 16,
                            max: 48,
                            divisions: 8,
                            activeColor: AppColors.cyan,
                            inactiveColor: AppColors.surfaceLight,
                            onChanged: (v) => setState(() => _chargeLimit = v),
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
                      curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.4, 0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Smart Charging'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF1E2736),
                                    ),
                                    child: const Icon(
                                      Icons.schedule,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Scheduled Charging',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _scheduledCharging,
                                onChanged: (v) =>
                                    setState(() => _scheduledCharging = v),
                                activeThumbColor: AppColors.cyan,
                              ),
                            ],
                          ),
                          if (_scheduledCharging)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Start Time',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E2736),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.cyan.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '11:00 PM',
                                      style: GoogleFonts.orbitron(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.5, 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Units & Location'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1E2736),
                                ),
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Home Location',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'Set your home address',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1E2736),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Range Unit',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SegmentedButton<String>(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return AppColors.cyan.withValues(
                                            alpha: 0.2,
                                          );
                                        }
                                        return Colors.transparent;
                                      }),
                                ),
                                segments: const [
                                  ButtonSegment(value: 'km', label: Text('km')),
                                  ButtonSegment(
                                    value: 'miles',
                                    label: Text('miles'),
                                  ),
                                ],
                                selected: {_rangeUnit},
                                onSelectionChanged: (set) =>
                                    setState(() => _rangeUnit = set.first),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Temperature',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SegmentedButton<String>(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return AppColors.cyan.withValues(
                                            alpha: 0.2,
                                          );
                                        }
                                        return Colors.transparent;
                                      }),
                                ),
                                segments: const [
                                  ButtonSegment(value: 'C', label: Text('°C')),
                                  ButtonSegment(value: 'F', label: Text('°F')),
                                ],
                                selected: {_tempUnit},
                                onSelectionChanged: (set) =>
                                    setState(() => _tempUnit = set.first),
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

            const SizedBox(height: 32),
            CyanButton(
              text: 'Save Settings',
              icon: Icons.save,
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
