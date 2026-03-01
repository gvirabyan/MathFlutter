import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._();
  UserSession._();
  static UserSession get instance => _instance;

  bool? _isAdmin;

  Future<bool> get isAdmin async {
    _isAdmin ??= (await SharedPreferences.getInstance()).getBool('is_admin') ?? false;
    return _isAdmin!;
  }

  void invalidate() => _isAdmin = null;
}