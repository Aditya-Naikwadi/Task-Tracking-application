import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.05,
    this.borderRadius = 20.0,
    this.color,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
