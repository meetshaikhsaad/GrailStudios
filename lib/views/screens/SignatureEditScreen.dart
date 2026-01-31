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

              const SizedBox(height: 20),

// ---------------- Attachment ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attachment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded),
                    color: grailGold, // or any color you like
                    onPressed: () {
                      _downloadAttachment(controller.signature.value!.documentUrl, context: context); // call your function here
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() {
                // ---------------- NO DOCUMENT ----------------
                if (controller.uploadedDocumentUrl.isEmpty) {
                  return GestureDetector(
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
                  );
                }

                // ---------------- DOCUMENT PREVIEW ----------------
                return Stack(
                  children: [
                    _attachmentPreview(controller.uploadedDocumentUrl.value),

                    // ❌ DELETE ICON
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: controller.removeDocument,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

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
                    'Update Signature',
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

  Widget _attachmentPreview(String url) {
    final ext = url.split('.').last.toLowerCase();

    if (['png', 'jpg', 'jpeg', 'gif'].contains(ext)) {
      // Image Preview
      return Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PhotoView(
            imageProvider: NetworkImage(url),
            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          ),
        ),
      );
    }
    else if (['pdf', 'docx'].contains(ext)) {
      return InlineDocumentPreview(url: url);
    }

    return const Text('Unsupported attachment type.');
  }

  Future<void> _downloadAttachment(String url, {BuildContext? context}) async {
    try {
      final fileName = url.split('/').last;

      // Use the DownloadService
      await DownloadService.instance.downloadFile(
        url,
        fileName,
        context: context,
      );
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
      print("Download failed: $e");
    }
  }


}
