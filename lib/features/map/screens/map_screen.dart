import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/services/ev_map_service.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';
import '../../stations/screens/charging_stations_screen.dart';
import '../../stations/screens/station_details_screen.dart';
import 'navigation_route_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();

  late AnimationController _pulseController;
  LatLng _userLocation = EvMapService.defaultLocation;
  List<EvMapStation> _stations = [];
  String _selectedStationId = '2'; // City Mall selected by default
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  String _activeFilter = 'All';

  bool _isLocating = false;
  bool _isRealLocation = false;

  final List<String> _filters = const [
    'All',
    'Fast DC',
    'Available',
    'CCS2',
    'Type 2',
  ];

  EvMapStation get _selectedStation {
    return _stations.firstWhere(
      (s) => s.id == _selectedStationId,
      orElse: () => _stations.isNotEmpty
          ? _stations.first
          : const EvMapStation(
              id: '2',
              title: 'City Mall Charging Hub',
              shortLabel: 'City Mall',
              location: LatLng(12.9796, 77.6066),
              pinColor: Color(0xFF00E5FF),
              distance: '2.4 km',
              hours: 'Open 24/7',
              power: 'AC (22 kW)',
              isFast: false,
              rating: 4.6,
              address: '2.4 km  •  Open 24/7',
              connectorType: 'Type 2',
              pricePerKWh: 14.0,
              availability: '1/4 Available',
              availablePlugs: 1,
              totalPlugs: 4,
            ),
    );
  }

  List<EvMapStation> get _filteredStations {
    if (_activeFilter == 'All') return _stations;
    if (_activeFilter == 'Fast DC') {
      return _stations.where((s) => s.isFast).toList();
    }
    if (_activeFilter == 'Available') {
      return _stations.where((s) => s.availablePlugs > 0).toList();
    }
    if (_activeFilter == 'CCS2') {
      return _stations.where((s) => s.connectorType == 'CCS2').toList();
    }
    if (_activeFilter == 'Type 2') {
      return _stations.where((s) => s.connectorType == 'Type 2').toList();
    }
    return _stations;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 1. Initial curated stations populated immediately (zero lag)
    _stations = EvMapService.getCuratedStationsAround(_userLocation);

    // 2. Fetch live GPS location and live street route asynchronously
    _initLiveMap();
  }

  Future<void> _initLiveMap({
    bool moveCamera = true,
    bool showToast = false,
  }) async {
    final result = await EvMapService.getUserLocation(requestIfNeeded: true);
    if (!mounted) return;

    final pos = result.location;
    final isReal = result.isRealLocation;

    setState(() {
      _userLocation = pos;
      _isRealLocation = isReal;
      _stations = EvMapService.getCuratedStationsAround(pos);
      if (_stations.isNotEmpty &&
          !_stations.any((s) => s.id == _selectedStationId)) {
        _selectedStationId = _stations.first.id;
      }
    });

    if (moveCamera && isReal) {
      try {
        _mapController.move(pos, 14.2);
      } catch (_) {}
    }

    _loadRouteToSelected();

    if (showToast && mounted) {
      _showLocationFeedback(result);
    }

    // Asynchronously fetch live OCM stations with real driver photos & reviews
    if (!EvMapService.isInTest) {
      try {
        final liveStations = await EvMapService.fetchNearbyStations(
          center: pos,
        );
        if (liveStations.isNotEmpty && mounted) {
          setState(() {
            _stations = liveStations;
            if (!_stations.any((s) => s.id == _selectedStationId)) {
              _selectedStationId = _stations.first.id;
            }
          });
          _loadRouteToSelected();
        }
      } catch (_) {}
    }
  }

  void _showLocationFeedback(UserLocationResult result) {
    if (result.isRealLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'GPS Location Acquired • Found ${_stations.length} charging stations nearby',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (result.status == LocationAccessStatus.serviceDisabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Location services disabled on device. Enable GPS to locate.',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Settings',
            textColor: AppColors.cyan,
            onPressed: () => EvMapService.openLocationSettings(),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result.status == LocationAccessStatus.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Location permission permanently denied. Enable in Settings.',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Settings',
            textColor: AppColors.cyan,
            onPressed: () => EvMapService.openAppSettings(),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGpsLocate() async {
    setState(() => _isLocating = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Finding your original location...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        duration: Duration(seconds: 2),
      ),
    );

    final result = await EvMapService.getUserLocation(requestIfNeeded: true);
    if (!mounted) return;

    setState(() {
      _isLocating = false;
      _userLocation = result.location;
      _isRealLocation = result.isRealLocation;
      _stations = EvMapService.getCuratedStationsAround(result.location);
      if (_stations.isNotEmpty) {
        _selectedStationId = _stations.first.id;
      }
    });

    try {
      _mapController.move(result.location, 14.5);
    } catch (_) {}

    _loadRouteToSelected();
    _showLocationFeedback(result);

    // Fetch real nearby stations around user's location
    if (!EvMapService.isInTest) {
      try {
        final live = await EvMapService.fetchNearbyStations(
          center: result.location,
        );
        if (live.isNotEmpty && mounted) {
          setState(() {
            _stations = live;
            _selectedStationId = live.first.id;
          });
          _loadRouteToSelected();
        }
      } catch (_) {}
    }
  }

  Future<void> _loadRouteToSelected() async {
    if (!mounted) return;
    setState(() => _isLoadingRoute = true);

    final dest = _selectedStation.location;
    final points = await EvMapService.fetchDrivingRoute(
      start: _userLocation,
      destination: dest,
    );

    if (mounted) {
      setState(() {
        _routePoints = points;
        _isLoadingRoute = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.map);
  }

  void _selectStation(String id) {
    setState(() => _selectedStationId = id);
    final st = _selectedStation;
    _mapController.move(st.location, _mapController.camera.zoom);
    _loadRouteToSelected();
  }

  void _navigateToStation(EvMapStation st) {
    final stationData = StationData.fromEvMapStation(st);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationRouteScreen(station: stationData),
      ),
    );
  }

  void _openStationDetails(EvMapStation st) {
    final stationData = StationData.fromEvMapStation(st);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationDetailsScreen(station: stationData),
      ),
    );
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
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.map,
                onItemSelected: (i) {
                  Navigator.pop(context);
                  _onNavSelected(i);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            SidebarNavigation(
              selectedIndex: AppRoutes.map,
              onItemSelected: _onNavSelected,
            )
          else if (isTablet)
            SidebarNavigation(
              isCollapsed: true,
              selectedIndex: AppRoutes.map,
              onItemSelected: _onNavSelected,
            ),

          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.map,
                  showMenuButton: isMobile,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 20),
                    child: isDesktop
                        ? _buildDesktopView()
                        : _buildExactMapCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── DESKTOP SPLIT VIEW: Map on left, Station list on right ────────────────
  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 65, child: _buildExactMapCard()),
        const SizedBox(width: 16),
        Expanded(flex: 35, child: _buildStationSideList()),
      ],
    );
  }

  // ── MAIN MAP CONTAINER WITH CARTO DARK MATTER TILE LAYER ──────────────────
  Widget _buildExactMapCard() {
    final selected = _selectedStation;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF04101D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00B4D8).withValues(alpha: 0.55),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // ── Interactive FlutterMap Layer ─────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation,
                initialZoom: 13.8,
                minZoom: 4.0,
                maxZoom: 19.0,
              ),
              children: [
                // 1. Clean Dark Map Base Layer (100% Free, No Watermark, No API Key Required)
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.ev_master',
                  maxNativeZoom: 16,
                  maxZoom: 19,
                ),
                // 2. High-Contrast Reference Labels Layer (Transparent overlay)
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Reference/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.ev_master',
                  maxNativeZoom: 16,
                  maxZoom: 19,
                ),

                // 2. Real-Time OSRM Road Driving Route Polyline
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      // Outer neon glow
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 6.5,
                        color: AppColors.cyan.withValues(alpha: 0.35),
                      ),
                      // Inner solid road track
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 3.2,
                        color: AppColors.cyan,
                      ),
                    ],
                  ),

                // 3. User Location Marker + Battery Range Aura
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation,
                      width: 50,
                      height: 50,
                      child: _buildUserLocationMarker(),
                    ),
                    // Station Markers
                    ..._filteredStations.map((st) {
                      final isSel = st.id == _selectedStationId;
                      return Marker(
                        point: st.location,
                        width: isSel ? 220 : 44,
                        height: isSel ? 60 : 44,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _selectStation(st.id),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return _buildTeardropPin(
                                station: st,
                                isSelected: isSel,
                                pulse: _pulseController.value,
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // ── Top Left: Filter Chips Row ───────────────────────────────────
            Positioned(
              top: 14,
              left: 14,
              right: 70,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((f) {
                    final isSel = _activeFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeFilter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.cyan
                                : const Color(0xFF071C2E)
                                      .withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.cyan
                                  : AppColors.cyanBorder,
                              width: 1.0,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: AppColors.cyan.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSel
                                  ? Colors.black
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Top Right: Map Controls (GPS Re-center, Zoom In, Zoom Out) ───
            Positioned(
              top: 14,
              right: 14,
              child: Column(
                children: [
                  _buildMapIconButton(
                    icon: _isLocating
                        ? Icons.hourglass_top_rounded
                        : Icons.my_location_rounded,
                    tooltip: 'Find My Original Location',
                    onTap: _handleGpsLocate,
                  ),
                  const SizedBox(height: 8),
                  _buildMapIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Zoom In',
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1.0,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildMapIconButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Zoom Out',
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1.0,
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Live GPS Location Status Pill ─────────────────────────────────
            Positioned(
              top: 56,
              left: 14,
              child: GestureDetector(
                onTap: _handleGpsLocate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071C2E).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isRealLocation
                          ? AppColors.green
                          : AppColors.cyanBorder,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRealLocation
                            ? Icons.gps_fixed_rounded
                            : Icons.gps_not_fixed_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isLocating
                            ? 'Detecting GPS...'
                            : (_isRealLocation
                                  ? 'Live GPS Active'
                                  : 'Tap to Locate Me'),
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Route Loading Indicator ──────────────────────────────────────
            if (_isLoadingRoute)
              Positioned(
                top: 90,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071C2E).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyanBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calculating OSRM route...',
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Bottom Docked Station Card (Matching design & tests) ────────
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: _buildBottomDockedCard(selected),
            ),
          ],
        ),
      ),
    );
  }

  // ── USER CURRENT LOCATION MARKER ──────────────────────────────────────────
  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cyan.withValues(alpha: 0.2),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cyan,
            boxShadow: [
              BoxShadow(color: AppColors.cyan, blurRadius: 10, spreadRadius: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF071C2E).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF00B4D8).withValues(alpha: 0.45),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // ── TEARDROP PIN MARKER WITH NEON GLOW ────────────────────────────────────
  Widget _buildTeardropPin({
    required EvMapStation station,
    required bool isSelected,
    required double pulse,
  }) {
    final pinColor = isSelected ? const Color(0xFF00E5FF) : station.pinColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Concentric glow rings for selected pin
        if (isSelected)
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: 36 + 24 * pulse,
              height: 36 + 24 * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00E5FF)
                      .withValues(alpha: 0.55 * (1.0 - pulse)),
                  width: 1.5,
                ),
              ),
            ),
          ),

        // Pin Icon Body
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(isSelected ? 36 : 28, isSelected ? 44 : 34),
              painter: _TeardropPinPainter(
                color: pinColor,
                isSelected: isSelected,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF071B2D).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      station.shortLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── BOTTOM DOCKED CARD (Matching test expectations & media_1790973912551.jpg) ──
  Widget _buildBottomDockedCard(EvMapStation selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF071C2E).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B4D8).withValues(alpha: 0.65),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.22),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Circular Station Thumbnail or Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A2540),
                  border: Border.all(
                    color: selected.isFast
                        ? const Color(0xFF00E676)
                        : AppColors.cyan,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (selected.isFast
                                  ? const Color(0xFF00E676)
                                  : AppColors.cyan)
                              .withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: selected.imageUrls.isNotEmpty
                      ? Image.network(
                          selected.imageUrls.first,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.ev_station_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                        )
                      : const Icon(
                          Icons.ev_station_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selected.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selected.distance}  •  ${selected.hours}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${selected.rating} (${selected.reviewsCount})',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Power Badge (e.g., "AC (22 kW)")
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected.isFast
                      ? const Color(0xFF00E676).withValues(alpha: 0.15)
                      : AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected.isFast
                        ? const Color(0xFF00E676).withValues(alpha: 0.5)
                        : AppColors.cyan.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  selected.power,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected.isFast
                        ? const Color(0xFF00E676)
                        : AppColors.cyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openStationDetails(selected),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cyanBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToStation(selected),
                  icon: const Icon(
                    Icons.navigation_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Navigate',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── DESKTOP SIDE LIST ─────────────────────────────────────────────────────
  Widget _buildStationSideList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyanBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Stations',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyanBorder),
                ),
                child: Text(
                  '${_filteredStations.length} Live',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredStations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final st = _filteredStations[i];
                final isSel = st.id == _selectedStationId;

                return GestureDetector(
                  onTap: () => _selectStation(st.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.cyan.withValues(alpha: 0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppColors.cyan : AppColors.cyanBorder,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: st.pinColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: st.pinColor.withValues(alpha: 0.6),
                            ),
                          ),
                          child: const Icon(
                            Icons.ev_station_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                st.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${st.distance} • ${st.power}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM TEARDROP PIN PAINTER ─────────────────────────────────────────────
class _TeardropPinPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  const _TeardropPinPainter({required this.color, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final headRadius = w * 0.44;
    final center = Offset(w * 0.5, headRadius);

    // Subtle drop shadow behind the pin
    final shadowPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.96),
          width: w * 0.5,
          height: h * 0.12,
        ),
      );
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Pin contour path
    final path = Path()
      ..moveTo(center.dx, h * 0.98)
      ..cubicTo(
        w * 0.12,
        h * 0.60,
        center.dx - headRadius,
        center.dy + headRadius * 0.4,
        center.dx - headRadius,
        center.dy,
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: headRadius),
        3.14159,
        3.14159,
        false,
      )
      ..cubicTo(
        center.dx + headRadius,
        center.dy + headRadius * 0.4,
        w * 0.88,
        h * 0.60,
        center.dx,
        h * 0.98,
      )
      ..close();

    // Pin gradient fill
    final gradient = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.1,
      colors: [
        Color.lerp(color, Colors.white, 0.45)!,
        color,
        Color.lerp(color, Colors.black, 0.40)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    canvas.drawPath(
      path,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Exterior sharp border
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 1.6 : 1.2,
    );

    // Inner circular badge with lightning bolt
    final innerRadius = headRadius * 0.56;
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = const Color(0xFF04101D),
    );

    // Draw Bolt Icon
    final boltPath = Path()
      ..moveTo(center.dx + innerRadius * 0.10, center.dy - innerRadius * 0.60)
      ..lineTo(center.dx - innerRadius * 0.35, center.dy + innerRadius * 0.05)
      ..lineTo(center.dx, center.dy + innerRadius * 0.05)
      ..lineTo(center.dx - innerRadius * 0.10, center.dy + innerRadius * 0.65)
      ..lineTo(center.dx + innerRadius * 0.40, center.dy - innerRadius * 0.05)
      ..lineTo(center.dx, center.dy - innerRadius * 0.05)
      ..close();

    canvas.drawPath(boltPath, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TeardropPinPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isSelected != isSelected;
  }
}
