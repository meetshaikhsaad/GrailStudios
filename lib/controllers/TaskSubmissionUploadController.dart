import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../helpers/ExportImports.dart';

class TaskSubmissionUploadController extends GetxController {
  final int taskId;
  TaskSubmissionUploadController(this.taskId);

  // Task data
  var task = Rxn<Task>();

  // UI states
  var isLoading = true.obs;
  var isUploadingFiles = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  /// same UploadItem model
  var uploadItems = <UploadItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTask();
  }

  /// Load task details
  Future<void> fetchTask() async {
    isLoading.value = true;
    try {
      final res = await ApiService().callApiWithMap(
        'tasks/$taskId',
        'GET',
        mapData: {},
      );

      task.value = Task.fromJson(res);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load task';
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick images/videos
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg','png','mp4','mov','pdf'],
    );

    if (result != null) {
      isUploadingFiles.value = true;

      for (final file in result.files) {
        final item = UploadItem(file);
        uploadItems.add(item);
        _uploadSingleItem(item);
      }
    }
  }

  /// Upload each file
  Future<void> _uploadSingleItem(UploadItem item) async {
    try {
      final data = await uploadFile(item.file);
      item.uploadedData = {
        ...data,
        "thumbnail_url": null,
        "tags": null,
        "duration_seconds": null,
      };
    } catch (_) {
      Get.snackbar('Upload Failed', item.file.name,
          backgroundColor: grailErrorRed);
    } finally {
      item.isUploading.value = false;

      if (uploadItems.every((e) => !e.isUploading.value)) {
        isUploadingFiles.value = false;
      }
    }
  }

  /// Upload to backend
  Future<Map<String, dynamic>> uploadFile(PlatformFile file) async {
    final uri =
    Uri.parse('${AppConstants.SERVER_URL}/api/upload/small-file');
    var request = http.MultipartRequest('POST', uri);

    final token = await ApiService.getAccessToken();
    request.headers.addAll({
      'Authorization': token,
      'Accept': 'application/json',
    });

    final mimeType = getMimeType(file.extension);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path!,
      contentType:
      http.MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
    ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        "file_url": data['url'],
        "file_size_mb": (file.size / (1024 * 1024)),
        "mime_type": mimeType,
      };
    } else {
      throw Exception('Upload failed');
    }
  }

  /// Final submit
  Future<void> submitTask() async {
    if (uploadItems.any((e) => e.isUploading.value)) {
      Get.snackbar('Wait', 'Files are still uploading');
      return;
    }

    final deliverables = uploadItems
        .where((e) => e.uploadedData != null)
        .map((e) => e.uploadedData)
        .toList();

    if (deliverables.isEmpty) {
      Get.snackbar('Error', 'Please upload at least one file');
      return;
    }

    isLoading.value = true;

    try {
      await ApiService().callApiWithMap(
        'tasks/$taskId/submit',
        'POST',
        mapData: {"deliverables": deliverables},
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Task submitted successfully!',
        backgroundColor: grailGold,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Submission failed',
          backgroundColor: grailErrorRed);
    } finally {
      isLoading.value = false;
    }
  }

  /// MIME helper
  String getMimeType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
