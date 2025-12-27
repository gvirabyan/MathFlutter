import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? color; // 👈 необязательный цвет

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.enabled,
    this.color, // 👈 необязательный
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.deepPurple;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? baseColor
              : baseColor.withOpacity(0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(text),
      ),
    );
  }
}
