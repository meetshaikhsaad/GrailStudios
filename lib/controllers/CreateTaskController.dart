import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class CreateTaskController extends GetxController {
  // Text Controllers
  final titleController = TextEditingController();
  final instructionsController = TextEditingController();
  final dueDateController = TextEditingController();

  // Quantity & Duration
  final qtyController = TextEditingController(text: '1');
  final minsController = TextEditingController(text: '0');

  // Reactive values
  var selectedAssigneeId = Rxn<int>();
  var selectedPriority = 'Medium'.obs; // Low, Medium, High
  var selectedContext = 'General'.obs;
  var selectedContentType = 'PPV'.obs;

  // Switches
  var isFaceVisible = true.obs;
  var isWatermark = false.obs;

  // Loading states
  var isLoadingAssignees = true.obs;
  var isLoading = false.obs;

  // Assignees list
  var assignees = <TaskAssignee>[].obs;

  // Content type options (adjust as per your backend)
  final List<String> contentTypes = ['PPV', 'Feed', 'Promo', 'Story', 'Other'];

  final List<String> contexts = ['General', 'Urgent', 'Contract'];

  @override
  void onInit() {
    super.onInit();
    fetchAssignees();
  }


  Future<void> fetchAssignees() async {
    isLoadingAssignees.value = true;

    try {
      final response = await ApiService().callApiWithMap(
        'tasks/assignees',
        'Get',
        mapData: {},
      );

      if (response != null && response is List) {
        assignees.value = response.map((json) => TaskAssignee.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load assignees', backgroundColor: grailErrorRed);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load assignees', backgroundColor: grailErrorRed);
    } finally {
      isLoadingAssignees.value = false;
    }
  }


  /// Pick files using FilePicker
  var uploadItems = <UploadItem>[].obs;
  var isUploadingFiles = false.obs;


  /// Pick files from device
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg','png'],
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

  Future<void> _uploadSingleItem(UploadItem item) async {
    try {
      final data = await uploadFile(item.file);
      item.uploadedData = data;
    } catch (_) {
      Get.snackbar('Upload Failed', item.file.name, backgroundColor: grailErrorRed);
    } finally {
      item.isUploading.value = false;

      if (uploadItems.every((e) => !e.isUploading.value)) {
        isUploadingFiles.value = false;
      }
    }
  }


  /// Upload a single file and return URL + metadata
  Future<Map<String, dynamic>> uploadFile(PlatformFile file) async {
    final uri = Uri.parse('${AppConstants.SERVER_URL}/api/upload/general-upload');
    var request = http.MultipartRequest('POST', uri);

    // Add headers
    final String accessToken = await ApiService.getAccessToken();
    request.headers.addAll({
      'Authorization': accessToken,
      'Accept': 'application/json',
    });

    // Determine MIME type
    final mimeType = getMimeType(file.extension);

    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path!,
      contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
    ));

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'file_url': data['url'],
        'file_size_mb': (file.size / (1024 * 1024)), // size in MB
        'mime_type': mimeType,
      };
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  /// Helper: determine MIME type based on file extension
  String getMimeType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'mp4': return 'video/mp4';
      case 'mov': return 'video/quicktime';
      case 'pdf': return 'application/pdf';
      default: return 'application/octet-stream';
    }
  }

  Future<void> createAssignment() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a title', backgroundColor: grailErrorRed);
      return;
    }

    if (selectedAssigneeId.value == null) {
      Get.snackbar('Error', 'Please select an assignee', backgroundColor: grailErrorRed);
      return;
    }

    if (dueDateController.text.isEmpty) {
      Get.snackbar('Error', 'Please select Due Date', backgroundColor: grailErrorRed);
      return;
    }

    isLoading.value = true;

    final payload = {
      "title": titleController.text.trim(),
      "description": instructionsController.text.trim(),
      "assignee_id": selectedAssigneeId.value,
      "status": "To Do",
      "priority": selectedPriority.value,
      "due_date": dueDateController.text.isEmpty
          ? null
          : DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now().add(const Duration(days: 7))), // Default 7 days
      "req_content_type": selectedContentType.value,
      "req_quantity": int.tryParse(qtyController.text) ?? 1,
      "req_duration_min": int.tryParse(minsController.text) ?? 0,
      "req_outfit_tags": [],
      "req_face_visible": isFaceVisible.value,
      "req_watermark": isWatermark.value,
      "context": selectedContext.value,
      "attachments": uploadItems
          .where((e) => e.uploadedData != null)
          .map((e) => e.uploadedData)
          .toList(),
    };

    try {
      final response = await ApiService().callApiWithMap(
        'tasks/',
        'Post',
        mapData: payload,
      );

      if (response != null) {
        Get.back();
        final taskAssignerController = Get.find<TaskAssignerController>();
        taskAssignerController.fetchTasks();
        Get.snackbar(
          'Success',
          'Assignment created successfully!',
          backgroundColor: grailGold,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create assignment',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    titleController.clear();
    instructionsController.clear();
    dueDateController.clear();
    qtyController.text = '1';
    minsController.text = '0';
    selectedAssigneeId.value = null;
    selectedPriority.value = 'Medium';
    selectedContext.value = 'General';
    selectedContentType.value = 'PPV';
    isFaceVisible.value = true;
    isWatermark.value = false;
  }

  @override
  void onClose() {
    titleController.dispose();
    instructionsController.dispose();
    dueDateController.dispose();
    qtyController.dispose();
    minsController.dispose();
    super.onClose();
  }
}

class UploadItem {
  final String id = UniqueKey().toString();
  final PlatformFile file;
  RxBool isUploading = true.obs;
  Map<String, dynamic>? uploadedData;

  UploadItem(this.file);
}