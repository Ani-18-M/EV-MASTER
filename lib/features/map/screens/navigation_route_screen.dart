import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../charging/screens/start_charging_screen.dart';
import '../../stations/screens/charging_stations_screen.dart';

class NavigationRouteScreen extends StatefulWidget {
  final StationData station;

  const NavigationRouteScreen({super.key, required this.station});

  @override
  State<NavigationRouteScreen> createState() => _NavigationRouteScreenState();
}

class _NavigationRouteScreenState extends State<NavigationRouteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final int _activeStepIndex = 1;

  final List<Map<String, dynamic>> _routeSteps = [
    {
      'icon': Icons.straight_rounded,
      'dist': '200 m',
      'instruction': 'Head North on Inner Ring Road',
      'sub': 'Continue past the metro pillar 142',
      'completed': true,
    },
    {
      'icon': Icons.turn_right_rounded,
      'dist': '400 m',
      'instruction': 'Turn Right onto 100 Feet Road',
      'sub': 'Towards City Mall & EV Charging Hub',
      'completed': false,
    },
    {
      'icon': Icons.roundabout_right_rounded,
      'dist': '1.2 km',
      'instruction': 'At the roundabout, take the 2nd exit',
      'sub': 'Stay on Mall Boulevard',
      'completed': false,
    },
    {
      'icon': Icons.ev_station_rounded,
      'dist': '600 m',
      'instruction': 'Arrive at destination on the left',
      'sub': 'City Mall Charging Hub • Bay Stall B-02',
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Guidance',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.station.name,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.cyan),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'GPS Active',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.cyanBorder, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 28,
          vertical: isMobile ? 16 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Live Maneuver HUD ─────────────────────────────────────────
                _buildLiveManeuverHUD(isMobile),
                const SizedBox(height: 16),

                // ── Trip Telemetry Matrix ─────────────────────────────────────
                _buildTelemetryMatrix(isMobile),
                const SizedBox(height: 16),

                // ── Destination Station Preview Card ──────────────────────────
                _buildDestinationCard(),
                const SizedBox(height: 16),

                // ── Step-by-Step Directions List ──────────────────────────────
                Text(
                  'Route Directions',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(_routeSteps.length, (index) {
                  final step = _routeSteps[index];
                  final isCurrent = index == _activeStepIndex;
                  return _buildStepTile(step, isCurrent: isCurrent);
                }),
                const SizedBox(height: 20),

                // ── Bottom Action CTAs ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: CyanButton(
                        text: 'Arrived • Start Charging',
                        icon: Icons.bolt_rounded,
                        height: 48,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StartChargingScreen(station: widget.station),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Center(
                          child: Text(
                            'End Route',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveManeuverHUD(bool isMobile) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0C243B), const Color(0xFF091624)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.cyan.withValues(
                alpha: 0.4 + (_pulseController.value * 0.3),
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(
                  alpha: 0.18 * _pulseController.value,
                ),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Large turn icon
              Container(
                width: isMobile ? 48 : 56,
                height: isMobile ? 48 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.cyan, width: 2),
                ),
                child: Icon(
                  Icons.turn_right_rounded,
                  color: Colors.white,
                  size: isMobile ? 28 : 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'In 400 m',
                          style: GoogleFonts.orbitron(
                            fontSize: isMobile ? 16 : 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NEXT TURN',
                            style: GoogleFonts.outfit(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Turn Right onto 100 Feet Road',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Towards City Mall & EV Charging Hub',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTelemetryMatrix(bool isMobile) {
    return Row(
      children: [
        _buildMetricItem(
          icon: Icons.timer_outlined,
          value: '8 min',
          label: 'Estimated Arrival',
          color: AppColors.cyan,
        ),
        const SizedBox(width: 8),
        _buildMetricItem(
          icon: Icons.navigation_rounded,
          value: widget.station.distance,
          label: 'Distance Left',
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 8),
        _buildMetricItem(
          icon: Icons.battery_charging_full_rounded,
          value: '54%',
          label: 'Battery at Arrival',
          color: AppColors.green,
          subLabel: '-4% draw',
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String? subLabel,
  }) {
    Color effectiveValueColor = const Color(0xFF011422);
    if (color == AppColors.cyan) {
      effectiveValueColor = const Color(0xFF004D61);
    } else if (color == AppColors.green) {
      effectiveValueColor = const Color(0xFF006622);
    }

    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        borderRadius: 14,
        borderColor: AppColors.cyanBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E2736),
                  ),
                  child: Icon(icon, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF032B3D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: effectiveValueColor,
              ),
            ),
            if (subLabel != null)
              Text(
                subLabel,
                style: GoogleFonts.outfit(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006622),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard() {
    return GlassContainer(
      metallicStyle: MetallicStyle.cyan,
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      borderColor: AppColors.cyanBorder,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2736),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF004D61), width: 1.5),
            ),
            child: const Icon(
              Icons.ev_station_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.station.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF011422),
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.65),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.station.power} • ${widget.station.availability}',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004D61),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2B3E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00E5FF)),
            ),
            child: Text(
              'Bay B-02',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00E5FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(Map<String, dynamic> step, {required bool isCurrent}) {
    final isCompleted = step['completed'] as bool;
    final color = isCurrent
        ? const Color(0xFF004D61)
        : (isCompleted ? const Color(0xFF006622) : const Color(0xFF334155));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 12,
        borderColor: isCurrent ? AppColors.cyan : AppColors.borderSubtle,
        backgroundColor: isCurrent
            ? AppColors.cyan.withValues(alpha: 0.06)
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E2736),
              ),
              child: Icon(
                step['icon'] as IconData,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['instruction'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    step['sub'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              step['dist'] as String,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
