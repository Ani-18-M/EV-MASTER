import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../charging/screens/start_charging_screen.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';
import 'charging_stations_screen.dart';

class StationDetailsScreen extends StatefulWidget {
  final StationData station;

  const StationDetailsScreen({super.key, required this.station});

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  int _selectedTabIndex =
      0; // 0: Stalls, 1: Battery Plan, 2: Pricing, 3: Amenities, 4: Reviews
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> tabs = [
    'Stalls',
    'Battery Plan',
    'Pricing',
    'Amenities',
    'Reviews',
  ];

  // State for interactive features
  int? _heldStallNumber;
  bool _isPreconditioningActive = true;
  double _targetSoC = 80.0;

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.stations);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.stations,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _onNavSelected(index);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar
          if (isDesktop)
            SidebarNavigation(
              selectedIndex: AppRoutes.stations,
              onItemSelected: _onNavSelected,
            )
          else if (isTablet)
            SidebarNavigation(
              isCollapsed: true,
              selectedIndex: AppRoutes.stations,
              onItemSelected: _onNavSelected,
            ),

          // Main Details Area
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  showMenuButton: !isDesktop && !isTablet,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 700 ? 16 : 28,
                      vertical: screenWidth < 700 ? 10 : 22,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button & Breadcrumbs
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Back to Stations',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenWidth < 700 ? 8 : 16),

                            // Hero Banner Card with photo and station info
                            _buildHeroBanner(screenWidth < 700),
                            SizedBox(height: screenWidth < 700 ? 10 : 20),

                            // Connector Types / Availability Cards (3 in a row)
                            _buildConnectorCards(screenWidth),
                            SizedBox(height: screenWidth < 700 ? 10 : 24),

                            // Segmented Tabs Bar: Pricing, Amenities, Reviews
                            _buildTabBar(),
                            SizedBox(height: screenWidth < 700 ? 10 : 18),

                            // Tab Body
                            _buildTabContent(),
                            SizedBox(height: screenWidth < 700 ? 12 : 28),

                            // Start Charging Button
                            CyanButton(
                              text: 'Start Charging',
                              height: screenWidth < 700 ? 44 : 50,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StartChargingScreen(
                                      station: widget.station,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (screenWidth >= 700) const SizedBox(height: 20),
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
  }

  Widget _buildHeroBanner([bool isCompact = false]) {
    return Container(
      height: isCompact ? 115 : 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
        border: Border.all(color: AppColors.cyanBorder, width: 1.2),
        color: AppColors.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
        child: Stack(
          children: [
            // Background Image (Real station photo with cinematic fallback)
            Positioned.fill(
              child: widget.station.imageUrls.isNotEmpty
                  ? Image.network(
                      widget.station.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/ev_charging_cinematic.jpg',
                        fit: BoxFit.cover,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Image.asset(
                          'assets/images/ev_charging_cinematic.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/ev_charging_cinematic.jpg',
                      fit: BoxFit.cover,
                    ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      const Color(0xFF06111D).withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),

            // Operator Pill Badge
            Positioned(
              top: isCompact ? 10 : 16,
              right: isCompact ? 10 : 16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.station.operatorName,
                      style: GoogleFonts.outfit(
                        fontSize: isCompact ? 10.5 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Photo Count Badge
            if (widget.station.imageUrls.length > 1)
              Positioned(
                top: isCompact ? 10 : 16,
                left: isCompact ? 10 : 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.station.imageUrls.length} Photos',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Station Information
            Positioned(
              left: isCompact ? 14 : 24,
              bottom: isCompact ? 10 : 20,
              right: isCompact ? 14 : 24,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isCompact ? 8 : 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.green, width: 1.5),
                    ),
                    child: Icon(
                      Icons.ev_station_rounded,
                      color: Colors.white,
                      size: isCompact ? 18 : 24,
                    ),
                  ),
                  SizedBox(width: isCompact ? 10 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.station.name,
                          style: GoogleFonts.outfit(
                            fontSize: isCompact ? 18 : 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isCompact ? 1 : 3),
                        Text(
                          widget.station.address,
                          style: GoogleFonts.outfit(
                            fontSize: isCompact ? 11.5 : 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isCompact ? 2 : 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: isCompact ? 13 : 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.station.rating} (${widget.station.reviews} reviews)',
                              style: GoogleFonts.outfit(
                                fontSize: isCompact ? 11 : 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildConnectorCards(double screenWidth) {
    final isMobile = screenWidth < 700;
    final connectors = [
      {
        'title': 'DC Fast (120 kW)',
        'status': '2/4 Avail',
        'icon': Icons.bolt_rounded,
        'color': AppColors.cyan,
      },
      {
        'title': 'AC (22 kW)',
        'status': '1/2 Avail',
        'icon': Icons.power_rounded,
        'color': AppColors.cyan,
      },
      {
        'title': 'Type 2',
        'status': '2/2 Avail',
        'icon': Icons.ev_station_rounded,
        'color': AppColors.green,
      },
    ];

    return Row(
      children: connectors
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 5),
                child: _buildConnectorCard(
                  c['title'] as String,
                  c['status'] as String,
                  c['icon'] as IconData,
                  c['color'] as Color,
                  isMobile,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildConnectorCard(
    String title,
    String status,
    IconData icon,
    Color color, [
    bool isCompact = false,
  ]) {
    return GlassContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 14,
        vertical: isCompact ? 8 : 14,
      ),
      borderRadius: isCompact ? 12 : 16,
      borderColor: AppColors.cyanBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 4 : 6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E2736),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isCompact ? 12 : 16,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: isCompact ? 10.5 : 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 4 : 10),
          Text(
            status,
            style: GoogleFonts.outfit(
              fontSize: isCompact ? 10.5 : 12,
              fontWeight: FontWeight.w700,
              color: color == AppColors.green
                  ? const Color(0xFF006622)
                  : (color == AppColors.cyan ? const Color(0xFF004D61) : color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedTabIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? AppColors.cyan : Colors.transparent,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.3,
                      color: isSelected
                          ? AppColors.darkText
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildStallsTab();
      case 1:
        return _buildBatteryPlanTab();
      case 2:
        return _buildPricingTab();
      case 3:
        return _buildAmenitiesTab();
      case 4:
      default:
        return _buildReviewsTab();
    }
  }

  Widget _buildStallsTab() {
    final stalls = widget.station.stalls;
    final availableCount = stalls.where((s) => s.status == 'Available').length;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 16,
      borderColor: AppColors.cyanBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Stall Bay Status',
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  shadows: [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      offset: const Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.green.withValues(alpha: 0.15),
                ),
                child: Text(
                  '$availableCount/${stalls.length} Available',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stalls.map((stall) {
            final isHeld = _heldStallNumber == stall.stallNumber;
            final isAvailable = stall.status == 'Available';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHeld
                    ? AppColors.cyan.withValues(alpha: 0.12)
                    : AppColors.surfaceLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHeld
                      ? AppColors.cyan
                      : (isAvailable
                            ? AppColors.cyanBorder
                            : AppColors.borderSubtle),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isHeld
                          ? AppColors.cyan
                          : (isAvailable
                                ? AppColors.green.withValues(alpha: 0.18)
                                : (stall.status == 'In Use'
                                      ? Colors.amber.withValues(alpha: 0.18)
                                      : Colors.red.withValues(alpha: 0.18))),
                    ),
                    child: Center(
                      child: Text(
                        '#${stall.stallNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isHeld
                              ? Colors.black
                              : (isAvailable
                                    ? AppColors.green
                                    : (stall.status == 'In Use'
                                          ? Colors.amber
                                          : Colors.redAccent)),
                        ),
                      ),
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
                              '${stall.connector} • ${stall.powerKW}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: isHeld
                                    ? AppColors.cyan.withValues(alpha: 0.2)
                                    : (isAvailable
                                          ? AppColors.green.withValues(
                                              alpha: 0.15,
                                            )
                                          : (stall.status == 'In Use'
                                                ? Colors.amber.withValues(
                                                    alpha: 0.15,
                                                  )
                                                : Colors.red.withValues(
                                                    alpha: 0.15,
                                                  ))),
                              ),
                              child: Text(
                                isHeld
                                    ? 'Hold Active (14m)'
                                    : (stall.status == 'In Use'
                                          ? 'In Use (${stall.socPercent}%)'
                                          : stall.status),
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isHeld
                                      ? AppColors.cyan
                                      : (isAvailable
                                            ? AppColors.green
                                            : (stall.status == 'In Use'
                                                  ? Colors.amber
                                                  : Colors.redAccent)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (stall.status == 'In Use' &&
                            stall.minutesRemaining != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Estimated complete in ~${stall.minutesRemaining} mins',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ] else if (isAvailable) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Ready to charge • Optimal for fast top-up',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isHeld)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() => _heldStallNumber = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reservation released')),
                        );
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  else if (isAvailable)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() => _heldStallNumber = stall.stallNumber);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF0B2138),
                            content: Text(
                              'Stall #${stall.stallNumber} held for 15 mins!',
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Hold (15m)',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBatteryPlanTab() {
    return GlassContainer(
      metallicStyle: MetallicStyle.cyan,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 16,
      borderColor: AppColors.cyanBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arrival SoC estimation card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E2736),
                ),
                child: const Icon(
                  Icons.battery_charging_full_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arrival Battery State: ${widget.station.arrivalSoC}%',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF011422),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recommended charge to 80% (+37.2 kWh) for maximum cell longevity',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF032B3D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 12),

          // Battery Pre-conditioning Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1E2736),
                          ),
                          child: const Icon(
                            Icons.thermostat_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pre-condition Battery Pack',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF011422),
                            shadows: [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                offset: const Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isPreconditioningActive
                          ? 'Warming pack to 32°C • Ready for max 120 kW peak speed'
                          : 'Pre-conditioning off. Cold battery will charge ~25% slower.',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _isPreconditioningActive
                            ? const Color(0xFF006622)
                            : const Color(0xFF032B3D),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPreconditioningActive,
                activeThumbColor: AppColors.cyan,
                onChanged: (val) =>
                    setState(() => _isPreconditioningActive = val),
              ),
            ],
          ),
          if (_isPreconditioningActive) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(
                value: 0.82,
                backgroundColor: Color(0xFF0F2B45),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current: 27°C',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF032B3D),
                  ),
                ),
                Text(
                  'Target: 32°C (ETA 4 min)',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    final energyToAdd =
        ((_targetSoC - widget.station.arrivalSoC).clamp(0, 100) / 100 * 60);
    final estimatedCost = (energyToAdd * widget.station.pricePerKWh).toInt();
    final estimatedMinutes = (energyToAdd / 120 * 60).round().clamp(5, 90);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 16,
      borderColor: AppColors.cyanBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRow('DC Fast (120 kW)', '₹18 / kWh'),
          const Divider(color: AppColors.borderSubtle, height: 20),
          _buildPriceRow('AC (22 kW)', '₹12 / kWh'),
          const Divider(color: AppColors.borderSubtle, height: 20),

          // 24-hr TOU Histogram
          Text(
            '24-Hour Time-of-Use Tariff Schedule',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTouBar('00-08h', '₹12', AppColors.green, 'Off-Peak', 0.5),
              const SizedBox(width: 8),
              _buildTouBar('08-17h', '₹16', AppColors.cyan, 'Mid-Peak', 0.75),
              const SizedBox(width: 8),
              _buildTouBar('17-22h', '₹20', Colors.amber, 'Peak Hours', 1.0),
              const SizedBox(width: 8),
              _buildTouBar('22-24h', '₹12', AppColors.green, 'Off-Peak', 0.5),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 10),

          // Target SoC & Cost Calculator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Charge Level',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${_targetSoC.toInt()}%',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004D61),
                ),
              ),
            ],
          ),
          Slider(
            value: _targetSoC,
            min: 20,
            max: 100,
            divisions: 16,
            activeColor: AppColors.cyan,
            inactiveColor: AppColors.surfaceLight,
            onChanged: (val) => setState(() => _targetSoC = val),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF092238).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalcMetric(
                  'Energy',
                  '+${energyToAdd.toStringAsFixed(1)} kWh',
                ),
                Container(width: 1, height: 24, color: AppColors.borderSubtle),
                _buildCalcMetric('Est. Cost', '₹$estimatedCost'),
                Container(width: 1, height: 24, color: AppColors.borderSubtle),
                _buildCalcMetric('Est. Duration', '$estimatedMinutes mins'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouBar(
    String time,
    String rate,
    Color color,
    String label,
    double heightFraction,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 38 * heightFraction,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1.0),
            ),
            child: Center(
              child: Text(
                rate,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcMetric(String title, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF011422),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesTab() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 16,
      borderColor: AppColors.cyanBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plug Reliability Score Card
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${widget.station.plugScore}%',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plug Reliability Score',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '99.4% successful handshakes and stable power output across 30 days',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 12),

          // Verified Amenities Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAmenity(Icons.coffee_rounded, 'Café (20m)'),
              _buildAmenity(Icons.wifi_rounded, 'Free Wi-Fi'),
              _buildAmenity(Icons.wc_rounded, 'Restrooms'),
              _buildAmenity(Icons.local_convenience_store_rounded, 'Mini-Mart'),
              _buildAmenity(Icons.shield_rounded, '24/7 Security'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = widget.station.reviewsList;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 16,
      borderColor: AppColors.cyanBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E2736),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '★ ${widget.station.rating} / 5.0',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.station.reviews} driver reviews)',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.green.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.green, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified OCM Network',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (reviews.isNotEmpty)
            ...reviews.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                r.author,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004D61),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: const Color(0xFFFFB300)
                                      .withValues(alpha: 0.15),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      r.rating.toStringAsFixed(1),
                                      style: GoogleFonts.outfit(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFFB300),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            r.date,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${r.comment}"',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                'No user reviews submitted yet. Be the first to check in and rate this station!',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String chargerType, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          chargerType,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          price,
          style: GoogleFonts.orbitron(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: const Color(0xFF004D61),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1E2736),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
