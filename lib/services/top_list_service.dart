import 'auth_service.dart';
import 'api_service.dart';

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
      final institutionPlaceId = user['institution']?['place_id'];

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
      final value = user[categoryKey];
      if (value == null || value.toString().isEmpty) {
        return [];
      }

      url =
      'get-points'
          '?filters[$categoryKey]=$value'
          '&sort=points:desc'
          '&pagination[start]=0'
          '&pagination[limit]=100';
    }

    final res = await ApiService.get(url);

    return (res as List)
        .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  /// Rankings (как было)
  static Future<Map<String, dynamic>> getRankings() async {
    final res = await ApiService.get('get-rankings');
    return (res['rankings'] as Map).cast<String, dynamic>();
  }
}
