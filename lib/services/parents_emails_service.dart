import 'api_service.dart';
import 'token_storage.dart';

class ParentsEmailsService {
  /// Получить emails родителей
  static Future<Map<String, dynamic>> getParentsEmails() async {
    final userId = await TokenStorage.getUserId();

    try {
      final res = await ApiService.get(
        'parents-emails'
            '?populate[0]=users_permissions_users'
            '&filters[users_permissions_users][id]=$userId',
      );

      final emails = (res['data'] as List<dynamic>? ?? [])
          .map((e) => {
        'id': e['id'],
        ...e['attributes'],
      })
          .toList();

      return {
        'status': 'success',
        'data': emails,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Сохранить несколько email’ов
  static Future<Map<String, dynamic>> saveParentsEmails(
      List<String> emails,
      ) async {
    try {
      final res = await ApiService.post(
        'saveMultipleParentsEmails',
        {
          'data': {'emails': emails},
        },
      );

      if (res['error'] != null) {
        return {
          'status': 'error',
          'message': res['error']?['message'],
        };
      }

      return {
        'status': 'success',
        'data': res['data'],
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Удалить email родителя
  static Future<Map<String, dynamic>> removeParentEmail(int id) async {
    try {
      final res = await ApiService.delete(
        'parents-emails/$id',
      );

      if (res['error'] != null) {
        return {
          'status': 'error',
          'message': res['error']?['message'],
        };
      }

      return {'status': 'success'};
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}
