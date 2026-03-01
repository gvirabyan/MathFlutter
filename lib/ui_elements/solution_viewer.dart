import 'package:flutter/material.dart';
import 'package:untitled2/ui_elements/loading_overlay.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:untitled2/app_colors.dart';

class SolutionWebView extends StatefulWidget {
  final int questionId;
  final String categoryName;

  const SolutionWebView({
    super.key,
    required this.questionId,
    required this.categoryName,
  });

  static void show(BuildContext context, int questionId, String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SolutionWebView(
        questionId: questionId,
        categoryName: categoryName,
      ),
    );
  }

  @override
  State<SolutionWebView> createState() => _SolutionWebViewState();
}

class _SolutionWebViewState extends State<SolutionWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final url = Uri.parse(
      'https://schulmatheapp.de/solution.php'
          '?questionID=${widget.questionId}'
          '&categoryName=${widget.categoryName}',
    ).toString();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 12) {
          Navigator.pop(context);
        }
      },
      child: Container(
        height: screenHeight * 0.94,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: [
            // ── Drag handle + Header ──────────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 8) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                color: AppColors.primaryPurple,
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    // Полоска-индикатор свайпа

                    // Заголовок с кнопкой закрытия
                    Row(
                      children: [
                        const SizedBox(width: 48), // балансировка
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Erklärung',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── WebView ──────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: controller),
                  if (isLoading)
                    const Center(child: LoadingOverlay()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}