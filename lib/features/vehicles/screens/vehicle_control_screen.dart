import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';

class VehicleControlScreen extends StatefulWidget {
  const VehicleControlScreen({super.key});

  @override
  State<VehicleControlScreen> createState() => _VehicleControlScreenState();
}

class _VehicleControlScreenState extends State<VehicleControlScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedVehicleIndex = 0;
  final List<String> _vehicles = ['Tesla', 'BYD', 'IONIQ 5'];

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _staggerController;

  // States
  bool _isLocked = true;
  bool _lightsOn = false;
  bool _chargePortOpen = false;
  bool _windowsOpen = false;
  bool _trunkOpen = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.vehicleControl);
  }

  void _showClimateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _ClimateBottomSheet(),
    );
  }

  void _beepHorn() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Beep!', style: AppTypography.body()),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _findVehicle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Locating...', style: AppTypography.body()),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(_vehicles.length, (index) {
          final isSelected = _selectedVehicleIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVehicleIndex = index;
                  _staggerController.forward(from: 0.0);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cyan.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  _vehicles[index],
                  style: AppTypography.body(
                    color: isSelected
                        ? AppColors.cyan
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCentralVisualization() {
    return SizedBox(
      height: 250,
      child: Center(
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _glowAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.cyan.withValues(alpha: 0.3),
                      AppColors.cyan.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.electric_car_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusItem(Icons.battery_charging_full_rounded, '82%'),
          _buildStatusDivider(),
          _buildStatusItem(Icons.speed_rounded, '428km'),
          _buildStatusDivider(),
          _buildStatusItem(Icons.thermostat_rounded, '22°C'),
          _buildStatusDivider(),
          _buildStatusItem(
            _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            _isLocked ? 'Locked' : 'Unlocked',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.body(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      height: 20,
      width: 1,
      color: AppColors.textMuted.withValues(alpha: 0.3),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required int index,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final delay = index * 0.05;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              delay,
              (delay + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutBack,
            ),
          ),
        );
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.cyanBorder : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.cyanGlow.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.cyan.withValues(alpha: 0.1)
                      : AppColors.surfaceLight,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTypography.body(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
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
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.vehicleControl,
                onItemSelected: (i) {
                  Navigator.pop(context);
                  _onNavSelected(i);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SidebarNavigation(
              selectedIndex: AppRoutes.vehicleControl,
              isCollapsed: !isDesktop,
              onItemSelected: _onNavSelected,
            ),
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.vehicleControl,
                  showMenuButton: isMobile,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 24,
                            top: 24,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vehicle Controls',
                                  style: AppTypography.display(fontSize: 24),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildVehicleSelector(),
                        _buildCentralVisualization(),
                        _buildStatusStrip(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GridView.count(
                            crossAxisCount: isMobile ? 2 : (isDesktop ? 4 : 3),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: [
                              _buildControlButton(
                                label: _isLocked ? 'Locked' : 'Unlocked',
                                icon: _isLocked
                                    ? Icons.lock_rounded
                                    : Icons.lock_open_rounded,
                                index: 0,
                                isActive: !_isLocked,
                                onTap: () =>
                                    setState(() => _isLocked = !_isLocked),
                              ),
                              _buildControlButton(
                                label: 'Climate',
                                icon: Icons.ac_unit_rounded,
                                index: 1,
                                onTap: _showClimateSheet,
                              ),
                              _buildControlButton(
                                label: 'Horn',
                                icon: Icons.volume_up_rounded,
                                index: 2,
                                onTap: _beepHorn,
                              ),
                              _buildControlButton(
                                label: 'Lights',
                                icon: Icons.light_mode_rounded,
                                index: 3,
                                isActive: _lightsOn,
                                onTap: () =>
                                    setState(() => _lightsOn = !_lightsOn),
                              ),
                              _buildControlButton(
                                label: 'Find',
                                icon: Icons.location_searching_rounded,
                                index: 4,
                                onTap: _findVehicle,
                              ),
                              _buildControlButton(
                                label: 'Charge Port',
                                icon: Icons.power_rounded,
                                index: 5,
                                isActive: _chargePortOpen,
                                onTap: () => setState(
                                  () => _chargePortOpen = !_chargePortOpen,
                                ),
                              ),
                              _buildControlButton(
                                label: 'Windows',
                                icon: Icons.open_with_rounded,
                                index: 6,
                                isActive: _windowsOpen,
                                onTap: () => setState(
                                  () => _windowsOpen = !_windowsOpen,
                                ),
                              ),
                              _buildControlButton(
                                label: 'Trunk',
                                icon: Icons.inventory_2_rounded,
                                index: 7,
                                isActive: _trunkOpen,
                                onTap: () =>
                                    setState(() => _trunkOpen = !_trunkOpen),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
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
}

class _ClimateBottomSheet extends StatefulWidget {
  const _ClimateBottomSheet();

  @override
  State<_ClimateBottomSheet> createState() => _ClimateBottomSheetState();
}

class _ClimateBottomSheetState extends State<_ClimateBottomSheet> {
  double _temperature = 22.0;
  bool _precondition = false;
  int _fanSpeed = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text('Climate Control', style: AppTypography.heading(fontSize: 20)),
          const SizedBox(height: 32),
          Text(
            '${_temperature.toInt()}°C',
            style: GoogleFonts.outfit(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.cyan,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: AppColors.cyan,
              overlayColor: AppColors.cyan.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _temperature,
              min: 16.0,
              max: 30.0,
              divisions: 14,
              onChanged: (val) => setState(() => _temperature = val),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pre-condition Battery',
                style: AppTypography.body(fontSize: 16),
              ),
              Switch(
                value: _precondition,
                onChanged: (val) => setState(() => _precondition = val),
                activeThumbColor: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fan Speed', style: AppTypography.body(fontSize: 16)),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _fanSpeed = index + 1),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _fanSpeed
                            ? AppColors.cyan
                            : AppColors.surfaceLight,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CyanButton(
              text: 'Activate',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
