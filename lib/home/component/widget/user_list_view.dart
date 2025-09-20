// Create a new file: lib/manager/view/user_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesheet/core/api/api_calls.dart'; // Adjust path if needed
import 'package:timesheet/home/controller/auth_controller.dart'; // Adjust path if needed
import 'package:timesheet/home/model/user_model.dart'; // Create UserModel if not exists

class UserListView extends StatelessWidget {
  UserListView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final HomeApi homeApi = HomeApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لیست کاربران زیرمجموعه'.tr)),
      body: FutureBuilder<List<UserModel>>(
        future: homeApi.getSubordinates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطا: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('هیچ کاربری یافت نشد'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.username),
                  subtitle: Text('نقش: ${user.role}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      try {
                        await authController.impersonate(user.userId);
                      } catch (e) {
                        Get.snackbar('خطا', 'لاگین ناموفق: $e');
                      }
                    },
                    child: Text('لاگین به عنوان'.tr),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
