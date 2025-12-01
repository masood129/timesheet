import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
import '../../../core/theme/theme.dart';
import '../../controller/home_controller.dart';
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size: fontSize + 4,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'BNazanin',
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

    Get.defaultDialog(
      title: 'جزئیات روز ${date.formatter.wN} ${date.day} ${date.formatter.mN}',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'BNazanin',
        color: colorScheme.primary,
      ),
      content: Obx(() {
        final homeController = Get.find<HomeController>();
        final effectiveWork = homeController.calculateEffectiveWork(date);
        final holiday = homeController.getHolidayForDate(date);
        final cardStatus = homeController.getCardStatus(date, context);
        final note = homeController.getNoteForDate(date);
        final periodStatus = homeController.getDayPeriodStatus(date);

        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(context, 'کار مفید', effectiveWork),
                const SizedBox(height: 8),
                if (homeController.isCurrentMonthPeriodCustom)
                  _buildDetailRow(
                    context,
                    'وضعیت بازه',
                    periodStatus.displayName,
                  ),
                const SizedBox(height: 8),
                if (holiday != null) ...[
                  _buildHolidaySection(context, holiday),
                  const SizedBox(height: 8),
                ],
                if (note != null && note.isNotEmpty)
                  _buildDetailRow(context, 'یادداشت', note),
                _buildDetailRow(
                  context,
                  'وضعیت',
                  cardStatus['leaveType'] == LeaveType.work ||
                          cardStatus['leaveType'] == LeaveType.mission
                      ? (cardStatus['isComplete']
                          ? 'روز کاری: کامل'
                          : 'روز کاری: ناقص')
                      : cardStatus['leaveType']?.displayName ?? 'بدون اطلاعات',
                ),
              ],
            ),
          ),
        );
      }),
      backgroundColor: colorScheme.surface,
      radius: 12,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'بستن',
            style: TextStyle(
              fontFamily: 'BNazanin',
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'BNazanin',
              color: colorScheme.primary,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'BNazanin',
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaySection(
    BuildContext context,
    Map<String, dynamic> holiday,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final events = holiday['events'] as List<dynamic>? ?? [];
    final isHoliday = holiday['isHoliday'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHoliday ? 'تعطیل' : 'رویدادها',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'BNazanin',
            color: isHoliday ? colorScheme.error : colorScheme.primary,
            fontSize: 16,
          ),
        ),
        ...events.map((event) {
          final description = event['description'] as String;
          final additionalDescription =
              event['additional_description'] as String? ?? '';
          final isEventHoliday = event['isHoliday'] == true;
          final isReligious = event['isReligious'] == true;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '- $description${additionalDescription.isNotEmpty ? ' ($additionalDescription)' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'BNazanin',
                color:
                    isHoliday
                        ? colorScheme.error
                        : isEventHoliday
                        ? colorScheme.error
                        : isReligious
                        ? colorScheme.secondary
                        : colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }),
      ],
    );
  }
}

