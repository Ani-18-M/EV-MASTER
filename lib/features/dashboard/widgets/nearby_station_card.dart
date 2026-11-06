import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class NearbyStationCard extends StatelessWidget {
  final String name;
  final String distance;
  final String availability;
  final String? power;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;

  const NearbyStationCard({
    super.key,
    required this.name,
    required this.distance,
    required this.availability,
    this.power,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return InkWell(
      borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
      onTap: onTap,
      child: GlassContainer(
        height: double.infinity,
        width: double.infinity,
        metallicStyle: MetallicStyle.silver,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 18,
          vertical: isMobile ? 8 : 16,
        ),
        borderRadius: isMobile ? 14 : 20,
        borderColor: AppColors.cyanBorder,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Icon Badge on the left
            Container(
              width: isMobile ? 38 : 52,
              height: isMobile ? 38 : 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF334155), Color(0xFF1E2736)],
                ),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon ?? Icons.location_on_rounded,
                color: Colors.white,
                size: isMobile ? 20 : 28,
              ),
            ),
            SizedBox(width: isMobile ? 10 : 16),

            // Middle Column: Name, Distance & Availability
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 12.5 : 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.65),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  if (isMobile)
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF006622),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$distance • $availability',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F2B3E),
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
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      distance,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF006622),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            availability,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF006622),
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
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Right side on mobile: Power tag & Chevron Arrow
            if (isMobile) ...[
              if (power != null) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(maxWidth: 85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFF0F172A),
                    border: Border.all(
                      color: const Color(0xFF00E5FF),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    power!,
                    style: GoogleFonts.outfit(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00E5FF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E2736),
                ),
                child: const Center(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
