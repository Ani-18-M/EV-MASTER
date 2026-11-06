import 'package:flutter/material.dart';

class EvThunderbolt extends StatelessWidget {
  final double width;
  final double height;
  final bool showGlow;

  const EvThunderbolt({
    super.key,
    this.width = 54,
    this.height = 54,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ev_logo_emblem.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
