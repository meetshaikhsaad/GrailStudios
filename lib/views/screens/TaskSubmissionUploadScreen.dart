import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';
class TaskSubmissionUploadScreen extends StatelessWidget {
  final int taskId;
  TaskSubmissionUploadScreen({super.key, required this.taskId});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskSubmissionUploadController(taskId));

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Submit Task',
        scaffoldKey: scaffoldKey,
        showBackButton: true,
      ),
      backgroundColor: Colors.white,

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: grailGold));
        }

        if (controller.hasError.value) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final task = controller.task.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TASK HEADER
              Text(task.title,
                  style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(task.description ?? '',
                  style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  _chip(task.priority ?? 'Medium', Colors.red),
                  _chip(task.context ?? 'General', Colors.blue),
                  _chip(task.status, _getStatusColor(task.status)),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: grailGold),
                  const SizedBox(width: 8),
                  Text(
                    task.dueDate != null
                        ? DateFormat('yyyy-MM-dd').format(task.dueDate!)
                        : 'No due date',
                  ),
                ],
              ),

              const Divider(height: 30),

              /// UPLOAD BOX
              const Text('Upload Work',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: controller.pickFiles,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Upload Deliverables',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// FILE LIST
              Obx(() => Column(
                children: controller.uploadItems.map((item) {
                  return ListTile(
                    leading: item.isUploading.value
                        ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle,
                        color: grailGold),
                    title: Text(item.file.name),
                    subtitle: item.isUploading.value
                        ? const Text('Uploading...')
                        : const Text('Uploaded'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () =>
                          controller.uploadItems.remove(item),
                    ),
                  );
                }).toList(),
              )),

              const SizedBox(height: 30),

              /// SUBMIT BUTTON
              Obx(() => ElevatedButton(
                onPressed: controller.isUploadingFiles.value
                    ? null
                    : controller.submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: grailGold,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text('Submit Work',
                    style: TextStyle(color: Colors.white)),
              )),
            ],
          ),
        );
      }),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
          TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
