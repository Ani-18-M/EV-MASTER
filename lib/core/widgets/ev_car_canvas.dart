import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Renders a sleek, vector-based futuristic EV sedan and charging pillar
/// with cyber glow, headlights, neon reflections, and cable.
class EvCarIllustration extends StatelessWidget {
  final double height;
  final bool showStation;
  final bool compact;

  const EvCarIllustration({
    super.key,
    this.height = 280,
    this.showStation = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _EvCarPainter(showStation: showStation, compact: compact),
        size: Size.infinite,
      ),
    );
  }
}

class _EvCarPainter extends CustomPainter {
  final bool showStation;
  final bool compact;

  _EvCarPainter({required this.showStation, required this.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Ambient Background Glows
    final bgGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(compact ? 0.0 : -0.2, 0.2),
        radius: 0.9,
        colors: [
          const Color(0xFF0D3256).withValues(alpha: 0.6),
          const Color(0xFF061426).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgGlowPaint);

    // 2. City Skyline Silhouette in background
    final cityPaint = Paint()
      ..color = const Color(0xFF091424).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final cityPath = Path();
    cityPath.moveTo(0, h * 0.7);
    final buildings = [
      0.05,
      0.55,
      0.12,
      0.45,
      0.18,
      0.52,
      0.25,
      0.38,
      0.32,
      0.48,
      0.40,
      0.35,
      0.48,
      0.50,
      0.56,
      0.42,
      0.65,
      0.53,
      0.72,
      0.40,
      0.80,
      0.47,
      0.90,
      0.39,
      1.0,
      0.70,
    ];
    for (int i = 0; i < buildings.length; i += 2) {
      cityPath.lineTo(w * buildings[i], h * buildings[i + 1]);
    }
    cityPath.lineTo(w, h * 0.75);
    cityPath.lineTo(0, h * 0.75);
    cityPath.close();
    canvas.drawPath(cityPath, cityPaint);

    // Subtle yellow/cyan city window dots
    final windowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25);
    for (double wx = w * 0.1; wx < w * 0.9; wx += 24) {
      canvas.drawCircle(Offset(wx, h * 0.48), 1.2, windowPaint);
      canvas.drawCircle(Offset(wx + 8, h * 0.52), 1.0, windowPaint);
    }

    // 3. Ground / Wet Asphalt with Reflection
    final groundRect = Rect.fromLTWH(0, h * 0.72, w, h * 0.28);
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0A1320), const Color(0xFF040810)],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, groundPaint);

    // Cyan ground grid / reflection lines
    final linePaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h * 0.73), Offset(w, h * 0.73), linePaint);
    canvas.drawLine(Offset(0, h * 0.78), Offset(w, h * 0.78), linePaint);
    canvas.drawLine(Offset(0, h * 0.86), Offset(w, h * 0.86), linePaint);

    // 4. EV Charging Station Terminal (Left / Center-left)
    if (showStation) {
      final stX = w * (compact ? 0.15 : 0.20);
      final stY = h * 0.32;
      final stW = compact ? 26.0 : 34.0;
      final stH = h * 0.44;

      // Station Body
      final stRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(stX, stY, stW, stH),
        const Radius.circular(8),
      );
      final stPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF162B45), const Color(0xFF0A1422)],
        ).createShader(stRect.outerRect);
      canvas.drawRRect(stRect, stPaint);

      // Station Neon Edge
      final stBorderPaint = Paint()
        ..color = AppColors.cyan.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(stRect, stBorderPaint);

      // Station Display Screen
      final screenRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(stX + 4, stY + 12, stW - 8, 22),
        const Radius.circular(4),
      );
      final screenPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8);
      canvas.drawRRect(screenRect, screenPaint);

      // Green / Cyan status LED
      canvas.drawCircle(
        Offset(stX + stW / 2, stY + 44),
        3.0,
        Paint()..color = AppColors.green,
      );

      // Glowing Charging Cable
      final cablePath = Path();
      cablePath.moveTo(stX + stW, stY + stH * 0.65);
      final carPortX = w * (compact ? 0.48 : 0.42);
      final carPortY = h * 0.65;
      cablePath.cubicTo(
        stX + stW + 20,
        stY + stH * 0.85,
        carPortX - 25,
        h * 0.74,
        carPortX,
        carPortY,
      );
      final cablePaint = Paint()
        ..color = AppColors.cyan
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);
      canvas.drawPath(cablePath, cablePaint);
    }

    // 5. Electric Sports Car Silhouette & Body
    final carStartX = w * (compact ? 0.35 : 0.32);
    final carWidth = w * (compact ? 0.58 : 0.54);
    final carBaseY = h * 0.74;

    // Car Body Shadow & Cyan Underglow
    final underglowPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.cyan.withValues(alpha: 0.45), Colors.transparent],
        radius: 0.8,
      ).createShader(Rect.fromLTWH(carStartX, carBaseY - 10, carWidth, 30));
    canvas.drawOval(
      Rect.fromLTWH(carStartX, carBaseY - 6, carWidth, 24),
      underglowPaint,
    );

    // Sleek Streamlined Car Body Path
    final carBody = Path();
    carBody.moveTo(carStartX, carBaseY - 8); // Rear bumper
    carBody.cubicTo(
      carStartX + carWidth * 0.05,
      carBaseY - 26,
      carStartX + carWidth * 0.20,
      carBaseY - 32,
      carStartX + carWidth * 0.36,
      carBaseY - 34, // Rear window base
    );
    // Roofline / Cabin
    carBody.cubicTo(
      carStartX + carWidth * 0.45,
      carBaseY - 56, // Roof peak
      carStartX + carWidth * 0.68,
      carBaseY - 54,
      carStartX + carWidth * 0.76,
      carBaseY - 28, // Windshield to hood
    );
    // Hood & Front Nose
    carBody.cubicTo(
      carStartX + carWidth * 0.88,
      carBaseY - 24,
      carStartX + carWidth * 0.96,
      carBaseY - 18,
      carStartX + carWidth,
      carBaseY - 10, // Front bumper
    );
    // Front chin & lower skirts
    carBody.lineTo(carStartX + carWidth * 0.95, carBaseY);
    carBody.lineTo(carStartX + carWidth * 0.82, carBaseY); // front wheel arch
    carBody.lineTo(carStartX + carWidth * 0.30, carBaseY); // rear wheel arch
    carBody.lineTo(carStartX + carWidth * 0.05, carBaseY);
    carBody.close();

    // Car Metallic Cyan Paint Gradient
    final carPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1B648F),
          const Color(0xFF0F3657),
          const Color(0xFF081C2F),
        ],
      ).createShader(Rect.fromLTWH(carStartX, carBaseY - 60, carWidth, 60));
    canvas.drawPath(carBody, carPaint);

    // Car Body Highlights & Aerodynamic Accent Line
    final highlightPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final accentLine = Path();
    accentLine.moveTo(carStartX + carWidth * 0.12, carBaseY - 20);
    accentLine.quadraticBezierTo(
      carStartX + carWidth * 0.55,
      carBaseY - 22,
      carStartX + carWidth * 0.94,
      carBaseY - 14,
    );
    canvas.drawPath(accentLine, highlightPaint);

    // Glass / Tinted Windows
    final cabinPath = Path();
    cabinPath.moveTo(carStartX + carWidth * 0.38, carBaseY - 32);
    cabinPath.cubicTo(
      carStartX + carWidth * 0.46,
      carBaseY - 52,
      carStartX + carWidth * 0.66,
      carBaseY - 50,
      carStartX + carWidth * 0.74,
      carBaseY - 28,
    );
    cabinPath.close();
    final cabinPaint = Paint()
      ..color = const Color(0xFF040A12).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(cabinPath, cabinPaint);

    // Futuristic LED Headlight & Tail Light
    // Headlight (Cyan LED strip)
    final headlightPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
    canvas.drawLine(
      Offset(carStartX + carWidth * 0.94, carBaseY - 15),
      Offset(carStartX + carWidth * 0.99, carBaseY - 12),
      headlightPaint,
    );
    // Headlight Beam
    final beamPath = Path();
    beamPath.moveTo(carStartX + carWidth * 0.99, carBaseY - 12);
    beamPath.lineTo(w, carBaseY - 24);
    beamPath.lineTo(w, carBaseY + 8);
    beamPath.close();
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.cyan.withValues(alpha: 0.25), Colors.transparent],
      ).createShader(Rect.fromLTWH(carStartX + carWidth, carBaseY - 24, w, 32));
    canvas.drawPath(beamPath, beamPaint);

    // Tail light (Red/Amber neon strip)
    final taillightPaint = Paint()
      ..color = const Color(0xFFFF3366)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(carStartX + 2, carBaseY - 14),
      Offset(carStartX + carWidth * 0.08, carBaseY - 12),
      taillightPaint,
    );

    // 6. Alloy Wheels & Glowing Brake Calipers
    void drawWheel(double cx, double cy, double radius) {
      // Tire
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()..color = const Color(0xFF060D17),
      );
      // Rim
      canvas.drawCircle(
        Offset(cx, cy),
        radius * 0.72,
        Paint()
          ..color = const Color(0xFF1E3A5F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      // Center neon cap
      canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = AppColors.cyan);
    }

    final wheelRadius = h * 0.055;
    drawWheel(carStartX + carWidth * 0.22, carBaseY - 3, wheelRadius);
    drawWheel(carStartX + carWidth * 0.80, carBaseY - 3, wheelRadius);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
