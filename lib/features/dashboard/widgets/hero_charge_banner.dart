import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../../core/widgets/ev_car_canvas.dart';
import '../../../core/widgets/glass_container.dart';

class HeroChargeBanner extends StatelessWidget {
  final VoidCallback onFindStations;
  final bool isCompactTile;

  const HeroChargeBanner({
    super.key,
    required this.onFindStations,
    this.isCompactTile = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    // Compact 2-column mobile tile mode
    if (isCompactTile) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onFindStations,
        child: GlassContainer(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 16,
          borderColor: AppColors.cyanBorder,
          metallicStyle: MetallicStyle.cyan,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Colors.white,
                      Color(0xFF00E5FF),
                      Color(0xFF0091EA),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title, Subtitle, CTA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Charge Smarter',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: const Color(0xFF011A29),
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
                    const SizedBox(height: 2),
                    Text(
                      'Drive Further',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: const Color(0xFF00495C),
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
                    Text(
                      'Find Stations →',
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF012B3D),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassContainer(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      borderColor: AppColors.cyanBorder,
      metallicStyle: MetallicStyle.cyan,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Right-side EV Car + Station graphic
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: isMobile ? 220 : (screenWidth < 1100 ? 380 : 500),
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.35],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Opacity(
                opacity: 0.88,
                child: Image.asset(
                  'assets/images/ev_hero_car.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const EvCarIllustration(
                        height: 200,
                        showStation: true,
                        compact: true,
                      ),
                ),
              ),
            ),
          ),

          // Left-side Text and CTA
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 28,
              vertical: isMobile ? 6 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Charge Smarter',
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 15.5 : 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: const Color(0xFF011A29),
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Drive Further',
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 12 : 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: const Color(0xFF00495C),
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.45),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: isMobile ? 130 : 185,
                    maxWidth: isMobile ? 190 : 240,
                  ),
                  child: CyanButton(
                    text: 'Find Charging Stations',
                    icon: Icons.near_me_rounded,
                    height: isMobile ? 28 : 38,
                    width: null,
                    onPressed: onFindStations,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
