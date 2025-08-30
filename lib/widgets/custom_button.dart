import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
    this.iconSize = 24,
    this.fontSize = 18,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
    this.borderRadius = 12,
    this.elevation = 5,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: iconSize),
        label: Padding(
          padding: padding,
          child: Text(text, style: TextStyle(fontSize: fontSize)),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: elevation,
          shadowColor: shadowColor ?? color.withOpacity(0.4),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
