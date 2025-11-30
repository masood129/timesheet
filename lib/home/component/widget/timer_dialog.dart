import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../model/project_model.dart';
import '../../controller/task_controller.dart';

class TimerDialog extends StatelessWidget {
  const TimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final colorScheme = Theme.of(context).colorScheme;
    final today = Jalali.now();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.timer, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'project_timer'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Timer Display Cards
            Obx(() {
              final isProjectRunning = taskController.isTimerRunning.value;
              final isPersonalRunning = taskController.isPersonalTimerRunning.value;
              final projectDuration = taskController.timerDuration.value;
              final personalDuration = taskController.personalTimerDuration.value;
              final projectName = taskController.runningTimerProject.value?.projectName;

              return Column(
                children: [
                  // Project Timer Card
                  _buildTimerCard(
                    context: context,
                    title: 'project_timer'.tr,
                    duration: projectDuration,
                    projectName: projectName,
                    isRunning: isProjectRunning,
                    color: colorScheme.primary,
                    icon: Icons.work,
                  ),
                  const SizedBox(height: 16),
                  
                  // Personal Timer Card
                  _buildTimerCard(
                    context: context,
                    title: 'personal_timer'.tr,
                    duration: personalDuration,
                    projectName: null,
                    isRunning: isPersonalRunning,
                    color: colorScheme.secondary,
                    icon: Icons.person,
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 20),
            
            // Project Selector (Always enabled unless personal timer is running)
            Obx(() {
              final isPersonalRunning = taskController.isPersonalTimerRunning.value;
              return SearchableDropdown<Project>(
                value: taskController.selectedTimerProject.value,
                decoration: InputDecoration(
                  labelText: 'select_project'.tr,
                  prefixIcon: Icon(Icons.folder_special, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  enabled: !isPersonalRunning,
                  helperText: isPersonalRunning 
                      ? null 
                      : 'انتخاب پروژه جدید، تایمر قبلی را متوقف می‌کند',
                  helperStyle: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                searchHint: 'جستجوی پروژه...',
                items: taskController.projects
                    .map(
                      (project) => DropdownMenuItem(
                        value: project,
                        child: Text(
                          project.projectName,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isPersonalRunning
                    ? null
                    : (value) => taskController.selectedTimerProject.value = value,
              );
            }),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Obx(() {
              final isProjectRunning = taskController.isTimerRunning.value;
              final isPersonalRunning = taskController.isPersonalTimerRunning.value;
              final hasProject = taskController.selectedTimerProject.value != null;
              
              return Column(
                children: [
                  // Project Timer Buttons
                  Row(
                    children: [
                  // Start/Switch Project Timer Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: !hasProject || isPersonalRunning
                          ? null
                          : () async {
                              await taskController.startTimer();
                              Navigator.pop(context);
                            },
                      icon: Icon(
                        Icons.play_arrow,
                        color: (!hasProject || isPersonalRunning)
                            ? colorScheme.onSurface.withValues(alpha: 0.38)
                            : colorScheme.onPrimary,
                      ),
                      label: Text(
                        isProjectRunning 
                            ? 'شروع تایمر جدید'
                            : 'start_project_timer'.tr,
                        style: TextStyle(
                          color: (!hasProject || isPersonalRunning)
                              ? colorScheme.onSurface.withValues(alpha: 0.38)
                              : colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                      if (isProjectRunning) ...[
                        const SizedBox(width: 8),
                        // Stop Current Timer Button
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await taskController.stopTimer(today);
                              await taskController.saveDailyDetail();
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.stop,
                              color: colorScheme.onError,
                            ),
                            label: Text(
                              'توقف',
                              style: TextStyle(
                                color: colorScheme.onError,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Personal Timer Buttons
                  Row(
                    children: [
                  // Start Personal Timer Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isProjectRunning
                          ? null
                          : () async {
                              taskController.startPersonalTimer();
                              Navigator.pop(context);
                            },
                      icon: Icon(
                        Icons.play_arrow,
                        color: isProjectRunning
                            ? colorScheme.onSurface.withValues(alpha: 0.38)
                            : colorScheme.onSecondary,
                      ),
                      label: Text(
                        'start_personal_timer'.tr,
                        style: TextStyle(
                          color: isProjectRunning
                              ? colorScheme.onSurface.withValues(alpha: 0.38)
                              : colorScheme.onSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                      if (isPersonalRunning) ...[
                        const SizedBox(width: 8),
                        // Stop Personal Timer Button
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await taskController.stopPersonalTimer(today);
                              await taskController.saveDailyDetail();
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.stop,
                              color: colorScheme.onError,
                            ),
                            label: Text(
                              'توقف',
                              style: TextStyle(
                                color: colorScheme.onError,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard({
    required BuildContext context,
    required String title,
    required String duration,
    required String? projectName,
    required bool isRunning,
    required Color color,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isRunning
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isRunning ? null : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRunning ? color : colorScheme.outline.withValues(alpha: 0.3),
          width: isRunning ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRunning 
                  ? color.withValues(alpha: 0.2) 
                  : colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRunning ? icon : Icons.timer_off,
              color: isRunning ? color : colorScheme.onSurface.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                if (isRunning && projectName != null)
                  Text(
                    projectName,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isRunning ? color : colorScheme.onSurface.withValues(alpha: 0.5),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

