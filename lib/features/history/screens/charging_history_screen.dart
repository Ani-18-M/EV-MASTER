import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class SessionData {
  final String dateStr;
  final String dayStr;
  final String monthStr;
  final String stationName;
  final String address;
  final String duration;
  final double kwh;
  final double cost;
  final String connectorInfo;
  final String status;

  const SessionData({
    required this.dateStr,
    required this.dayStr,
    required this.monthStr,
    required this.stationName,
    required this.address,
    required this.duration,
    required this.kwh,
    required this.cost,
    required this.connectorInfo,
    required this.status,
  });
}

const List<SessionData> _mockSessions = [
  SessionData(
    dateStr: 'Oct 9',
    dayStr: '09',
    monthStr: 'OCT',
    stationName: 'Downtown EV Hub',
    address: 'San Francisco, CA',
    duration: '45min',
    kwh: 28.4,
    cost: 8.52,
    connectorInfo: 'CCS 50kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Oct 7',
    dayStr: '07',
    monthStr: 'OCT',
    stationName: 'Palo Alto Supercharger',
    address: 'Palo Alto, CA',
    duration: '1h12min',
    kwh: 52.1,
    cost: 15.63,
    connectorInfo: 'Tesla 150kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Oct 5',
    dayStr: '05',
    monthStr: 'OCT',
    stationName: 'SF Marina ChargePoint',
    address: 'San Francisco, CA',
    duration: '32min',
    kwh: 18.7,
    cost: 5.61,
    connectorInfo: 'J1772 22kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Oct 3',
    dayStr: '03',
    monthStr: 'OCT',
    stationName: 'Oakland EVgo',
    address: 'Oakland, CA',
    duration: '28min',
    kwh: 21.3,
    cost: 6.39,
    connectorInfo: 'CCS 100kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Oct 1',
    dayStr: '01',
    monthStr: 'OCT',
    stationName: 'Home Charger',
    address: 'Home',
    duration: '6h30min',
    kwh: 42.0,
    cost: 8.40,
    connectorInfo: 'Level 2',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Sep 28',
    dayStr: '28',
    monthStr: 'SEP',
    stationName: 'Downtown EV Hub',
    address: 'San Francisco, CA',
    duration: '50min',
    kwh: 30.1,
    cost: 9.03,
    connectorInfo: 'CCS 50kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Sep 24',
    dayStr: '24',
    monthStr: 'SEP',
    stationName: 'Palo Alto Supercharger',
    address: 'Palo Alto, CA',
    duration: '40min',
    kwh: 35.0,
    cost: 10.50,
    connectorInfo: 'Tesla 150kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Sep 21',
    dayStr: '21',
    monthStr: 'SEP',
    stationName: 'SF Marina ChargePoint',
    address: 'San Francisco, CA',
    duration: '1h05min',
    kwh: 45.2,
    cost: 13.56,
    connectorInfo: 'J1772 22kW',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Sep 18',
    dayStr: '18',
    monthStr: 'SEP',
    stationName: 'Home Charger',
    address: 'Home',
    duration: '7h10min',
    kwh: 48.0,
    cost: 9.60,
    connectorInfo: 'Level 2',
    status: 'Complete',
  ),
  SessionData(
    dateStr: 'Sep 15',
    dayStr: '15',
    monthStr: 'SEP',
    stationName: 'Oakland EVgo',
    address: 'Oakland, CA',
    duration: '15min',
    kwh: 12.5,
    cost: 3.75,
    connectorInfo: 'CCS 100kW',
    status: 'Complete',
  ),
];

class ChargingHistoryScreen extends StatefulWidget {
  const ChargingHistoryScreen({super.key});

  @override
  State<ChargingHistoryScreen> createState() => _ChargingHistoryScreenState();
}

class _ChargingHistoryScreenState extends State<ChargingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'This Week', 'This Month', 'This Year'];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _onFilterChanged(int index) {
    if (_selectedFilterIndex != index) {
      setState(() {
        _selectedFilterIndex = index;
      });
      _staggerController.reset();
      _staggerController.forward();
    }
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => _onFilterChanged(index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyan.withValues(alpha: 0.2)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? AppColors.cyan
                  : AppColors.cyanBorder.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTypography.body(
              color: isSelected ? AppColors.cyan : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return GlassContainer(
      metallicStyle: MetallicStyle.cyan,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('Total Sessions', '47'),
          _buildSummaryStat('Total kWh', '284.3'),
          _buildSummaryStat('Total Cost', '\$142.80'),
          _buildSummaryStat('Avg/session', '\$3.04'),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
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
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF032B3D),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionData session, int index) {
    final startDelay = index * 0.1;
    final curve = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(
        startDelay.clamp(0.0, 1.0),
        (startDelay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.cyanBorder.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      session.dayStr,
                      style: AppTypography.heading(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      session.monthStr,
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppColors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            session.stationName,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
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
                        ),
                        Text(
                          session.status,
                          style: GoogleFonts.outfit(
                            color: session.status == 'Complete'
                                ? const Color(0xFF006622)
                                : const Color(0xFF00495C),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.address,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(Icons.timer_outlined, session.duration),
                        _buildBadge(
                          Icons.electric_bolt_outlined,
                          '${session.kwh} kWh',
                        ),
                        _buildBadge(
                          Icons.attach_money_outlined,
                          '\$${session.cost.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.connectorInfo,
                      style: AppTypography.body(
                        color: AppColors.cyan,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cyanBorder.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.body(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You\'ve saved ~\$68 vs equivalent gasoline',
              style: AppTypography.body(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charging History',
              style: AppTypography.heading(fontSize: 20),
            ),
            Text(
              'All sessions',
              style: AppTypography.body(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _filters.length,
                  (index) => _buildFilterChip(index, _filters[index]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryBar(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _mockSessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionCard(_mockSessions[index], index);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSavingsBanner(),
          ],
        ),
      ),
    );
  }
}
