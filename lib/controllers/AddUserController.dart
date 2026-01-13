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
  var selectedManagerId = Rxn<int>();
  var isLoadingManagers = false.obs;
  var isLoadingDigitalCreators = false.obs;
  var isLoading = false.obs;

  // Selected digital creators (multi-select)
  var selectedDigitalCreatorIds = <int>[].obs;
  var loggedInRole = ''.obs;

  Future<void> _loadLoggedInUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInRole.value = prefs.getString(AppConstants.USER_ROLE) ?? '';
  }

  // Options
  final List<Map<String, dynamic>> roleOptions = const [
    {"id": 'admin', "orientationName": 'Admin'},
    {"id": 'manager', "orientationName": 'Manager'},
    {"id": 'team_member', "orientationName": 'Team Member'},
    {"id": 'digital_creator', "orientationName": 'Digital Creator'},
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  var managers = <Manager>[].obs;
  var digitalCreators = <DigitalCreator>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadLoggedInUserRole();
    fetchManagers();
    fetchDigitalCreators();
  }

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
      "manager_id": selectedManagerId.value ?? 0,
      "assigned_model_id": 0,
      "assign_model_ids": selectedRole.value == "manager"?selectedDigitalCreatorIds.value:[],
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

  Future<void> fetchManagers() async {
    isLoadingManagers.value = true;

    try {
      final response = await ApiService().callApiWithMap(
        'users/available/managers',
        'Get',
        mapData: {},
      );

      if (response != null && response is List) {
        final List<Manager> managerList =
        response.map((json) => Manager.fromJson(json)).toList();

        managerList.insert(
          0,
          Manager(
            id: 0, // sentinel value
            fullName: '-- No Manager --',
            profilePictureUrl: null,
            role: 'none',
          ),
        );

        managers.value = managerList;
        selectedManagerId.value = managerList.first.id;

      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load managers', backgroundColor: grailErrorRed);
    } finally {
      isLoadingManagers.value = false;
    }
  }

  Future<void> fetchDigitalCreators() async {
    isLoadingDigitalCreators.value = true;
    try {
      final response = await ApiService().callApiWithMap(
        'users/available/models',
        'Get',
        mapData: {},
      );
      if (response != null && response is List) {
        digitalCreators.value = response.map((json) => DigitalCreator.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load digital creators', backgroundColor: grailErrorRed);
    } finally {
      isLoadingDigitalCreators.value = false;
    }
  }

}