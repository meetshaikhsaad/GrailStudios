import '../../helpers/ExportImports.dart';

class AddUserController extends GetxController {
  // Text Controllers
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();
  final bioController = TextEditingController();

  // Reactive values
  var selectedRole = ''.obs;
  var selectedGender = ''.obs;
  var isLoading = false.obs;

  // Options
  final List<Map<String, dynamic>> roleOptions = const [
    {"id": 'admin', "orientationName": 'Admin'},
    {"id": 'manager', "orientationName": 'Manager'},
    {"id": 'team_member', "orientationName": 'Team Member'},
    {"id": 'digital_creator', "orientationName": 'Digital Creator'},
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> saveUser() async {
    isLoading.value = true;

    final Map<String, dynamic> payload = {
      "email": emailController.text.trim(),
      "username": usernameController.text.trim(),
      "password": passwordController.text,
      "role": selectedRole.value,
      "full_name": fullNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "gender": selectedGender.value,
      "country_id": 0,
      "city": "",
      "address_1": "",
      "bio": bioController.text.trim().isEmpty ? "" : bioController.text.trim(),
    };

    try {
      final response = await ApiService().callApiWithMap(
        'users/',
        'Post',
        mapData: payload,
      );

      if (response != null) {
        Get.back();
        final controller = Get.find<UsersAndRolesController>();
        controller.fetchUsers();
        Get.snackbar(
          'Success',
          'User added successfully!',
          backgroundColor: grailGold,
          colorText: Colors.white,
        );

      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add user. Please try again.',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }

  }
}