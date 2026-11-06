import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? subtitleColor;
  final Color? iconColor;
  final MetallicStyle metallicStyle;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.subtitleColor,
    this.iconColor,
    this.metallicStyle = MetallicStyle.cyan,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final borderRadius = isMobile ? 16.0 : 20.0;
    final innerRadius = borderRadius > 1.2 ? borderRadius - 1.2 : borderRadius;
    final isCyan = metallicStyle == MetallicStyle.cyan;

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // 3D Metallic Chrome Bevel Rim gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCyan
              ? const [
                  Color(0xFFFFFFFF), // Specular chrome flash
                  Color(0xFFC4FAFC), // Ice cyan gleam
                  Color(0xFF00E5FF), // Pure metallic cyan
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: isMobile ? 14 : 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isCyan
                ? const Color(0xFF00E5FF).withValues(alpha: 0.35)
                : const Color(0xFFCCDEEA).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.2), // 3D bevel rim edge
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 18,
            vertical: isMobile ? 8 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(innerRadius),
            // Solid Metallic Chrome Brushed Finish with specular horizon line
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCyan
                  ? const [
                      Color(0xFFE2FCFD), // Top specular chrome white-cyan flash
                      Color(0xFF76FDFF), // Liquid electric cyan highlight
                      Color(0xFF00D4E4), // Brushed cyan midtone
                      Color(0xFF006B85), // Metallic shadow groove
                      Color(0xFFE6FFFF), // Chrome specular horizon line (metallic luster flash!)
                      Color(0xFF00E5FF), // Electric cyan re-bounce
                      Color(0xFF007A99), // Brushed cyan alloy
                      Color(0xFF003847), // Solid deep metallic titanium base
                    ]
                  : const [
                      Color(0xFFF8FAFC), // Platinum chrome flash
                      Color(
                        0xFFD6E2E9,
                      ), // MASTER upper silver highlight (#D6E2E9)
                      Color(
                        0xFFCCDEEA,
                      ), // MASTER liquid silver midtone (#CCDEEA)
                      Color(0xFF515B69), // Brushed titanium groove (#515B69)
                      Color(0xFFFFFFFF), // Chrome specular horizon line (metallic luster flash!)
                      Color(0xFFB4CEDF), // Liquid chrome re-bounce (#B4CEDF)
                      Color(0xFF64748B), // Brushed steel alloy
                      Color(0xFF1E2736), // Deep solid metallic base (#1E2736)
                    ],
              stops: const [0.0, 0.12, 0.28, 0.46, 0.53, 0.64, 0.82, 1.0],
            ),
            border: Border.all(
              color: isCyan ? const Color(0xFFC4FAFC) : const Color(0xFFE2E8F0),
              width: 0.9,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 3D Metallic Circular Icon Badge on the left
              Container(
                width: isMobile ? 38 : 52,
                height: isMobile ? 38 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCyan
                        ? const [Color(0xFF03243B), Color(0xFF01121F)]
                        : const [Color(0xFF334155), Color(0xFF1E2736)],
                  ),
                  border: Border.all(
                    color: isCyan
                        ? const Color(0xFF76FDFF)
                        : const Color(0xFFE2E8F0),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.40),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isMobile ? 20 : 28,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 16),

              // Text details on the right: Title, Value, Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w700,
                        color: isCyan
                            ? const Color(0xFF032B3D)
                            : const Color(0xFF1E293B),
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      value,
                      style: GoogleFonts.orbitron(
                        fontSize: isMobile ? 16 : 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isCyan
                            ? const Color(0xFF011422)
                            : const Color(0xFF0F172A),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.7),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 10 : 11.5,
                        fontWeight: FontWeight.w700,
                        color: isCyan
                            ? (subtitleColor == AppColors.green
                                  ? const Color(0xFF006830)
                                  : const Color(0xFF00495C))
                            : (subtitleColor == AppColors.green
                                  ? const Color(0xFF006830)
                                  : (subtitleColor ?? const Color(0xFF334155))),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
