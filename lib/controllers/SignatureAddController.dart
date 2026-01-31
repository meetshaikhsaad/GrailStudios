import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class SignatureAddController extends GetxController {
  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController();

  // Reactive
  var selectedSignerId = Rxn<int>();
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Signers list (reuse TaskAssignee model)
  var signers = <TaskAssignee>[].obs;
  var isLoadingSigners = true.obs;

  // Uploaded document
  PlatformFile? selectedFile;
  RxString uploadedDocumentUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSigners();
  }

  /// Fetch available signers
  Future<void> fetchSigners() async {
    isLoadingSigners.value = true;
    try {
      final response = await ApiService().callApiWithMap(
        'tasks/assignees',
        'GET',
        mapData: {},
      );

      if (response is List) {
        signers.assignAll(
          response.map((e) => TaskAssignee.fromJson(e)).toList(),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to load signers',
          backgroundColor: grailErrorRed);
    } finally {
      isLoadingSigners.value = false;
    }
  }

  /// Pick document
  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result == null) return;

    final file = result.files.single;

    // Max size: 10 MB
    const maxSize = 10 * 1024 * 1024;
    if (file.size > maxSize) {
      Get.snackbar(
        'File too large',
        'Maximum allowed file size is 10 MB',
        backgroundColor: grailErrorRed,
      );
      return;
    }

    selectedFile = file;
    await uploadDocument(file);
  }

  /// Upload document
  Future<void> uploadDocument(PlatformFile file) async {
    isUploading.value = true;

    try {
      final typeGroup = _getTypeGroup(file.extension);

      final uri = Uri.parse(
        '${AppConstants.SERVER_URL}/api/upload/small-file?type_group=$typeGroup',
      );

      final request = http.MultipartRequest('POST', uri);

      final token = await ApiService.getAccessToken();
      request.headers.addAll({
        'Authorization': token,
        'Accept': 'application/json',
      });

      final mimeType = _getMimeType(file.extension);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          contentType: MediaType(
            mimeType.split('/')[0],
            mimeType.split('/')[1],
          ),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        uploadedDocumentUrl.value = data['url'];
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        'Could not upload file',
        backgroundColor: grailErrorRed,
      );
    } finally {
      isUploading.value = false;
    }
  }


  /// Create signature
  Future<void> createSignature() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required',
          backgroundColor: grailErrorRed);
      return;
    }

    if (selectedSignerId.value == null) {
      Get.snackbar('Error', 'Please select a signer',
          backgroundColor: grailErrorRed);
      return;
    }

    if (uploadedDocumentUrl.isEmpty) {
      Get.snackbar('Error', 'Please upload a document',
          backgroundColor: grailErrorRed);
      return;
    }

    isLoading.value = true;

    final payload = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "signer_id": selectedSignerId.value,
      "document_url": uploadedDocumentUrl.value,
      "deadline": DateFormat('yyyy-MM-ddTHH:mm:ss')
          .format(DateTime.parse(deadlineController.text)),
    };

    try {
      await ApiService().callApiWithMap(
        'signature/',
        'POST',
        mapData: payload,
      );

      Get.offAllNamed(AppRoutes.signatureAssigner);
      // Get.find<SignatureAssignerController>().fetchSignatures();

      Get.snackbar(
        'Success',
        'Signature request created successfully',
        backgroundColor: grailGold,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to create signature',
        backgroundColor: grailErrorRed,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getTypeGroup(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'pdf':
      case 'doc':
      case 'docx':
        return 'document';
      default:
        return 'document';
    }
  }

  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.onClose();
  }
}
