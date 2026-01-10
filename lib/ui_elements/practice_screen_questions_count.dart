import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget _item(
    BuildContext context, {
      required String title,
      required String score,
      required int count,
      required VoidCallback onTap,
    }) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    ),
  );
}
