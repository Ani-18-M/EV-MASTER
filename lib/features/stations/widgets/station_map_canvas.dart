import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

enum MapEngineTheme { cyberDark, tacticalMatrix, satelliteHybrid }

class MapPin {
  final String id;
  final String title;
  final Offset position; // Relative 0.0 to 1.0 on standard map grid
  final bool isFast;
  final bool isAvailable;
  final String power;
  final String distance;
  final String speedTag;
  final String price;
  final int totalPorts;
  final int availablePorts;

  const MapPin({
    required this.id,
    required this.title,
    required this.position,
    this.isFast = true,
    this.isAvailable = true,
    this.power = 'DC Fast (120 kW)',
    this.distance = '1.2 km',
    this.speedTag = '120 kW',
    this.price = '\$0.28 / kWh',
    this.totalPorts = 4,
    this.availablePorts = 2,
  });
}

class StationMapCanvas extends StatefulWidget {
  final String? selectedStationId;
  final ValueChanged<String>? onStationSelected;
  final String? activeNavigationStationId;
  final VoidCallback? onCancelNavigation;
  final ValueChanged<String>? onStartNavigation;
  final ValueChanged<String>? onOpenStationDetails;
  final List<String>? visibleStationIds;

  const StationMapCanvas({
    super.key,
    this.selectedStationId,
    this.onStationSelected,
    this.activeNavigationStationId,
    this.onCancelNavigation,
    this.onStartNavigation,
    this.onOpenStationDetails,
    this.visibleStationIds,
  });

  @override
  State<StationMapCanvas> createState() => _StationMapCanvasState();
}

