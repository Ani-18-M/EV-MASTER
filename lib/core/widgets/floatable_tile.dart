import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A wrapper widget that makes tiles float interactively when hovered or tapped.
class FloatableTile extends StatefulWidget {
  final Widget child;
  final double floatLift;
  final double hoverScale;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const FloatableTile({
    super.key,
    required this.child,
    this.floatLift = 8.0,
    this.hoverScale = 1.025,
    this.glowColor,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  State<FloatableTile> createState() => _FloatableTileState();
}

class _FloatableTileState extends State<FloatableTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? AppColors.cyan;
    final r = widget.borderRadius ?? BorderRadius.circular(18);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (_) => setState(() => _isHovered = true),
        onPointerUp: (_) {
          Future.delayed(const Duration(milliseconds: 280), () {
            if (mounted) setState(() => _isHovered = false);
          });
        },
        onPointerCancel: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(
            0,
            _isHovered ? -widget.floatLift : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: r,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: glow.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            scale: _isHovered ? widget.hoverScale : 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
