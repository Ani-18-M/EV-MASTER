import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:math';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  late AnimationController _socController;
  late Animation<double> _socAnimation;

  late AnimationController _staggerController;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'brand': 'Tesla',
      'model': 'Model 3 Long Range',
      'plate': '7EV-412',
      'soc': 82.0,
      'range': 428,
      'status': 'Online',
    },
    {
      'brand': 'BYD',
      'model': 'Atto 3',
      'plate': '4BEV-891',
      'soc': 47.0,
      'range': 214,
      'status': 'Charging',
    },
    {
      'brand': 'Hyundai',
      'model': 'IONIQ 5',
      'plate': 'EV-2204',
      'soc': 23.0,
      'range': 89,
      'status': 'Low Battery',
    },
  ];

  @override
  void initState() {
    super.initState();
    _socController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _socAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _socController, curve: Curves.easeOut));

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _socController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _socController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.vehicles);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Online':
        return AppColors.green;
      case 'Charging':
        return AppColors.cyan;
      case 'Low Battery':
        return AppColors.amber;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getSocColor(double soc) {
    if (soc > 60) return AppColors.green;
    if (soc >= 30) return AppColors.amber;
    return AppColors.red;
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        } else {
          // Initialize with current page value
          value = (_currentPage == index) ? 1.0 : 0.7;
        }
        return Center(
          child: Transform.scale(
            scale: Curves.easeOut.transform(value),
            child: SizedBox(height: 450, width: 360, child: child),
          ),
        );
      },
      child: GlassContainer(
        metallicStyle: index == _currentPage
            ? MetallicStyle.cyan
            : MetallicStyle.silver,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle['brand'],
                        style: AppTypography.body(
                          color: const Color(0xFF334155),
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        vehicle['model'],
                        style: GoogleFonts.outfit(
                          fontSize: 20,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(vehicle['status']),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    vehicle['status'],
                    style: AppTypography.body(
                      color: _getStatusColor(vehicle['status']),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _socAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(140, 140),
                  painter: _SocArcPainter(
                    soc: vehicle['soc'] * _socAnimation.value,
                    color: _getSocColor(vehicle['soc']),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(vehicle['soc'] * _socAnimation.value).toInt()}%',
                            style: GoogleFonts.orbitron(
                              fontSize: 32,
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
                          Text(
                            'State of Charge',
                            style: AppTypography.body(
                              fontSize: 10,
                              color: const Color(0xFF334155),
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoPill(
                  Icons.speed_rounded,
                  '${vehicle['range']}km Range',
                ),
                _buildInfoPill(Icons.directions_car_rounded, vehicle['plate']),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleDetailScreen(
                            vehicleName: vehicle['brand'],
                            vehicleModel: vehicle['model'],
                            socPercent: vehicle['soc'] / 100,
                            range: '${vehicle['range']}km',
                            licensePlate: vehicle['plate'],
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.cyanBorder),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: AppTypography.button(color: AppColors.cyan),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CyanButton(
                    text: 'Control',
                    onPressed: () => AppRouter.navigate(
                      context,
                      AppRoutes.vehicleControl,
                      AppRoutes.vehicles,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.body(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAddVehicleCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text('Add Vehicle', style: AppTypography.heading(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Stats', style: AppTypography.heading(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  'Fleet Range',
                  '731km',
                  Icons.map_rounded,
                  0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  'Energy',
                  '14.2 kWh',
                  Icons.bolt_rounded,
                  1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  'Active',
                  '2/3',
                  Icons.electric_car_rounded,
                  2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, int index) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              index * 0.1,
              (index * 0.1) + 0.5 > 1.0 ? 1.0 : (index * 0.1) + 0.5,
              curve: Curves.easeOut,
            ),
          ),
        );
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 12),
            Text(value, style: AppTypography.display(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.body(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: AppTypography.heading(fontSize: 18)),
          const SizedBox(height: 16),
          _buildActivityTile(
            'Tesla Model 3',
            'Supercharging completed',
            '2h ago',
            Icons.ev_station_rounded,
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            'BYD Atto 3',
            'Charging started',
            '4h ago',
            Icons.battery_charging_full_rounded,
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            'Hyundai IONIQ 5',
            'Low battery warning',
            '1d ago',
            Icons.battery_alert_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(
    String title,
    String subtitle,
    String time,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
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
                  style: AppTypography.body(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: AppTypography.body(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.body(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
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
                selectedIndex: AppRoutes.vehicles,
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
              selectedIndex: AppRoutes.vehicles,
              isCollapsed: !isDesktop,
              onItemSelected: _onNavSelected,
            ),
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.vehicles,
                  showMenuButton: isMobile,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Vehicles',
                                style: AppTypography.display(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manage your electric fleet',
                                style: AppTypography.body(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 450,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                                _socController.forward(from: 0.0);
                              });
                            },
                            itemCount: _vehicles.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _vehicles.length) {
                                return _buildAddVehicleCard();
                              }
                              return _buildVehicleCard(_vehicles[index], index);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _vehicles.length + 1,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.cyan
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildQuickStats(),
                        _buildRecentActivity(),
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

class _SocArcPainter extends CustomPainter {
  final double soc;
  final Color color;

  _SocArcPainter({required this.soc, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.surfaceLight
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw full track (270 degrees, opening at bottom)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      trackPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      (pi * 1.5) * (soc / 100),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SocArcPainter oldDelegate) {
    return oldDelegate.soc != soc || oldDelegate.color != color;
  }
}