class _StationMapCanvasState extends State<StationMapCanvas>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _routePulseController;
  late AnimationController _beaconPulseController;
  late AnimationController _trafficController;
  late AnimationController _tiltController;
  late AnimationController _driveSimController;

  // Interactive Pan and Zoom State
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  Offset _dragStart = Offset.zero;
  Offset _panStart = Offset.zero;

  // Modern Map States
  bool _showTraffic = true;
  bool _is3DMode = false;
  bool _isSimulatingDrive = false;
  bool _showStationSheet = false;
  MapEngineTheme _currentTheme = MapEngineTheme.cyberDark;

  // Accurate cartographic coordinates matching the reference layout
  static const List<MapPin> allPins = [
    MapPin(
      id: '1',
      title: 'GreenCharge Station',
      position: Offset(0.58, 0.22),
      isFast: true,
      isAvailable: true,
      power: 'DC Fast (120 kW)',
      distance: '1.2 km',
      speedTag: '120 kW',
      price: '\$0.28 / kWh',
      totalPorts: 4,
      availablePorts: 2,
    ),
    MapPin(
      id: '2',
      title: 'City Mall Charging Hub',
      position: Offset(0.78, 0.38),
      isFast: false,
      isAvailable: true,
      power: 'AC (22 kW)',
      distance: '3.4 km',
      speedTag: '22 kW',
      price: '\$0.19 / kWh',
      totalPorts: 4,
      availablePorts: 1,
    ),
    MapPin(
      id: '3',
      title: 'Riverside Station',
      position: Offset(0.36, 0.44),
      isFast: true,
      isAvailable: true,
      power: 'DC Fast (150 kW)',
      distance: '4.1 km',
      speedTag: '150 kW',
      price: '\$0.32 / kWh',
      totalPorts: 4,
      availablePorts: 2,
    ),
    MapPin(
      id: '4',
      title: 'Tech Park Station',
      position: Offset(0.68, 0.64),
      isFast: false,
      isAvailable: true,
      power: 'AC (11 kW)',
      distance: '5.2 km',
      speedTag: '11 kW',
      price: '\$0.15 / kWh',
      totalPorts: 6,
      availablePorts: 3,
    ),
    MapPin(
      id: '5',
      title: 'Westside Fast Hub',
      position: Offset(0.14, 0.52),
      isFast: true,
      isAvailable: false,
      power: 'DC Fast (120 kW)',
      distance: '6.1 km',
      speedTag: '120 kW',
      price: '\$0.29 / kWh',
      totalPorts: 4,
      availablePorts: 0,
    ),
    MapPin(
      id: '6',
      title: 'South Gateway Charging',
      position: Offset(0.38, 0.76),
      isFast: false,
      isAvailable: true,
      power: 'AC (22 kW)',
      distance: '4.8 km',
      speedTag: '22 kW',
      price: '\$0.20 / kWh',
      totalPorts: 4,
      availablePorts: 2,
    ),
  ];

  // User Vehicle Position at bottom center-right
  static const Offset initialUserPosition = Offset(0.68, 0.88);

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _routePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _beaconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _trafficController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _driveSimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _driveSimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSimulatingDrive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _routePulseController.dispose();
    _beaconPulseController.dispose();
    _trafficController.dispose();
    _tiltController.dispose();
    _driveSimController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomScale = (_zoomScale + 0.3).clamp(0.7, 2.8);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomScale = (_zoomScale - 0.3).clamp(0.7, 2.8);
    });
  }

  void _recenter() {
    setState(() {
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
    });
  }

  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
      if (_is3DMode) {
        _tiltController.forward();
      } else {
        _tiltController.reverse();
      }
    });
  }

  void _cycleTheme() {
    setState(() {
      final nextIndex =
          (_currentTheme.index + 1) % MapEngineTheme.values.length;
      _currentTheme = MapEngineTheme.values[nextIndex];
    });
  }

  void _toggleDriveSimulation() {
    setState(() {
      if (_isSimulatingDrive) {
        _driveSimController.stop();
        _isSimulatingDrive = false;
      } else {
        _isSimulatingDrive = true;
        _driveSimController.forward(from: 0.0);
      }
    });
  }

  MapPin? _getSelectedPin() {
    final id = widget.activeNavigationStationId ?? widget.selectedStationId;
    if (id == null) return allPins[0];
    return allPins.firstWhere((p) => p.id == id, orElse: () => allPins[0]);
  }

  MapPin? _getNavigatingPin() {
    if (widget.activeNavigationStationId == null) return null;
    return allPins.firstWhere(
      (p) => p.id == widget.activeNavigationStationId,
      orElse: () => allPins[0],
    );
  }

  // Calculate simulated user vehicle position along route when simulating drive
  Offset _computeCurrentVehiclePosition(
    Offset start,
    Offset? target,
    double progress,
  ) {
    if (target == null || progress <= 0.0) return start;
    if (progress >= 1.0) return target;

    // Route Waypoints: start -> wp1 -> wp2 -> target
    final wp1 = Offset(start.dx, 0.78);
    final wp2 = Offset(target.dx, 0.78);

    // 3 segments
    const seg1Ratio = 0.25;
    const seg2Ratio = 0.50;
    const seg3Ratio = 0.25;

    if (progress < seg1Ratio) {
      final t = progress / seg1Ratio;
      return Offset.lerp(start, wp1, t)!;
    } else if (progress < seg1Ratio + seg2Ratio) {
      final t = (progress - seg1Ratio) / seg2Ratio;
      return Offset.lerp(wp1, wp2, t)!;
    } else {
      final t = (progress - seg1Ratio - seg2Ratio) / seg3Ratio;
      return Offset.lerp(wp2, target, t)!;
    }
  }

  // Heading angle along route
  double _computeVehicleHeading(Offset start, Offset? target, double progress) {
    if (target == null || progress <= 0.0) return -math.pi / 2; // North
    const seg1Ratio = 0.25;
    const seg2Ratio = 0.50;

    if (progress < seg1Ratio) {
      return -math.pi / 2; // North
    } else if (progress < seg1Ratio + seg2Ratio) {
      return (target.dx >= start.dx) ? 0.0 : math.pi; // East or West
    } else {
      return (target.dy <= 0.78) ? -math.pi / 2 : math.pi / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeNavPin = _getNavigatingPin();
    final selectedPin = _getSelectedPin();
    final visiblePins = widget.visibleStationIds != null
        ? allPins
              .where((p) => widget.visibleStationIds!.contains(p.id))
              .toList()
        : allPins;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cyanBorder, width: 1.2),
              color: const Color(0xFF060E18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Interactive Pan & Zoom Vector Cartography
                GestureDetector(
                  onScaleStart: (details) {
                    _dragStart = details.focalPoint;
                    _panStart = _panOffset;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      if (details.scale != 1.0) {
                        _zoomScale = (_zoomScale * details.scale).clamp(
                          0.7,
                          2.8,
                        );
                      }
                      _panOffset =
                          _panStart + (details.focalPoint - _dragStart);
                    });
                  },
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _radarController,
                      _routePulseController,
                      _beaconPulseController,
                      _trafficController,
                      _tiltController,
                      _driveSimController,
                    ]),
                    builder: (context, child) {
                      final currentVehiclePos = _computeCurrentVehiclePosition(
                        initialUserPosition,
                        activeNavPin?.position,
                        _driveSimController.value,
                      );

                      return CustomPaint(
                        size: Size(w, h),
                        painter: _ProfessionalCartographyPainter(
                          panOffset: _panOffset,
                          zoomScale: _zoomScale,
                          radarAngle: _radarController.value * 2 * math.pi,
                          userPos: currentVehiclePos,
                          targetPos: activeNavPin?.position,
                          routeProgress: _routePulseController.value,
                          beaconPulse: _beaconPulseController.value,
                          trafficProgress: _trafficController.value,
                          tiltValue: _tiltController.value,
                          showTraffic: _showTraffic,
                          mapTheme: _currentTheme,
                        ),
                      );
                    },
                  ),
                ),

                // Station Pins Overlay
                ...visiblePins.map((pin) {
                  final isSelected =
                      widget.selectedStationId == pin.id ||
                      widget.activeNavigationStationId == pin.id;

                  // Transform pin coordinates with camera pan, zoom, and tilt
                  final rawX = w * pin.position.dx;
                  final rawY = h * pin.position.dy;
                  final centerX = w / 2;
                  final centerY = h / 2;

                  final tiltFactor = 1.0 - (_tiltController.value * 0.18);
                  final transformedX =
                      (rawX - centerX) * _zoomScale + centerX + _panOffset.dx;
                  final transformedY =
                      ((rawY - centerY) * _zoomScale * tiltFactor) +
                      centerY +
                      _panOffset.dy +
                      (_tiltController.value * 25);

                  // Viewport culling for performance
                  if (transformedX < -60 ||
                      transformedX > w + 60 ||
                      transformedY < -60 ||
                      transformedY > h + 60) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: transformedX - 22,
                    top: transformedY - 44,
                    child: GestureDetector(
                      onTap: () {
                        widget.onStationSelected?.call(pin.id);
                        setState(() => _showStationSheet = true);
                      },
                      child: _buildModernStationMarker(
                        pin: pin,
                        isSelected: isSelected,
                        isNavigating:
                            widget.activeNavigationStationId == pin.id,
                      ),
                    ),
                  );
                }),

                // User EV Location Beacon with Forward Headlight Cone
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _beaconPulseController,
                    _driveSimController,
                    _tiltController,
                  ]),
                  builder: (context, _) {
                    final currentVehiclePos = _computeCurrentVehiclePosition(
                      initialUserPosition,
                      activeNavPin?.position,
                      _driveSimController.value,
                    );
                    final heading = _computeVehicleHeading(
                      initialUserPosition,
                      activeNavPin?.position,
                      _driveSimController.value,
                    );

                    final rawX = w * currentVehiclePos.dx;
                    final rawY = h * currentVehiclePos.dy;
                    final centerX = w / 2;
                    final centerY = h / 2;
                    final tiltFactor = 1.0 - (_tiltController.value * 0.18);
                    final posX =
                        (rawX - centerX) * _zoomScale + centerX + _panOffset.dx;
                    final posY =
                        ((rawY - centerY) * _zoomScale * tiltFactor) +
                        centerY +
                        _panOffset.dy +
                        (_tiltController.value * 25);

                    return Positioned(
                      left: posX - 26,
                      top: posY - 36,
                      child: IgnorePointer(
                        child: Transform.rotate(
                          angle: heading + (math.pi / 2),
                          child: _buildUserVehicleBeacon(
                            _beaconPulseController.value,
                            isDriving: _isSimulatingDrive,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Top Left: Precision Compass Instrument & Weather Telemetry
                Positioned(
                  left: 14,
                  top: 14,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompassInstrument(),
                      const SizedBox(width: 8),
                      _buildWeatherTelemetryChip(),
                    ],
                  ),
                ),

                // Top Right: Cartography Toolbar Dock
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF081827).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.cyanBorder,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToolbarBtn(
                          Icons.add_rounded,
                          _zoomIn,
                          tooltip: 'Zoom In',
                        ),
                        const SizedBox(height: 5),
                        _buildToolbarBtn(
                          Icons.remove_rounded,
                          _zoomOut,
                          tooltip: 'Zoom Out',
                        ),
                        const SizedBox(height: 5),
                        _buildToolbarBtn(
                          Icons.my_location_rounded,
                          _recenter,
                          tooltip: 'Recenter GPS',
                        ),
                        const SizedBox(height: 5),
                        _buildToolbarBtn(
                          _is3DMode
                              ? Icons.view_in_ar_rounded
                              : Icons.layers_outlined,
                          _toggle3DMode,
                          isActive: _is3DMode,
                          tooltip: _is3DMode
                              ? '3D View Active'
                              : 'Switch to 3D View',
                          badge: _is3DMode ? '3D' : '2D',
                        ),
                        const SizedBox(height: 5),
                        _buildToolbarBtn(
                          Icons.palette_rounded,
                          _cycleTheme,
                          tooltip: 'Theme: ${_themeName(_currentTheme)}',
                        ),
                        const SizedBox(height: 5),
                        _buildToolbarBtn(
                          _showTraffic
                              ? Icons.traffic_rounded
                              : Icons.traffic_outlined,
                          () => setState(() => _showTraffic = !_showTraffic),
                          isActive: _showTraffic,
                          tooltip: 'Live Traffic Flow',
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left: Cartographic Scale Ruler Bar
                Positioned(
                  left: 16,
                  bottom:
                      (activeNavPin != null ||
                          (selectedPin != null && _showStationSheet))
                      ? (activeNavPin != null ? 84 : 142)
                      : 16,
                  child: _buildScaleRuler(),
                ),

                // Top Floating Turn-by-Turn Navigation HUD (Active Mode)
                if (activeNavPin != null)
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 14,
                    child: _buildNavigationCockpitHUD(activeNavPin),
                  ),

                // Bottom Floating Interactive Station Preview Sheet (When pin is selected & not in full nav)
                if (activeNavPin == null &&
                    selectedPin != null &&
                    _showStationSheet)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: _buildFloatingStationSheet(selectedPin),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _themeName(MapEngineTheme theme) {
    switch (theme) {
      case MapEngineTheme.cyberDark:
        return 'Cyber Dark';
      case MapEngineTheme.tacticalMatrix:
        return 'Matrix';
      case MapEngineTheme.satelliteHybrid:
        return 'Satellite';
    }
  }

  // Floating Station Preview Sheet at bottom of map
  Widget _buildFloatingStationSheet(MapPin pin) {
    final themeColor = pin.isFast
        ? const Color(0xFF00E676)
        : const Color(0xFF00B0FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF081827).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cyan.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withValues(alpha: 0.15),
                  border: Border.all(color: themeColor, width: 1.2),
                ),
                child: const Icon(
                  Icons.ev_station_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Title and Distance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pin.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pin.power} • ${pin.distance} away',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Close Sheet Button
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _showStationSheet = false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Real-time Bay Occupancy Indicator Chips
          Row(
            children: [
              Text(
                'Live Bays:',
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: List.generate(pin.totalPorts, (index) {
                    final isAvailable = index < pin.availablePorts;
                    return Expanded(
                      child: Container(
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isAvailable
                              ? const Color(0xFF00E676)
                              : Colors.amber.shade700.withValues(alpha: 0.65),
                          boxShadow: isAvailable
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00E676)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pin.availablePorts}/${pin.totalPorts} Free',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: pin.availablePorts > 0
                      ? const Color(0xFF00E676)
                      : Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Action Buttons: Navigate & Details
          Row(
            children: [
              // Price Tag Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pin.price,
                      style: GoogleFonts.orbitron(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start Navigation Button
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  widget.onStartNavigation?.call(pin.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.navigation_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Navigate',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF04111D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern 3D-styled EV Station Marker
  Widget _buildModernStationMarker({
    required MapPin pin,
    required bool isSelected,
    required bool isNavigating,
  }) {
    final themeColor = pin.isFast
        ? const Color(0xFF00E676)
        : const Color(0xFF00B0FF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live Speed / Power Pill Badge above marker
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1C2C).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : themeColor.withValues(alpha: 0.6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            pin.speedTag,
            style: GoogleFonts.orbitron(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: themeColor,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Marker Capsule with 3D bevel and glow
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 42 : 36,
          height: isSelected ? 42 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.2, -0.3),
              colors: [
                Colors.white,
                themeColor,
                themeColor.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.9),
              width: isSelected ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: isSelected ? 0.85 : 0.4),
                blurRadius: isSelected ? 20 : 10,
                spreadRadius: isSelected ? 4 : 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: isSelected ? 20 : 17,
              height: isSelected ? 20 : 17,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF081826),
              ),
              child: Center(
                child: Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: isSelected ? 14 : 12,
                ),
              ),
            ),
          ),
        ),

        // Ground anchor dot with shadow
        Container(
          width: 5,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // Futuristic Top-Down EV Vehicle Beacon
  Widget _buildUserVehicleBeacon(double pulse, {bool isDriving = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Forward Headlight Beam Cone illuminating the road
        Transform.translate(
          offset: const Offset(0, -22),
          child: CustomPaint(
            size: const Size(48, 44),
            painter: _HeadlightBeamPainter(),
          ),
        ),

        // Radar Distance Ripple
        Container(
          width: 32 + (pulse * 28),
          height: 32 + (pulse * 28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: (1.0 - pulse) * 0.7),
              width: 1.2,
            ),
          ),
        ),

        // Vehicle Pod Icon with metallic cyan core & dynamic speed glow
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDriving
                  ? [
                      Colors.white,
                      const Color(0xFF00E676),
                      const Color(0xFF00B0FF),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFF00E5FF),
                      const Color(0xFF0091EA),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color:
                    (isDriving
                            ? const Color(0xFF00E676)
                            : const Color(0xFF00E5FF))
                        .withValues(alpha: 0.8),
                blurRadius: isDriving ? 18 : 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.navigation_rounded,
              size: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Precision Compass Rose Widget
  Widget _buildCompassInstrument() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _recenter,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0A1B2C).withValues(alpha: 0.9),
          border: Border.all(color: AppColors.cyanBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3D00),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 3,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 2,
              child: Text(
                'N',
                style: GoogleFonts.outfit(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF3D00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Environmental Weather & Telemetry Chip
  Widget _buildWeatherTelemetryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1B2C).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cyanBorder, width: 1.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            '22°C Clear',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 10, color: Colors.white24),
          const SizedBox(width: 6),
          const Icon(
            Icons.battery_charging_full_rounded,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            'Opt. Temp 24°C',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF00E676),
            ),
          ),
        ],
      ),
    );
  }

  // Cartography Toolbar Button with Optional Text Badge
  Widget _buildToolbarBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
    String? tooltip,
    String? badge,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.cyan.withValues(alpha: 0.25)
                : const Color(0xFF0A1B2C).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isActive ? AppColors.cyan : AppColors.cyanBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              if (badge != null)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2.5,
                      vertical: 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.cyan : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.orbitron(
                        fontSize: 6.5,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? const Color(0xFF05111C)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Cartographic Scale Ruler Bar
  Widget _buildScaleRuler() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF071422).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 1, height: 6, color: Colors.white60),
          Container(
            width: 44 * _zoomScale.clamp(0.8, 1.8),
            height: 1.5,
            color: Colors.white60,
          ),
          Container(width: 1, height: 6, color: Colors.white60),
          const SizedBox(width: 6),
          Text(
            '${(500 / _zoomScale).round()} m',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Turn-by-Turn Navigation HUD Cockpit Banner
  Widget _buildNavigationCockpitHUD(MapPin pin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF081827).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Turn Manoeuvre Icon Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E676).withValues(alpha: 0.18),
              border: Border.all(color: const Color(0xFF00E676), width: 1.2),
            ),
            child: const Icon(
              Icons.turn_right_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Maneuver Instructions and Telemetry
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Route to ${pin.title}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'In 150m, Turn right onto Metro Pkwy • ${pin.distance} (4 min ETA)',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cyan,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Lane Guidance & Real-time Speed Limit Pill
                Row(
                  children: [
                    // Lane Guidance Arrows: [ ↑ ] [ ↑ ] [ ↱ ]
                    _buildLaneGuidanceWidget(),
                    const SizedBox(width: 6),

                    // Speed limit badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red, width: 1.2),
                      ),
                      child: Text(
                        '60',
                        style: GoogleFonts.orbitron(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Live Telemetry
                    Expanded(
                      child: Text(
                        _isSimulatingDrive ? '48 km/h • Sim' : 'Live Tracking',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _isSimulatingDrive
                              ? const Color(0xFF00E676)
                              : Colors.white60,
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

          const SizedBox(width: 8),

          // Simulate Drive Button
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _toggleDriveSimulation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _isSimulatingDrive
                    ? const Color(0xFF00E676).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: _isSimulatingDrive
                      ? const Color(0xFF00E676)
                      : Colors.white24,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSimulatingDrive
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _isSimulatingDrive ? 'Pause' : 'Simulate',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isSimulatingDrive
                          ? const Color(0xFF00E676)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // End Route Button
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (_isSimulatingDrive) {
                _driveSimController.stop();
                _isSimulatingDrive = false;
              }
              widget.onCancelNavigation?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'End',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lane Guidance Visualizer (3 lanes, right turning lane active)
  Widget _buildLaneGuidanceWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward_rounded, size: 11, color: Colors.white),
          SizedBox(width: 2),
          Icon(Icons.arrow_upward_rounded, size: 11, color: Colors.white),
          SizedBox(width: 2),
          Icon(Icons.turn_right_rounded, size: 11, color: Colors.white),
        ],
      ),
    );
  }
}

