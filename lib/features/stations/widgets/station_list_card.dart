import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/floatable_tile.dart';
import '../../../core/widgets/glass_container.dart';

class StationListCard extends StatelessWidget {
  final String name;
  final String distance;
  final String availability;
  final String power;
  final bool isFast;
  final bool isSelected;
  final bool isNavigating;
  final int? waitTimeMinutes;
  final int? plugScore;
  final VoidCallback? onHoldStall;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  const StationListCard({
    super.key,
    required this.name,
    required this.distance,
    required this.availability,
    required this.power,
    this.isFast = true,
    this.isSelected = false,
    this.isNavigating = false,
    this.waitTimeMinutes,
    this.plugScore,
    this.onHoldStall,
    required this.onTap,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isFast
        ? const Color(0xFF00E676)
        : const Color(0xFF00B0FF);

    return FloatableTile(
      floatLift: 4.0,
      hoverScale: 1.015,
      glowColor: isSelected ? AppColors.cyan : primaryColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 18,
          borderColor: isSelected
              ? AppColors.cyan
              : (isNavigating ? const Color(0xFF00E5FF) : AppColors.cyanBorder),
          metallicStyle: isSelected ? MetallicStyle.cyan : MetallicStyle.silver,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Double Ring Glowing Icon Badge (matching the screenshot)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.22),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Station Information (Center Column)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Station Name
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
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
                    const SizedBox(height: 3),

                    // Distance • Availability line
                    Row(
                      children: [
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
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            availability,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isFast
                                  ? const Color(0xFF006622)
                                  : const Color(0xFF00495C),
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
                    const SizedBox(height: 3),

                    // Power Rating Badge/Text + Wait time & Plug Score
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            power,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004D61),
                              letterSpacing: 0.2,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  offset: const Offset(0, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (waitTimeMinutes != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFF1E2736),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  waitTimeMinutes == 0
                                      ? '0m wait'
                                      : '${waitTimeMinutes}m wait',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: waitTimeMinutes == 0
                                        ? const Color(0xFF00E676)
                                        : Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (plugScore != null) ...[
                          const SizedBox(width: 5),
                          Text(
                            '$plugScore%',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action buttons (Hold Stall & Navigate)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onHoldStall != null) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onHoldStall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF00E5FF)
                              .withValues(alpha: 0.10),
                          border: Border.all(
                            color: const Color(0xFF00E5FF)
                                .withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          'Hold',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // "Navigate" Pill Button (matching screenshot)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onNavigate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isNavigating
                            ? AppColors.cyan
                            : const Color(0xFF0C243B).withValues(alpha: 0.8),
                        border: Border.all(
                          color: isNavigating
                              ? AppColors.cyan
                              : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isNavigating
                                        ? AppColors.cyan
                                        : const Color(0xFF00E5FF))
                                    .withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        isNavigating ? 'Active' : 'Navigate',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: isNavigating
                              ? const Color(0xFF05111B)
                              : AppColors.cyan,
                        ),
                      ),
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
}
