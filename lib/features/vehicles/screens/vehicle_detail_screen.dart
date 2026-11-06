import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

// import 'vehicle_control_screen.dart';
// import '../../history/screens/vehicle_charging_history_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleName;
  final String vehicleModel;
  final double socPercent;
  final String range;
  final String licensePlate;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleName,
    required this.vehicleModel,
    required this.socPercent,
    required this.range,
    required this.licensePlate,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text(widget.vehicleName, style: AppTypography.heading()),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Control',
              style: AppTypography.button().copyWith(color: AppColors.cyan),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeroSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSpecificationsTab(), _buildHistoryTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyan.withValues(alpha: 0.15),
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.vehicleModel,
            style: AppTypography.display().copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.licensePlate,
              style: AppTypography.body().copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.socPercent),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      color: AppColors.surfaceLight,
                    ),
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      color: AppColors.cyan,
                      backgroundColor: Colors.transparent,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(value * 100).toInt()}%',
                            style: GoogleFonts.orbitron(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.range,
                            style: AppTypography.body().copyWith(
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.cyan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
        ),
        labelColor: AppColors.cyan,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Specifications'),
          Tab(text: 'Charging History'),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    final specs = [
      {
        'icon': Icons.battery_charging_full,
        'label': 'Battery',
        'value': '82 kWh',
      },
      {'icon': Icons.flash_on, 'label': 'Charging', 'value': '250 kW Max'},
      {'icon': Icons.speed, 'label': 'Motor', 'value': 'Dual AWD'},
      {'icon': Icons.add_road, 'label': 'Top Speed', 'value': '233 km/h'},
      {'icon': Icons.timer, 'label': '0-100 km/h', 'value': '4.4s'},
      {'icon': Icons.route, 'label': 'Range', 'value': '533 km'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E2736),
                    ),
                    child: Icon(
                      spec['icon'] as IconData,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    spec['label'] as String,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF334155),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                spec['value'] as String,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final history = [
      {
        'date': 'Today, 10:30 AM',
        'duration': '45 min',
        'kwh': '32 kWh',
        'cost': '\$12.50',
      },
      {
        'date': 'Oct 06, 2:15 PM',
        'duration': '20 min',
        'kwh': '15 kWh',
        'cost': '\$6.20',
      },
      {
        'date': 'Oct 04, 9:00 AM',
        'duration': '60 min',
        'kwh': '45 kWh',
        'cost': '\$18.00',
      },
      {
        'date': 'Oct 01, 6:45 PM',
        'duration': '35 min',
        'kwh': '25 kWh',
        'cost': '\$9.80',
      },
      {
        'date': 'Sep 28, 11:20 AM',
        'duration': '50 min',
        'kwh': '38 kWh',
        'cost': '\$14.50',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final session = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
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
                    Icons.ev_station,
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
                        session['date']!,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session['kwh']} • ${session['duration']}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF334155),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  session['cost']!,
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF006622),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
