import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? color;
  final double? fontSize; // 1. Добавляем новое поле

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.enabled,
    this.color,
    this.fontSize, // 2. Добавляем в конструктор
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
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          if (!enabled) return;
          onPressed?.call();
        },
        child: Stack(
          children: [
            Center(
              child: Text(
                text,
                // 3. Применяем стиль. Если fontSize не передан, будет null (стандартный размер)
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600, // Можно добавить жирности для красоты
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SvgPicture.asset(
                  'assets/buttons/buttons_pic.svg',
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