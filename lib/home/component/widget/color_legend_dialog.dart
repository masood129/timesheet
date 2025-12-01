import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// نمایش دیالوگ راهنمای رنگ‌ها
void showColorLegendDialog(BuildContext context) {
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
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
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
  final iconColor =
      brightness == Brightness.dark ? Colors.white : Colors.black87;

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
          child: Icon(icon, size: iconSize * 0.65, color: iconColor),
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

