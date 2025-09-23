// Update auth_controller.dart with impersonate method
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_calls/api_calls.dart';

class AuthController extends GetxController {
  var user = Rxn<Map<String, dynamic>>(); // اطلاعات کاربر (userId, Username, Role)
  var token = ''.obs; // توکن JWT
  final ApiCalls homeApi = ApiCalls();

  @override
  void onInit() {
    super.onInit();
    loadUserFromPrefs(); // بارگذاری اطلاعات کاربر از SharedPreferences
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final username = prefs.getString('username');
    final role = prefs.getString('Role');
    final token = prefs.getString('jwt_token');

    if (userId != null && username != null && role != null && token != null) {
      user.value = {
        'userId': userId,
        'Username': username,
        'Role': role,
      };
      this.token.value = token;
    }
  }

  Future<bool> login(String username) async {
    try {
      final token = await homeApi.login(username);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final storedUsername = prefs.getString('username');
      final role = prefs.getString('Role');
      if (userId != null && storedUsername != null && role != null) {
        user.value = {
          'userId': userId,
          'Username': storedUsername,
          'Role': role,
        };
        this.token.value = token;
        return true;
      } else {
        Get.snackbar('خطا', 'خطا در دریافت اطلاعات کاربر'.tr);
        return false;
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطای ورود: $e'.tr);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await homeApi.logout();
      user.value = null;
      token.value = '';
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('خطا', 'خطای خروج: $e'.tr);
    }
  }

  Future<void> impersonate(int targetUserId) async {
    try {
      await homeApi.loginAs(targetUserId);
      // Reload user from prefs to update state
      await loadUserFromPrefs();
      Get.toNamed('/home'); //TODO: moshkele dispose controller bad az initilize shodan.
      Get.snackbar('موفقیت', 'لاگین به عنوان کاربر جدید انجام شد'.tr);
    } catch (e) {
      Get.snackbar('خطا', 'خطای لاگین به عنوان: $e'.tr);
    }
  }
}