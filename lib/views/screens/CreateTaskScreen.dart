import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';
import '../../controllers/CreateTaskController.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateTaskController controller = Get.put(CreateTaskController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Create Assignment',
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 5, 35, 40),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // Title
              TextFormField(
                controller: controller.titleController,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g. Upload 5 Summer Reels',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),

              // Instructions
              TextFormField(
                controller: controller.instructionsController,
                maxLines: 4,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  hintText: 'Detailed requirements for the creator...',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Assign To
              Obx(() => controller.isLoadingAssignees.value
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                value: controller.selectedAssigneeId.value,
                hint: const Text('Select Creator...'),
                decoration: InputDecoration(
                  labelText: 'Assign To *',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: controller.assignees.map((assignee) {
                  return DropdownMenuItem<int>(
                    value: assignee.id,
                    child: Text(assignee.fullName),
                  );
                }).toList(),
                onChanged: (value) => controller.selectedAssigneeId.value = value,
                validator: (value) => value == null ? 'Please select a creator' : null,
              )),
              const SizedBox(height: 20),

              // Due Date
              TextFormField(
                controller: controller.dueDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final dateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                      controller.dueDateController.text = DateFormat('MM/dd/yyyy HH:mm').format(dateTime);
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Due Date *',
                  hintText: 'mm/dd/yyyy --:-- --',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priorityButton('Low', controller.selectedPriority, Colors.green),
                  _priorityButton('Medium', controller.selectedPriority, Colors.orange),
                  _priorityButton('High', controller.selectedPriority, Colors.red),
                ],
              ),
              const SizedBox(height: 20),

              // Context
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedContext.value.isEmpty ? null : controller.selectedContext.value,
                hint: const Text('Select Context'),
                decoration: InputDecoration(
                  labelText: 'Context',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: controller.contexts.map((ctx) => DropdownMenuItem(value: ctx, child: Text(ctx))).toList(),
                onChanged: (value) => controller.selectedContext.value = value ?? '',
              )),
              const SizedBox(height: 20),

              // Content Type
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedContentType.value.isEmpty ? null : controller.selectedContentType.value,
                hint: const Text('Content Type'),
                decoration: InputDecoration(
                  labelText: 'Content Type',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: controller.contentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => controller.selectedContentType.value = value ?? '',
              )),
              const SizedBox(height: 20),

              // Qty & Mins
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Qty',
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: controller.minsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Mins',
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Face Visible & Watermark
              Obx(() => SwitchListTile(
                title: const Text('Face Visible'),
                value: controller.isFaceVisible.value,
                onChanged: (val) => controller.isFaceVisible.value = val,
              )),
              Obx(() => SwitchListTile(
                title: const Text('Watermark'),
                value: controller.isWatermark.value,
                onChanged: (val) => controller.isWatermark.value = val,
              )),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  controller.pickFiles();
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Click to upload images/videos',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Assignment Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.createAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grailGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Confirm Assignment',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )),
            ],
          ),
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