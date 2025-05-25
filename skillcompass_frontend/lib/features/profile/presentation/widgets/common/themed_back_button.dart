import 'package:flutter/material.dart';

class ThemedBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final String? tooltip;
  const ThemedBackButton({Key? key, this.onPressed, this.color = const Color(0xFF2A4B7C), this.tooltip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: color, size: 28),
      tooltip: tooltip ?? 'Geri',
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
} 