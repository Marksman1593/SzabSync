import 'package:flutter/material.dart';
import 'package:szabsync/constants/app_colors.dart';

class CustomIcon extends StatelessWidget {
  final Icon icon;

  CustomIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => RadialGradient(
        center: Alignment.topCenter,
        stops: [.5, 1],
        colors: [
          AppColors.secondary,
          AppColors.secondaryDark,
        ],
      ).createShader(bounds),
      child: icon,
    );
  }
}
