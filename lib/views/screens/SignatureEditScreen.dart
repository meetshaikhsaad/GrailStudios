import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class SignatureEditScreen extends StatelessWidget {
  final int signatureId;

  const SignatureEditScreen({Key? key, required this.signatureId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(SignatureCrudController())..initEdit(signatureId);

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Edit Signature',
        scaffoldKey: scaffoldKey,
        showBackButton: true,
        notificationVisibility: false,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.signature.value == null) {
          return const Center(child: Text('Failed to load signature'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(35, 10, 35, 40),
          child: Column(
            children: [
              // ---------------- Title ----------------
              TextFormField(
                controller: controller.titleController,
                decoration:
                _inputDecoration('Title *', 'e.g. NDA Agreement'),
              ),
              const SizedBox(height: 20),

              // ---------------- Description ----------------
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                    'Description', 'Optional instructions'),
              ),
              const SizedBox(height: 20),

              // ---------------- Assigner (Read-only) ----------------
              DropdownButtonFormField<int>(
                value: controller.signature.value!.signer.id,
                decoration: _inputDecoration('Assign To', ''),
                items: [
                  DropdownMenuItem<int>(
                    value: controller.signature.value!.signer.id,
                    child: Text(controller.signature.value!.signer.fullName),
                  ),
                ],
                onChanged: null, // 👈 disables dropdown
                disabledHint: Text(
                  controller.signature.value!.signer.fullName,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Deadline ----------------
              TextFormField(
                controller: controller.deadlineController,
                readOnly: true,
                decoration:
                _inputDecoration('Deadline *', 'yyyy-mm-dd --:--'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(
                      controller.deadlineController.text,
                    ),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        DateTime.parse(controller.deadlineController.text),
                      ),
                    );

                    if (time != null) {
                      final dt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      controller.deadlineController.text =
                          DateFormat('yyyy-MM-dd HH:mm').format(dt);
                    }
                  }
                },
              ),
              const SizedBox(height: 40),

              // ---------------- Save Button ----------------
              Obx(() => SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.updateSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grailGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
            ],
          ),
        );
      }),
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
