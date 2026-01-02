import 'package:flutter/material.dart';
import 'package:untitled2/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.enabled,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = color ?? AppColors.primaryPurple;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? baseColor : baseColor.withOpacity(0.5), // 🔥 ключ
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          if (!enabled) return;
          onPressed?.call();
        },        child: Text(text),
      ),
    );
  }
}
