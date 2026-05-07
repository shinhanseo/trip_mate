import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final Color leftColor;
  final Color rightColor;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Widget? icon;

  final double elevation;
  final Color shadowColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.leftColor,
    required this.rightColor,
    required this.onTap,
    this.height = 56,
    this.borderRadius = 30,
    this.textStyle,
    this.icon,
    this.elevation = 6,
    this.shadowColor = AppColors.shadowBlack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: elevation,
        shadowColor: shadowColor,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [leftColor, rightColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(
                      text,
                      style:
                          textStyle ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
