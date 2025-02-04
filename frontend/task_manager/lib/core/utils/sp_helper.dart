
import 'package:shared_preferences/shared_preferences.dart';

class SpHelper{
  final authKey = "x-auth-token-tm"; // tm = task_manager - unique
  Future<String?> getToken()async{
    return (await SharedPreferences.getInstance()).getString(authKey);
  }

  Future<void> setToken(String token)async{
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(authKey, token);
  }
}