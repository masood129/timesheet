import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesheet/core/api/api_calls/api_calls.dart';
import 'package:timesheet/home/controller/auth_controller.dart';

import '../../../model/user_model.dart';
import '../../../core/theme/snackbar_helper.dart';
import '../../../core/utils/page_title_manager.dart';

class UserListView extends StatelessWidget {
  UserListView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ApiCalls homeApi = ApiCalls();

  @override
  Widget build(BuildContext context) {
    // Set page title when building the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PageTitleManager.setTitle('لیست کاربران');
    });
    
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
                        ThemedSnackbar.showError('خطا', 'لاگین ناموفق: $e');
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
