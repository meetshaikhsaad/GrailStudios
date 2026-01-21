import 'package:intl/intl.dart';

import '../../helpers/ExportImports.dart';

class TaskAssignerScreen extends StatelessWidget {
  TaskAssignerScreen({super.key});

  final ScrollController _scrollController = ScrollController();
  Future<String> _getLoggedInUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.USER_ROLE) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final TaskAssignerController controller = Get.put(TaskAssignerController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final List<String> statusOptions = ['All', 'To Do', 'Blocked', 'Completed', 'Missed'];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchTasks(loadMore: true);
      }
    });


    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Task Assign',
        scaffoldKey: scaffoldKey,
        showBackButton: false,
      ),
      floatingActionButton: FutureBuilder<String>(
        future: _getLoggedInUserRole(), // method to read from SharedPreferences
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final loggedInRole = snapshot.data;

          // Only show FAB for admin or manager
          if (loggedInRole != 'admin' && loggedInRole != 'manager') {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: grailGold,
            onPressed: () {
              // Directly navigate to the screen
              Get.toNamed(AppRoutes.createTask);
            },
            child: const Icon(Icons.add, color: Colors.white), // FAB icon
          );
        },
      ),

      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Bar + Filter Icon
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: grailGold),
                  onPressed: () {
                    // TODO: Open filter bottom sheet for status/assignee
                    Get.snackbar('Filters', 'Filter options coming soon!');
                  },
                ),
              ],
            ),
          ),

          // Filter Chips (static for now)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: statusOptions.map((status) {
                final isSelected = controller.selectedStatus.value == status ||
                    (status == 'All' && controller.selectedStatus.value.isEmpty);

                return _filterChip(status, isSelected, () {
                  if (status == 'All') {
                    controller.selectedStatus.value = '';
                  } else {
                    controller.selectedStatus.value = status;
                  }
                  controller.fetchTasks(); // fetch filtered tasks
                });
              }).toList(),
            )),
          ),

          const SizedBox(height: 16),

          // Tasks List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: grailGold));
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${controller.errorMessage.value}', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.tasks.isEmpty) {
                return const Center(child: Text('No tasks found'));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.tasks.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.tasks.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: grailGold),
                      ),
                    );
                  }

                  final task = controller.tasks[index];
                  return InkWell(
                    onTap: () => _showTaskOptionsBottomSheet(task),
                    child: TaskCard(task: task),
                  );
                },
              );

            }),
          ),
        ],
      ),
    );
  }

  void _showTaskOptionsBottomSheet(Task task) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Task Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Edit Option
              Visibility(
                visible: task.status != 'Completed',
                child: ListTile(
                  leading: const Icon(Icons.edit, color: grailGold),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close sheet
                    // Navigation AFTER sheet is closed
                    Future.microtask(() {
                      Get.to(() => EditTaskScreen(taskId: task.id!));
                    });
                  },
                ),
              ),

              // Delete Option
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.microtask(() => _confirmDeleteTask(task.id!));
                },
              ),

              // Chat Option
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.blue),
                title: const Text('Chat'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.microtask(() {
                    // Get.toNamed(AppRoutes.taskChat, arguments: {'taskId': task.id});
                  });
                },
              ),

              const SizedBox(height: 10),

              // Cancel
              ListTile(
                title: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteTask(int taskId) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this task?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // close dialog
        try {
          await ApiService().callApiWithMap(
            'tasks/$taskId',
            'DELETE',
            mapData: {},
          );
          Get.snackbar('Success', 'Task deleted successfully');
          // Refresh task list
          final controller = Get.find<TaskAssignerController>();
          controller.fetchTasks();
        } catch (e) {
          Get.snackbar('Error', 'Failed to delete task: $e', backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }


  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        selected: isSelected,
        selectedColor: grailGold,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide.none),
        onSelected: (_) => onTap(),
      ),
    );
  }
}