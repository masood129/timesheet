import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/theme.dart';
import '../component/note_dialog.dart';
import '../controller/home_controller.dart';
import 'monthly_details_view.dart';

class CalendarView extends StatelessWidget {
  CalendarView({super.key});

  final HomeController homeController = Get.put(HomeController());
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final year = homeController.currentYear.value;
          final month = homeController.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          return Text('${'calendar_title'.tr}: $monthName $year');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: homeController.previousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: homeController.nextMonth,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Get.to(() => MonthlyDetailsView()),
          ),
        ],
      ),
      drawer: Drawer(
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
                final newLocale = Get.locale!.languageCode == 'fa'
                    ? const Locale('en')
                    : const Locale('fa');
                Get.updateLocale(newLocale);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('loading_calendar'.tr),
              ],
            ),
          );
        }

        final year = homeController.currentYear.value;
        final month = homeController.currentMonth.value;
        final daysInMonth = homeController.daysInMonth;

        return ListView.builder(
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = Jalali(year, month, day);
            final isFriday = date.weekDay == 7;
            final cardStatus = homeController.getCardStatus(date, context);

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6,
              ),
              child: Card(
                color: colorScheme.surface,
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? colorScheme.outline
                            : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: cardStatus['avatarColor'],
                      child: Icon(
                        cardStatus['avatarIcon'],
                        color: cardStatus['avatarIconColor'],
                      ),
                    ),
                  ),
                  title: Text(
                    '${date.formatter.wN} $day ${date.formatter.mN} ${date.year}',
                    style: TextStyle(
                      color: isFriday ? colorScheme.error : null,
                      fontWeight: isFriday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '',//TODO: SUBTITLE for there
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                  ),
                  onTap: () => showModalBottomSheet(
                    useSafeArea: true,
                    enableDrag: false,
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => NoteDialog(date: date),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}