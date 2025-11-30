import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesheet/home/controller/project_access_controller.dart';
import '../../core/utils/page_title_manager.dart';

class ProjectAccessPage extends StatelessWidget {
  const ProjectAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set page title when building the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PageTitleManager.setTitle('دسترسی پروژه‌ها');
    });
    
    final controller = Get.put(ProjectAccessController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تنظیمات دسترسی پروژه‌ها'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refresh(),
              tooltip: 'بروزرسانی',
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadProjects(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          if (controller.projects.isEmpty) {
            return const Center(
              child: Text(
                'هیچ پروژه‌ای یافت نشد',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.projects.length,
              itemBuilder: (context, index) {
                final project = controller.projects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          project.hasAccess
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                      child: Icon(
                        project.hasAccess ? Icons.check_circle : Icons.cancel,
                        color: project.hasAccess ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(
                      project.projectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      project.hasAccess
                          ? 'فعال - این پروژه در لیست شما نمایش داده می‌شود'
                          : 'غیرفعال - این پروژه در لیست شما نمایش داده نمی‌شود',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            project.hasAccess
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Switch(
                      value: project.hasAccess,
                      onChanged: (value) {
                        controller.toggleProjectAccess(project.id);
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
