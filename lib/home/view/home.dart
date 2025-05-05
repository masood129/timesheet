import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/theme.dart';
import '../component/note_dialog.dart';
import '../controller/home_controller.dart';

class CalendarView extends StatelessWidget {
  CalendarView({super.key});

  final CalendarController calendarController = Get.put(CalendarController());
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final year = calendarController.currentYear.value;
          final month = calendarController.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          return Text('${'calendar_title'.tr}: $monthName $year');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: calendarController.previousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: calendarController.nextMonth,
          ),
          Obx(() => Switch(
            value: themeController.isDark.value,
            onChanged: themeController.toggleTheme,
            activeColor: Theme.of(context).colorScheme.secondary,
          )),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newLocale = Get.locale!.languageCode == 'fa'
                  ? const Locale('en')
                  : const Locale('fa');
              Get.updateLocale(newLocale);
            },
          ),
        ],
      ),
      body: Obx(() {
        final year = calendarController.currentYear.value;
        final month = calendarController.currentMonth.value;
        final daysInMonth = calendarController.daysInMonth;

        return ListView.builder(
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = Jalali(year, month, day);
            final note = calendarController.getNoteForDate(date) ?? 'no_note'.tr;
            final isFriday = date.weekDay == 7;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    '${date.formatter.wN} ${date.day} ${date.formatter.mN} ${date.year}',
                    style: TextStyle(
                      color: isFriday ? Theme.of(context).colorScheme.error : null,
                      fontWeight: isFriday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    note,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  onTap: () => _showNoteDialog(context, date),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showNoteDialog(BuildContext context, Jalali date) {
    final leaveType = ''.obs; // RxString

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return NoteDialog(date: date, leaveType: leaveType);
      },
    );
  }
}
