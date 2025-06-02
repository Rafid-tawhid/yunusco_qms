import 'package:flutter/material.dart';

class RectangleIconButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final Color disabledColor; // New property for disabled state
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onPressed; // Changed to async function
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
    this.disabledColor = Colors.grey, // Default disabled color
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(12),
    this.elevation = 2.0,
    this.minimumSize,
    this.border,
  });

  @override
  State<RectangleIconButton> createState() => _RectangleIconButtonState();
}

class _RectangleIconButtonState extends State<RectangleIconButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (widget.onPressed == null || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: _isLoading ? 0 : widget.elevation,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      color: _isLoading ? widget.disabledColor : widget.backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onTap: _isLoading ? null : _handlePress,
        child: Container(
          constraints: BoxConstraints(
            minWidth: widget.minimumSize?.width ?? 48,
            minHeight: widget.minimumSize?.height ?? 48,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
              : Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}