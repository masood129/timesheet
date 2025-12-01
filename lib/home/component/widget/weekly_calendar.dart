import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
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

    Get.defaultDialog(
      title: 'راهنمای رنگ‌های تقویم',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'BNazanin',
        color: colorScheme.primary,
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // رنگ‌های وضعیت بازه (اگر ماه سفارشی باشد)
              Text(
                'وضعیت روزها در بازه:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BNazanin',
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                context,
                color: colorScheme.surface,
                label: 'روز عادی (در بازه ماه)',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.purple[100]!,
                label: 'اضافه شده (از ماه دیگر)',
                icon: Icons.add_circle_outline,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.grey[300]!,
                label: 'حذف شده (خارج از بازه)',
                icon: Icons.remove_circle_outline,
              ),
              const Divider(height: 24),
              
              // رنگ‌های وضعیت کاری
              Text(
                'وضعیت کاری:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BNazanin',
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                context,
                color: Colors.teal[700]!,
                label: 'روز امروز',
                icon: Icons.today_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.green[600]!,
                label: 'روز کاری کامل',
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.amber[700]!,
                label: 'روز کاری ناقص',
                icon: Icons.warning_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.red[700]!,
                label: 'تعطیل رسمی',
                icon: Icons.event_busy_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.deepOrange[600]!,
                label: 'جمعه',
                icon: Icons.weekend_rounded,
              ),
              const Divider(height: 24),
              
              // رنگ‌های انواع مرخصی
              Text(
                'انواع مرخصی:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BNazanin',
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                context,
                color: Colors.blue[600]!,
                label: 'مرخصی استحقاقی',
                icon: Icons.beach_access_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.pink[700]!,
                label: 'مرخصی استعلاجی',
                icon: Icons.local_hospital_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.purple[600]!,
                label: 'مرخصی هدیه',
                icon: Icons.card_giftcard_rounded,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                context,
                color: Colors.deepPurple[500]!,
                label: 'ماموریت',
                icon: Icons.flight_takeoff_rounded,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
      radius: 12,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'متوجه شدم',
            style: TextStyle(
              fontFamily: 'BNazanin',
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, size: 14, color: colorScheme.primary),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'BNazanin',
            color: colorScheme.onSurface,
          ),
        ),
      ],
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

