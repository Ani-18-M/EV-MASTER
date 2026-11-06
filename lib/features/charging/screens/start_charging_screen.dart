import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../stations/screens/charging_stations_screen.dart';

import 'dart:math' as math;

class StartChargingScreen extends StatefulWidget {
  final StationData station;

  const StartChargingScreen({super.key, required this.station});

  @override
  State<StartChargingScreen> createState() => _StartChargingScreenState();
}

enum ChargingState { connecting, charging, complete }

class _StartChargingScreenState extends State<StartChargingScreen>
    with TickerProviderStateMixin {
  ChargingState _currentState = ChargingState.connecting;

  late final AnimationController _pulseController;
  late final AnimationController _successController;

  double _currentSoc = 47.0;
  final double _targetSoc = 80.0;

  int _elapsedSeconds = 0;
  double _energyAdded = 0.0;
  double _power = 0.0;
  double _cost = 0.0;

  Timer? _timer;
  Timer? _initTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _initTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentState = ChargingState.charging;
          _startChargingSimulation();
        });
      }
    });
  }

  void _startChargingSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        _energyAdded += 0.5;
        _power = 120.0 + (math.Random().nextDouble() * 10 - 5);
        _cost = _energyAdded * 0.35;

        _currentSoc += 0.8;
        if (_currentSoc >= _targetSoc) {
          _currentSoc = _targetSoc;
          _finishCharging();
        }
      });
    });
  }

  void _finishCharging() {
    _timer?.cancel();
    setState(() {
      _currentState = ChargingState.complete;
    });
    _successController.forward();
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    _pulseController.dispose();
    _successController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadarPulsePainter(_pulseController.value),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.station.name,
            style: AppTypography.heading(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.station.address,
            style: AppTypography.body(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Connecting to charger...',
                style: AppTypography.body(color: AppColors.cyan),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cyanBorder),
            ),
            child: Text(
              'Stall #4 Selected',
              style: AppTypography.body(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.button(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: _GaugePainter(progress: _currentSoc / 100),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_currentSoc.toInt()}%',
                      style: AppTypography.digital(
                        fontSize: 48,
                        color: AppColors.cyan,
                      ),
                    ),
                    Text(
                      'Charging',
                      style: AppTypography.body(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLiveStat('Elapsed', _formatTime(_elapsedSeconds)),
              _buildLiveStat('Added', '${_energyAdded.toStringAsFixed(1)} kWh'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLiveStat('Power', '${_power.toStringAsFixed(0)} kW'),
              _buildLiveStat('Cost', '\$${_cost.toStringAsFixed(2)}'),
            ],
          ),
          const Spacer(),
          GlassContainer(
            metallicStyle: MetallicStyle.cyan,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E2736),
                  ),
                  child: const Icon(
                    Icons.ev_station,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.station.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
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
                      const SizedBox(height: 4),
                      Text(
                        'Stall #4 • CCS 150kW',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF032B3D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              _finishCharging();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Stop Charging',
              style: AppTypography.button(color: AppColors.red),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLiveStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.digital(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.body(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCompleteState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _successController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.green, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 64),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Charging Complete!',
            style: AppTypography.heading(fontSize: 28, color: AppColors.green),
          ),
          const SizedBox(height: 48),
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildFinalStatRow(
                  'Total Energy',
                  '${_energyAdded.toStringAsFixed(1)} kWh',
                ),
                const Divider(color: Color(0xFF94A3B8), height: 24),
                _buildFinalStatRow('Time', _formatTime(_elapsedSeconds)),
                const Divider(color: Color(0xFF94A3B8), height: 24),
                _buildFinalStatRow('Final SOC', '${_currentSoc.toInt()}%'),
                const Divider(color: Color(0xFF94A3B8), height: 24),
                _buildFinalStatRow(
                  'Total Cost',
                  '\$${_cost.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Show receipt modal (mock)
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    side: const BorderSide(color: AppColors.cyan),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('View Receipt', style: AppTypography.button()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CyanButton(
                  text: 'Done',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStatRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isTotal ? const Color(0xFF0F172A) : const Color(0xFF334155),
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTotal ? 15 : 13.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.w800,
            color: isTotal ? const Color(0xFF004D61) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentState == ChargingState.connecting
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _currentState == ChargingState.connecting
              ? _buildConnectingState()
              : _currentState == ChargingState.charging
              ? _buildChargingState()
              : _buildCompleteState(),
        ),
      ),
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;

  _RadarPulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final p = (progress + (i * 0.33)) % 1.0;
      final radius = maxRadius * p;
      final opacity = 1.0 - p;

      final paint = Paint()
        ..color = AppColors.cyan.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);

      final fillPaint = Paint()
        ..color = AppColors.cyan.withValues(alpha: opacity * 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;

  _GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final startAngle = math.pi * 0.75;
    final sweepAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    final gradient = SweepGradient(
      colors: [AppColors.cyan, AppColors.cyan.withValues(alpha: 0.5)],
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
    );

    final fgPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
