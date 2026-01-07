import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/task_controller.dart';

class CalculationSummary extends StatefulWidget {
  final TaskController controller;

  const CalculationSummary({super.key, required this.controller});

  @override
  State<CalculationSummary> createState() => _CalculationSummaryState();
}

class _CalculationSummaryState extends State<CalculationSummary>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconTurns = _animationController.drive(
      Tween<double>(begin: 0.0, end: 0.5),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.tertiary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.tertiary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // هدر با گرادیانت زیبا
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calculate_rounded,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.controller.summaryReport.value.isEmpty
                            ? 'calculations_title'.tr
                            : widget.controller.summaryReport.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _iconTurns,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // محتوای قابل باز شدن
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // زمان حضور
                    _buildTimeInfoCard(
                      context,
                      Icons.access_time_rounded,
                      widget.controller.presenceDuration.value,
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      colorScheme.onSurface,
                    ),

                    const Divider(height: 20, thickness: 1),

                    // بخش پروژه‌ها
                    _buildSectionHeader(
                      context,
                      'tasks_title_section'.tr,
                      Icons.task_alt_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildTaskList(context),

                    const Divider(height: 20, thickness: 1),

                    // بخش هزینه‌ها
                    _buildSectionHeader(
                      context,
                      'costs_title_section'.tr,
                      Icons.monetization_on_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildCostList(context),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoCard(
    BuildContext context,
    IconData icon,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: textColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.isEmpty ? 'no_effective_work'.tr : text,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: colorScheme.onSurface,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => widget.controller.taskDetails.isNotEmpty
          ? Column(
              children: widget.controller.taskDetails
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildDetailItem(
                        context,
                        Icons.check_circle_rounded,
                        task,
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        colorScheme.onSurface,
                      ),
                    ),
                  )
                  .toList(),
            )
          : _buildEmptyState(
              context,
              'no_tasks_recorded'.tr,
              Icons.task_outlined,
            ),
    );
  }

  Widget _buildCostList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => widget.controller.costDetails.isNotEmpty
          ? Column(
              children: widget.controller.costDetails
                  .map(
                    (cost) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildDetailItem(
                        context,
                        Icons.attach_money_rounded,
                        cost,
                        colorScheme.errorContainer,
                        colorScheme.onErrorContainer,
                      ),
                    ),
                  )
                  .toList(),
            )
          : _buildEmptyState(
              context,
              'no_costs_recorded'.tr,
              Icons.money_off_rounded,
            ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String text,
    Color backgroundColor,
    Color iconColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
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
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
