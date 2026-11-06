import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/services/ev_map_service.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';
import '../widgets/station_list_card.dart';
import '../widgets/station_map_canvas.dart';
import 'station_details_screen.dart';

class StallData {
  final int stallNumber;
  final String status; // 'Available', 'In Use', 'Reserved', 'Maintenance'
  final int? socPercent;
  final int? minutesRemaining;
  final String powerKW;
  final String connector;

  const StallData({
    required this.stallNumber,
    required this.status,
    this.socPercent,
    this.minutesRemaining,
    required this.powerKW,
    required this.connector,
  });
}

class StationData {
  final String id;
  final String name;
  final String distance;
  final String availability;
  final String power;
  final bool isFast;
  final double rating;
  final int reviews;
  final String address;
  final String connectorType;
  final int waitTimeMinutes;
  final int plugScore;
  final List<String> amenities;
  final List<StallData> stalls;
  final double pricePerKWh;
  final bool isVehicleCompatible;
  final int arrivalSoC;
  final String operatorName;
  final List<String> imageUrls;
  final List<StationReview> reviewsList;

  const StationData({
    required this.id,
    required this.name,
    required this.distance,
    required this.availability,
    required this.power,
    required this.isFast,
    this.rating = 4.8,
    this.reviews = 128,
    this.address = '1.2 km • Open 24/7',
    this.connectorType = 'CCS2',
    this.waitTimeMinutes = 0,
    this.plugScore = 98,
    this.amenities = const ['Café', 'Restrooms', 'Free Wi-Fi', '24/7 Security'],
    this.stalls = const [
      StallData(
        stallNumber: 1,
        status: 'Available',
        powerKW: '120 kW',
        connector: 'CCS2',
      ),
      StallData(
        stallNumber: 2,
        status: 'In Use',
        socPercent: 82,
        minutesRemaining: 6,
        powerKW: '120 kW',
        connector: 'CCS2',
      ),
      StallData(
        stallNumber: 3,
        status: 'Available',
        powerKW: '120 kW',
        connector: 'CCS2',
      ),
      StallData(
        stallNumber: 4,
        status: 'Maintenance',
        powerKW: '120 kW',
        connector: 'Type 2',
      ),
    ],
    this.pricePerKWh = 18.0,
    this.isVehicleCompatible = true,
    this.arrivalSoC = 18,
    this.operatorName = 'ChargePoint Network',
    this.imageUrls = const [],
    this.reviewsList = const [],
  });

  factory StationData.fromEvMapStation(EvMapStation st) {
    final plugs = st.totalPlugs;
    final avail = st.availablePlugs;
    return StationData(
      id: st.id,
      name: st.title,
      distance: st.distance,
      availability: st.availability,
      power: st.power,
      isFast: st.isFast,
      rating: st.rating,
      reviews: st.reviewsCount,
      address: st.address.isNotEmpty
          ? '${st.distance}  •  ${st.address}'
          : '${st.distance}  •  ${st.hours}',
      connectorType: st.connectorType,
      pricePerKWh: st.pricePerKWh,
      operatorName: st.operatorName,
      imageUrls: st.imageUrls,
      reviewsList: st.reviews,
      stalls: List.generate(plugs, (idx) {
        final isAvailable = idx < avail;
        return StallData(
          stallNumber: idx + 1,
          status: isAvailable ? 'Available' : 'In Use',
          socPercent: isAvailable ? null : (55 + ((idx * 13) % 40)),
          minutesRemaining: isAvailable ? null : (6 + ((idx * 9) % 25)),
          powerKW: st.power,
          connector: st.connectorType,
        );
      }),
    );
  }
}

class ChargingStationsScreen extends StatefulWidget {
  const ChargingStationsScreen({super.key});

  @override
  State<ChargingStationsScreen> createState() => _ChargingStationsScreenState();
}

class _ChargingStationsScreenState extends State<ChargingStationsScreen> {
  int _selectedFilterIndex = 0;
  String _selectedStationId = '1';
  String? _activeNavigationStationId;
  String? _reservedStationId;
  int? _reservedStallNumber;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter options matching the screenshot
  final List<String> filters = ['All', 'Fast', 'Medium', 'Slow'];

