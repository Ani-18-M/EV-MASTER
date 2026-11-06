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
];

class VehicleChargingHistoryScreen extends StatefulWidget {
  final String vehicleName;

  const VehicleChargingHistoryScreen({super.key, required this.vehicleName});

  @override
  State<VehicleChargingHistoryScreen> createState() =>
      _VehicleChargingHistoryScreenState();
}

class _VehicleChargingHistoryScreenState
    extends State<VehicleChargingHistoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _chartController;
  late final AnimationController _staggerController;
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ['Week', 'Month', 'Year'];

  final List<double> _weekData = [10.5, 25.0, 15.2, 45.0, 20.0, 60.5, 30.2];

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chartController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onPeriodChanged(int index) {
    if (_selectedPeriodIndex != index) {
      setState(() {
        _selectedPeriodIndex = index;
      });
      _chartController.reset();
      _chartController.forward();
      _staggerController.reset();
      _staggerController.forward();
    }
  }

  Widget _buildVehicleMiniCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 0.78,
                  backgroundColor: Color(0xFF1E2736),
                  color: AppColors.cyan,
                  strokeWidth: 4,
                ),
                Text(
                  '78%',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.vehicleName,
                style: GoogleFonts.outfit(
                  fontSize: 18,
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
              const SizedBox(height: 4),
              Text(
                'Last charged: Today, 8:45 AM',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyanBorder.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onPeriodChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cyan.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _periods[index],
                  style: AppTypography.body(
                    color: isSelected ? AppColors.cyan : AppColors.textMuted,
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Sessions', '12'),
        _buildStatItem('kWh', '184.2'),
        _buildStatItem('Cost', '\$42.50'),
        _buildStatItem('Avg/session', '\$3.54'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading(color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.body(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return GlassContainer(
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Energy Added (kWh)',
            style: GoogleFonts.outfit(
              fontSize: 14,
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
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LineChartPainter(
                    data: _weekData,
                    progress: _chartController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mon',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tue',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Wed',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Thu',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Fri',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Sat',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Sun',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
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
                  color: const Color(0xFF1E2736),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.cyanBorder.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      session.dayStr,
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      session.monthStr,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          session.status,
                          style: GoogleFonts.outfit(
                            color: session.status == 'Complete'
                                ? const Color(0xFF006622)
                                : const Color(0xFF004D61),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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
        color: const Color(0xFF1E2736),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF004D61).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
        title: Text(
          '${widget.vehicleName} History',
          style: AppTypography.heading(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleMiniCard(),
            const SizedBox(height: 24),
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildChart(),
            const SizedBox(height: 24),
            Text('Recent Sessions', style: AppTypography.heading(fontSize: 18)),
            const SizedBox(height: 16),
            ...List.generate(
              _mockSessions.length,
              (index) => _buildSessionCard(_mockSessions[index], index),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;

  _LineChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final maxVal = 100.0;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxVal) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (data[i - 1] / maxVal) * size.height;
        final cp1x = prevX + stepX / 2;
        final cp2x = prevX + stepX / 2;
        path.cubicTo(cp1x, prevY, cp2x, y, x, y);
      }
    }

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final extractPath = metric.extractPath(0.0, metric.length * progress);

    canvas.drawPath(extractPath, paintLine);

    if (progress == 1.0) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cyan.withValues(alpha: 0.2),
          AppColors.cyan.withValues(alpha: 0.0),
        ],
      );

      final paintFill = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, paintFill);

      final dotPaint = Paint()
        ..color = AppColors.cyan
        ..style = PaintingStyle.fill;

      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final y = size.height - (data[i] / maxVal) * size.height;
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
