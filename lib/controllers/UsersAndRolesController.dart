import '../../helpers/ExportImports.dart'; // Includes ApiService, grailErrorRed, etc.

class UsersAndRolesController extends GetxController {
  // Reactive state
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var users = <User>[].obs;

  // Pagination
  var skip = 0;
  final int limit = 100;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;

  final searchQuery = ''.obs;
  final selectedRole = ''.obs; // '', 'admin', 'manager', 'model'

  // Assign User (Bottom Sheet 2)
  var assignModels = <UserRelation>[].obs;    // digital creators
  var assignManagers = <UserRelation>[].obs;  // managers

  var selectedAssignModel = Rxn<UserRelation>();
  var selectedAssignManager = Rxn<UserRelation>();

  var isAssignLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    // Debounce search to avoid API spam
    debounce(searchQuery, (_) {
      refreshUsers();
    }, time: const Duration(milliseconds: 500));

    fetchUsers();
  }

  Future<void> fetchUsers({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      hasError.value = false;
      users.clear();
      skip = 0;
      hasMoreData.value = true;
    }

    try {
      final response = await ApiService().callApiWithMap(
        'users/',
        'Get',
        queryParams: {
          'skip': skip.toString(),
          'limit': limit.toString(),
          if (selectedRole.value.isNotEmpty)
            'role': selectedRole.value,
          if (searchQuery.value.isNotEmpty)
            'search': searchQuery.value,
        },
        mapData: {}, // Not needed for GET
      );

      if (response != null && response is List) {
        final List<User> fetchedUsers = response.map((json) => User.fromJson(json)).toList();

        if (loadMore) {
          users.addAll(fetchedUsers);
        } else {
          users.assignAll(fetchedUsers);
        }

        // Update pagination
        if (fetchedUsers.length < limit) {
          hasMoreData.value = false;
        } else {
          skip += limit;
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load users. Please try again.',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchAssignData() async {
    try {
      isAssignLoading.value = true;

      // Fetch digital creators
      final modelsRes = await ApiService().callApiWithMap(
        'users/available/models',
        'Get',
        mapData: {},
      );

      if (modelsRes is List) {
        assignModels.assignAll(
          modelsRes.map((e) => UserRelation.fromJson(e)).toList(),
        );
      }

      // Fetch managers
      final managersRes = await ApiService().callApiWithMap(
        'users/available/managers',
        'Get',
        mapData: {},
      );

      if (managersRes is List) {
        final list = managersRes.map((e) => UserRelation.fromJson(e)).toList();
        list.insert(0, UserRelation(id: 0, fullName: '-- No Manager --', role: 'none'));
        assignManagers.assignAll(list);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assign data',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    } finally {
      isAssignLoading.value = false;
    }
  }


  Future<void> assignUserToManager() async {
    if (selectedAssignModel.value == null) {
      Get.snackbar('Validation', 'Please select a user');
      return;
    }

    isAssignLoading.value = true;

    try {
      final payload = {
        "manager_id": selectedAssignManager.value != null &&
            selectedAssignManager.value!.id != 0
            ? selectedAssignManager.value!.id
            : null,
      };

      await ApiService().callApiWithMap(
        'users/${selectedAssignModel.value!.id}',
        'Put',
        mapData: payload,
      );

      Get.back(); // close assign sheet
      refreshUsers();

      Get.snackbar(
        'Success',
        'User assigned successfully',
        backgroundColor: grailGold,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to assign user',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    } finally {
      isAssignLoading.value = false;
      selectedAssignManager.value = null;
    }
  }

  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  Future<void> loadMoreUsers() async {
    await fetchUsers(loadMore: true);
  }



}