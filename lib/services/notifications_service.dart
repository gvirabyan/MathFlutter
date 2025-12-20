import 'api_service.dart';
import 'token_storage.dart';

class NotificationsService {
  /// Получить уведомления (с пагинацией)
  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
  }) async {
    final userId = await TokenStorage.getUserId();

    final res = await ApiService.get(
      'notifications'
          '?filters[users_permissions_user][id][\$eq]=$userId'
          '&pagination[page]=$page'
          '&sort[0]=read'
          '&sort[1]=createdAt:desc',
    );

    return {
      'data': res['data'] ?? [],
      'pageCount': res['meta']?['pagination']?['pageCount'] ?? 0,
    };
  }

  /// Отметить уведомление как прочитанное
  static Future<bool> readNotification(int id) async {
    final res = await ApiService.put(
      'notifications/$id',
      {
        'data': {'read': true},
      },
    );

    return res['data'] != null;
  }

  /// Отметить ВСЕ уведомления как прочитанные
  static Future<bool> readAllNotifications() async {
    final res = await ApiService.put(
      'readAllNotifications',
      {
        'data': {'read': true},
      },
    );

    return res != null;
  }

  /// Проверка: есть ли непрочитанные
  static bool hasUnread(List<dynamic> notifications) {
    return notifications.any(
          (n) =>
      n['attributes']?['read'] == false ||
          n['read'] == false,
    );
  }
}
