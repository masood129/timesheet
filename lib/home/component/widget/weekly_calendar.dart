import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../core/theme/theme.dart';
import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';
import 'grid_calendar_day_card.dart';

class WeeklyCalendarWidget extends StatelessWidget {
  const WeeklyCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        final colorScheme = Theme.of(context).colorScheme;
        final weekDays = homeController.getCurrentWeekDays();
        final screenWidth = MediaQuery.of(context).size.width;
        
        // محاسبه اندازه‌های responsive بر اساس عرض صفحه
        final double maxCalendarWidth;
        final double headerFontSize;
        final double horizontalPadding;
        
        if (screenWidth > 1400) {
          maxCalendarWidth = 1400;
          headerFontSize = 16;
          horizontalPadding = 16;
        } else if (screenWidth > 1000) {
          maxCalendarWidth = 1200;
          headerFontSize = 15;
          horizontalPadding = 12;
        } else if (screenWidth > 600) {
          maxCalendarWidth = screenWidth * 0.95;
          headerFontSize = 14;
          horizontalPadding = 8;
        } else {
          maxCalendarWidth = screenWidth;
          headerFontSize = 13;
          horizontalPadding = 6;
        }

        return Column(
          children: [
            // اطلاعات هفته
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'هفته: ${weekDays.first.formatter.d} تا ${weekDays.last.formatter.d}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BNazanin',
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        onPressed: homeController.previousWeek,
                        tooltip: 'هفته قبل',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.today,
                          color: colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        onPressed: () {
                          homeController.currentWeekStartDate.value = Jalali.now();
                          homeController.update();
                        },
                        tooltip: 'هفته جاری',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        onPressed: homeController.nextWeek,
                        tooltip: 'هفته بعد',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Grid هفتگی
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxCalendarWidth, // عرض responsive
                  ),
                  child: Column(
                    children: [
                      // هدر روزهای هفته - با همان ساختار Grid
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 4.0,
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 7,
                          childAspectRatio: 2.5,
                          children: [
                            'شنبه', // index 0, weekday 1
                            'یک‌شنبه', // index 1, weekday 2
                            'دوشنبه', // index 2, weekday 3
                            'سه‌شنبه', // index 3, weekday 4
                            'چهارشنبه', // index 4, weekday 5
                            'پنج‌شنبه', // index 5, weekday 6
                            'جمعه', // index 6, weekday 7
                          ].asMap().entries.map((entry) {
                            return Center(
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BNazanin',
                                  color:
                                      entry.key == 6
                                          ? colorScheme.error
                                          : colorScheme.onSurface,
                                  fontSize: headerFontSize,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Grid هفتگی
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(horizontalPadding),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: screenWidth > 1000 ? 8.0 : 6.0,
                              mainAxisSpacing: screenWidth > 1000 ? 8.0 : 6.0,
                              childAspectRatio: 0.7, // ارتفاع بیشتر از عرض
                            ),
                            itemCount: 7,
                            itemBuilder: (context, index) {
                              return GridCalendarDayCard(date: weekDays[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // دکمه‌های جزئیات و راهنما
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // دکمه راهنمای رنگ‌ها
                  Tooltip(
                    message: 'راهنمای رنگ‌ها',
                    child: InkWell(
                      onTap: () => _showColorLegendDialog(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.secondary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              color: colorScheme.onSecondaryContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'راهنما',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'BNazanin',
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // دکمه جزئیات روز امروز
                  ElevatedButton(
                    onPressed: () {
                      _showDayDetailsDialog(context, Jalali.now());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 4,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'جزئیات روز امروز',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BNazanin',
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// نمایش دیالوگ راهنمای رنگ‌ها
  void _showColorLegendDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // محاسبه اندازه‌های responsive
    final double dialogWidth = screenWidth > 600 ? 550 : screenWidth * 0.95;
    final double titleFontSize = screenWidth > 600 ? 24 : 20;
    final double headerFontSize = screenWidth > 600 ? 18 : 16;
    final double itemFontSize = screenWidth > 600 ? 16 : 15;
    final double iconSize = screenWidth > 600 ? 32 : 28;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // هدر دیالوگ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.palette_rounded,
                          color: colorScheme.onPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'راهنمای رنگ‌های تقویم',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BNazanin',
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onPrimary,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                // محتوای دیالوگ
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // بخش اول: وضعیت بازه
                        _buildSectionHeader(
                          context,
                          'وضعیت روزها در بازه:',
                          Icons.date_range_rounded,
                          headerFontSize,
                        ),
                        const SizedBox(height: 12),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.surface,
                          label: 'روز عادی (در بازه ماه)',
                          icon: Icons.check_circle_outline,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.addedDayColor,
                          label: 'اضافه شده (از ماه دیگر)',
                          icon: Icons.add_circle_outline,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.removedDayColor,
                          label: 'حذف شده (خارج از بازه)',
                          icon: Icons.remove_circle_outline,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        
                        const Divider(height: 32, thickness: 1.5),
                        
                        // بخش دوم: وضعیت کاری
                        _buildSectionHeader(
                          context,
                          'وضعیت کاری:',
                          Icons.work_rounded,
                          headerFontSize,
                        ),
                        const SizedBox(height: 12),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.todayColor,
                          label: 'روز امروز',
                          icon: Icons.today_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.workCompleteColor,
                          label: 'روز کاری کامل',
                          icon: Icons.check_circle_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.workIncompleteColor,
                          label: 'روز کاری ناقص',
                          icon: Icons.warning_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.holidayColor,
                          label: 'تعطیل رسمی',
                          icon: Icons.event_busy_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.fridayColor,
                          label: 'جمعه',
                          icon: Icons.weekend_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        
                        const Divider(height: 32, thickness: 1.5),
                        
                        // بخش سوم: انواع مرخصی
                        _buildSectionHeader(
                          context,
                          'انواع مرخصی:',
                          Icons.event_available_rounded,
                          headerFontSize,
                        ),
                        const SizedBox(height: 12),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.annualLeaveColor,
                          label: 'مرخصی استحقاقی',
                          icon: Icons.beach_access_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.sickLeaveColor,
                          label: 'مرخصی استعلاجی',
                          icon: Icons.local_hospital_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.giftLeaveColor,
                          label: 'مرخصی هدیه',
                          icon: Icons.card_giftcard_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                        const SizedBox(height: 10),
                        _buildDialogLegendItem(
                          context,
                          color: colorScheme.missionColor,
                          label: 'ماموریت',
                          icon: Icons.flight_takeoff_rounded,
                          itemFontSize: itemFontSize,
                          iconSize: iconSize,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // دکمه بستن
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'متوجه شدم',
                        style: TextStyle(
                          fontSize: itemFontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BNazanin',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    double fontSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size: fontSize + 2,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: FontConfig.persianFont,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required IconData icon,
    required double itemFontSize,
    required double iconSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // تعیین رنگ آیکون بر اساس روشنایی رنگ پس‌زمینه
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final iconColor = brightness == Brightness.dark ? Colors.white : Colors.black87;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize + 12,
            height: iconSize + 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: iconSize * 0.65,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: 'BNazanin',
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetailsDialog(BuildContext context, Jalali date) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // محاسبه اندازه‌های responsive
    final double dialogWidth = screenWidth > 700 ? 650 : screenWidth * 0.95;
    final double titleFontSize = screenWidth > 600 ? 24 : 20;
    final double headerFontSize = screenWidth > 600 ? 18 : 16;
    final double itemFontSize = screenWidth > 600 ? 16 : 15;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // هدر دیالوگ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جزئیات روز',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontConfig.persianFont,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.formatter.wN} ${date.day} ${date.formatter.mN}',
                            style: TextStyle(
                              fontSize: headerFontSize - 2,
                              fontFamily: FontConfig.persianFont,
                              color: colorScheme.onPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // محتوای دیالوگ
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Obx(() {
                    final homeController = Get.find<HomeController>();
                    final cardStatus = homeController.getCardStatus(date, context);
                    final leaveType = cardStatus['leaveType'] as LeaveType?;
                    final isComplete = cardStatus['isComplete'] as bool;

                    // دریافت daily detail
                    final gregorianDate = date.toGregorian();
                    final formattedDate =
                        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
                    
                    final detail = homeController.dailyDetails.firstWhereOrNull(
                      (d) => d.date == formattedDate,
                    );

                    // دریافت TaskController برای دسترسی به پروژه‌ها
                    TaskController? taskController;
                    try {
                      taskController = Get.find<TaskController>();
                    } catch (e) {
                      taskController = null;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // وضعیت روز
                        _buildSectionHeader(
                          context,
                          'وضعیت روز',
                          Icons.calendar_today_rounded,
                          headerFontSize,
                        ),
                        const SizedBox(height: 16),
                        _buildStatusCard(
                          context,
                          leaveType: leaveType,
                          isComplete: isComplete,
                          itemFontSize: itemFontSize,
                        ),

                        const Divider(height: 32, thickness: 1.5),

                        // ساعت کار شخصی
                        _buildSectionHeader(
                          context,
                          'ساعت کار شخصی',
                          Icons.person_rounded,
                          headerFontSize,
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(
                          context,
                          icon: Icons.person_rounded,
                          iconColor: colorScheme.secondary,
                          label: 'ساعت کار شخصی',
                          value: detail?.personalTime != null
                              ? _formatMinutesToHours(detail!.personalTime!)
                              : '0:00',
                          itemFontSize: itemFontSize,
                        ),

                        const Divider(height: 32, thickness: 1.5),

                        // دیرکرد
                        if (detail?.arrivalTime != null) ...[
                          _buildSectionHeader(
                            context,
                            'دیرکرد',
                            Icons.schedule_rounded,
                            headerFontSize,
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryCard(
                            context,
                            icon: Icons.schedule_rounded,
                            iconColor: _calculateDelay(detail!.arrivalTime!) > 0
                                ? colorScheme.error
                                : Colors.green,
                            label: 'دیرکرد',
                            value: _formatDelay(_calculateDelay(detail.arrivalTime!)),
                            itemFontSize: itemFontSize,
                          ),
                          const Divider(height: 32, thickness: 1.5),
                        ],

                        // پروژه‌ها
                        _buildSectionHeader(
                          context,
                          'پروژه‌ها',
                          Icons.folder_rounded,
                          headerFontSize,
                        ),
                        const SizedBox(height: 16),
                        if (detail?.tasks.isNotEmpty == true) ...[
                          ...detail!.tasks.map((task) {
                            // اگر projectName از بک‌اند آمده باشد، از آن استفاده می‌کنیم
                            // در غیر این صورت از لیست projects جستجو می‌کنیم
                            final projectName = task.projectName ??
                                taskController?.projects
                                    .firstWhereOrNull(
                                      (p) => p.id == task.projectId,
                                    )?.projectName ??
                                'پروژه حذف شده #${task.projectId}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildProjectItem(
                                context,
                                projectName: projectName,
                                hours: task.duration != null
                                    ? _formatMinutesToHours(task.duration!)
                                    : '0:00',
                                itemFontSize: itemFontSize,
                              ),
                            );
                          }),
                        ] else
                          _buildEmptyState(
                            context,
                            'پروژه‌ای ثبت نشده',
                            itemFontSize,
                          ),

                        const Divider(height: 32, thickness: 1.5),

                        // مرخصی
                        if (leaveType != null && leaveType != LeaveType.work) ...[
                          _buildSectionHeader(
                            context,
                            'مرخصی',
                            Icons.event_available_rounded,
                            headerFontSize,
                          ),
                          const SizedBox(height: 16),
                          _buildLeaveItem(
                            context,
                            leaveType: leaveType,
                            itemFontSize: itemFontSize,
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ),

              // دکمه بستن
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'بستن',
                      style: TextStyle(
                        fontSize: itemFontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontConfig.persianFont,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required LeaveType? leaveType,
    required bool isComplete,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (leaveType == null) {
      statusText = 'بدون اطلاعات';
      statusColor = colorScheme.outline;
      statusIcon = Icons.help_outline_rounded;
    } else if (leaveType == LeaveType.work || leaveType == LeaveType.mission) {
      statusText = isComplete ? 'روز کاری: کامل' : 'روز کاری: ناقص';
      statusColor = isComplete ? Colors.green : colorScheme.error;
      statusIcon = isComplete ? Icons.check_circle_rounded : Icons.warning_rounded;
    } else {
      statusText = leaveType.displayName;
      switch (leaveType) {
        case LeaveType.annualLeave:
          statusColor = colorScheme.annualLeaveColor;
          statusIcon = Icons.beach_access_rounded;
          break;
        case LeaveType.sickLeave:
          statusColor = colorScheme.sickLeaveColor;
          statusIcon = Icons.local_hospital_rounded;
          break;
        case LeaveType.giftLeave:
          statusColor = colorScheme.giftLeaveColor;
          statusIcon = Icons.card_giftcard_rounded;
          break;
        case LeaveType.mission:
          statusColor = colorScheme.missionColor;
          statusIcon = Icons.flight_takeoff_rounded;
          break;
        default:
          statusColor = colorScheme.outline;
          statusIcon = Icons.event_rounded;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: FontConfig.persianFont,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor.withValues(alpha: 0.1),
            iconColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: FontConfig.persianFont,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: itemFontSize + 2,
              fontFamily: FontConfig.persianFont,
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context, {
    required String projectName,
    required String hours,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              projectName,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: FontConfig.persianFont,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: itemFontSize,
              fontFamily: FontConfig.persianFont,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveItem(
    BuildContext context, {
    required LeaveType leaveType,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // تعیین رنگ و آیکون بر اساس نوع مرخصی
    Color leaveColor;
    IconData leaveIcon;
    
    switch (leaveType) {
      case LeaveType.annualLeave:
        leaveColor = colorScheme.annualLeaveColor;
        leaveIcon = Icons.beach_access_rounded;
        break;
      case LeaveType.sickLeave:
        leaveColor = colorScheme.sickLeaveColor;
        leaveIcon = Icons.local_hospital_rounded;
        break;
      case LeaveType.giftLeave:
        leaveColor = colorScheme.giftLeaveColor;
        leaveIcon = Icons.card_giftcard_rounded;
        break;
      case LeaveType.mission:
        leaveColor = colorScheme.missionColor;
        leaveIcon = Icons.flight_takeoff_rounded;
        break;
      default:
        leaveColor = colorScheme.outline;
        leaveIcon = Icons.event_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: leaveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: leaveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            leaveIcon,
            color: leaveColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              leaveType.displayName,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: FontConfig.persianFont,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String message,
    double itemFontSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: itemFontSize - 1,
              fontFamily: FontConfig.persianFont,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMinutesToHours(int totalMinutes) {
    if (totalMinutes == 0) return '0:00';
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  int _calculateDelay(String arrivalTime) {
    try {
      // فرض: ساعت شروع کار استاندارد 9:00 صبح است
      // می‌توانید این مقدار را از تنظیمات یا API دریافت کنید
      const int standardWorkStartHour = 9;
      const int standardWorkStartMinute = 0;
      
      final parts = arrivalTime.split(':');
      if (parts.length < 2) return 0;
      
      final arrivalHour = int.parse(parts[0]);
      final arrivalMinute = int.parse(parts[1]);
      
      final arrivalMinutes = arrivalHour * 60 + arrivalMinute;
      final standardMinutes = standardWorkStartHour * 60 + standardWorkStartMinute;
      
      final delay = arrivalMinutes - standardMinutes;
      return delay > 0 ? delay : 0;
    } catch (e) {
      return 0;
    }
  }

  String _formatDelay(int delayMinutes) {
    if (delayMinutes == 0) return 'بدون دیرکرد';
    
    final hours = delayMinutes ~/ 60;
    final minutes = delayMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '$hours ساعت و $minutes دقیقه';
    } else if (hours > 0) {
      return '$hours ساعت';
    } else {
      return '$minutes دقیقه';
    }
  }
}

