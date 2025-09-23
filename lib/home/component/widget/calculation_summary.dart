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
      duration: const Duration(milliseconds: 200),
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
      () => ExpansionTile(
        title: Text(
          widget.controller.summaryReport.value.isEmpty
              ? 'calculations_title'.tr
              : widget.controller.summaryReport.value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        leading: Icon(Icons.calculate, color: colorScheme.primary, size: 20),
        trailing: RotationTransition(
          turns: _iconTurns,
          child: Icon(
            Icons.expand_less,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        backgroundColor: colorScheme.surfaceContainer,
        collapsedBackgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        onExpansionChanged: (bool expanding) {
          setState(() {
            _isExpanded = expanding;
          });
          if (expanding) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: colorScheme.outlineVariant, height: 16),
                _buildSummaryRow(
                  context,
                  Icons.access_time,
                  widget.controller.presenceDuration.value,
                ),
                _buildSummaryRow(
                  context,
                  Icons.work,
                  widget.controller.effectiveWork.value,
                ),
                const SizedBox(height: 8),
                Text(
                  '${'tasks_title_section'.tr}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTaskList(context),
                const SizedBox(height: 8),
                Text(
                  '${'costs_title_section'.tr}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.primary,
                  ),
                ),
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
        Text(
          text.isEmpty ? 'no_effective_work'.tr : text,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => Column(
        children:
            widget.controller.taskDetails.isNotEmpty
                ? widget.controller.taskDetails
                    .map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.task,
                              color: colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList()
                : [
                  Text(
                    'no_tasks_recorded'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
      ),
    );
  }

  Widget _buildCostList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => Column(
        children:
            widget.controller.costDetails.isNotEmpty
                ? widget.controller.costDetails
                    .map(
                      (cost) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cost,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList()
                : [
                  Text(
                    'no_costs_recorded'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
      ),
    );
  }
}
