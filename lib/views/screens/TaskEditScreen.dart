import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class TaskEditScreen extends StatelessWidget {
  final int taskId;

  TaskEditScreen({super.key, required this.taskId});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final TaskEditController controller = Get.put(TaskEditController(taskId: taskId));
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Edit Task',
        scaffoldKey: scaffoldKey,
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: grailGold));
        }
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.errorMessage.value}', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchTask(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(35, 5, 35, 40),
          child: Column(
            children: [
              // Title
              _buildTextField('Title', controller.titleController),
              const SizedBox(height: 20),
              // Description
              _buildTextField('Description', controller.descriptionController, maxLines: 4),
              const SizedBox(height: 20),
              // Status
              _buildDropdown('Status', controller.statusOptions, controller.selectedStatus.value,
                      (value) => controller.selectedStatus.value = value!),
              const SizedBox(height: 20),
              // Priority buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priorityButton('Low', controller.selectedPriority, Colors.green),
                  _priorityButton('Medium', controller.selectedPriority, Colors.orange),
                  _priorityButton('High', controller.selectedPriority, Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              // Due Date Picker
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDueDate.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.selectedDueDate.value = picked;
                  }
                },
                child: Obx(() => InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                  ),
                  child: Text(controller.selectedDueDate.value != null
                      ? DateFormat('MM/dd/yyyy').format(controller.selectedDueDate.value!)
                      : 'Select date'),
                )),
              ),
              const SizedBox(height: 20),
              // Quantity & Duration
              Row(
                children: [
                  Expanded(
                      child: _buildTextField('Qty', controller.reqQuantityController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTextField('Duration (min)', controller.reqDurationController,
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              // Outfit Tags
              _buildTextField('Outfit Tags (comma-separated)', controller.reqOutfitTagsController),
              const SizedBox(height: 20),
              // Update button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.updateTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grailGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Update Task',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String selectedValue, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _priorityButton(String label, RxString selectedPriority, Color color) {
    return Obx(() {
      final isSelected = selectedPriority.value == label;
      return Expanded(
        child: GestureDetector(
          onTap: () => selectedPriority.value = label,
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
