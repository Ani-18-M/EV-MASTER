import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';

class EnergyUsageScreen extends StatefulWidget {
  const EnergyUsageScreen({super.key});

  @override
  State<EnergyUsageScreen> createState() => _EnergyUsageScreenState();
}

class _EnergyUsageScreenState extends State<EnergyUsageScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedPeriod = 'Weekly';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  late AnimationController _entryController;
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _entryController.forward();
    _chartController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _onMenuPressed() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.energy);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.energy,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _onNavSelected(index);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SidebarNavigation(
              selectedIndex: AppRoutes.energy,
              isCollapsed: !isDesktop,
              onItemSelected: _onNavSelected,
            ),
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.energy,
                  showMenuButton: isMobile,
                  onMenuPressed: _onMenuPressed,
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _entryController,
                    builder: (context, child) {
                      return ListView(
                        padding: const EdgeInsets.all(24.0),
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildChartSection()),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildVehicleBreakdown(),
                                      const SizedBox(height: 24),
                                      _buildEfficiencyTrend(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildChartSection(),
                                const SizedBox(height: 24),
                                _buildVehicleBreakdown(),
                                const SizedBox(height: 24),
                                _buildEfficiencyTrend(),
                              ],
                            ),
                          const SizedBox(height: 32),
                          _buildStartSessionButton(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.0, 0.2),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.0, 0.2),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Energy Usage',
              style: AppTypography.display().copyWith(fontSize: 28),
            ),
            Row(
              children: _periods.map((period) {
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                    _chartController.forward(from: 0);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.cyan
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      period,
                      style: AppTypography.button().copyWith(
                        color: isSelected
                            ? AppColors.cyan
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.2, 0.4),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.2, 0.4),
              ),
            ),
        child: GlassContainer(
          metallicStyle: MetallicStyle.cyan,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total kWh this week',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF032B3D),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '49.6',
                    style: GoogleFonts.orbitron(
                      fontSize: 36,
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
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'kWh',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF032B3D),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cost: \$14.88',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                      Text(
                        'Sessions: 7',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF032B3D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _BarChartPainter(
                    animation: _chartController,
                    data: [6.2, 8.5, 4.8, 7.1, 9.3, 7.7, 5.6],
                    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  ),
                  child: Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleBreakdown() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.4, 0.6),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.4, 0.6),
              ),
            ),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Breakdown',
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
              const SizedBox(height: 16),
              _buildProgressRow('Tesla Model 3', 24.6, 0.58, AppColors.cyan),
              const SizedBox(height: 16),
              _buildProgressRow('BYD Atto 3', 18.1, 0.37, AppColors.green),
              const SizedBox(height: 16),
              _buildProgressRow('Hyundai IONIQ 5', 6.9, 0.15, AppColors.amber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    String title,
    double value,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} kWh (${(percentage * 100).toInt()}%)',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFCBD5E1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyTrend() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.6, 0.8),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.6, 0.8),
              ),
            ),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Efficiency Trend',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Avg Session',
                      '7.1 kWh',
                      const Color(0xFF004D61),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'Peak (Fri)',
                      '9.3 kWh',
                      const Color(0xFF854D0E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'Saved vs ICE',
                      '68%',
                      const Color(0xFF006622),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.8, 1.0),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.8, 1.0),
              ),
            ),
        child: CyanButton(
          text: 'Start New Session',
          icon: Icons.flash_on,
          onPressed: () {
            AppRouter.navigate(context, AppRoutes.stations, AppRoutes.energy);
          },
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Animation<double> animation;
  final List<double> data;
  final List<String> labels;

  _BarChartPainter({
    required this.animation,
    required this.data,
    required this.labels,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double maxData = data.reduce((a, b) => a > b ? a : b);
    final int barCount = data.length;
    final double barWidth = size.width / (barCount * 2);
    final double spacing = barWidth;

    final Paint barPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final double x = spacing + (i * (barWidth + spacing));
      final double targetHeight = (data[i] / maxData) * size.height * 0.8;
      final double currentHeight = targetHeight * animation.value;
      final double y =
          size.height - currentHeight - 30; // Leave room for labels

      if (data[i] == maxData) {
        barPaint.shader = LinearGradient(
          colors: [AppColors.cyan, AppColors.cyanDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, currentHeight));
      } else {
        barPaint.shader = null;
        barPaint.color = const Color(0xFF0F2B3E).withValues(alpha: 0.35);
      }

      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, currentHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      final TextSpan span = TextSpan(
        style: GoogleFonts.outfit(
          color: const Color(0xFF032B3D),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        text: labels[i],
      );
      final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
