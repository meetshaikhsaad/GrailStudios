import '../../helpers/ExportImports.dart';

class EditTaskController extends GetxController {
  final int taskId;

  EditTaskController({required this.taskId});

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var reqQuantityController = TextEditingController();
  var reqDurationController = TextEditingController();
  var reqOutfitTagsController = TextEditingController();

  var selectedStatus = ''.obs;
  var selectedPriority = ''.obs;
  var selectedDueDate = Rxn<DateTime>();

  final List<String> statusOptions = ['To Do', 'Blocked', 'Completed', 'Missed'];
  final List<String> priorityOptions = ['Low', 'Medium', 'High'];

  @override
  void onInit() {
    super.onInit();
    fetchTask();
  }

  Future<void> fetchTask() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await ApiService().callApiWithMap('tasks/$taskId', 'GET', mapData: {});
      if (response is Map<String, dynamic>) {
        final task = Task.fromJson(response);

        titleController.text = task.title ?? '';
        descriptionController.text = task.description ?? '';
        reqQuantityController.text = task.reqQuantity?.toString() ?? '0';
        reqDurationController.text = task.reqDurationMin?.toString() ?? '0';
        reqOutfitTagsController.text = task.reqOutfitTags?.join(', ') ?? '';
        selectedStatus.value = task.status ?? 'To Do';
        selectedPriority.value = task.priority ?? 'Low';
        selectedDueDate.value = task.dueDate;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Only update editable fields
  Future<void> updateTask() async {
    final data = {
      "title": titleController.text,
      "description": descriptionController.text,
      "status": selectedStatus.value,
      "priority": selectedPriority.value,
      "due_date": selectedDueDate.value?.toIso8601String(),
      "req_quantity": int.tryParse(reqQuantityController.text) ?? 0,
      "req_duration_min": int.tryParse(reqDurationController.text) ?? 0,
      "req_outfit_tags": reqOutfitTagsController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    };

    try {
      final response = await ApiService().callApiWithMap('tasks/$taskId', 'PUT', mapData: data);
      if (response is Map<String, dynamic>) {
        Get.back();
        final taskAssignerController = Get.find<TaskAssignerController>();
        taskAssignerController.fetchTasks();
        Get.snackbar(
          'Success',
          'Task updated successfully!',
          backgroundColor: grailGold,
          colorText: Colors.white,
        );

      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
