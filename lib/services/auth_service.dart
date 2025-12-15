import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 🔐 LOGIN
  static Future<Map<String, dynamic>> login(
      Map<String, dynamic> userData,
      ) async {
    final data = await ApiService.post(
      'auth/local?populate[0]=institution',
      userData,
    );

    if (data['error'] == null) {
      await _storeJwtAndUser(data);
      return {'status': 'success'};
    }
    return {'status': 'error', 'error': data['error']};
  }

  // 🔑 PROVIDER LOGIN
  static Future<Map<String, dynamic>> loginViaProvider(
      String provider,
      String accessToken,
      ) async {
    final data = await ApiService.get(
      'auth/$provider/callback$accessToken',
    );

    if (data['error'] == null) {
      await _storeJwtAndUser(data);
      return {'status': 'success'};
    }
    return {'status': 'error', 'message': data['error']?['message']};
  }

  // 📝 REGISTER
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData,
      ) async {
    final data =
    await ApiService.post('auth/local/register', userData);

    if (data['error'] == null) {
      await _storeJwtAndUser(data);
      return {'status': 'success'};
    }
    return {'status': 'error', 'error': data['error']};
  }

  // 🧑 REGISTER BY NICKNAME
  static Future<Map<String, dynamic>> registerByNickname(
      Map<String, dynamic> userData,
      ) async {
    final data = await ApiService.post(
      'auth/local/register-nicknamed-user',
      userData,
    );

    if (data['error'] == null) {
      await _storeJwtAndUser(data);
      return {'status': 'success'};
    }
    return {'status': 'error', 'message': data['error']};
  }

  // 📧 FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final data = await ApiService.post(
      'auth/forgot-password',
      {'email': email},
    );

    return data['error'] == null
        ? {'status': 'success'}
        : {'status': 'error', 'message': data['error']?['message']};
  }

  // 🔁 RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword(
      Map<String, dynamic> body,
      ) async {
    final data =
    await ApiService.post('auth/reset-password', body);

    if (data['error'] == null) {
      await _storeJwtAndUser(data);
      return {'status': 'success'};
    }
    return {'status': 'error', 'message': data['error']?['message']};
  }

  // 👤 GET USER
  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user-id');

    final data = await ApiService.get(
      'users/$userId?populate[0]=institution&populate[1]=installations',
    );

    return data['error'] == null
        ? {'status': 'success', 'user': data}
        : {'status': 'error', 'message': data['error']?['message']};
  }

  // ✏️ UPDATE USER
  static Future<Map<String, dynamic>> updateUser(
      Map<String, dynamic> body,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user-id');

    final data = await ApiService.put('users/$userId', body);

    return data['error'] == null
        ? {'status': 'success'}
        : {'status': 'error', 'message': data['error']?['message']};
  }

  // 🗑 DELETE NICKNAMED USER
  static Future<Map<String, dynamic>> deleteNicknamedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user-id');

    final data = await ApiService.delete(
      'users/$userId/delete-nicknamed-user',
    );

    return data['error'] == null
        ? {'status': 'success'}
        : {'status': 'error', 'message': data['error']?['message']};
  }

  // 🚪 LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user-id');
  }

  // 🔐 STORE JWT
  static Future<void> _storeJwtAndUser(
      Map<String, dynamic> data,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['jwt']);
    await prefs.setString('user-id', data['user']['id'].toString());
  }
}
