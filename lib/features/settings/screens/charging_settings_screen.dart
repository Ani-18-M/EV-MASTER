import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';

class ChargingSettingsScreen extends StatefulWidget {
  const ChargingSettingsScreen({super.key});

  @override
  State<ChargingSettingsScreen> createState() => _ChargingSettingsScreenState();
}

class _ChargingSettingsScreenState extends State<ChargingSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  bool _autoStart = true;
  bool _notifyStart = true;
  bool _notifyEnd = true;
  bool _notifyLow = false;

  bool _networkTesla = true;
  bool _networkChargePoint = true;
  bool _networkEVgo = false;
  bool _networkElectrifyAmerica = true;

  double _maxDuration = 4.0;
  bool _maxCostLimit = false;
  bool _costAlerts = true;

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
        content: Text('Charging settings saved', style: AppTypography.body()),
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

  Widget _buildToggleRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.cyan,
            activeTrackColor: AppColors.cyan.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.cyan,
      checkColor: AppColors.background,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
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
        title: Text('Charging Settings', style: AppTypography.heading()),
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
                    _buildSectionHeader('General & Notifications'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildToggleRow(
                            'Auto-start charging',
                            _autoStart,
                            (v) => setState(() => _autoStart = v),
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 16),
                          _buildToggleRow(
                            'Session Start Alert',
                            _notifyStart,
                            (v) => setState(() => _notifyStart = v),
                          ),
                          _buildToggleRow(
                            'Session End Alert',
                            _notifyEnd,
                            (v) => setState(() => _notifyEnd = v),
                          ),
                          _buildToggleRow(
                            'Low Battery Alert',
                            _notifyLow,
                            (v) => setState(() => _notifyLow = v),
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
                    _buildSectionHeader('Payment'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E2736),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Default Method',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                Text(
                                  'Visa •••• 4242',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Change',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF004D61),
                              ),
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
                    _buildSectionHeader('Preferred Networks'),
                    GlassContainer(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _buildCheckboxRow(
                            'Tesla Supercharger',
                            _networkTesla,
                            (v) => setState(() => _networkTesla = v ?? false),
                          ),
                          _buildCheckboxRow(
                            'ChargePoint',
                            _networkChargePoint,
                            (v) => setState(
                              () => _networkChargePoint = v ?? false,
                            ),
                          ),
                          _buildCheckboxRow(
                            'EVgo',
                            _networkEVgo,
                            (v) => setState(() => _networkEVgo = v ?? false),
                          ),
                          _buildCheckboxRow(
                            'Electrify America',
                            _networkElectrifyAmerica,
                            (v) => setState(
                              () => _networkElectrifyAmerica = v ?? false,
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
                    _buildSectionHeader('Session Limits & Alerts'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Max Duration',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${_maxDuration.toInt()}h',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004D61),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _maxDuration,
                            min: 1,
                            max: 12,
                            divisions: 11,
                            activeColor: AppColors.cyan,
                            inactiveColor: AppColors.surfaceLight,
                            onChanged: (v) => setState(() => _maxDuration = v),
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 24),
                          _buildToggleRow(
                            'Max Cost Limit',
                            _maxCostLimit,
                            (v) => setState(() => _maxCostLimit = v),
                          ),
                          if (_maxCostLimit)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 16,
                              ),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: AppTypography.body(),
                                decoration: InputDecoration(
                                  labelText: 'Limit (\$)',
                                  labelStyle: AppTypography.body(
                                    color: AppColors.textMuted,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.surfaceLight,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          _buildToggleRow(
                            'Cost Alerts (\$/kWh)',
                            _costAlerts,
                            (v) => setState(() => _costAlerts = v),
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
