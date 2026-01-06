import '../../helpers/ExportImports.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserDetailController extends GetxController {
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isUploadingImage = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var user = Rxn<User>(); // Reactive, nullable User

  // Editable controllers
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final address1Controller = TextEditingController();
  final cityController = TextEditingController();
  final zipcodeController = TextEditingController();
  final xLinkController = TextEditingController();
  final ofLinkController = TextEditingController();
  final instaLinkController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  var pendingProfilePictureUrl = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchUserDetail();
  }

  Future<void> fetchUserDetail() async {
    isLoading.value = true;
    hasError.value = false;
    user.value = null; // Clear previous

    try {
      final int userId = Get.arguments['userId'] as int;
      final response = await ApiService().callApiWithMap(
        'users/$userId',
        'Get',
        mapData: {},
      );

      if (response != null && response is Map<String, dynamic>) {
        user.value = User.fromJson(response);

        // Populate editable fields
        phoneController.text = user.value!.phone ?? '';
        bioController.text = user.value!.bio ?? '';
        address1Controller.text = user.value!.address1 ?? '';
        cityController.text = user.value!.city ?? '';
        zipcodeController.text = user.value!.zipcode ?? '';
        xLinkController.text = user.value!.xLink ?? '';
        ofLinkController.text = user.value!.ofLink ?? '';
        instaLinkController.text = user.value!.instaLink ?? '';

      } else {
        throw Exception('Invalid response');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load user details', backgroundColor: grailErrorRed);
    } finally {
      isLoading.value = false;
    }
  }

// DELETE User API
  Future<void> deleteUser() async {
    if (user.value == null) return;

    final bool? confirm = await Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.value!.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    try {
      final response = await ApiService().callApiWithMap(
        'users/${user.value!.id}',
        'Delete',
        mapData: {}, // DELETE usually doesn't need body
      );

      if (response != null) {
        final controller = Get.find<UsersAndRolesController>();
        Get.back();
        controller.fetchUsers();
        Get.snackbar(
          'Success',
          'User deleted successfully!',
          backgroundColor: grailGold,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete user',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser() async {
    isSaving.value = true;

    final payload = {
      "phone": phoneController.text.trim(),
      "bio": bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      "address_1": address1Controller.text.trim().isEmpty ? null : address1Controller.text.trim(),
      "city": cityController.text.trim().isEmpty ? null : cityController.text.trim(),
      "zipcode": zipcodeController.text.trim().isEmpty ? null : zipcodeController.text.trim(),
      "x_link": xLinkController.text.trim().isEmpty ? null : xLinkController.text.trim(),
      "of_link": ofLinkController.text.trim().isEmpty ? null : ofLinkController.text.trim(),
      "insta_link": instaLinkController.text.trim().isEmpty ? null : instaLinkController.text.trim(),
    };

    if (pendingProfilePictureUrl.value != null) {
      payload["profile_picture_url"] = pendingProfilePictureUrl.value;
    }

    try {
      final response = await ApiService().callApiWithMap(
        'users/${user.value!.id}',
        'Put',
        mapData: payload,
      );

      if (response != null) {
        final controller = Get.find<UsersAndRolesController>();
        Get.back();
        controller.fetchUsers();
        Get.snackbar(
          'Success',
          'User updated successfully!',
          backgroundColor: grailGold,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user', backgroundColor: grailErrorRed, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  // Upload Profile Picture
  Future<void> pickProfilePicture() async {
    await Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Picture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: grailGold),
              title: const Text('Open Camera'),
              onTap: () => _pickAndUpload(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: grailGold),
              title: const Text('Open Gallery'),
              onTap: () => _pickAndUpload(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Center(child: Text('Cancel', style: TextStyle(color: Colors.red))),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    Get.back(); // Close bottom sheet

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    isUploadingImage.value = true;

    try {
      final String accessToken = await ApiService.getAccessToken();
      if (accessToken.isEmpty) throw Exception('No auth token');

      final uri = Uri.parse('${AppConstants.SERVER_URL}/api/upload/general-upload');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': accessToken,
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pickedFile.path,
          contentType: MediaType('image', pickedFile.path.split('.').last),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String newUrl = data['url'];

        pendingProfilePictureUrl.value = newUrl;

        Get.snackbar(
          'Success',
          'Image uploaded! Tap "Update User" to save changes.',
          backgroundColor: grailGold,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Upload failed: ${response.body}', backgroundColor: grailErrorRed);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image', backgroundColor: grailErrorRed);
    } finally {
      isUploadingImage.value = false;
    }
  }
}