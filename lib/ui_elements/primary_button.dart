import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          backgroundColor: enabled ? baseColor : baseColor.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          // ВАЖНО: обнуляем padding, чтобы иконка прилегала к краям кнопки
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          if (!enabled) return;
          onPressed?.call();
        },
        child: Stack(
          children: [
            // Текст строго по центру
            Center(child: Text(text)),

            // Иконка растянута по высоте кнопки (от пола до верха) и прижата вправо
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SvgPicture.asset(
                  'assets/buttons/buttons_pic.svg',
                  // fitHeight заставляет иконку растянуться вертикально под размер Positioned
                  fit: BoxFit.fitHeight,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
