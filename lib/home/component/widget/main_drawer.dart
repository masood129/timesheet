import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../manager/view/manager_dashboard.dart';
import '../../controller/auth_controller.dart';
import '../../controller/home_controller.dart';
import '../../view/monthly_details_view.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final ThemeController themeController = Get.find<ThemeController>();
  final HomeController homeController = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();

  void _showGymCostDialog(BuildContext context) {
    final yearController = TextEditingController();
    final monthController = TextEditingController();
    final costController = TextEditingController();

    final years = List.generate(5, (index) => DateTime.now().year - 2 + index);
    final months = List.generate(12, (index) => index + 1);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ثبت هزینه ورزش ماهیانه'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'سال'.tr),
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  yearController.text = value.toString();
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'ماه'.tr),
                items: months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  monthController.text = value.toString();
                },
              ),
              TextField(
                controller: costController,
                decoration: InputDecoration(labelText: 'هزینه (تومان)'.tr),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                if (yearController.text.isEmpty ||
                    monthController.text.isEmpty ||
                    costController.text.isEmpty) {
                  Get.snackbar('خطا', 'لطفاً همه فیلدها را پر کنید'.tr);
                  return;
                }
                try {
                  await homeController.saveMonthlyGymCost(
                    int.parse(yearController.text),
                    int.parse(monthController.text),
                    int.parse(costController.text),
                  );
                  Get.snackbar('موفقیت', 'هزینه ورزش ثبت شد'.tr);
                  Navigator.pop(context);
                } catch (e) {
                  Get.snackbar('خطا', 'خطا در ثبت هزینه: $e'.tr);
                }
              },
              child: Text('ثبت'.tr),
            ),
          ],
        );
      },
    );
  }

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
              _showGymCostDialog(context);
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