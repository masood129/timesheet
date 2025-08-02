import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/theme.dart';
import '../component/note_dialog.dart';
import '../controller/home_controller.dart';
import '../controller/task_controller.dart';
import '../model/project_model.dart';
import 'monthly_details_view.dart';

class CalendarView extends StatelessWidget {
  CalendarView({super.key});

  final HomeController homeController = Get.put(HomeController());
  final TaskController taskController = Get.put(TaskController());
  final themeController = Get.find<ThemeController>();

  void _showTimerDialog(BuildContext context) {
    final today = Jalali.now();
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(
            'تایمر پروژه'.tr,
            style: TextStyle(color: colorScheme.primary),
          ),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Project>(
                  value: taskController.selectedTimerProject.value,
                  hint: Text(
                    'انتخاب پروژه'.tr,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  decoration: InputDecoration(
                    labelText: 'پروژه'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      taskController.projects
                          .map(
                            (project) => DropdownMenuItem(
                              value: project,
                              child: Text(project.projectName),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    taskController.selectedTimerProject.value = value;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  taskController.isTimerRunning.value
                      ? 'تایمر در حال اجرا: ${taskController.timerDuration.value}'
                      : 'تایمر متوقف است',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'.tr, style: TextStyle(color: colorScheme.error)),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    taskController.selectedTimerProject.value == null
                        ? null
                        : () {
                          if (taskController.isTimerRunning.value) {
                            taskController.stopTimer(today);
                            Navigator.pop(context);
                            // Open NoteDialog to show the added task
                            showModalBottomSheet(
                              useSafeArea: true,
                              enableDrag: false,
                              isScrollControlled: true,
                              context: context,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => NoteDialog(date: today),
                            );
                          } else {
                            taskController.startTimer();
                            Navigator.pop(context);
                          }
                        },
                child: Text(
                  taskController.isTimerRunning.value
                      ? 'توقف تایمر'.tr
                      : 'شروع تایمر'.tr,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => _showTimerDialog(context),
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
                themeController.isDark.value
                    ? 'light_theme'.tr
                    : 'dark_theme'.tr,
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
                final newLocale =
                    Get.locale!.languageCode == 'fa'
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
        final today = Jalali.now();

        return ListView.builder(
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = Jalali(year, month, day);
            final isFriday = date.weekDay == 7;
            final cardStatus = homeController.getCardStatus(date, context);
            final effectiveWork = homeController.calculateEffectiveWork(date);
            final isToday =
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6,
              ),
              child: Card(
                elevation: isToday ? 8 : 4,
                shadowColor: isToday ? Colors.blue.withOpacity(0.3) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      isToday
                          ? BorderSide(color: Colors.amber[300]!, width: 1.5)
                          : BorderSide.none,
                ),
                child: Container(
                  decoration:
                      isToday
                          ? BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Colors.blue[800]!, Colors.blue[200]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          )
                          : BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                  child: ExpansionTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? colorScheme.outline
                                  : colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor:
                            isToday
                                ? Colors.tealAccent[400]
                                : cardStatus['avatarColor'],
                        child: Icon(
                          isToday
                              ? Icons.event_available
                              : cardStatus['avatarIcon'],
                          color:
                              isToday
                                  ? Colors.white
                                  : cardStatus['avatarIconColor'],
                        ),
                      ),
                    ),
                    title: Text(
                      '${date.formatter.wN} $day ${date.formatter.mN} ${date.year}',
                      style: TextStyle(
                        color:
                            isToday
                                ? Colors.white
                                : isFriday
                                ? colorScheme.error
                                : null,
                        fontWeight:
                            isToday || isFriday
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      effectiveWork.isNotEmpty
                          ? effectiveWork
                          : 'no_effective_work'.tr,
                      style: TextStyle(
                        color:
                            isToday
                                ? Colors.white70
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    onExpansionChanged: (expanded) {
                      if (expanded && cardStatus['leaveType'] == null) {
                        // Optionally fetch details for the specific day if needed
                      }
                    },
                    trailing: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: isToday ? Colors.white : null,
                      ),
                      onPressed: () {
                        taskController.loadDailyDetail(
                          date,
                          homeController.dailyDetails,
                        );
                        showModalBottomSheet(
                          useSafeArea: true,
                          enableDrag: false,
                          isScrollControlled: true,
                          context: context,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => NoteDialog(date: date),
                        );
                      },
                    ),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cardStatus['leaveType'] != null) ...[
                                if (cardStatus['leaveType'] == 'کاری') ...[
                                  if (cardStatus['isComplete'])
                                    Text(
                                      'وضعیت: کامل'.tr,
                                      style: TextStyle(
                                        color: colorScheme.completedStatus,
                                      ),
                                    ),
                                  if (!cardStatus['isComplete'])
                                    Text(
                                      'وضعیت: ناقص'.tr,
                                      style: TextStyle(
                                        color: colorScheme.incompleteStatus,
                                      ),
                                    ),
                                ] else
                                  Text(
                                    'وضعیت روز: ${cardStatus['leaveType']}'.tr,
                                  ),
                              ],
                              const SizedBox(height: 8),
                              if (cardStatus['leaveType'] != null) ...[
                                if (homeController.dailyDetails
                                        .firstWhereOrNull(
                                          (d) =>
                                              d.date ==
                                              '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                        )
                                        ?.arrivalTime !=
                                    null)
                                  Text(
                                    '${'arrival_time'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.arrivalTime}',
                                  ),
                                if (homeController.dailyDetails
                                        .firstWhereOrNull(
                                          (d) =>
                                              d.date ==
                                              '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                        )
                                        ?.leaveTime !=
                                    null)
                                  Text(
                                    '${'leave_time'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.leaveTime}',
                                  ),
                                if (homeController.dailyDetails
                                        .firstWhereOrNull(
                                          (d) =>
                                              d.date ==
                                              '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                        )
                                        ?.personalTime !=
                                    null)
                                  Text(
                                    '${'personal_time'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.personalTime} ${'minute'.tr}',
                                  ),
                                if (homeController.dailyDetails
                                        .firstWhereOrNull(
                                          (d) =>
                                              d.date ==
                                              '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                        )
                                        ?.goCost !=
                                    null)
                                  Text(
                                    '${'go_cost'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.goCost}',
                                  ),
                                if (homeController.dailyDetails
                                        .firstWhereOrNull(
                                          (d) =>
                                              d.date ==
                                              '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                        )
                                        ?.returnCost !=
                                    null)
                                  Text(
                                    '${'return_cost'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.returnCost}',
                                  ),
                                if (homeController.dailyDetails
                                    .firstWhereOrNull(
                                      (d) =>
                                          d.date ==
                                          '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                    )!
                                    .personalCarCosts
                                    .isNotEmpty)
                                  Text(
                                    '${'personal_car_cost'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.personalCarCosts.map((cost) => '${cost.kilometers ?? 0} km: ${cost.cost ?? 0}').join(', ')}',
                                  ),
                                if (homeController.dailyDetails
                                        .firstWhereOrNull(
                                          (d) =>
                                              d.date ==
                                              '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                        )
                                        ?.description !=
                                    null)
                                  Text(
                                    '${'description'.tr}: ${homeController.dailyDetails.firstWhereOrNull((d) => d.date == '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}')!.description}',
                                  ),
                                if (homeController.dailyDetails
                                    .firstWhereOrNull(
                                      (d) =>
                                          d.date ==
                                          '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                    )!
                                    .tasks
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'tasks'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  ...homeController.dailyDetails
                                      .firstWhereOrNull(
                                        (d) =>
                                            d.date ==
                                            '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                      )!
                                      .tasks
                                      .map((task) {
                                        final project = homeController
                                            .dailyDetails
                                            .firstWhere(
                                              (d) => d.tasks.any(
                                                (t) =>
                                                    t.projectId ==
                                                    task.projectId,
                                              ),
                                              orElse:
                                                  () =>
                                                      homeController
                                                          .dailyDetails
                                                          .firstWhereOrNull(
                                                            (d) =>
                                                                d.date ==
                                                                '${date.toGregorian().year}-${date.toGregorian().month.toString().padLeft(2, '0')}-${date.toGregorian().day.toString().padLeft(2, '0')}',
                                                          )!,
                                            )
                                            .tasks
                                            .firstWhere(
                                              (t) =>
                                                  t.projectId == task.projectId,
                                              orElse: () => task,
                                            );
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            '- ${project.description ?? 'no_description'.tr} (${task.duration ?? 0} ${'minute'.tr})',
                                          ),
                                        );
                                      }),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
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
