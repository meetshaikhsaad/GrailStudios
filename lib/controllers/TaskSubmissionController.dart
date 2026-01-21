import '../../helpers/ExportImports.dart';

class TaskSubmissionController extends GetxController {
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var tasks = <Task>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = ''.obs; // For status filter
  var selectedAssigneeId = Rxn<int>(); // For assignee filter

  var isLoadingMore = false.obs;

  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchTasks();
  }

  void onStatusFilterChanged(String? status) {
    selectedStatus.value = status ?? '';
    fetchTasks();
  }

  void onAssigneeFilterChanged(int? assigneeId) {
    selectedAssigneeId.value = assigneeId;
    fetchTasks();
  }


  Future<void> fetchTasks({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      _currentPage = 1;
      _hasMore = true;
    }

    try {
      String url = 'tasks/?skip=$_currentPage&limit=$_limit';

      if (searchQuery.isNotEmpty) {
        url += '&search=${searchQuery.value}';
      }
      if (selectedStatus.isNotEmpty) {
        url += '&status=${selectedStatus.value}';
      }
      if (selectedAssigneeId.value != null) {
        url += '&assignee_id=${selectedAssigneeId.value}';
      }

      final response = await ApiService().callApiWithMap(
        url,
        'GET',
        mapData: {},
      );

      if (response is Map<String, dynamic>) {
        final taskList = TaskListResponse.fromJson(response);

        if (loadMore) {
          tasks.addAll(taskList.tasks);
        } else {
          tasks.assignAll(taskList.tasks);
        }

        _hasMore = taskList.tasks.length == _limit;
        _currentPage++;
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

}