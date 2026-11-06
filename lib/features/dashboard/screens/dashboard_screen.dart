import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/floatable_tile.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/services/ev_map_service.dart';
import '../../stations/screens/charging_stations_screen.dart';
import '../../stations/screens/station_details_screen.dart';
import '../widgets/hero_charge_banner.dart';
import '../widgets/kpi_card.dart';
import '../widgets/nearby_station_card.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/top_header_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<StationData> _liveNearbyStations = [];

  static const _defaultStations = [
    StationData(
      id: '1',
      name: 'GreenCharge Station',
      distance: '1.2 km',
      availability: '2/4 Available',
      power: 'DC Fast (120 kW)',
      isFast: true,
    ),
    StationData(
      id: '2',
      name: 'CityCharge Hub',
      distance: '3.8 km',
      availability: '3/6 Available',
      power: 'AC (22 kW)',
      isFast: false,
    ),
    StationData(
      id: '3',
      name: 'Tesla Supercharger',
      distance: '5.1 km',
      availability: '8/12 Available',
      power: 'DC Fast (250 kW)',
      isFast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveNearby();
  }

  Future<void> _loadLiveNearby() async {
    if (EvMapService.isInTest) return;
    try {
      final loc = await EvMapService.getCurrentLocation();
      final list = await EvMapService.fetchNearbyStations(center: loc);
      if (list.isNotEmpty && mounted) {
        setState(() {
          _liveNearbyStations = list
              .take(3)
              .map((e) => StationData.fromEvMapStation(e))
              .toList();
        });
      }
    } catch (_) {}
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;
    final isMobile = screenWidth < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.home,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _onNavSelected(index);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for Desktop & Tablet
          if (isDesktop)
            SidebarNavigation(
              selectedIndex: AppRoutes.home,
              onItemSelected: _onNavSelected,
            )
          else if (isTablet)
            SidebarNavigation(
              isCollapsed: true,
              selectedIndex: AppRoutes.home,
              onItemSelected: _onNavSelected,
            ),

          // Main Dashboard Body
          Expanded(
            child: Stack(
              children: [
                // Background Ambient Glow Orbs
                Positioned(
                  top: -80,
                  right: -60,
                  child: IgnorePointer(
                    child: Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.cyan.withValues(alpha: 0.14),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  left: 120,
                  child: IgnorePointer(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.cyan.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: 60,
                  child: IgnorePointer(
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF0D47A1).withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content Column
                Column(
                  children: [
                    // Top Bar
                    TopHeaderBar(
                      currentIndex: AppRoutes.home,
                      showMenuButton: !isDesktop && !isTablet,
                      onMenuPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),

                    // Main Content: Fills dashboard with proportional tile ratios
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight;

                          if (isMobile) {
                            return _buildMobileDashboard(availableHeight);
                          }

                          return _buildDesktopDashboard(
                            screenWidth,
                            availableHeight,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Refined Mobile Dashboard with 2-per-row KPIs and 1-per-row rectangular Station tiles
  Widget _buildMobileDashboard(double availableHeight) {
    // Total vertical padding: 10 top + 10 bottom = 20px
    final availableContentHeight = (availableHeight - 20.0).clamp(
      0.0,
      double.infinity,
    );

    // Proportional tile budgeting:
    // Non-tile overhead: Greeting (~34px) + Nearby Stations Header (~22px) = ~56px
    // 2 KPI rows (1x each) + 1 Hero Banner (1.35x) + 3 rectangular station rows (0.65x each) = 5.3 units
    final availableTileSpace = (availableContentHeight - 56.0).clamp(
      380.0,
      800.0,
    );
    final kpiHeight = (availableTileSpace / 5.3).clamp(72.0, 100.0);
    final heroHeight = (kpiHeight * 1.35).clamp(96.0, 138.0);
    final stationHeight = (kpiHeight * 0.65).clamp(52.0, 66.0);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableContentHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Good Morning',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Drive Cleaner. Live Greener.',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 1st Row of KPI Tiles (2 per row): Total Charges & Active Vehicles
            SizedBox(
              height: kpiHeight,
              child: Row(
                children: [
                  Expanded(
                    child: FloatableTile(
                      child: const KpiCard(
                        title: 'Total Charges',
                        value: '12',
                        subtitle: '+2% from last week',
                        icon: Icons.charging_station_rounded,
                        iconColor: Colors.white,
                        subtitleColor: AppColors.cyan,
                        metallicStyle: MetallicStyle.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FloatableTile(
                      child: const KpiCard(
                        title: 'Active Vehicles',
                        value: '2',
                        subtitle: 'All online',
                        icon: Icons.electric_car_rounded,
                        iconColor: Colors.white,
                        subtitleColor: AppColors.green,
                        metallicStyle: MetallicStyle.silver,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2nd Row of KPI Tiles (2 per row): Energy Consumed & CO2 Offset
            SizedBox(
              height: kpiHeight,
              child: Row(
                children: [
                  Expanded(
                    child: FloatableTile(
                      child: const KpiCard(
                        title: 'Energy Consumed',
                        value: '42.6 kWh',
                        subtitle: '+12% from last week',
                        icon: Icons.electric_meter_rounded,
                        iconColor: Colors.white,
                        subtitleColor: AppColors.cyan,
                        metallicStyle: MetallicStyle.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FloatableTile(
                      child: const KpiCard(
                        title: 'CO₂ Offset',
                        value: '184 kg',
                        subtitle: '+18% clean offset',
                        icon: Icons.eco_rounded,
                        iconColor: Colors.white,
                        subtitleColor: AppColors.green,
                        metallicStyle: MetallicStyle.silver,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Full-width Hero Charge Banner with EV car and CTA button
            SizedBox(
              height: heroHeight,
              child: FloatableTile(
                child: HeroChargeBanner(
                  onFindStations: () {
                    AppRouter.navigate(
                      context,
                      AppRoutes.stations,
                      AppRoutes.home,
                    );
                  },
                ),
              ),
            ),

            // Nearby Stations Section (Grouped with clean, compact spacing between station tiles)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Nearby Charging Stations',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        AppRouter.navigate(
                          context,
                          AppRoutes.stations,
                          AppRoutes.home,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...(_liveNearbyStations.isNotEmpty
                        ? _liveNearbyStations.take(3)
                        : _defaultStations)
                    .map(
                      (st) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: SizedBox(
                          height: stationHeight,
                          child: FloatableTile(
                            child: NearbyStationCard(
                              name: st.name,
                              distance: st.distance,
                              availability: st.availability,
                              power: st.power,
                              icon: Icons.near_me_rounded,
                              iconColor: Colors.white,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StationDetailsScreen(station: st),
                                  ),
                                );
                              },
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
    );
  }

  // Desktop & Tablet Proportional Dashboard
  Widget _buildDesktopDashboard(double screenWidth, double availableHeight) {
    // Non-tile vertical content (padding, greeting, headers): ~148px
    final availableTileSpace = (availableHeight - 148.0).clamp(420.0, 800.0);
    final kpiHeight = (availableTileSpace / 3.5).clamp(135.0, 185.0);
    final heroHeight = (kpiHeight * 1.5).clamp(200.0, 275.0);
    final stationHeight = kpiHeight;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 1100 ? 30 : 40,
        vertical: 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (availableHeight - 32).clamp(0.0, double.infinity),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Drive Cleaner. Live Greener.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3 KPI Cards (1st Row): fills the row with reference ratio (3 FloatableTiles)
            _buildKpiRowDesktop(kpiHeight),
            const SizedBox(height: 16),

            // Hero Banner (2nd Row): fills the row completely (1 FloatableTile)
            FloatableTile(
              floatLift: 5.0,
              hoverScale: 1.01,
              child: SizedBox(
                width: double.infinity,
                height: heroHeight,
                child: HeroChargeBanner(
                  onFindStations: () {
                    AppRouter.navigate(
                      context,
                      AppRoutes.stations,
                      AppRoutes.home,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nearby Charging Stations Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Charging Stations',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    AppRouter.navigate(
                      context,
                      AppRoutes.stations,
                      AppRoutes.home,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      'View All',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Station Cards (3rd Row): fills the row with reference ratio (3 FloatableTiles)
            _buildStationListDesktop(stationHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRowDesktop(double rowHeight) {
    const cards = [
      KpiCard(
        title: 'Total Charges',
        value: '12',
        subtitle: '+2% from last week',
        icon: Icons.charging_station_rounded,
        iconColor: Colors.white,
        subtitleColor: AppColors.cyan,
        metallicStyle: MetallicStyle.cyan,
      ),
      KpiCard(
        title: 'Active Vehicles',
        value: '2',
        subtitle: 'All online',
        icon: Icons.electric_car_rounded,
        iconColor: Colors.white,
        subtitleColor: AppColors.green,
        metallicStyle: MetallicStyle.silver,
      ),
      KpiCard(
        title: 'Energy Consumed',
        value: '42.6 kWh',
        subtitle: '+12% from last week',
        icon: Icons.electric_meter_rounded,
        iconColor: Colors.white,
        subtitleColor: AppColors.cyan,
        metallicStyle: MetallicStyle.cyan,
      ),
    ];

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          Expanded(child: FloatableTile(child: cards[0])),
          const SizedBox(width: 18),
          Expanded(child: FloatableTile(child: cards[1])),
          const SizedBox(width: 18),
          Expanded(child: FloatableTile(child: cards[2])),
        ],
      ),
    );
  }

  Widget _buildStationListDesktop(double rowHeight) {
    final displayStations = _liveNearbyStations.isNotEmpty
        ? _liveNearbyStations.take(3).toList()
        : _defaultStations;

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          for (int i = 0; i < displayStations.length; i++) ...[
            if (i > 0) const SizedBox(width: 18),
            Expanded(
              child: FloatableTile(
                child: NearbyStationCard(
                  name: displayStations[i].name,
                  distance: displayStations[i].distance,
                  availability: displayStations[i].availability,
                  power: displayStations[i].power,
                  icon: Icons.near_me_rounded,
                  iconColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StationDetailsScreen(station: displayStations[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
