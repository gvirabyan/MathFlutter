import 'api_service.dart';
import 'auth_service.dart';

class TopListService {
  /// Полный аналог Vue getTopList
  static Future<List<Map<String, dynamic>>> getTopListByCategory(
    String categoryKey,
  ) async {
    final resUser = await AuthService.getUser();
    if (resUser['status'] != 'success') {
      return [];
    }

    final user = resUser['user'] as Map<String, dynamic>;
    String url;

    if (categoryKey == 'world') {
      url =
          'get-points'
          '?sort=points:desc'
          '&pagination[start]=0'
          '&pagination[limit]=100';
    } else if (categoryKey == 'course') {
      final course = user['course'];
      final institutionData = user['institution'];

      // Безопасно извлекаем ID учебного заведения
      String? institutionPlaceId;
      if (institutionData is Map) {
        institutionPlaceId = institutionData['place_id']?.toString();
      } else {
        institutionPlaceId = institutionData?.toString();
      }

      if (course == null || institutionPlaceId == null) {
        return [];
      }

      url =
          'get-points'
          '?filters[institution]=$institutionPlaceId'
          '&filters[course]=$course'
          '&sort=points:desc'
          '&pagination[start]=0'
          '&pagination[limit]=100';
    } else {
      // ПРОБЛЕМНАЯ ЗОНА ТУТ
      final value = user[categoryKey];

      if (value == null || value.toString().isEmpty) {
        return [];
      }

      // ИСПРАВЛЕНИЕ: Если значение — это Map (объект), берем только нужный ID
      String finalFilterValue;
      if (value is Map) {
        finalFilterValue =
            value['place_id']?.toString() ??
            value['id']?.toString() ??
            value.toString();
      } else {
        finalFilterValue = value.toString();
      }

      url =
          'get-points'
          '?filters[$categoryKey]=$finalFilterValue'
          '&sort=points:desc'
          '&pagination[start]=0'
          '&pagination[limit]=100';
    }

    try {
      final res = await ApiService.get(url);

      return (res as List)
          .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Rankings (как было)
  static Future<Map<String, dynamic>> getRankings() async {
    final res = await ApiService.get('get-rankings');
    return (res['rankings'] as Map).cast<String, dynamic>();
  }
}
