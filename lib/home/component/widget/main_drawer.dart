import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../view/monthly_details_view.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text('settings'.tr, style: TextStyle(color: colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, color: colorScheme.primary),
            title: Text(themeController.isDark.value ? 'light_theme'.tr : 'dark_theme'.tr, style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              themeController.toggleTheme(!themeController.isDark.value);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.language, color: colorScheme.primary),
            title: Text(Get.locale!.languageCode == 'fa' ? 'english'.tr : 'persian'.tr, style: TextStyle(color: colorScheme.onSurface)),
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
        ],
      ),
    );
  }
}