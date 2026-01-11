import 'package:flutter/material.dart';

class DailyGoal extends StatelessWidget {
  final int value;
  final bool disabled;
  final ValueChanged<int> onChanged;

  const DailyGoal({
    super.key,
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          const Text(
            'Tägliches Ziel setzen',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          const SizedBox(height: 16),
          DropdownMenu<int>(
            initialSelection: value == 0 ? null : value,
            enabled: !disabled,
            width: MediaQuery.of(context).size.width - 40,

            // Стрелочка как на скриншоте
            trailingIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
            selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black, size: 20),

            textStyle: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),

            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(6),
              // Убираем внутренние отступы самого контейнера меню
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              // Тонкая линия под текстом
              contentPadding: EdgeInsets.only(bottom: 8),
              constraints: BoxConstraints(maxHeight: 32), // Уменьшили высоту самого поля
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12, width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12, width: 1),
              ),
            ),

            onSelected: (v) {
              if (v != null) onChanged(v);
            },

            dropdownMenuEntries: [10, 20, 30, 40].map((int val) {
              final bool isSelected = value == val;
              return DropdownMenuEntry<int>(
                value: val,
                label: '$val Fragen',
                style: MenuItemButton.styleFrom(
                  // УМЕНЬШЕННАЯ ВЫСОТА ЭЛЕМЕНТА
                  fixedSize: const Size.fromHeight(24),
                  // Плотные отступы между пунктами
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  // Только цвет текста меняется на серый, без подчеркиваний
                  foregroundColor: isSelected ? Colors.black38 : Colors.black,
                  // Убираем фоновое выделение при наведении/выборе, если нужно
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}