// Forward Projecting Headlight Conical Beam Painter
class _HeadlightBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.4),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.65, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Ultra-Professional Cartography Vector Engine Painter with 3D Tilt, Themes, & Live Traffic
class _ProfessionalCartographyPainter extends CustomPainter {
  final Offset panOffset;
  final double zoomScale;
  final double radarAngle;
  final Offset userPos;
  final Offset? targetPos;
  final double routeProgress;
  final double beaconPulse;
  final double trafficProgress;
  final double tiltValue;
  final bool showTraffic;
  final MapEngineTheme mapTheme;

  _ProfessionalCartographyPainter({
    required this.panOffset,
    required this.zoomScale,
    required this.radarAngle,
    required this.userPos,
    this.targetPos,
    required this.routeProgress,
    required this.beaconPulse,
    required this.trafficProgress,
    required this.tiltValue,
    required this.showTraffic,
    required this.mapTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Theme color palette selection
    final Color bgColor;
    final Color waterColor;
    final Color shorelineColor;
    final Color parkColor;
    final Color buildingColor;
    final Color buildingBorderColor;
    final Color building3DSideColor;
    final Color streetColor;
    final Color boulevardCasingColor;
    final Color boulevardCoreColor;
    final Color highwayCasingColor;
    final Color highwayCoreColor;
    final Color accentCyan;

    switch (mapTheme) {
      case MapEngineTheme.cyberDark:
        bgColor = const Color(0xFF060E18);
        waterColor = const Color(0xFF030A12);
        shorelineColor = const Color(0xFF0A1E30);
        parkColor = const Color(0xFF051912);
        buildingColor = const Color(0xFF0A1826);
        buildingBorderColor = const Color(0xFF0F263C);
        building3DSideColor = const Color(0xFF06111D);
        streetColor = const Color(0xFF0D1E30);
        boulevardCasingColor = const Color(0xFF162D45);
        boulevardCoreColor = const Color(0xFF102235);
        highwayCasingColor = const Color(0xFF183654);
        highwayCoreColor = const Color(0xFF0F243B);
        accentCyan = const Color(0xFF00E5FF);
        break;

      case MapEngineTheme.tacticalMatrix:
        bgColor = const Color(0xFF04080D);
        waterColor = const Color(0xFF020407);
        shorelineColor = const Color(0xFF0B2418);
        parkColor = const Color(0xFF061B10);
        buildingColor = const Color(0xFF071712);
        buildingBorderColor = const Color(0xFF0E3324);
        building3DSideColor = const Color(0xFF030E09);
        streetColor = const Color(0xFF0A1F16);
        boulevardCasingColor = const Color(0xFF103A28);
        boulevardCoreColor = const Color(0xFF0C2B1E);
        highwayCasingColor = const Color(0xFF154832);
        highwayCoreColor = const Color(0xFF0E3524);
        accentCyan = const Color(0xFF00E676);
        break;

      case MapEngineTheme.satelliteHybrid:
        bgColor = const Color(0xFF03060A);
        waterColor = const Color(0xFF010306);
        shorelineColor = const Color(0xFF0E2235);
        parkColor = const Color(0xFF07141A);
        buildingColor = const Color(0xFF0A1520);
        buildingBorderColor = const Color(0xFF152A3D);
        building3DSideColor = const Color(0xFF050B12);
        streetColor = const Color(0xFF0D1C28);
        boulevardCasingColor = const Color(0xFF183047);
        boulevardCoreColor = const Color(0xFF112335);
        highwayCasingColor = const Color(0xFF204060);
        highwayCoreColor = const Color(0xFF152B42);
        accentCyan = const Color(0xFF00B0FF);
        break;
    }

    // Apply Camera Transform: Pan, Zoom, and Smooth 3D Perspective Tilt
    canvas.save();
    canvas.translate(w / 2, h / 2);
    if (tiltValue > 0) {
      canvas.scale(zoomScale, zoomScale * (1.0 - (tiltValue * 0.18)));
      canvas.translate(0, tiltValue * 25);
    } else {
      canvas.scale(zoomScale);
    }
    canvas.translate(
      -w / 2 + panOffset.dx / zoomScale,
      -h / 2 + panOffset.dy / zoomScale,
    );

    // 1. Deep Base Ground
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(-w, -h, w * 3, h * 3), bgPaint);

    // Subtle Satellite Contour / Elevation Gridlines in Satellite Mode
    if (mapTheme == MapEngineTheme.satelliteHybrid) {
      final contourPaint = Paint()
        ..color = const Color(0xFF00B0FF).withValues(alpha: 0.04)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      for (double r = 50; r < w * 1.5; r += 70) {
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), r, contourPaint);
      }
    }

    // 2. Natural River / Water Body
    final waterPaint = Paint()..color = waterColor;
    final shorelinePaint = Paint()
      ..color = shorelineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final riverPath = Path();
    riverPath.moveTo(-w * 0.2, h * 0.15);
    riverPath.cubicTo(w * 0.3, h * 0.2, w * 0.45, h * 0.55, w * 1.2, h * 0.5);
    riverPath.lineTo(w * 1.2, h * 0.65);
    riverPath.cubicTo(w * 0.45, h * 0.7, w * 0.25, h * 0.35, -w * 0.2, h * 0.3);
    riverPath.close();

    canvas.drawPath(riverPath, waterPaint);
    canvas.drawPath(riverPath, shorelinePaint);

    // 3. Urban Parks / Green Reserves
    final parkPaint = Paint()..color = parkColor;
    final parkBorder = Paint()
      ..color = shorelineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final park1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.22, h * 0.18),
      const Radius.circular(16),
    );
    canvas.drawRRect(park1, parkPaint);
    canvas.drawRRect(park1, parkBorder);

    final park2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.72, w * 0.24, h * 0.16),
      const Radius.circular(18),
    );
    canvas.drawRRect(park2, parkPaint);
    canvas.drawRRect(park2, parkBorder);

    // 4. City Architectural Building Parcels (2.5D Extrusions in 3D Mode)
    final blockPaint = Paint()..color = buildingColor;
    final blockBorder = Paint()
      ..color = buildingBorderColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final extrusionPaint = Paint()..color = building3DSideColor;

    final buildings = [
      Rect.fromLTWH(w * 0.12, h * 0.38, w * 0.1, h * 0.08),
      Rect.fromLTWH(w * 0.24, h * 0.38, w * 0.08, h * 0.08),
      Rect.fromLTWH(w * 0.12, h * 0.48, w * 0.08, h * 0.1),
      Rect.fromLTWH(w * 0.48, h * 0.08, w * 0.12, h * 0.09),
      Rect.fromLTWH(w * 0.63, h * 0.08, w * 0.1, h * 0.09),
      Rect.fromLTWH(w * 0.75, h * 0.18, w * 0.12, h * 0.12),
      Rect.fromLTWH(w * 0.62, h * 0.45, w * 0.14, h * 0.12),
      Rect.fromLTWH(w * 0.78, h * 0.48, w * 0.12, h * 0.1),
      Rect.fromLTWH(w * 0.48, h * 0.58, w * 0.14, h * 0.09),
      Rect.fromLTWH(w * 0.16, h * 0.68, w * 0.15, h * 0.12),
    ];

    final extrusionHeight = 14.0 * tiltValue;

    for (final rect in buildings) {
      if (extrusionHeight > 0) {
        // Draw 3D isometric building sides
        final sidePath = Path()
          ..moveTo(rect.left, rect.bottom)
          ..lineTo(rect.left, rect.bottom - extrusionHeight)
          ..lineTo(rect.right, rect.bottom - extrusionHeight)
          ..lineTo(rect.right, rect.bottom)
          ..close();
        canvas.drawPath(sidePath, extrusionPaint);

        final roofRect = Rect.fromLTWH(
          rect.left,
          rect.top - extrusionHeight,
          rect.width,
          rect.height,
        );
        canvas.drawRect(roofRect, blockPaint);
        canvas.drawRect(roofRect, blockBorder);
      } else {
        canvas.drawRect(rect, blockPaint);
        canvas.drawRect(rect, blockBorder);
      }
    }

    // 5. Secondary City Street Grid
    final gridStreetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 1.6;

    final secondaryStreets = [
      [Offset(-w * 0.1, h * 0.25), Offset(w * 1.1, h * 0.25)],
      [Offset(-w * 0.1, h * 0.48), Offset(w * 1.1, h * 0.48)],
      [Offset(-w * 0.1, h * 0.68), Offset(w * 1.1, h * 0.68)],
      [Offset(-w * 0.1, h * 0.85), Offset(w * 1.1, h * 0.85)],
      [Offset(w * 0.22, -h * 0.1), Offset(w * 0.22, h * 1.1)],
      [Offset(w * 0.45, -h * 0.1), Offset(w * 0.45, h * 1.1)],
      [Offset(w * 0.60, -h * 0.1), Offset(w * 0.60, h * 1.1)],
      [Offset(w * 0.75, -h * 0.1), Offset(w * 0.75, h * 1.1)],
      [Offset(w * 0.90, -h * 0.1), Offset(w * 0.90, h * 1.1)],
    ];
    for (final street in secondaryStreets) {
      canvas.drawLine(street[0], street[1], gridStreetPaint);
    }

    // 6. Primary Arterial Boulevards
    final boulevardCasing = Paint()
      ..color = boulevardCasingColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    final boulevardCore = Paint()
      ..color = boulevardCoreColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final mainAvenues = [
      [Offset(0, h * 0.36), Offset(w, h * 0.36)],
      [Offset(w * 0.35, 0), Offset(w * 0.35, h)],
      [Offset(0, h * 0.78), Offset(w, h * 0.78)],
      [Offset(w * 0.68, 0), Offset(w * 0.68, h)],
    ];
    for (final av in mainAvenues) {
      canvas.drawLine(av[0], av[1], boulevardCasing);
      canvas.drawLine(av[0], av[1], boulevardCore);
    }

    // 7. Divided Expressways with Flyovers (I-95 Corridor)
    final highwayUnder = Paint()
      ..color = highwayCasingColor
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;
    final highwayCore = Paint()
      ..color = highwayCoreColor
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    final highwayCenterline = Paint()
      ..color = accentCyan.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    final expPath = Path();
    expPath.moveTo(-w * 0.1, h * 0.85);
    expPath.cubicTo(w * 0.35, h * 0.55, w * 0.65, h * 0.45, w * 1.1, h * 0.12);

    canvas.drawPath(expPath, highwayUnder);
    canvas.drawPath(expPath, highwayCore);
    canvas.drawPath(expPath, highwayCenterline);

    // River Bridge Crossing
    final bridgeDeck = Paint()
      ..color = const Color(0xFF22486E)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(w * 0.42, h * 0.45),
      Offset(w * 0.48, h * 0.55),
      bridgeDeck,
    );

    // 8. Dynamic Live Traffic Simulation (Flowing Vehicle Lights / Heat Particles)
    if (showTraffic) {
      // Static Traffic Heat Lines
      final trafficClear = Paint()
        ..color = const Color(0xFF00E676).withValues(alpha: 0.4)
        ..strokeWidth = 2.0;
      final trafficModerate = Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.4)
        ..strokeWidth = 2.0;

      canvas.drawLine(
        Offset(w * 0.35, h * 0.05),
        Offset(w * 0.35, h * 0.4),
        trafficClear,
      );
      canvas.drawLine(
        Offset(w * 0.35, h * 0.4),
        Offset(w * 0.35, h * 0.65),
        trafficModerate,
      );
      canvas.drawLine(
        Offset(w * 0.35, h * 0.65),
        Offset(w * 0.35, h * 0.95),
        trafficClear,
      );
      canvas.drawLine(
        Offset(0, h * 0.78),
        Offset(w * 0.45, h * 0.78),
        trafficClear,
      );
      canvas.drawLine(
        Offset(w * 0.45, h * 0.78),
        Offset(w * 0.8, h * 0.78),
        trafficModerate,
      );

      // Flowing Dynamic Traffic Particles along Highway (I-95)
      for (final metric in expPath.computeMetrics()) {
        final totalLen = metric.length;

        // Northbound Traffic: White/Cyan headlights
        for (int i = 0; i < 5; i++) {
          final frac = (trafficProgress + (i * 0.2)) % 1.0;
          final tangent = metric.getTangentForOffset(totalLen * frac);
          if (tangent != null) {
            final headLightPaint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill;
            canvas.drawCircle(tangent.position, 2.0, headLightPaint);
          }
        }

        // Southbound Traffic: Red taillights
        for (int i = 0; i < 4; i++) {
          final frac = (1.0 - ((trafficProgress + (i * 0.25)) % 1.0));
          final tangent = metric.getTangentForOffset(totalLen * frac);
          if (tangent != null) {
            final tailLightPaint = Paint()
              ..color = const Color(0xFFFF3D00).withValues(alpha: 0.9)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(tangent.position, 1.8, tailLightPaint);
          }
        }
      }
    }

    // 9. Intersection Node Markers
    final junctionPaint = Paint()
      ..color = accentCyan.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    final junctions = [
      Offset(w * 0.35, h * 0.36),
      Offset(w * 0.68, h * 0.36),
      Offset(w * 0.35, h * 0.78),
      Offset(w * 0.68, h * 0.78),
      Offset(w * 0.45, h * 0.52),
    ];
    for (final j in junctions) {
      canvas.drawCircle(j, 2.2, junctionPaint);
    }

    // 10. Cartographic Micro-Typography Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawRoadLabel(String label, Offset pos, {double angle = 0}) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      if (angle != 0) canvas.rotate(angle);
      textPainter.text = TextSpan(
        text: label,
        style: GoogleFonts.outfit(
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A729A).withValues(alpha: 0.75),
          letterSpacing: 1.1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    drawRoadLabel('I-95 EXPRESSWAY', Offset(w * 0.5, h * 0.48), angle: -0.55);
    drawRoadLabel('GRAND CENTRAL PKWY', Offset(w * 0.5, h * 0.345));
    drawRoadLabel(
      'METRO BOULEVARD',
      Offset(w * 0.335, h * 0.22),
      angle: -math.pi / 2,
    );
    drawRoadLabel('RIVERSIDE DRIVE', Offset(w * 0.5, h * 0.765));
    drawRoadLabel('CENTRAL PARK', Offset(w * 0.19, h * 0.17));
    drawRoadLabel('TECH DISTRICT', Offset(w * 0.82, h * 0.62));

    // 11. Rotating Scanning Radar from User Vehicle
    final userPixelPos = Offset(w * userPos.dx, h * userPos.dy);
    final radarRadius = w * 0.45;

    // Concentric Range Rings
    final ringPaint = Paint()
      ..color = accentCyan.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(userPixelPos, radarRadius * 0.33, ringPaint);
    canvas.drawCircle(userPixelPos, radarRadius * 0.66, ringPaint);
    canvas.drawCircle(userPixelPos, radarRadius, ringPaint);

    // Sweep Sector Arc
    final sweepPaint = Paint()
      ..shader =
          SweepGradient(
            center: FractionalOffset(userPos.dx, userPos.dy),
            startAngle: 0.0,
            endAngle: math.pi / 2,
            colors: [accentCyan.withValues(alpha: 0.18), Colors.transparent],
            transform: GradientRotation(radarAngle),
          ).createShader(
            Rect.fromCircle(center: userPixelPos, radius: radarRadius),
          );
    canvas.drawCircle(userPixelPos, radarRadius, sweepPaint);

    // 12. Active High-Tech Navigation Route Polyline
    if (targetPos != null) {
      final targetPixelPos = Offset(w * targetPos!.dx, h * targetPos!.dy);

      // Multi-segment realistic city navigation route
      final routePath = Path();
      routePath.moveTo(w * 0.68, h * 0.88); // Initial start
      routePath.lineTo(w * 0.68, h * 0.78);
      routePath.lineTo(targetPixelPos.dx, h * 0.78);
      routePath.lineTo(targetPixelPos.dx, targetPixelPos.dy);

      // Outer Navigation Neon Ambient Glow
      final routeGlow = Paint()
        ..color = accentCyan.withValues(alpha: 0.3)
        ..strokeWidth = 12.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(routePath, routeGlow);

      // Core Solid Navigation Polyline
      final routeCore = Paint()
        ..color = accentCyan
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(routePath, routeCore);

      // Inner White Centerline
      final routeCenter = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(routePath, routeCenter);

      // Animated Traveling Navigation Pulse Chevrons
      for (final metric in routePath.computeMetrics()) {
        final totalLength = metric.length;
        for (int i = 0; i < 4; i++) {
          final frac = (routeProgress + (i * 0.25)) % 1.0;
          final tangent = metric.getTangentForOffset(totalLength * frac);
          if (tangent != null) {
            final chevronPaint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill;
            canvas.drawCircle(tangent.position, 4.0, chevronPaint);

            final chevronGlow = Paint()
              ..color = accentCyan.withValues(alpha: 0.8)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(tangent.position, 8.0, chevronGlow);
          }
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProfessionalCartographyPainter oldDelegate) {
    return oldDelegate.panOffset != panOffset ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.radarAngle != radarAngle ||
        oldDelegate.userPos != userPos ||
        oldDelegate.targetPos != targetPos ||
        oldDelegate.routeProgress != routeProgress ||
        oldDelegate.beaconPulse != beaconPulse ||
        oldDelegate.trafficProgress != trafficProgress ||
        oldDelegate.tiltValue != tiltValue ||
        oldDelegate.showTraffic != showTraffic ||
        oldDelegate.mapTheme != mapTheme;
  }
}