  // Advanced filter criteria
  bool _onlyAvailable = false;
  double _minPowerKW = 0.0;
  String _selectedConnector = 'All';

  // Curated fallback stations
  static const List<StationData> _defaultStations = [
    StationData(
      id: '1',
      name: 'GreenCharge Station',
      distance: '1.2 km',
      availability: '2/4 Available',
      power: 'DC Fast (120 kW)',
      isFast: true,
      rating: 4.8,
      reviews: 128,
      address: '1.2 km • Open 24/7',
      connectorType: 'CCS2',
      waitTimeMinutes: 0,
      plugScore: 98,
      operatorName: 'ChargeZone Superfast',
      imageUrls: [
        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1200&q=80',
      ],
      amenities: ['Café', 'Restrooms', 'Free Wi-Fi', '24/7 Security'],
      stalls: [
        StallData(
          stallNumber: 1,
          status: 'Available',
          powerKW: '120 kW',
          connector: 'CCS2',
        ),
        StallData(
          stallNumber: 2,
          status: 'In Use',
          socPercent: 82,
          minutesRemaining: 6,
          powerKW: '120 kW',
          connector: 'CCS2',
        ),
        StallData(
          stallNumber: 3,
          status: 'Available',
          powerKW: '120 kW',
          connector: 'CCS2',
        ),
        StallData(
          stallNumber: 4,
          status: 'Maintenance',
          powerKW: '120 kW',
          connector: 'Type 2',
        ),
      ],
      pricePerKWh: 18.0,
      isVehicleCompatible: true,
      arrivalSoC: 18,
    ),
    StationData(
      id: '2',
      name: 'City Mall Charging Hub',
      distance: '3.4 km',
      availability: '1/4 Available',
      power: 'AC (22 kW)',
      isFast: false,
      rating: 4.5,
      reviews: 84,
      address: '3.4 km • Open 10 AM - 11 PM',
      connectorType: 'Type 2',
      waitTimeMinutes: 8,
      plugScore: 94,
      operatorName: 'Tata Power EZ Charge',
      imageUrls: [
        'https://images.unsplash.com/photo-1558441719-8b489c63f70b?auto=format&fit=crop&w=1200&q=80',
      ],
      amenities: [
        'Mall Food Court',
        'Restrooms',
        'Free Wi-Fi',
        'Convenience Store',
      ],
      stalls: [
        StallData(
          stallNumber: 1,
          status: 'In Use',
          socPercent: 65,
          minutesRemaining: 18,
          powerKW: '22 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 2,
          status: 'Available',
          powerKW: '22 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 3,
          status: 'In Use',
          socPercent: 91,
          minutesRemaining: 8,
          powerKW: '22 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 4,
          status: 'In Use',
          socPercent: 44,
          minutesRemaining: 32,
          powerKW: '22 kW',
          connector: 'Type 2',
        ),
      ],
      pricePerKWh: 12.0,
      isVehicleCompatible: true,
      arrivalSoC: 14,
    ),
    StationData(
      id: '3',
      name: 'Riverside Station',
      distance: '4.1 km',
      availability: '2/4 Available',
      power: 'DC Fast (150 kW)',
      isFast: true,
      rating: 4.9,
      reviews: 210,
      address: '4.1 km • Open 24/7',
      connectorType: 'CCS2',
      waitTimeMinutes: 0,
      plugScore: 99,
      operatorName: 'Jio-BP Pulse',
      imageUrls: [
        'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=1200&q=80',
      ],
      amenities: ['Café', 'Restrooms', 'Scenic Park', '24/7 Security'],
      stalls: [
        StallData(
          stallNumber: 1,
          status: 'Available',
          powerKW: '150 kW',
          connector: 'CCS2',
        ),
        StallData(
          stallNumber: 2,
          status: 'In Use',
          socPercent: 74,
          minutesRemaining: 11,
          powerKW: '150 kW',
          connector: 'CCS2',
        ),
        StallData(
          stallNumber: 3,
          status: 'Available',
          powerKW: '150 kW',
          connector: 'CCS2',
        ),
        StallData(
          stallNumber: 4,
          status: 'In Use',
          socPercent: 88,
          minutesRemaining: 5,
          powerKW: '150 kW',
          connector: 'CCS2',
        ),
      ],
      pricePerKWh: 19.5,
      isVehicleCompatible: true,
      arrivalSoC: 12,
    ),
    StationData(
      id: '4',
      name: 'Tech Park Station',
      distance: '5.2 km',
      availability: '3/6 Available',
      power: 'AC (11 kW)',
      isFast: false,
      rating: 4.6,
      reviews: 62,
      address: '5.2 km • Open 24/7',
      connectorType: 'Type 2',
      waitTimeMinutes: 0,
      plugScore: 96,
      operatorName: 'Zeon Charging',
      imageUrls: [
        'https://images.unsplash.com/photo-1571127236794-81c0bbfe1ce3?auto=format&fit=crop&w=1200&q=80',
      ],
      amenities: [
        'Tech Park Cafeteria',
        'Restrooms',
        'Free Wi-Fi',
        '24/7 Security',
      ],
      stalls: [
        StallData(
          stallNumber: 1,
          status: 'Available',
          powerKW: '11 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 2,
          status: 'Available',
          powerKW: '11 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 3,
          status: 'Available',
          powerKW: '11 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 4,
          status: 'In Use',
          socPercent: 79,
          minutesRemaining: 14,
          powerKW: '11 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 5,
          status: 'In Use',
          socPercent: 52,
          minutesRemaining: 36,
          powerKW: '11 kW',
          connector: 'Type 2',
        ),
        StallData(
          stallNumber: 6,
          status: 'In Use',
          socPercent: 93,
          minutesRemaining: 5,
          powerKW: '11 kW',
          connector: 'Type 2',
        ),
      ],
      pricePerKWh: 11.0,
      isVehicleCompatible: true,
      arrivalSoC: 16,
    ),
  ];

