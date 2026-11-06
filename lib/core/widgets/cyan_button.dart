import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class CyanButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;

  const CyanButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<CyanButton> createState() => _CyanButtonState();
}

class _CyanButtonState extends State<CyanButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          gradient: const LinearGradient(
            colors: [Color(0xFF00F0FF), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: _isHovered ? 0.6 : 0.35),
              blurRadius: _isHovered ? 20 : 12,
              spreadRadius: _isHovered ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.height / 2),
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.darkText,
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.height <= 32 ? 10 : 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: widget.height <= 32 ? 14 : 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: widget.height <= 32 ? 6 : 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.text,
                              style: GoogleFonts.outfit(
                                fontSize: widget.height <= 32 ? 11.5 : 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: widget.height <= 32 ? 0.6 : 1.5,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
