import 'package:flutter/material.dart';
import 'package:untitled2/ui_elements/loading_overlay.dart';
import '../../app_colors.dart';
import '../../services/category_service.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = "";
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  final List<String> _categories = [
    "Rationale zahlen",
    "Multiplizieren",
    "Kommazahlen",
    "Prozent",
    "Rationale",
    "Dividieren",
    "Addieren",
    "Subtrahieren",
    "Schriftliche",
    "Vergleichen",
    "mit Übertrag",
    "ohne Übertrag",
    "Tauschaufgaben",
    "Geld",
    "Zeit",
    "Runde",
    "Maßumwandlungen",
    "Einstellige",
    "Klammern",
    "Exponenten",
    "mit x",
    "binomische",
    "lineare",
    "Wurzel",
    "quadratische",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await CategoryService.getCategories(search: query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Можно показать ошибку пользователю
      print('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок на фиолетовом фоне
            Container(
              color: AppColors.primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Suche",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Остальной контент на белом фоне
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Поле поиска
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _performSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Das Schlüsselwort eingeben",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _searchQuery = "");
                              _performSearch("");
                            },
                          )
                              : null,
                        ),
                      ),
                    ),

                    // Контент (Категории или Результаты)
                    Expanded(
                      child: _searchQuery.isEmpty
                          ? _buildCategoryGrid()
                          : _buildSearchResults(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: -6,
        children: _categories
            .map(
              (cat) => ActionChip(
            label: Text(cat),
            backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 1,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              _controller.text = cat;
              setState(() => _searchQuery = cat);
              _performSearch(cat);
            },
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: LoadingOverlay(
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Keine Ergebnisse gefunden',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = _searchResults[index];

        // Извлекаем данные из API response
        final name = item['attributes']['name'] ?? '';
        final className = item['attributes']['category_class']?['data']?['attributes']?['name'] ?? '';
        final questions = item['questions'] ?? 0;
        final answers = item['answers'] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            // Это выравнивает все элементы внутри Row по нижней линии
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Название категории (займет всё свободное место слева)
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Блок статистики (будет в самом низу и справа)
              Column(
                mainAxisSize: MainAxisSize.min, // Занимает минимум места по высоте
                crossAxisAlignment: CrossAxisAlignment.end, // Текст внутри прижат к правому краю
                children: [
                  Text(
                    '$answers/$questions',
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (className.isNotEmpty)
                    Text(
                      "Klasse $className",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}