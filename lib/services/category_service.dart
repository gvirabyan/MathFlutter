import 'api_service.dart';

class CategoryService {
  /// Получить все категории или поиск
  static Future<List<dynamic>> getCategories({String? search}) async {
    final url = (search != null && search.isNotEmpty)
        ? 'categories?populate[0]=category_class&filters[name][\$containsi]=$search'
        : 'categories?populate[0]=category_class';

    final res = await ApiService.get(url);
    return res['data'] ?? [];
  }

  /// Категории по классу
  static Future<List<dynamic>> getCategoriesByClass({
    required int categoryClassId,
    required bool isAdmin,
  }) async {
    final res = await ApiService.get(
      'categories'
          '?populate[0]=category_class'
          '&filters[category_class][id][\$eq]=$categoryClassId'
          '&isAdmin=$isAdmin'
          '&pagination[limit]=100',
    );

    return res['data'] ?? [];
  }

  /// Последняя категория
  static Future<dynamic> getLastCategory() async {
    return await ApiService.get('last-categories');
  }

  /// Прошлые категории
  static Future<List<dynamic>> getPastCategories() async {
    final res = await ApiService.get('past-categories');
    return res ?? [];
  }
}
