import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class SignatureAddScreen extends StatelessWidget {
  const SignatureAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignatureCrudController())..initAdd();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Add Signature',
        scaffoldKey: scaffoldKey,
        showBackButton: true,
        notificationVisibility: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 5, 35, 40),
        child: Column(
          children: [
            // Title
            TextFormField(
              controller: controller.titleController,
              decoration: _inputDecoration('Title *', 'e.g. NDA Agreement'),
            ),
            const SizedBox(height: 20),

            // Description
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 4,
              decoration:
              _inputDecoration('Description', 'Optional instructions'),
            ),
            const SizedBox(height: 20),

            // Signer
            Obx(() => controller.isLoadingSigners.value
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<int>(
              value: controller.selectedSignerId.value,
              hint: const Text('Select Signer'),
              decoration: _inputDecoration('Assign To *', ''),
              items: controller.signers
                  .map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.fullName),
              ))
                  .toList(),
              onChanged: (v) => controller.selectedSignerId.value = v,
            )),
            const SizedBox(height: 20),

            // Deadline
            TextFormField(
              controller: controller.deadlineController,
              readOnly: true,
              decoration: _inputDecoration('Deadline *', 'mm/dd/yyyy --:--'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    final dt = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute);
                    controller.deadlineController.text =
                        DateFormat('yyyy-MM-dd HH:mm').format(dt);
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            // Upload document
            Obx(() => GestureDetector(
              onTap: controller.pickDocument,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Center(
                  child: controller.isUploading.value
                      ? const CircularProgressIndicator()
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        controller.uploadedDocumentUrl.isNotEmpty
                            ? 'Document Uploaded'
                            : 'Upload Document (PDF/DOC)',
                      ),
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 30),

            // Submit
            Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.createSignature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: grailGold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Create Signature',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
