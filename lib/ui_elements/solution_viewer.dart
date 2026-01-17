import 'package:flutter/material.dart';
import 'package:untitled2/ui_elements/loading_overlay.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:untitled2/app_colors.dart'; // Убедитесь, что путь верный

class SolutionWebView extends StatefulWidget {
  final int questionId;
  final String categoryName;

  const SolutionWebView({
    super.key,
    required this.questionId,
    required this.categoryName,
  });

  // Статический метод для удобного вызова
  static void show(BuildContext context, int questionId, String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Позволяет занять весь экран
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
    // Высота на почти весь экран (с небольшим отступом сверху для эстетики)
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryPurple,
          title: const Text('Erklärung', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: false, // Убираем стандартную кнопку назад
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(child: LoadingOverlay()),
          ],
        ),
      ),
    );
  }
}