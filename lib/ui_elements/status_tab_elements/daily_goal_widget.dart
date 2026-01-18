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
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          const Text(
            'Tägliches Ziel setzen',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),

          DropdownMenu<int>(
            initialSelection: value == 0 ? null : value,
            enabled: !disabled,
            // 1. Устанавливаем ширину ровно по границам линии (экран минус padding 26*2)
            width: MediaQuery.of(context).size.width - 52,

            trailingIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
              size: 20,
            ),
            selectedTrailingIcon: const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.black,
              size: 20,
            ),

            textStyle: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),

            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(6),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              // 2. Убираем горизонтальный padding, чтобы текст был слева, а иконка справа до упора.
              // Увеличиваем вертикальный padding для симметрии (8-10 обычно идеально).
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              // 3. Убираем ограничение по высоте или делаем его чуть больше, чтобы отступы были видны
              constraints: BoxConstraints(maxHeight: 55),
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

            dropdownMenuEntries: [10, 20, 30, 40].map((val) {
              final bool isSelected = value == val;
              return DropdownMenuEntry<int>(
                value: val,
                label: '$val Fragen',
                style: MenuItemButton.styleFrom(
                  fixedSize: const Size.fromHeight(24),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor: isSelected ? Colors.black38 : Colors.black,
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
