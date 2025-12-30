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

  @override
  void onInit() {
    super.onInit();
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
    }

    try {
      final response = await ApiService().callApiWithMap(
        'users/',
        'Get',
        queryParams: {
          'skip': skip.toString(),
          'limit': limit.toString(),
          'role': "admin",
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

  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  Future<void> loadMoreUsers() async {
    await fetchUsers(loadMore: true);
  }
}