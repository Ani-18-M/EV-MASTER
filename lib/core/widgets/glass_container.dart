import 'package:flutter/material.dart';

enum MetallicStyle {
  silver, // The "MASTER" metallic silver chrome
  cyan, // The "EV" metallic cyan chrome
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;
  final List<BoxShadow>? shadows;
  final bool isTransparent;
  final MetallicStyle? metallicStyle;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
    this.backgroundColor,
    this.blur = 16,
    this.shadows,
    this.isTransparent = false,
    this.metallicStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        metallicStyle ??
        (borderColor == const Color(0xFF00E5FF)
            ? MetallicStyle.cyan
            : MetallicStyle.silver);

    final isCyan = style == MetallicStyle.cyan;
    final innerRadius = borderRadius > 1.2 ? borderRadius - 1.2 : borderRadius;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // 3D Bevel Rim with signature metallic chrome gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCyan
              ? const [
                  Color(0xFFFFFFFF), // Specular chrome flash
                  Color(0xFFC4FAFC), // Ice cyan gleam
                  Color(0xFF00E5FF), // Pure EV electric cyan
                  Color(0xFF005E73), // Titanium shadow groove
                  Color(0xFF76FDFF), // Reflected cyan highlight
                  Color(0xFFFFFFFF), // Specular corner reflection
                ]
              : const [
                  Color(0xFFFFFFFF), // Specular chrome flash
                  Color(0xFFE2E8F0), // Platinum silver highlight (#D6E2E9)
                  Color(
                    0xFFCCDEEA,
                  ), // MASTER silver-blue chrome midtone (#CCDEEA)
                  Color(0xFF515B69), // Metallic shadow groove (#515B69)
                  Color(0xFFBDD2E2), // Chrome specular bounce (#BDD2E2)
                  Color(0xFFFFFFFF), // Specular corner reflection
                ],
          stops: const [0.0, 0.18, 0.42, 0.65, 0.88, 1.0],
        ),
        boxShadow:
            shadows ??
            (isCyan
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFFCCDEEA).withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 2),
                      spreadRadius: 1,
                    ),
                  ]),
      ),
      padding: const EdgeInsets.all(1.2), // 3D bevel rim thickness
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(innerRadius),
            // Solid, non-transparent Metallic Chrome gradient with specular horizon line
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundColor != null
                  ? [backgroundColor!, backgroundColor!]
                  : (isCyan
                        ? const [
                            Color(
                              0xFFE2FCFD,
                            ), // Top specular chrome white-cyan flash
                            Color(0xFF76FDFF), // Liquid electric cyan highlight
                            Color(0xFF00D4E4), // Brushed cyan midtone
                            Color(0xFF006B85), // Metallic shadow groove
                            Color(0xFFE6FFFF), // Chrome specular horizon line (metallic luster flash!)
                            Color(0xFF00E5FF), // Electric cyan re-bounce
                            Color(0xFF007A99), // Brushed cyan alloy
                            Color(
                              0xFF003847,
                            ), // Solid deep metallic titanium base
                          ]
                        : const [
                            Color(0xFFF8FAFC), // Platinum chrome flash
                            Color(
                              0xFFD6E2E9,
                            ), // MASTER upper silver highlight (#D6E2E9)
                            Color(
                              0xFFCCDEEA,
                            ), // MASTER liquid silver midtone (#CCDEEA)
                            Color(
                              0xFF515B69,
                            ), // Brushed titanium groove (#515B69)
                            Color(0xFFFFFFFF), // Chrome specular horizon line (metallic luster flash!)
                            Color(
                              0xFFB4CEDF,
                            ), // Liquid chrome re-bounce (#B4CEDF)
                            Color(0xFF64748B), // Brushed steel alloy
                            Color(
                              0xFF1E2736,
                            ), // Deep solid metallic base (#1E2736)
                          ]),
              stops: backgroundColor != null
                  ? const [0.0, 1.0]
                  : const [0.0, 0.12, 0.28, 0.46, 0.53, 0.64, 0.82, 1.0],
            ),
            border: Border.all(
              color: isCyan ? const Color(0xFFC4FAFC) : const Color(0xFFE2E8F0),
              width: 0.9,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
