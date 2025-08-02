import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/task_controller.dart';

class CalculationSummary extends StatelessWidget {
  final TaskController controller;

  const CalculationSummary({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
          () => ExpansionTile(
        title: Text(
          controller.summaryReport.value.isEmpty ? 'محاسبات'.tr : controller.summaryReport.value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary),
        ),
        leading: Icon(Icons.calculate, color: colorScheme.primary, size: 20),
        backgroundColor: colorScheme.surfaceContainer,
        collapsedBackgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: colorScheme.outlineVariant, height: 16),
                _buildSummaryRow(context, Icons.access_time, controller.presenceDuration.value),
                _buildSummaryRow(context, Icons.work, controller.effectiveWork.value),
                const SizedBox(height: 8),
                Text('زمان وظایف به تفکیک:'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.primary)),
                const SizedBox(height: 8),
                _buildTaskList(context),
                const SizedBox(height: 8),
                Text('هزینه‌ها به تفکیک:'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.primary)),
                const SizedBox(height: 8),
                _buildCostList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.secondary, size: 18),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
          () => Column(
        children: controller.taskDetails.isNotEmpty
            ? controller.taskDetails.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.task, color: colorScheme.secondary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(task, style: TextStyle(fontSize: 14, color: colorScheme.onSurface))),
            ],
          ),
        ),
        ).toList()
            : [Text('وظیفه‌ای ثبت نشده است'.tr, style: TextStyle(fontSize: 14, color: colorScheme.onSurface))],
      ),
    );
  }

  Widget _buildCostList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
          () => Column(
        children: controller.costDetails.isNotEmpty
            ? controller.costDetails.map((cost) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: colorScheme.secondary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(cost, style: TextStyle(fontSize: 14, color: colorScheme.onSurface))),
            ],
          ),
        ),
        ).toList()
            : [Text('هزینه‌ای ثبت نشده است'.tr, style: TextStyle(fontSize: 14, color: colorScheme.onSurface))],
      ),
    );
  }
}