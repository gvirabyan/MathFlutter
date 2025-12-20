import 'api_service.dart';

class CoursesService {
  static Future<List<dynamic>> getCourses(String placeId) async {
    final res = await ApiService.get(
      'institutions/$placeId/courses',
    );
    return res['courses'] ?? [];
  }
}
