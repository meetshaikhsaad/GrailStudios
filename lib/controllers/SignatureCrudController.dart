import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class SignatureCrudController extends GetxController {
  // ---------------- IDs ----------------
  int? signatureId;

  // ---------------- Text Controllers ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController();

  // ---------------- Reactive UI ----------------
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isUploading = false.obs;

  // ---------------- Signers ----------------
  var signers = <TaskAssignee>[].obs;
  var isLoadingSigners = false.obs;
  var selectedSignerId = Rxn<int>();

  // ---------------- Signature ----------------
  Rxn<Signature> signature = Rxn<Signature>();

  // ---------------- Document ----------------
  PlatformFile? selectedFile;
  RxString uploadedDocumentUrl = ''.obs;

  // ================= INIT =================
  void initAdd() {
    fetchSigners();
  }

  void initEdit(int id) {
    signatureId = id;
    fetchSignatureDetails(id);
  }

  void removeDocument() {
    uploadedDocumentUrl.value = '';
    selectedFile = null;
  }

  // ================= FETCH SIGNERS =================
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

  // ================= FETCH SIGNATURE =================
  Future<void> fetchSignatureDetails(int id) async {
    isLoading.value = true;

    try {
      final response = await ApiService().callApiWithMap(
        'signature/$id',
        'GET',
        mapData: {},
      );

      final sig = Signature.fromJson(response);
      signature.value = sig;

      // populate fields
      titleController.text = sig.title;
      descriptionController.text = sig.description ?? '';
      deadlineController.text =
          DateFormat('yyyy-MM-dd HH:mm').format(sig.deadline);
      uploadedDocumentUrl.value = sig.documentUrl;
    } catch (_) {
      Get.snackbar('Error', 'Failed to load signature',
          backgroundColor: grailErrorRed);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= PICK DOCUMENT =================
  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // if both are allowed just change this line
      // allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null) return;

    final file = result.files.single;
    const maxSize = 10 * 1024 * 1024;

    if (file.size > maxSize) {
      Get.snackbar('File too large', 'Maximum allowed size is 10 MB',
          backgroundColor: grailErrorRed);
      return;
    }

    selectedFile = file;
    await uploadDocument(file);
  }

  // ================= UPLOAD DOCUMENT =================
  Future<void> uploadDocument(PlatformFile file) async {
    isUploading.value = true;

    try {
      final uri = Uri.parse(
        '${AppConstants.SERVER_URL}/api/upload/small-file?type_group=${_getTypeGroup(file.extension)}',
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
          contentType:
          MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        uploadedDocumentUrl.value = jsonDecode(response.body)['url'];
      } else {
        throw Exception(response.body);
      }
    } catch (_) {
      Get.snackbar('Upload Failed', 'Could not upload file',
          backgroundColor: grailErrorRed);
    } finally {
      isUploading.value = false;
    }
  }

  // ================= CREATE SIGNATURE =================
  Future<void> createSignature() async {
    if (titleController.text.trim().isEmpty ||
        selectedSignerId.value == null ||
        uploadedDocumentUrl.isEmpty) {
      Get.snackbar('Error', 'All required fields must be filled',
          backgroundColor: grailErrorRed);
      return;
    }

    isSaving.value = true;

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
      Get.snackbar('Success', 'Signature created',
          backgroundColor: grailGold, colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error', 'Failed to create signature',
          backgroundColor: grailErrorRed);
    } finally {
      isSaving.value = false;
    }
  }

  // ================= UPDATE SIGNATURE =================
  Future<void> updateSignature() async {
    if (signatureId == null || signature.value == null) return;

    isSaving.value = true;

    final payload = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "document_url": uploadedDocumentUrl.value,
      "deadline": DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
          .format(DateTime.parse(deadlineController.text).toUtc()),
    };

    try {
      await ApiService().callApiWithMap(
        'signature/$signatureId',
        'PUT',
        mapData: payload,
      );

      Get.offAllNamed(AppRoutes.signatureAssigner);
      Get.snackbar('Updated', 'Signature updated',
          backgroundColor: grailGold, colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update signature',
          backgroundColor: grailErrorRed);
    } finally {
      isSaving.value = false;
    }
  }

  // ================= HELPERS =================
  String _getTypeGroup(String? ext) {
    // if (['jpg', 'jpeg', 'png'].contains(ext)) return 'image';
    return 'document';
  }

  String _getMimeType(String? ext) {
    switch (ext) {
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
