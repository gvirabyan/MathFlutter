import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 полупрозрачный белый фон
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.9),
          ),
        ),

        // 🔹 GIF по центру
        const Center(
          child: _LoadingGif(),
        ),
      ],
    );
  }
}

class _LoadingGif extends StatelessWidget {
  const _LoadingGif();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/gifs/loading.gif',
      width: 90,
      height: 90,
      fit: BoxFit.contain,
      key: const ValueKey('loading_gif'),
    );
  }
}