  late List<StationData> stations;
  bool _isLoadingLive = false;
  bool _isRealLocation = false;

  @override
  void initState() {
    super.initState();
    stations = List.from(_defaultStations);
    _loadLiveStations();
  }

  Future<void> _loadLiveStations({bool showFeedback = false}) async {
    if (EvMapService.isInTest) return;
    try {
      setState(() => _isLoadingLive = true);
      final result = await EvMapService.getUserLocation(requestIfNeeded: true);
      final loc = result.location;
      _isRealLocation = result.isRealLocation;

      final evList = await EvMapService.fetchNearbyStations(center: loc);
      if (evList.isNotEmpty && mounted) {
        setState(() {
          stations = evList
              .map((e) => StationData.fromEvMapStation(e))
              .toList();
          if (!stations.any((s) => s.id == _selectedStationId)) {
            _selectedStationId = stations.first.id;
          }
          _isLoadingLive = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingLive = false);
      }

      if (showFeedback && mounted) {
        if (result.isRealLocation) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Found ${stations.length} charging stations near your current location',
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
                'GPS is disabled. Turn on location services to find nearest stations.',
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
                'Location access is denied. Enable in Settings.',
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
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLive = false);
    }
  }

  List<StationData> get filteredStations {
    return stations.where((station) {
      // 1. Filter Chips (All, Fast, Medium, Slow)
      if (_selectedFilterIndex == 1 && !station.isFast) return false;
      if (_selectedFilterIndex == 2 &&
          !(station.power.contains('22') || station.power.contains('Medium'))) {
        return false;
      }
      if (_selectedFilterIndex == 3 &&
          !(station.power.contains('11') || station.power.contains('Slow'))) {
        return false;
      }

      // 2. Advanced modal filter criteria
      if (_onlyAvailable && station.availability.startsWith('0/')) return false;
      if (_selectedConnector != 'All' &&
          station.connectorType != _selectedConnector) {
        return false;
      }
      if (_minPowerKW > 0) {
        final kwMatch = RegExp(r'(\d+)\s*kW').firstMatch(station.power);
        if (kwMatch != null) {
          final kw = double.tryParse(kwMatch.group(1) ?? '0') ?? 0;
          if (kw < _minPowerKW) return false;
        }
      }

      return true;
    }).toList();
  }

  void _startNavigation(StationData station) {
    setState(() {
      if (_activeNavigationStationId == station.id) {
        _activeNavigationStationId = null;
      } else {
        _activeNavigationStationId = station.id;
        _selectedStationId = station.id;
      }
    });

    if (_activeNavigationStationId != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0B2138),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cyan, width: 1),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Route calculated to ${station.name} (${station.distance})',
                  style: GoogleFonts.outfit(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showHoldStallModal(StationData station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassContainer(
              isTransparent: true,
              borderRadius: 24,
              borderColor: AppColors.cyan,
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hold Stall (15 Min Grace)',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              station.name,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.cyan,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Vehicle Compatibility pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.green.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tesla Model 3 • ${station.connectorType} Compatible (${station.power})',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select an Available Stall to Lock:',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...station.stalls.map((stall) {
                    final isThisReserved =
                        _reservedStationId == station.id &&
                        _reservedStallNumber == stall.stallNumber;
                    final isAvailable = stall.status == 'Available';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isThisReserved
                            ? AppColors.cyan.withValues(alpha: 0.15)
                            : AppColors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isThisReserved
                              ? AppColors.cyan
                              : (isAvailable
                                    ? AppColors.cyanBorder
                                    : AppColors.borderSubtle),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isThisReserved
                                  ? AppColors.cyan
                                  : (isAvailable
                                        ? AppColors.green.withValues(alpha: 0.2)
                                        : Colors.white10),
                            ),
                            child: Center(
                              child: Text(
                                '#${stall.stallNumber}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isThisReserved
                                      ? Colors.black
                                      : (isAvailable
                                            ? AppColors.green
                                            : Colors.white60),
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
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: isThisReserved
                                            ? AppColors.cyan.withValues(
                                                alpha: 0.2,
                                              )
                                            : (isAvailable
                                                  ? AppColors.green.withValues(
                                                      alpha: 0.15,
                                                    )
                                                  : (stall.status == 'In Use'
                                                        ? Colors.amber
                                                              .withValues(
                                                                alpha: 0.15,
                                                              )
                                                        : Colors.red.withValues(
                                                            alpha: 0.15,
                                                          ))),
                                      ),
                                      child: Text(
                                        isThisReserved
                                            ? 'Reserved (14m)'
                                            : (stall.status == 'In Use'
                                                  ? 'In Use (${stall.socPercent}%)'
                                                  : stall.status),
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isThisReserved
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
                                    stall.minutesRemaining != null)
                                  Text(
                                    'Est. finishes in ~${stall.minutesRemaining} mins',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isThisReserved)
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  _reservedStationId = null;
                                  _reservedStallNumber = null;
                                });
                                setState(() {
                                  _reservedStationId = null;
                                  _reservedStallNumber = null;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reservation released.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.outfit(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (isAvailable)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyan,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  _reservedStationId = station.id;
                                  _reservedStallNumber = stall.stallNumber;
                                });
                                setState(() {
                                  _reservedStationId = station.id;
                                  _reservedStallNumber = stall.stallNumber;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF0B2138),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: AppColors.cyan,
                                      ),
                                    ),
                                    content: Text(
                                      'Stall #${stall.stallNumber} held for 15 mins at ${station.name}',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Hold 15m',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
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
          },
        );
      },
    );
  }

  Widget _buildVehicleMatchBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF071B2D).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cyan.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.electric_car_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Tesla Model 3 • CCS2 Ready',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '100% Station Match',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Supports up to 250 kW DC Fast Charging • Pre-conditioning enabled',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassContainer(
              isTransparent: true,
              borderRadius: 24,
              borderColor: AppColors.cyan,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Charging Stations',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 12),

                  // Only available switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.cyan,
                    title: Text(
                      'Show Available Only',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Hide stations with 0 available ports',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _onlyAvailable,
                    onChanged: (val) {
                      setModalState(() => _onlyAvailable = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  // Connector Type
                  Text(
                    'Connector Type',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'CCS2', 'Type 2', 'CHAdeMO'].map((type) {
                      final isSel = _selectedConnector == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSel,
                        selectedColor: AppColors.cyan,
                        backgroundColor: AppColors.surfaceLight,
                        labelStyle: GoogleFonts.outfit(
                          color: isSel ? Colors.black : Colors.white70,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedConnector = type);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Min Power kW Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minimum Power',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _minPowerKW == 0
                            ? 'Any Power'
                            : '${_minPowerKW.toInt()} kW+',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _minPowerKW,
                    min: 0,
                    max: 150,
                    divisions: 6,
                    activeColor: AppColors.cyan,
                    inactiveColor: AppColors.surfaceLight,
                    onChanged: (val) {
                      setModalState(() => _minPowerKW = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _onlyAvailable = false;
                              _selectedConnector = 'All';
                              _minPowerKW = 0.0;
                            });
                            setState(() {});
                          },
                          child: Text(
                            'Reset',
                            style: GoogleFonts.outfit(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;

    void onNavSelected(int index) {
      AppRouter.navigate(context, index, AppRoutes.stations);
    }

    final currentStations = filteredStations;

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
                  onNavSelected(index);
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
              onItemSelected: onNavSelected,
            )
          else if (isTablet)
            SidebarNavigation(
              isCollapsed: true,
              selectedIndex: AppRoutes.stations,
              onItemSelected: onNavSelected,
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.stations,
                  showMenuButton: !isDesktop && !isTablet,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),

                Expanded(
                  child: isDesktop
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Title
                              Row(
                                children: [
                                  Text(
                                    'Charging Stations',
                                    style: GoogleFonts.outfit(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.green.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6.5,
                                          height: 6.5,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _isLoadingLive
                                              ? 'Syncing OCM Live...'
                                              : 'OCM Live Network',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Tooltip(
                                    message: 'Find Stations Near My Current Location',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () =>
                                          _loadLiveStations(showFeedback: true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _isRealLocation
                                                ? AppColors.green
                                                : AppColors.cyanBorder,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.my_location_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _isRealLocation
                                                  ? 'Current Location Active'
                                                  : 'Locate Me',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Vehicle Compatibility Match Banner
                              _buildVehicleMatchBanner(),

                              // Filter Bar matching screenshot
                              _buildFilterBar(),
                              const SizedBox(height: 18),

                              // Split View: Map (Left) & Station Cards List (Right)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Workable Map Canvas
                                  Expanded(
                                    flex: 5,
                                    child: SizedBox(
                                      height: 540,
                                      child: StationMapCanvas(
                                        selectedStationId: _selectedStationId,
                                        activeNavigationStationId:
                                            _activeNavigationStationId,
                                        visibleStationIds: currentStations
                                            .map((s) => s.id)
                                            .toList(),
                                        onStationSelected: (id) {
                                          setState(
                                            () => _selectedStationId = id,
                                          );
                                        },
                                        onStartNavigation: (id) {
                                          final st = stations.firstWhere(
                                            (s) => s.id == id,
                                            orElse: () => stations[0],
                                          );
                                          _startNavigation(st);
                                        },
                                        onOpenStationDetails: (id) {
                                          final st = stations.firstWhere(
                                            (s) => s.id == id,
                                            orElse: () => stations[0],
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  StationDetailsScreen(
                                                    station: st,
                                                  ),
                                            ),
                                          );
                                        },
                                        onCancelNavigation: () {
                                          setState(
                                            () => _activeNavigationStationId =
                                                null,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),

                                  // Right: Station Cards List
                                  Expanded(
                                    flex: 5,
                                    child: _buildStationsList(currentStations),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Charging Stations',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.green.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5.5,
                                          height: 5.5,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _isLoadingLive
                                              ? 'Syncing...'
                                              : 'Live OCM',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.my_location_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    tooltip: 'Locate Me',
                                    onPressed: () =>
                                        _loadLiveStations(showFeedback: true),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildFilterBar(),
                              const SizedBox(height: 12),

                              // Mobile: Interactive Map with Draggable Bottom Sheet & floating match badge
                              Expanded(
                                child: Stack(
                                  children: [
                                    // 1. Map Canvas
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: StationMapCanvas(
                                          selectedStationId: _selectedStationId,
                                          activeNavigationStationId:
                                              _activeNavigationStationId,
                                          visibleStationIds: currentStations
                                              .map((s) => s.id)
                                              .toList(),
                                          onStationSelected: (id) {
                                            setState(
                                              () => _selectedStationId = id,
                                            );
                                          },
                                          onStartNavigation: (id) {
                                            final st = stations.firstWhere(
                                              (s) => s.id == id,
                                              orElse: () => stations[0],
                                            );
                                            _startNavigation(st);
                                          },
                                          onOpenStationDetails: (id) {
                                            final st = stations.firstWhere(
                                              (s) => s.id == id,
                                              orElse: () => stations[0],
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    StationDetailsScreen(
                                                      station: st,
                                                    ),
                                              ),
                                            );
                                          },
                                          onCancelNavigation: () {
                                            setState(
                                              () => _activeNavigationStationId =
                                                  null,
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // 2. Floating Vehicle Compatibility Pill
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF07192A)
                                              .withValues(alpha: 0.92),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.cyan.withValues(
                                              alpha: 0.4,
                                            ),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.bolt_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Tesla Model 3 • CCS2 Ready',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${currentStations.length} Nearby',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: AppColors.cyan,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 3. Draggable Scrollable Sheet
                                    DraggableScrollableSheet(
                                      initialChildSize: 0.36,
                                      minChildSize: 0.18,
                                      maxChildSize: 0.88,
                                      builder: (context, scrollController) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF071929)
                                                .withValues(alpha: 0.96),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                            border: Border.all(
                                              color: AppColors.cyanBorder,
                                              width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                blurRadius: 16,
                                                offset: const Offset(0, -4),
                                              ),
                                            ],
                                          ),
                                          child: ListView(
                                            controller: scrollController,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            children: [
                                              // Drag handle
                                              Center(
                                                child: Container(
                                                  width: 36,
                                                  height: 4,
                                                  margin: const EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.cyan
                                                        .withValues(alpha: 0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Nearby Stations (${currentStations.length})',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Swipe up to expand',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10.5,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ...currentStations.map((station) {
                                                final isSelected =
                                                    station.id ==
                                                    _selectedStationId;
                                                final isNavigating =
                                                    station.id ==
                                                    _activeNavigationStationId;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8,
                                                      ),
                                                  child: StationListCard(
                                                    name: station.name,
                                                    distance: station.distance,
                                                    availability:
                                                        station.availability,
                                                    power: station.power,
                                                    isFast: station.isFast,
                                                    isSelected: isSelected,
                                                    isNavigating: isNavigating,
                                                    waitTimeMinutes:
                                                        station.waitTimeMinutes,
                                                    plugScore:
                                                        station.plugScore,
                                                    onHoldStall: () =>
                                                        _showHoldStallModal(
                                                          station,
                                                        ),
                                                    onTap: () {
                                                      setState(
                                                        () =>
                                                            _selectedStationId =
                                                                station.id,
                                                      );
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              StationDetailsScreen(
                                                                station:
                                                                    station,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    onNavigate: () =>
                                                        _startNavigation(
                                                          station,
                                                        ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          // Filter Chips (All, Fast, Medium, Slow)
          ...List.generate(filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _selectedFilterIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? AppColors.cyan
                        : const Color(0xFF081C2E).withValues(alpha: 0.7),
                    border: Border.all(
                      color: isSelected ? AppColors.cyan : AppColors.cyanBorder,
                      width: 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filters[index],
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.3,
                      color: isSelected
                          ? const Color(0xFF04101A)
                          : AppColors.cyan,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),

          // Filter Button with Funnel Icon (matching screenshot)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _showFilterModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF081C2E).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cyanBorder, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyan,
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

  Widget _buildStationsList(List<StationData> stationList) {
    if (stationList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No charging stations match your filter criteria.',
            style: GoogleFonts.outfit(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stationList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final station = stationList[index];
        final isSelected = station.id == _selectedStationId;
        final isNavigating = station.id == _activeNavigationStationId;

        return StationListCard(
          name: station.name,
          distance: station.distance,
          availability: station.availability,
          power: station.power,
          isFast: station.isFast,
          isSelected: isSelected,
          isNavigating: isNavigating,
          waitTimeMinutes: station.waitTimeMinutes,
          plugScore: station.plugScore,
          onHoldStall: () => _showHoldStallModal(station),
          onTap: () {
            setState(() => _selectedStationId = station.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StationDetailsScreen(station: station),
              ),
            );
          },
          onNavigate: () => _startNavigation(station),
        );
      },
    );
  }
}
