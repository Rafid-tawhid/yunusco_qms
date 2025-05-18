import 'package:flutter/material.dart';

class RectangleIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback onPressed;
  final double elevation;
  final Size? minimumSize;
  final BoxBorder? border;

  const RectangleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(12),
    this.elevation = 2.0,
    this.minimumSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onPressed,
        child: Container(
          constraints: BoxConstraints(
            minWidth: minimumSize?.width ?? 48,
            minHeight: minimumSize?.height ?? 48,
          ),
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}