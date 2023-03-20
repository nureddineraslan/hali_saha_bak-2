import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  Future<String?> getUserType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userType = sharedPreferences.getString('user_type');
    return userType;
  }

  Future<void> setUserType(String userType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('user_type', userType);
  }

  Future<void> clearUserType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('userType');
  }
}
