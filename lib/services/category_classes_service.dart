import 'api_service.dart';

class CategoryClassesService {
  static Future<List<dynamic>> getCategoryClasses() async {
    final res = await ApiService.get(
      'category-classes?populate[0]=category',
    );
    return res['data'] ?? [];
  }
}
