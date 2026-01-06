import '../../helpers/ExportImports.dart';

class UserDetailController extends GetxController {
  var isLoading = true.obs;
  var isSaving = false.obs;
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
}