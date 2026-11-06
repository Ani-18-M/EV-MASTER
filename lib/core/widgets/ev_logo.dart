import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class EvLogo extends StatefulWidget {
  final bool showTagline;
  final double iconHeight;
  final double fontSize;
  final bool isHorizontal;

  const EvLogo({
    super.key,
    this.showTagline = true,
    double? iconHeight,
    double? iconSize,
    this.fontSize = 24,
    this.isHorizontal = true,
  }) : iconHeight = iconHeight ?? iconSize ?? 68;

  @override
  State<EvLogo> createState() => _EvLogoState();
}

class _EvLogoState extends State<EvLogo> with TickerProviderStateMixin {
  // ── Pulse glow (breathes in/out) ─────────────────────────────────────────
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  // ── Shimmer sweep (light sweeps left→right) ───────────────────────────────
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // Shimmer repeats every 3 s with a 1.5 s pause between sweeps
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Animate shimmer position from -2.0 (off-screen left) → 2.0 (off-screen right)
    _shimmerAnim = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Offset get _emblemCenter {
    final r = widget.iconHeight / 2;
    if (!widget.isHorizontal && widget.showTagline) {
      // Full vertical logo (564x475): cx is at width/2, cy is at height * (180/475)
      final w = widget.iconHeight * (564.0 / 475.0);
      return Offset(w / 2, widget.iconHeight * (180.0 / 475.0));
    }
    return Offset(r, r);
  }

  @override
  Widget build(BuildContext context) {
    final logo = _buildLogo();
    final glowRadius = widget.iconHeight / 2;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _shimmerAnim]),
      builder: (context, _) {
        return CustomPaint(
          // ① Pulse glow drawn behind the logo (pure circular halo, no square box)
          painter: _CircularGlowPainter(
            t: _glowAnim.value,
            color: AppColors.cyan,
            radius: glowRadius,
            center: _emblemCenter,
          ),
          child: ShaderMask(
            // ② Shimmer sweep drawn over the logo via srcATop blend
            shaderCallback: (Rect bounds) =>
                _shimmerShader(bounds, _shimmerAnim.value),
            blendMode: BlendMode.srcATop,
            child: logo,
          ),
        );
      },
    );
  }

  /// Builds a linear gradient whose bright highlight travels smoothly from left to right
  /// with zero duplicate stop values or clamping artifacts.
  Shader _shimmerShader(Rect bounds, double pos) {
    return LinearGradient(
      begin: Alignment(pos - 0.45, 0),
      end: Alignment(pos + 0.45, 0),
      colors: const [Color(0x00FFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(bounds);
  }

  Widget _buildLogo() {
    if (widget.isHorizontal) {
      if (widget.showTagline) {
        return Image.asset(
          'assets/images/ev_logo_horizontal.png',
          height: widget.iconHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/ev_logo_full.png',
            height: widget.iconHeight,
            fit: BoxFit.contain,
          ),
        );
      } else {
        return Image.asset(
          'assets/images/ev_logo_emblem.png',
          height: widget.iconHeight,
          fit: BoxFit.contain,
        );
      }
    } else {
      return Image.asset(
        widget.showTagline
            ? 'assets/images/ev_logo_full.png'
            : 'assets/images/ev_logo_emblem.png',
        height: widget.iconHeight,
        fit: BoxFit.contain,
      );
    }
  }
}

/// Paints a pure circular glow using [MaskFilter.blur] — no visible container
/// or background box, just a soft blurred ring of cyan light.
class _CircularGlowPainter extends CustomPainter {
  final double t;
  final Color color;
  final double radius;
  final Offset center;

  const _CircularGlowPainter({
    required this.t,
    required this.color,
    required this.radius,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Inner tight glow
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = color.withValues(alpha: 0.38 + 0.42 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 14 * t),
    );
    // Outer wide halo
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = color.withValues(alpha: 0.10 + 0.18 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 22 + 26 * t),
    );
  }

  @override
  bool shouldRepaint(_CircularGlowPainter old) => old.t != t;
}
