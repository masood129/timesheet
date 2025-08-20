// main_drawer.dart (اصلاح شده)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../manager/view/manager_dashboard.dart';
import '../../controller/auth_controller.dart';
import '../../controller/home_controller.dart';
import '../../view/monthly_details_view.dart';
import 'gym_cost_dialog.dart'; // import فایل جدید

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final ThemeController themeController = Get.find<ThemeController>();
  final HomeController homeController = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text(
              'settings'.tr,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, color: colorScheme.primary),
            title: Text(
              themeController.isDark.value ? 'light_theme'.tr : 'dark_theme'.tr,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            onTap: () {
              themeController.toggleTheme(!themeController.isDark.value);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.language, color: colorScheme.primary),
            title: Text(
              Get.locale!.languageCode == 'fa' ? 'english'.tr : 'persian'.tr,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            onTap: () {
              final newLocale = Get.locale!.languageCode == 'fa' ? const Locale('en') : const Locale('fa');
              Get.updateLocale(newLocale);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: colorScheme.primary),
            title: Text('monthly_details'.tr, style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => MonthlyDetailsView());
            },
          ),
          ListTile(
            leading: Icon(Icons.fitness_center, color: colorScheme.primary),
            title: Text('هزینه ورزش ماهیانه'.tr, style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              showGymCostDialog(context, homeController);
            },
          ),
          Obx(() => authController.user.value != null &&
              ['group_manager', 'general_manager', 'finance_manager']
                  .contains(authController.user.value!['Role'])
              ? ListTile(
            leading: Icon(Icons.dashboard, color: colorScheme.primary),
            title: Text('manager_dashboard'.tr, style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ManagerDashboard());
            },
          )
              : const SizedBox.shrink()),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.primary),
            title: Text('logout'.tr, style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              authController.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}